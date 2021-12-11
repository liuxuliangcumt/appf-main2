/// 声网对象调用工具
// @dart=2.9
import 'package:dong_gan_dan_che/common/BaseUtil.dart';

class AgoraUtil {
  // 对应声网项目APP ID
  static String agoraAppId = "a8510c1b63f541cda73ed0387b099b00";
  // 对应声网项目的证书,
  static String agoraCertificate = "a24fca709b7d40e799fa78a1b293f476";
  // 对应声网项目的Token, 用于验证要打开的直播间, 之后应该是根据后端生成的Token来访问直播间
  static String agoraToken = "006a8510c1b63f541cda73ed0387b099b00IAC4kovxqxkwcAtjh/CTWwDtV1uaMHW9RZJrTM1HPwPg7fTEZm0AAAAAEAC8aS6KF/XKYAEAAQAV9cpg";

  // 当前正在观看的直播间信息
  static num liveId = 0;
  static String liveCode = "";
  static String liveTitle = "";

  static bool bIsAuthor = false;
  static bool bIsFavorite = false;

  // 主播编号
  static Map liveInfo;

  // 开播
  static void openLive() {

  }

  // 观看直播
  static void watchLive(item, callback) {
    HttpUtil.getInstance().postJson(API.watchLive, params: {
      "liveId": item["liveId"],
      "liveCode": item["liveCode"]
    }).then((response) {
      if (response == null) {
        return;
      }
      var param = jsonDecode(response.toString());
      var data = param["data"];
      AgoraUtil.agoraAppId = data["agoraAppId"];
      AgoraUtil.agoraToken = data["agoraToken"];
      AgoraUtil.liveTitle = item["liveTitle"];
      AgoraUtil.liveCode = data["liveCode"];
      AgoraUtil.liveId = item["liveId"];
      AgoraUtil.liveInfo = item;
      // 回调函数
      callback(liveCode);
    });
  }

  static void closeLive(cb) {
    var userId = BaseUtil.gStUser.containsKey("id") ? BaseUtil.gStUser["id"] : 0;
    String url = AgoraUtil.liveInfo["authorId"] == userId ? API.closeLive : API.leaveLive;
    HttpUtil.getInstance().postJson(url, params: {
      "liveId": AgoraUtil.liveId,
      "liveCode": AgoraUtil.liveCode,
    }).then(cb);
    AgoraUtil.liveTitle = "";
  }
}

class GiftTypeInfo {
  num id;
  String giftName;
  String giftType;
  num giftMoney;
  num giftNum;
  String giftImg;
  String giftGifImg;
  String remark;

  GiftTypeInfo(
    this.id,
    this.giftName,
    this.giftType,
    this.giftMoney,
    this.giftNum,
    this.giftImg,
    this.giftGifImg,
    this.remark
  );
}