/*
 * 事件定义
 */
//@dart=2.9
import 'package:event_bus/event_bus.dart';

class EventUtil {
  static EventBus gEventBus = new EventBus();
}

//region 直播
// 主播关闭直播间
class SendCloseLiveEvent {
  Map data;
  SendCloseLiveEvent(this.data);
}

// 进入直播间
class SendEnterLiveAfterEvent {
  Map data;
  SendEnterLiveAfterEvent(this.data);
}

// 离开直播间
class SendLeaveLiveEvent {
  Map data;
  SendLeaveLiveEvent(this.data);
}

// 进入直播间
class SendUpdateStudentDeviceInfo {
  Map data;
  SendUpdateStudentDeviceInfo(this.data);
}

// 发送消息
class SendLiveChatEvent {
  String userName;
  String message;

  SendLiveChatEvent(this.userName, this.message);
}

// 发送消息
class SendLiveGiftEvent {
  String userName;
  String avatar;
  String giftName;
  String giftPath;
  int giftNumber;
  int giftMoney;

  SendLiveGiftEvent(this.userName, this.avatar, this.giftName, this.giftPath, this.giftNumber, this.giftMoney);
}
//endregion

//region 点播视频
// 某人开始播放视频
class SendPlayVideoAfterEvent {
  Map data;
  SendPlayVideoAfterEvent(this.data);
}

// 某人关闭视频播放
class SendCloseVideoAfterEvent {
  Map data;
  SendCloseVideoAfterEvent(this.data);
}

// 发送消息
class SendVideoChatEvent {
  String userName;
  String message;

  SendVideoChatEvent(this.userName, this.message);
}

// 发送消息
class SendVideoGiftEvent {
  String userName;
  String avatar;
  String giftName;
  String giftPath;
  int giftNumber;
  int giftMoney;

  SendVideoGiftEvent(this.userName, this.avatar, this.giftName, this.giftPath, this.giftNumber, this.giftMoney);
}

//endregion

// 切换界面
class SwitchIndexPageEvent {
  final pageIndex;
  SwitchIndexPageEvent(this.pageIndex);
}

// 更新页面列表对应的数据
class UpdateIndexListEvent {
  String type;
  UpdateIndexListEvent(this.type);
}

// 充值更新支付金额
class UpdateRechargeMoneyEvent {
  final money;
  UpdateRechargeMoneyEvent(this.money);
}

// 更新比赛信息
class UpdateMatchRoomEvent {
  final data;
  UpdateMatchRoomEvent(this.data);
}
// 比赛开始
class BeginMatchRoomEvent {
  final data;
  BeginMatchRoomEvent(this.data);
}
// 比赛结束
class EndMatchRoomEvent {
  final data;
  EndMatchRoomEvent(this.data);
}
