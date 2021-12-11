/*
 * WebSocket通信
 */
// @dart=2.9
import 'dart:async';

import 'package:dong_gan_dan_che/common/BleUtil.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'BaseUtil.dart';

class WebSocketUtil {
  static SocketClient gSocket = SocketClient();

  static void initSocket() {
    gSocket.mEnable = true;
    gSocket.reconnect();
  }

  static void exitSocket() {
    gSocket.mEnable = false;
    gSocket.exit();
  }

  static void sendMessage(message, data) {
    gSocket.sendMessage(message, data);
  }

  static void sendMatchRoomUser(matchPeople) {
    gSocket.sendMatchRoomUser(matchPeople);
  }
}

// 直播房间webSocket
class SocketClient {
  /// 启用: =true的情况下,如果关闭了WebSocket, 则需要重连; =false不需要重连
  bool mEnable = false;
  /// 重连标记
  bool mReconnect = false;

  IOWebSocketChannel mChannel;
  Timer mTimerHeart;
  Timer mTimerConnect;

  dynamic mVideoId; /// 正在播放得视频

  // 初始化
  void init() {
    // 创建通道
    createChennel();

    // 接受弹幕、礼物消息(webSocket)
    mChannel.stream.listen(onWebSocketMessage, onDone: onDone, onError: onError);

    // 启动心跳
    startHeart();
  }


  // 析构
  void exit() {
    try {
      if (mTimerHeart != null) {
        mTimerHeart.cancel();
      }
      mTimerHeart = null;
      if (mChannel != null) {
        mChannel?.sink?.close(status.goingAway);
      }
      mChannel = null;
    } catch(e) {

    }
  }

  bool createChennel() {
    try {
      if (BaseUtil.gBasePort == null || BaseUtil.gBasePort.length < 2) {
        mChannel = IOWebSocketChannel.connect(
            'ws://${BaseUtil.gBaseHost}/app/socket/${BaseUtil.gStUser["id"]}');
      } else {
        mChannel = IOWebSocketChannel.connect(
            'ws://${BaseUtil.gBaseHost}:${BaseUtil.gBasePort}/app/socket/${BaseUtil.gStUser["id"]}');
      }
      return true;
    } catch (ex) {
      return false;
    }
  }

  void startHeart() {
    if (mTimerHeart != null) {
      mTimerHeart.cancel();
      mTimerHeart = null;
    }
    const oneSec = const Duration(seconds: 10);
    var callback = (timer) {
      var bBicycleLog = BaseUtil.gStBicycleLog != null && BaseUtil.gStBicycleLog["id"] != null && BaseUtil.gStBicycleLog["id"] > 0;
      var data = jsonEncode({
        "MessageId": "heart",
        "data": {
          "token": HttpUtil.getInstance().mToken,
          "userId": BaseUtil.gStUser["id"],
          "userType": BaseUtil.gStUser["userType"],
          "liveId": AgoraUtil.liveId,
          "liveCode": AgoraUtil.liveCode,
        },
        "BicycleLog": bBicycleLog ? BaseUtil.gStBicycleLog : {}
      });
      try {
        /// print("发送心跳包");
        // 发送心跳包
        mChannel.sink.add(data);
      } catch(e) {
        print(e);
      }
    };
    mTimerHeart = Timer.periodic(oneSec, callback);
  }

  void onDone() {
    print("WebSocket关闭");
    if (mChannel == null) {
      print("mChannel为空, 说明调用了exit");
    } else {
      print("mChannel非NULL, 说明后端触发关闭");
      exit();
      if (mEnable && !mReconnect) {
        startReconnect();
      }
    }
  }

  void onError(err) {
    print(err.runtimeType.toString());
    WebSocketChannelException ex = err;
    print(ex.message);
    /// 通信超时
    if (ex.message.indexOf("errno = 110") >= 0) {
      exit();
      if (mEnable && !mReconnect) {
        startReconnect();
      }
    }
  }

  // WebSocket通信
  void onWebSocketMessage(message) {
    /// print("接收数据" + message);
    var json = jsonDecode(message);
    var method = json["method"];
    var data = json["data"];
    if (method == "connect" && data == "succeed") {
      stopReconnect();
    }
    else if (method == "heartResult") {
    }
    else if (method == "updateStudentDeviceInfo") {
      /// 学员通知教练更新设备信息
      EventUtil.gEventBus.fire(SendUpdateStudentDeviceInfo(data));
    }
    else if (method == "enterLiveAfter") {
      // 某人进入直播间
      EventUtil.gEventBus.fire(SendEnterLiveAfterEvent(data));
    }
    else if(method == "leaveLiveAfter") {
      // 某人离开了直播间
      EventUtil.gEventBus.fire(SendLeaveLiveEvent(data));
    }
    else if (method == "closeLive") {
      // 主播关闭了直播间
      EventUtil.gEventBus.fire(SendCloseLiveEvent(data));
    }
    else if (method == "updateLiveChat") {
      // 更新直播间聊天信息
      EventUtil.gEventBus.fire(SendLiveChatEvent(data["userName"], data["message"]));
    }
    else if(method == "updateLiveGift") {
      // 更新直播间礼物信息
      EventUtil.gEventBus.fire(SendLiveGiftEvent(data["userName"],data["avatar"],data["giftName"],data["giftPath"],data["giftNumber"],data["giftMoney"]));
    }
    else if (method == "playVideoAfter") {
      // 某人开始播放视频
      EventUtil.gEventBus.fire(SendPlayVideoAfterEvent(data));
    }
    else if(method == "closeVideoAfter") {
      // 某人关闭视频播放
      EventUtil.gEventBus.fire(SendCloseVideoAfterEvent(data));
    }
    else if (method == "updateVideoChat") {
      // 更新视频点播聊天信息
      EventUtil.gEventBus.fire(SendVideoChatEvent(data["userName"], data["message"]));
    }
    else if(method == "updateVideoGift") {
      // 更新视频点播礼物信息
      EventUtil.gEventBus.fire(SendVideoGiftEvent(data["userName"],data["avatar"],data["giftName"],data["giftPath"],data["giftNumber"],data["giftMoney"]));
    }
    else if(method == "setDrag") {
      if (BaseUtil.gStBicycleLog != null && BaseUtil.gStBicycleLog["id"] != null && BaseUtil.gStBicycleLog["id"] > 0) {
        int drag = int.parse(BaseUtil.gNumberFormat.format(data["drag"]));
        BleUtil.sendDataToBle([ 0x55, 0xAA, 0x02, 0x02, 0x00, drag ]);
        CustomSnackBar(BaseUtil.gNavigatorKey.currentContext, Text("教练设置了阻力为$drag!!!"));
      }
    }
    else if(method == "updateMatchRoom") {
      // 更新比赛
      EventUtil.gEventBus.fire(UpdateMatchRoomEvent(data));
    }
    else if(method == "beginMatchRoom") {
      // 开始比赛
      EventUtil.gEventBus.fire(BeginMatchRoomEvent(data));
    }
    else if(method == "endMatchRoom") {
      // 结束比赛
      EventUtil.gEventBus.fire(EndMatchRoomEvent(data));
    }
  }

  // 重连
  void reconnect() {
    print("开始连接");
    exit();
    init();
  }

  void startReconnect() {
    if(mTimerConnect != null) {
      mTimerConnect?.cancel();
      mTimerConnect = null;
    }
    mReconnect = true;
    const oneSec = const Duration(seconds: 20);
    var callback = (timer) {
      if (mReconnect) {
        reconnect();
      }
    };
    mTimerConnect = Timer.periodic(oneSec, callback);
  }

  void stopReconnect() {
    mReconnect = false;
    if(mTimerConnect != null) {
      mTimerConnect?.cancel();
      mTimerConnect = null;
    }
  }

  // 发送消息
  void sendMessage(message, data) {
    data["token"] = HttpUtil.getInstance().mToken;
    data["userId"] = BaseUtil.gStUser["id"];
    data["userType"] =  BaseUtil.gStUser["userType"];
    data["liveId"] = AgoraUtil.liveId;
    data["liveCode"] = AgoraUtil.liveCode;

    data["videoId"] = mVideoId;
    var str = jsonEncode({
      "MessageId": message,
      "data": data
    });
    try {
      mChannel.sink.add(str);
    } catch (e) {
      reconnect();
    }
  }

  void sendMatchRoomUser(matchPeople) {
    var str = jsonEncode({
      "MessageId": "matchRoomUser",
      "BicycleLog": BaseUtil.gStBicycleLog,
      "MatchPeople": matchPeople
    });
    try {
      mChannel.sink.add(str);
    } catch (e) {
      reconnect();
    }
  }

}
