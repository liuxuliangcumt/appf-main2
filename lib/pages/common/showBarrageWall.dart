/*
 * 显示弹幕: 弹幕墙
 */
// @dart=2.9
import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:dong_gan_dan_che/pages/common/barrage.dart';

class ShowBarrageWallPage extends StatefulWidget {
  @override
  _ShowBarrageWallPage createState() => _ShowBarrageWallPage();
}

class _ShowBarrageWallPage extends State<ShowBarrageWallPage> {
  StreamSubscription streamSubscriptionPlay;
  StreamSubscription streamSubscriptionClose;
  StreamSubscription streamSubscriptionChat;

  BarrageWallController controllerBar;
  Timer timerBar;
  bool isBarPlaying = false;

  final arrChatInfo = <SendVideoChatEvent>[];

  @override
  void initState() {
    super.initState();
    controllerBar = BarrageWallController.all(
      options: ChannelOptions(height: BaseUtil.dp(40.0)),
      channelCount: 8,
    );

    initEventListen();

    initPlay();
  }

  @override
  void dispose() {
    streamSubscriptionPlay.cancel();
    streamSubscriptionClose.cancel();
    streamSubscriptionChat.cancel();
    super.dispose();
  }

  void initEventListen() {
    var that = this;
    /// 某个观众进入了直播间
    streamSubscriptionPlay = EventUtil.gEventBus.on<SendPlayVideoAfterEvent>().listen((event) {
      var data = event.data;
      that.setState(() {
        var user = data["userInfo"];
        arrChatInfo.insert(0, SendVideoChatEvent(user["nickName"], "来了"));
        if (arrChatInfo.length > 200) {
          arrChatInfo.removeLast();
        }
      });
    });
    /// 某个观众离开了直播间
    streamSubscriptionClose = EventUtil.gEventBus.on<SendCloseVideoAfterEvent>().listen((event) {
      var data = event.data;
      that.setState(() {
        var user = data["userInfo"];
        arrChatInfo.insert(0, SendVideoChatEvent(user["nickName"], "走了"));
      });
    });
    /// 收到了聊天消息
    streamSubscriptionChat = EventUtil.gEventBus.on<SendVideoChatEvent>().listen((event) {
      that.setState(() {
        arrChatInfo.insert(0, event);
        if (arrChatInfo.length > 200) {
          arrChatInfo.removeLast();
        }
      });
    });
  }

  void initPlay() {
    Future.delayed(Duration(milliseconds: 100),() async{
      // 每间隔 300 毫秒添加一条弹幕
      timerBar = Timer.periodic(const Duration(milliseconds: 1000), (_) {
        if(arrChatInfo.length > 0) {
          _addBarrage(arrChatInfo[0].userName, arrChatInfo[0].message);
          arrChatInfo.removeAt(0);
          controllerBar.play();
        }
      });
      setState(() {});
    });
    /// 测试
    // for (int i = 0; i < 200; i++) {
    //   arrChatInfo.add(SendVideoChatEvent("张三", "我刷屏了！！！"));
    // }
  }

  @override
  Widget build(BuildContext context) {
    return buildChatPanel();
  }

  /// 显示聊天面板
  Widget buildChatPanel() {
    return Container(
      alignment: Alignment.topCenter,
      margin: EdgeInsets.only(
        top: BaseUtil.dp(80)
      ),
      child: controllerBar.buildView()
    );
  }

  int _addBarrage(userName, message) {
    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
            padding: EdgeInsets.symmetric(
              vertical: BaseUtil.dp(5),
              horizontal: BaseUtil.dp(20),
            ),
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(BaseUtil.dp(20)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  userName + " :  ",
                  style: TextStyle(color: Color(0xFFF5B657), fontSize: 16),
                ),
                Text(
                  message,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            )
        ),
      ],
    );

    var item = BarrageItem(
      content: content,
      // 随机一个 1 到 2 之间的滚动速度
      speed: Random().nextDouble() + 1,
      start: isBarPlaying,
    );

    return controllerBar.add(item);
  }
}