// @dart=2.9
import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter/material.dart';


import 'package:dong_gan_dan_che/common/AgoraUtil.dart';
import 'package:dong_gan_dan_che/pages/agora/header.dart';
import 'package:dong_gan_dan_che/pages/agora/footer.dart';
import 'package:dong_gan_dan_che/pages/agora/authorInfo.dart';
import 'package:dong_gan_dan_che/pages/agora/changeDrag.dart';
import 'package:dong_gan_dan_che/pages/agora/peopleList.dart';

import 'package:dong_gan_dan_che/common/BaseUtil.dart';


class AgoraLivePage extends StatefulWidget {
  final arguments;

  /// Creates a call page with given channel name.
  const AgoraLivePage({Key key, this.arguments}) : super(key: key);

  @override
  _AgoraLivePageState createState() => _AgoraLivePageState();
}

class _AgoraLivePageState extends State<AgoraLivePage> {
  StreamSubscription streamSubscriptionEnterAfter;
  StreamSubscription streamSubscriptionLeaveAfter;
  StreamSubscription streamSubscriptionClose;
  StreamSubscription streamSubscriptionChat;
  StreamSubscription streamSubscriptionGift;
  bool bClickClose = false;

  TextEditingController controllerNumber = TextEditingController(text: "1");
  final FocusNode focusNodeNumber = FocusNode();

  /// non-modifiable channel name of the page
  String strChannelName;
  /// non-modifiable client role of the page
  ClientRole clientRole;

  /// 是否显示教练信息
  bool bShowAuthorInfo = false;
  /// 是否显示观众列表
  bool bShowPeopleList = false;
  /// 是否显示修改阻力
  bool bShowChangeDrag = false;
  // 被选中的学员
  dynamic arrSelectedStudent;

  /// 是否播放礼物信息
  bool bShowGift = false;
  SendLiveGiftEvent eventGift;
  Timer timerShowGift;

  /// 测试使用测试服务器地址,否则使用BaseUtil.baseUrl
  String strBaseUrl = "https://www.reciprocalaffection.com/uploads/DongGanDanChe/gift";
  //    String strBaseUrl = BaseUtil.baseUrl;

  final arrUserId = <int>[];
  final arrChatInfo = <SendLiveChatEvent>[];
  bool muted = false;
  RtcEngine rtcEngine;

  @override
  void dispose() {
    streamSubscriptionEnterAfter.cancel();
    streamSubscriptionLeaveAfter.cancel();
    streamSubscriptionClose.cancel();
    streamSubscriptionChat.cancel();
    streamSubscriptionGift.cancel();
    focusNodeNumber.dispose();
    // clear users
    arrUserId.clear();
    // destroy sdk
    rtcEngine.leaveChannel();
    rtcEngine.destroy();

    if (!bClickClose) {
      var userId = BaseUtil.gStUser.containsKey("id") ? BaseUtil.gStUser["id"] : 0;
      String url = AgoraUtil.liveInfo["authorId"] == userId ? API.closeLive : API.leaveLive;
      HttpUtil.getInstance().postJson(url, params: {
        "liveId": AgoraUtil.liveId,
        "liveCode": AgoraUtil.liveCode,
      }).then((response) {
      });
      AgoraUtil.liveTitle = "";
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    bClickClose = false;

    // initialize agora sdk
    strChannelName = widget.arguments["channelName"];
    clientRole = widget.arguments["role"];

    // 初始化WebSocket事件监听
    initEventListen();

    // 初始化直播信息
    initialize();
  }

  void initEventListen() {
    var that = this;
    /// 某个观众进入了直播间
    streamSubscriptionEnterAfter = EventUtil.gEventBus.on<SendEnterLiveAfterEvent>().listen((event) {
      var data = event.data;
      that.setState(() {
        AgoraUtil.liveInfo = data["liveInfo"];
        var user = data["userInfo"];
        arrChatInfo.insert(0, SendLiveChatEvent(user["nickName"], "进入了直播间"));
        if (arrChatInfo.length > 200) {
          arrChatInfo.removeLast();
        }
      });
    });
    /// 某个观众离开了直播间
    streamSubscriptionLeaveAfter = EventUtil.gEventBus.on<SendLeaveLiveEvent>().listen((event) {
      var data = event.data;
      that.setState(() {
        AgoraUtil.liveInfo = data["liveInfo"];
        var user = data["userInfo"];
        arrChatInfo.insert(0, SendLiveChatEvent(user["nickName"], "离开了直播间"));
      });
    });
    /// 主播关播了
    streamSubscriptionClose = EventUtil.gEventBus.on<SendCloseLiveEvent>().listen((event) {
      if (!AgoraUtil.bIsAuthor) {
        CustomSnackBar(BaseUtil.gNavigatorKey.currentContext, Text("主播关闭了哟!!!"));
      } else if(!bClickClose) {
        Navigator.popAndPushNamed(context, "/liveClose");
        CustomSnackBar(BaseUtil.gNavigatorKey.currentContext, Text("管理员关播了哟!!!"));
      }
    });
    /// 收到了聊天消息
    streamSubscriptionChat = EventUtil.gEventBus.on<SendLiveChatEvent>().listen((event) {
      that.setState(() {
        arrChatInfo.insert(0, event);
        if (arrChatInfo.length > 200) {
          arrChatInfo.removeLast();
        }
      });
    });
    /// 收到了礼物
    streamSubscriptionGift = EventUtil.gEventBus.on<SendLiveGiftEvent>().listen((event) {
      that.setState(() {
        eventGift = event;
        bShowGift = true;
        if (AgoraUtil.bIsAuthor) {
          var m = BaseUtil.gStUser["amount"];
          if (m == null) {
            m = 0;
          }
          BaseUtil.gStUser["amount"] = m + eventGift.giftMoney * eventGift.giftNumber;
        }
      });
      if (timerShowGift != null) {
        timerShowGift.cancel();
      }
      const oneSec = const Duration(seconds: 3);
      var callback = (timer) {
        timerShowGift.cancel();
        timerShowGift = null;
        setState(() {
          bShowGift = false;
        });
      };
      timerShowGift = Timer.periodic(oneSec, callback);
    });
  }

  Future<void> initialize() async {
    if (AgoraUtil.agoraAppId.isEmpty) {
      setState(() {
//        m_arrChat.add(
//          'APP_ID missing, please provide your APP_ID in settings.dart',
//        );
//        m_arrChat.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    // await rtcEngine.enableWebSdkInteroperability(true);
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = VideoDimensions(width: 1920, height: 1080);
    await rtcEngine.setVideoEncoderConfiguration(configuration);
    await rtcEngine.joinChannel(AgoraUtil.agoraToken, strChannelName, null, 0);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    rtcEngine = await RtcEngine.create(AgoraUtil.agoraAppId);
    await rtcEngine.enableVideo();
    await rtcEngine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await rtcEngine.setClientRole(clientRole);
  //  await rtcEngine.enableAudioVolumeIndication(2000, 3, true);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    rtcEngine.setEventHandler(RtcEngineEventHandler(error: (code) {
      print("RtcEngineEventHandler: ($code)");
      setState(() {
      //  final info = 'onError: $code';
      //  m_arrChat.add(info);
      });
    }, joinChannelSuccess: (channel, uid, elapsed) {
      print("joinChannelSuccess: ($channel, $uid, $elapsed)");
      setState(() {
      //  final info = 'onJoinChannel: $channel, uid: $uid';
      //  m_arrChat.add(info);
      });
    }, leaveChannel: (stats) {
      print("leaveChannel: ($stats)");
      setState(() {
      //  m_arrChat.add('onLeaveChannel');
        arrUserId.clear();
      });
    }, userJoined: (uid, elapsed) {
      print("userJoined: ($uid, $elapsed)");
      setState(() {
      //  final info = 'userJoined: $uid';
      //  m_arrChat.add(info);
        arrUserId.add(uid);
      });
    }, userOffline: (uid, elapsed) {
      print("userOffline: ($uid, $elapsed)");
      setState(() {
      //  final info = 'userOffline: $uid';
      //  m_arrChat.add(info);
        arrUserId.remove(uid);
      });
    }, firstRemoteVideoFrame: (uid, width, height, elapsed) {
      print("firstRemoteVideoFrame: ($uid, $width, $height, $elapsed)");
      setState(() {
      //  final info = 'firstRemoteVideo: $uid ${width}x $height';
      //  m_arrChat.add(info);
      });
    }, audioVolumeIndication: (List<AudioVolumeInfo> speakers, int totalVolume) {
      print("audioVolumeIndication: ($speakers, $totalVolume)");
    }), );
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];
    if (clientRole == ClientRole.Broadcaster) {
      list.add(RtcLocalView.SurfaceView());
    }
    arrUserId.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(uid: uid)));
    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
              children: <Widget>[_videoView(views[0])],
            ));
      case 2:
        return Container(
            child: Column(
              children: <Widget>[
                _expandedVideoRow([views[0]]),
                _expandedVideoRow([views[1]])
              ],
            ));
      case 3:
        return Container(
            child: Column(
              children: <Widget>[
                _expandedVideoRow(views.sublist(0, 2)),
                _expandedVideoRow(views.sublist(2, 3))
              ],
            ));
      case 4:
        return Container(
            child: Column(
              children: <Widget>[
                _expandedVideoRow(views.sublist(0, 2)),
                _expandedVideoRow(views.sublist(2, 4))
              ],
            ));
      default:
    }
    return Container();
  }

  /// Toolbar layout
  // Widget _toolbar() {
  //   if (clientRole == ClientRole.Audience) return Container();
  //   return Container(
  //     alignment: Alignment.bottomCenter,
  //     padding: const EdgeInsets.symmetric(vertical: 48),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: <Widget>[
  //         RawMaterialButton(
  //           onPressed: _onToggleMute,
  //           child: Icon(
  //             muted ? Icons.mic_off : Icons.mic,
  //             color: muted ? Colors.white : Colors.blueAccent,
  //             size: 20.0,
  //           ),
  //           shape: CircleBorder(),
  //           elevation: 2.0,
  //           fillColor: muted ? Colors.blueAccent : Colors.white,
  //           padding: const EdgeInsets.all(12.0),
  //         ),
  //         RawMaterialButton(
  //           onPressed: () => _onCallEnd(context),
  //           child: Icon(
  //             Icons.call_end,
  //             color: Colors.white,
  //             size: 35.0,
  //           ),
  //           shape: CircleBorder(),
  //           elevation: 2.0,
  //           fillColor: Colors.redAccent,
  //           padding: const EdgeInsets.all(15.0),
  //         ),
  //         RawMaterialButton(
  //           onPressed: _onSwitchCamera,
  //           child: Icon(
  //             Icons.switch_camera,
  //             color: Colors.blueAccent,
  //             size: 20.0,
  //           ),
  //           shape: CircleBorder(),
  //           elevation: 2.0,
  //           fillColor: Colors.white,
  //           padding: const EdgeInsets.all(12.0),
  //         )
  //       ],
  //     ),
  //   );
  // }

  /// 显示聊天面板
  Widget buildChatPanel() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: BaseUtil.dp(48)),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.8,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: BaseUtil.dp(48)),
          child: ListView.builder(
            reverse: true,
            itemCount: arrChatInfo.length,
            itemBuilder: (BuildContext context, int index) {
              if (arrChatInfo.isEmpty) {
                return null;
              }
              return Padding(
                padding: EdgeInsets.symmetric(
                  vertical: BaseUtil.dp(3),
                  horizontal: BaseUtil.dp(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: BaseUtil.dp(10),
                          horizontal: BaseUtil.dp(20),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(BaseUtil.dp(20)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              constraints: BoxConstraints(maxWidth: BaseUtil.dp(80)),
                              child: Text(
                                arrChatInfo[index].userName,
                                maxLines: 100,
                                style: TextStyle(color: Color(0xFFF5B657)),
                              ),
                            ),
                            Text(
                              " :  ",
                              style: TextStyle(color: Color(0xFFFF9600), fontWeight: FontWeight.bold),
                            ),
                            Container(
                              constraints: BoxConstraints(maxWidth: BaseUtil.dp(220)),
                              child: Text(
                                arrChatInfo[index].message,
                                maxLines: 100,
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          ],
                        )
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// 显示礼物
  Widget buildGiftPanel() {
    if (!bShowGift) {
      return Text("");
    }
    var strAvatar = eventGift.avatar == null || eventGift.avatar == "" ? BaseUtil.gDefaultAvatar : BaseUtil.gBaseUrl + eventGift.avatar;
    var strGift = eventGift.giftPath == null || eventGift.giftPath == "" ? BaseUtil.gDefaultAvatar : strBaseUrl + eventGift.giftPath;

    Widget avatar = Container(
      height: 30,
      width: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
      ),
      child: ClipOval(
        child: Image.network(
          strAvatar,
          fit: BoxFit.cover,
        ),
      ),
    );
    Widget gift = Container(
      height: 66,
      width: 66,
      child: ClipOval(
        child: Image.network(
          strGift,
          fit: BoxFit.cover,
        ),
      ),
    );
    return Container(
      padding: EdgeInsets.symmetric(vertical: BaseUtil.dp(48)),
      alignment: Alignment.topLeft,
      child: FractionallySizedBox(
        heightFactor: 0.35,
        child: Container(
          alignment: Alignment.centerLeft,
          child: Stack(
            children: [
              Container(
                width: BaseUtil.dp(180),
                height: BaseUtil.dp(46),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(BaseUtil.dp(46)),
                  gradient: LinearGradient(
                      colors: <Color>[
                        Color(0xCCF876F4),
                        Color(0xCC599FFF),
                      ],
                      begin: FractionalOffset(0.0, 0.0),
                      end: FractionalOffset(1.0, 0.0),
                      stops: <double>[0.1, 1.0],
                      tileMode: TileMode.clamp
                  ),
                ),
                margin: EdgeInsets.only(left: BaseUtil.dp(10), top: BaseUtil.dp(7)),
                padding: EdgeInsets.only(left: BaseUtil.dp(15)),
                child: Row(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: avatar,
                    ),
                    Container(
                      padding: EdgeInsets.only(left: BaseUtil.dp(10)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            eventGift.userName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Color(0xFFF5B657),
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          Text(
                            "赠送" + eventGift.giftName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          )
                        ],
                      )
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: BaseUtil.dp(140)),
                child: gift
              ),
              Container(
                margin: EdgeInsets.only(left: BaseUtil.dp(210), top: BaseUtil.dp(5)),
                child: Text(
                  "x${eventGift.giftNumber}",
                  style: TextStyle(
                    color: Color(0xFFFFF700),
                    fontSize: BaseUtil.dp(50),
                    shadows: <Shadow>[
                      Shadow(
                        offset: Offset(-1.0, -1.0),
                        blurRadius: 5.0,
                        color: Color(0xFFFF7800),
                      ),
//                      Shadow(
//                        offset: Offset(1.0, 1.0),
//                        blurRadius: 3.0,
//                        color: Color(0xAAFF0000),
//                      ),
                    ],
                  )
                )
              )
            ],
          )
        ),
      ),
    );
  }
  //
  // void _onCallEnd(BuildContext context) {
  //   Navigator.pop(context);
  // }
  //
  // void _onToggleMute() {
  //   setState(() {
  //     muted = !muted;
  //   });
  //   rtcEngine.muteLocalAudioStream(muted);
  // }
  //
  // void _onSwitchCamera() {
  //   rtcEngine.switchCamera();
  // }

  @override
  Widget build(BuildContext context) {
    List<Widget> arrWidget = [];
    arrWidget.add(Container(
      color: Colors.black,
    ));
    arrWidget.add(_viewRows());
    arrWidget.add(Container(
      child: DongGanDanCheLiveHeader(
        onClose: _onClose,
        onShowAuthor: () {
          setState(() {
            bShowAuthorInfo = true;
          });
        },
        onShowPeopleList: () {
          setState(() {
            bShowPeopleList = true;
          });
        },
      ),
    ));
    arrWidget.add(buildChatPanel());
    arrWidget.add(Container(
        alignment: Alignment.bottomCenter,
        child: DongGanDanCheLiveFooter(
          onSendLiveMessage: (msg) {
            if(msg == null || msg == "") {
              return;
            }
            WebSocketUtil.sendMessage("sendLiveChat", {
              "message": msg,
            });
          },
        )
    ));
    arrWidget.add(buildGiftPanel());
    if (bShowAuthorInfo) {
      arrWidget.add(DongGanDanCheLiveAuthorInfo(
        onClose: () {
          setState(() {
            bShowAuthorInfo = false;
          });
        },
      ));
    } else if (bShowPeopleList) {
      arrWidget.add(DongGanDanCheLivePeopleList(
        onClose: () {
          setState(() {
            bShowPeopleList = false;
          });
        },
        onShowChangeDrag: (arrSelected) {
          arrSelectedStudent = arrSelected;
          showSetDrag(context);
        },
      ));
    } else if (bShowChangeDrag) {
      arrWidget.add(DongGanDanCheLiveChangeDrag(
        studentId: arrSelectedStudent[0],
        onClose: () {
          setState(() {
            bShowChangeDrag = false;
          });
        },
      ));
    }
    return WillPopScope(
      onWillPop: () async {
        if (bShowAuthorInfo) {
          setState(() { bShowAuthorInfo = false; });
        } else if (bShowPeopleList) {
          setState(() { bShowPeopleList = false; });
        } else if (bShowChangeDrag) {
          setState(() { bShowChangeDrag = false; });
        } else {
          _onClose();
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
          onTap: () {
            // 触摸收起键盘
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Center(
            child: Stack(
                children: arrWidget
            ),
          ),
        ),
      )
    );
  }

  /// 阻力设置界面
  showSetDrag(context) async {
    if (arrSelectedStudent.length == 1) {
      setState(() {
        bShowPeopleList = false;
        bShowChangeDrag = true;
      });
      return;
    }
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (context){
        return Container(
          height: BaseUtil.dp(211),
          padding: EdgeInsets.symmetric(vertical: BaseUtil.dp(24), horizontal: BaseUtil.dp(16)),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(bottom: BaseUtil.dp(25)),
                alignment: Alignment.centerLeft,
                child: Text(
                  "设置阻力",
                  style: TextStyle(
                    fontSize: BaseUtil.dp(16),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(""),
                    ),
                    Text(
                      "阻力值",
                      style: TextStyle(
                        fontSize: BaseUtil.dp(14),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(right: BaseUtil.dp(15))),
                    Container(
                      width: BaseUtil.dp(120),
                      padding: EdgeInsets.symmetric(vertical: BaseUtil.dp(0), horizontal: BaseUtil.dp(10)),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          style: BorderStyle.solid,
                          color: Color(0xFFCCCCCCC)
                        ),
                      ),
                      child: TextField(
                        focusNode: focusNodeNumber,
                        controller: controllerNumber,
                        keyboardType: TextInputType.numberWithOptions(),
                        style: TextStyle(
                          fontSize: 14.0,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(""),
                    ),
                  ],
                )
              ),
              Padding(padding: EdgeInsets.only(top: BaseUtil.dp(30))),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(""),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: BaseUtil.dp(8), horizontal: BaseUtil.dp(30)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            width: 1,
                            color: Color(0xFFCCCCCCC),
                            style: BorderStyle.solid
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(4.0),
                        ),
                      ),
                      child: Text(
                        "取消",
                        style: TextStyle(
                            fontSize: BaseUtil.dp(14),
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(""),
                  ),
                  GestureDetector(
                    onTap: () {
                      HttpUtil.getInstance().postJson(API.batchUpdateBicycleDrag, params: {
                        "userIds": arrSelectedStudent.toString(),
                        "drag": controllerNumber.text
                      }).then((response) {
                        Navigator.pop(context);
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: BaseUtil.dp(8), horizontal: BaseUtil.dp(30)),
                      decoration: BoxDecoration(
                        color: BaseUtil.gDefaultColor,
                        border: Border.all(
                            width: 1,
                            color: Color(0xFFCCCCCCC),
                            style: BorderStyle.solid
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(4.0),
                        ),
                      ),
                      child: Text(
                        "确定",
                        style: TextStyle(
                            fontSize: BaseUtil.dp(14),
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(""),
                  ),
                ]
              )
            ],
          ),
        );
      }
    );
  }

  void _onClose() {
    bClickClose = true;
    var userId = BaseUtil.gStUser.containsKey("id") ? BaseUtil.gStUser["id"] : 0;
    if (AgoraUtil.liveInfo["authorId"] == userId) {
      Navigator.popAndPushNamed(context, "/liveClose");
    } else {
      AgoraUtil.closeLive((response) {
        if (response == null) {
          CustomSnackBar(context, Text("获取失败"));
          return;
        }
        Navigator.pop(context);
        Future.delayed(Duration(milliseconds: 200),() async {
          EventUtil.gEventBus.fire(SwitchIndexPageEvent(0));
        });
      });
    }
  }
}
