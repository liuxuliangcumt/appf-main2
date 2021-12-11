/*
 * 比赛房间, 比赛准备阶段和比赛进行阶段的显示
 */

// @dart=2.9
import 'dart:async';

import 'package:dong_gan_dan_che/common/WxUtil.dart';
import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class DongGanDanCheMatchRoomPage extends StatefulWidget {
  final arguments;

  DongGanDanCheMatchRoomPage({Key key, this.arguments}) : super(key: key);

  @override
  _DongGanDanCheMatchRoomPage createState() => _DongGanDanCheMatchRoomPage();
}

class _DongGanDanCheMatchRoomPage extends State<DongGanDanCheMatchRoomPage> {
  StreamSubscription streamSubscriptionUpdate;
  StreamSubscription streamSubscriptionBegin;
  StreamSubscription streamSubscriptionEnd;
  int userId = 0;
  String matchType = '1';
  double totalMileage = 0.0;
  double startMileage = -1.0;
  dynamic matchInfo = {};
  dynamic matchPeople = {};

  Timer mWebSocketTimer;

  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  void dispose() {
    exit();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var status = matchInfo["status"] == null ? '1' : matchInfo["status"];
    List<Widget> arrWidget = [];
    var matchPeopleList = matchInfo["matchPeopleList"] == null
        ? []
        : matchInfo["matchPeopleList"];
    var boxWidth = BaseUtil.dp(343);
    var boxHeight = BaseUtil.dp(146);
    var bIsReady = status == '1';

    /// 生成标题栏
    arrWidget.add(buildHeader(bIsReady ? "比赛准备中" : "比赛进行中"));
    arrWidget.add(Padding(padding: EdgeInsets.only(top: BaseUtil.dp(15))));

    /// 生成选手信息显示对象
    arrWidget.add(Expanded(
      flex: 1,
      child: SingleChildScrollView(
        child: Container(
          child: Column(
            children:
                _buildMatchPeopleList(matchPeopleList, boxWidth, boxHeight),
          ),
        ),
      ),
    ));
    var coachId = matchInfo["userId"] == null ? 0 : matchInfo["userId"];
    if (coachId == userId) {
      /// 生成按钮
      arrWidget.add(buildButton(bIsReady));
    }
    arrWidget.add(Padding(padding: EdgeInsets.only(top: BaseUtil.dp(10))));
    return WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: Container(
              color: Colors.white,
              child: Column(
                children: arrWidget,
              ),
            )));
  }

  List<Widget> _buildMatchPeopleList(matchPeopleList, boxWidth, boxHeight) {
    List<Widget> ret = [];
    if (matchPeopleList.length == 0) {
      ret.add(_buildMatchPeopleListEmpty(boxWidth, boxHeight));
      return ret;
    }

    /// 循环生成单个学员信息
    matchPeopleList.forEach((people) {
      ret.add(_buildMatchPeople(people, boxWidth, boxHeight));
    });
    return ret;
  }

  Widget _buildMatchPeopleListEmpty(boxWidth, boxHeight) {
    return Text("");
    // return Padding(
    //   padding: EdgeInsets.only(bottom: BaseUtil.dp(15)),
    //   child: ClipRRect(
    //       borderRadius: BorderRadius.all(
    //         Radius.circular(BaseUtil.dp(8)),
    //       ),
    //       child: Container(
    //         width: boxWidth,
    //         height: boxHeight,
    //         alignment: Alignment.center,
    //         color: Color(0xFFEEEBE9),
    //         child: Text("无"),
    //       )),
    // );
  }

  Widget _buildMatchPeople(people, boxWidth, boxHeight) {
    var strNickName = people["nickName"] == null ? "学员" : people["nickName"];
    return Padding(
        padding: EdgeInsets.only(bottom: BaseUtil.dp(15)),
        child: ClipRRect(
          borderRadius: BorderRadius.all(
            Radius.circular(BaseUtil.dp(8)),
          ),
          child: Container(
            width: boxWidth,
            color: Color(0xFFEEEBE9),
            padding: EdgeInsets.symmetric(
                horizontal: BaseUtil.dp(14), vertical: BaseUtil.dp(16)),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      child: Text(
                        strNickName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: BaseUtil.dp(16)),
                      ),
                    ),
                    Expanded(flex: 1, child: Text("")),
                    _buildMatchPeopleStatus(people),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: BaseUtil.dp(10)),
                ),
                _buildMatchPeopleRunning(people)
              ],
            ),
          ),
        ));
  }

  Widget _buildMatchPeopleStatus(people) {
    var clr = BaseUtil.gArrArtWordColor[0];
    var status = people["status"] == null ? "0" : people["status"];
    var statusName = "";
    if (status == "0") {
      statusName = "未参加";
      clr = BaseUtil.gArrArtWordColor[3];
    } else if (status == "1") {
      statusName = "准备就绪";
      clr = BaseUtil.gArrArtWordColor[2];
    } else if (status == "2") {
      statusName = "比赛中";
      clr = BaseUtil.gArrArtWordColor[1];
    } else if (status == "3") {
      statusName = "完成比赛";
      clr = BaseUtil.gArrArtWordColor[0];
    }
    return Container(
      child: Text(statusName,
          style: TextStyle(
            color: clr["text"],
            fontSize: BaseUtil.dp(16),
            shadows: <Shadow>[
              Shadow(
                offset: Offset(0.0, 0.0),
                blurRadius: 2.0,
                color: clr["shadowLeftTop"],
              ),
            ],
          )),
    );
  }

  Widget _buildMatchPeopleRunning(people) {
    var status = people["status"] == null ? "0" : people["status"];
    if (status == "2") {
      var mileage = people["mileage"] == null ? 0.0 : people["mileage"];
      mileage = BaseUtil.gNumberFormat3.format(mileage);
      return Container(
        child: Row(
          children: [
            Text(
              "里程: ",
              style: TextStyle(color: Colors.black, fontSize: BaseUtil.dp(16)),
            ),
            Text(
              "$mileage",
              style: TextStyle(
                  color: Colors.cyan,
                  fontWeight: FontWeight.bold,
                  fontSize: BaseUtil.dp(16)),
            ),
            Text(
              "公里",
              style: TextStyle(color: Colors.black, fontSize: BaseUtil.dp(16)),
            ),
          ],
        ),
      );
    } else if (status == "3") {
      var mileage = people["mileage"] == null ? 0.0 : people["mileage"];
      mileage = BaseUtil.gNumberFormat3.format(mileage);
      var strMileage = "$mileage";
      int s = people["second"] == null ? 0 : people["second"];
      int m = (s / 60).floor();
      s = s % 60;
      var strTime = m > 0 ? "$m分$s秒" : "$s秒";
      return Container(
        child: Row(
          children: [
            Text(
              "里程: ",
              style: TextStyle(color: Colors.black, fontSize: BaseUtil.dp(16)),
            ),
            Text(
              "$strMileage",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: BaseUtil.dp(16)),
            ),
            Text(
              "公里",
              style: TextStyle(color: Colors.black, fontSize: BaseUtil.dp(16)),
            ),
            Expanded(flex: 1, child: Text("")),
            Text(
              "用时: ",
              style: TextStyle(color: Colors.black, fontSize: BaseUtil.dp(16)),
            ),
            Text(
              "$strTime",
              style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: BaseUtil.dp(16)),
            ),
          ],
        ),
      );
    }
    return Text("");
  }

  Widget buildHeader(title) {
    return Container(
        padding: EdgeInsets.only(
            top: BaseUtil.dp(30),
            left: BaseUtil.dp(20),
            right: BaseUtil.dp(20)),
        height: BaseUtil.dp(60),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                child: Center(
                  child: Image.asset(
                    'assets/images/common/back.webp',
                    width: BaseUtil.dp(10),
                  ),
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(right: BaseUtil.dp(15))),
            Expanded(
                flex: 1,
                child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      title,
                      style: TextStyle(
                          color: Color(0xFF333333),
                          fontSize: BaseUtil.dp(16),
                          fontWeight: FontWeight.bold),
                    ))),
            GestureDetector(
              onTap: () {
                WxUtil.getInstance().shareMatch(widget.arguments);
              },
              child: Container(
                child: Center(
                  child: Image.asset(
                    'assets/images/common/share.png',
                    width: BaseUtil.dp(30),
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Widget buildButton(bIsReady) {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: BaseUtil.dp(10), horizontal: BaseUtil.dp(20)),
      child: RawMaterialButton(
        constraints: BoxConstraints(minHeight: 40),
        fillColor: BaseUtil.gDefaultColor,
        elevation: 0,
        highlightElevation: 0,
        highlightColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(23)),
        ),
        onPressed: () {
          HttpUtil.getInstance().postJson(
              bIsReady ? API.beginMatch : API.endMatch,
              params: {"matchId": matchInfo["id"]}).then((response) {});
        },
        child: Center(
          child: Text(
            bIsReady ? '开始比赛' : '提前结束比赛',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  void initData() {
    userId = BaseUtil.gStUser["id"];
    matchInfo = widget.arguments;
    matchType = matchInfo["type"] == null ? '1' : matchInfo["type"];
    if (matchType == '2') {
      totalMileage = matchInfo["fixData"] == null ? 0.0 : matchInfo["fixData"];
    }
    if (mWebSocketTimer != null) {
      mWebSocketTimer.cancel();
    }
    const oneSec = const Duration(seconds: 1);
    var callback = (timer) {
      if (startMileage < -0.1) {
        return;
      }
      var status = matchPeople["status"] == null ? "0" : matchPeople["status"];
      if (status == "3") {
        mWebSocketTimer.cancel();
        return;
      }
      var mileage = BaseUtil.gStBicycleLog["mileage"] - startMileage;

      /// 固定里程的比赛, 设置最大值
      if (matchType == '2' && mileage > totalMileage) {
        var matchId =
            widget.arguments["id"] == null ? 0 : widget.arguments["id"];

        /// 通知某个学员完成了比赛: 不再继续发送数据
        HttpUtil.getInstance().postJson(API.finishPeopleMatch, params: {
          "matchId": matchId,
          "userId": userId,
          "mileage": mileage
        }).then((response) {});
        mWebSocketTimer.cancel();
        return;
      }
      matchPeople["mileage"] = mileage;
      WebSocketUtil.sendMatchRoomUser(matchPeople);
    };
    mWebSocketTimer = Timer.periodic(oneSec, callback);
    var that = this;

    /// 更新比赛信息
    streamSubscriptionUpdate =
        EventUtil.gEventBus.on<UpdateMatchRoomEvent>().listen((event) {
      that.setState(() {
        matchInfo = event.data;
      });
    });

    /// 比赛开始,记录当前人员信息, 记录设备起始里程数
    streamSubscriptionBegin =
        EventUtil.gEventBus.on<BeginMatchRoomEvent>().listen((event) {
      var matchPeopleList = matchInfo["matchPeopleList"] == null
          ? []
          : matchInfo["matchPeopleList"];
      matchPeopleList.forEach((people) {
        var id = people["userId"] == null ? 0 : people["userId"];
        if (id == userId) {
          matchPeople = people;
        }
      });
      var peopleId = matchPeople["userId"] == null ? 0 : matchPeople["userId"];
      if (peopleId > 0) {
        startMileage = BaseUtil.gStBicycleLog["mileage"];
      } else {
        startMileage = -1.0;
      }
    });

    /// 结束比赛，跳转到成绩界面
    streamSubscriptionEnd =
        EventUtil.gEventBus.on<EndMatchRoomEvent>().listen((event) {
      Navigator.pushNamed(context, "/match/result", arguments: matchInfo);
    });
  }

  void exit() {
    streamSubscriptionUpdate.cancel();
    streamSubscriptionBegin.cancel();
    streamSubscriptionEnd.cancel();
    if (mWebSocketTimer != null) {
      mWebSocketTimer.cancel();
    }

    /// 如果比赛不是已完成状态，则通知离开比赛房间，取消对应的准备状态
    var status = matchInfo["status"] == null ? 0 : matchInfo["status"];
    var id = widget.arguments["id"] == null ? 0 : widget.arguments["id"];
    if (status != 3 && id > 0) {
      HttpUtil.getInstance().postJson(API.leaveMatchRoom,
          params: {"matchId": id, "userId": userId}).then((response) {});
    }
  }
}
