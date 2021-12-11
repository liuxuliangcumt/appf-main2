/*
 * 显示礼物信息
 */
// @dart=2.9
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:dong_gan_dan_che/common/BaseUtil.dart';

class ShowGiftPage extends StatefulWidget {
  @override
  _ShowGiftPage createState() => _ShowGiftPage();
}

class _ShowGiftPage extends State<ShowGiftPage> {
  StreamSubscription streamSubscriptionGift;
  /// 是否播放礼物信息
  bool bShowGift = false;
  SendVideoGiftEvent eventGift;
  Timer timerShowGift;

  /// 测试使用测试服务器地址,否则使用BaseUtil.baseUrl
  String strBaseUrl = "https://www.reciprocalaffection.com/uploads/DongGanDanChe/gift";
  //    String strBaseUrl = BaseUtil.baseUrl;

  @override
  void initState() {
    super.initState();
    initEventListen();
  }

  @override
  void dispose() {
    streamSubscriptionGift.cancel();
    super.dispose();
  }

  void initEventListen() {
    var that = this;
    /// 收到了礼物
    streamSubscriptionGift = EventUtil.gEventBus.on<SendVideoGiftEvent>().listen((event) {
      that.setState(() {
        eventGift = event;
        bShowGift = true;
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

  @override
  Widget build(BuildContext context) {
    return buildGiftPanel();
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

}