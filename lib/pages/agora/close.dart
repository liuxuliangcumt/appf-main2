// @dart=2.9
import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:flutter/material.dart';
import 'dart:ui';   //引入ui库，因为ImageFilter Widget在这个里边。


class DongGanDanCheLiveClose extends StatefulWidget {
  final Function onClose;
  const DongGanDanCheLiveClose({
    Key key,
    this.onClose
  }) : super(key: key);

  @override
  _DongGanDanCheLiveClose createState() => _DongGanDanCheLiveClose();
}

class _DongGanDanCheLiveClose extends State<DongGanDanCheLiveClose> {
  Map mUserInfo = {};

  @override
  void initState(){
    super.initState();
    AgoraUtil.closeLive((response) {
      if (response == null) {
        CustomSnackBar(context, Text("获取失败"));
        return;
      }
      //先转json
      var json = jsonDecode(response.toString());
      setState(() {
        AgoraUtil.liveInfo = json["data"];
      });
    });
  }
  @override
  void dispose() {
    super.dispose();
    Future.delayed(Duration(milliseconds: 200),() async {
      EventUtil.gEventBus.fire(SwitchIndexPageEvent(0));
    });
  }

  @override
  Widget build(BuildContext context) {
    var item = AgoraUtil.liveInfo;
    if (item == null) {
      item = {};
    }
    var strAvatar = item['authorAvatar'] == null || item['authorAvatar'] == "" ? BaseUtil.gDefaultAvatar : BaseUtil.gBaseUrl + item['authorAvatar'];
//    var onlineNum = item['onlineNum'] == null || item['onlineNum'] == "" ? "0" : item['onlineNum'].toString();
    var strUserName = item['authorNickName'] == null ? "" : item['authorNickName'];
    var strShowTime = item['showTime'] == null || item['showTime'] == "" ? "00:00:00" : item['showTime'];
    var strReward = item['rewardAmount'] == null || item['rewardAmount'] == "" ? "0" : item['rewardAmount'];
    var strPeople = item['maxPeople'] == null ? "0" : "${item['maxPeople']}";
    var strCollection = item['fansNum'] == null ? "0" : "${item['fansNum']}";

    Widget avatar = GestureDetector(
      child:Container(
        height: 110,
        width: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(80),
          color: Colors.orange,
          border: Border.all(
            color: Colors.white,
            width: 1,
          ),
        ),
        child: ClipOval(
          child: Image.network(
            strAvatar,
            fit: BoxFit.cover,
          ),
        ),
      )
    );
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          children: [
            ConstrainedBox( //约束盒子组件，添加额外的限制条件到 child上。
                constraints: const BoxConstraints.expand(), //限制条件，可扩展的。
                child:Image.network(strAvatar, fit: BoxFit.cover,)
            ),
            ConstrainedBox( // 黑色透明遮罩
              constraints: const BoxConstraints.expand(), //限制条件，可扩展的。
              child: Container(
                color: Colors.black45,
              ),
            ),
            ClipRect(  //裁切长方形
              child: BackdropFilter(   //背景滤镜器
                filter: ImageFilter.blur(sigmaX: 12.0,sigmaY: 12.0), //图片模糊过滤，横向竖向都设置12.0
                child: Column(
                  children: [
                    Padding(padding: EdgeInsets.only(top: BaseUtil.dp(30))),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: EdgeInsets.only(left: BaseUtil.dp(65)),
                            child:  Center(
                              child: Text(
                                "直播结束",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: BaseUtil.dp(16),
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: BaseUtil.dp(5), horizontal: BaseUtil.dp(16)),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: BaseUtil.dp(30),
                            ),
                          )

                        )
                      ],
                    ),
                    Padding(padding: EdgeInsets.only(top: BaseUtil.dp(30))),
                    avatar,
                    Padding(padding: EdgeInsets.only(top: BaseUtil.dp(15))),
                    Center(
                        child: Text(
                        strUserName,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: BaseUtil.dp(20),
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: BaseUtil.dp(30))),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      strShowTime,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: BaseUtil.dp(14),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  child: Text(
                                    "直播时长",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: BaseUtil.dp(12),
                                    ),
                                  ),
                                ),
                              ]
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "$strReward",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: BaseUtil.dp(14),
                                      ),
                                    ),
                                    Container(
                                      width: BaseUtil.dp(24),
                                      height: BaseUtil.dp(24),
                                      child: Image.asset("assets/images/live/close/gift.png", fit: BoxFit.cover,),
                                    ),
                                  ],
                                ),
                                Container(
                                  child: Text(
                                    "收到礼物",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: BaseUtil.dp(12),
                                    ),
                                  ),
                                ),
                              ]
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      strPeople,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: BaseUtil.dp(14),
                                      ),
                                    ),
                                    Container(
                                      width: BaseUtil.dp(24),
                                      height: BaseUtil.dp(24),
                                      child: Image.asset("assets/images/live/close/fire.png", fit: BoxFit.cover,),
                                    ),
                                  ],
                                ),
                                Container(
                                  child: Text(
                                    "本场热度",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: BaseUtil.dp(12),
                                    ),
                                  ),
                                ),
                              ]
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$strCollection人',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: BaseUtil.dp(14),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  child: Text(
                                    "收到关注",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: BaseUtil.dp(12),
                                    ),
                                  ),
                                ),
                              ]
                          ),
                        ),
                      ],
                    ),
                    Padding(padding: EdgeInsets.only(top: BaseUtil.dp(30))),
                  ],
                )
              ),
            ),
          ]
        ),
      ),
    );
  }
}
