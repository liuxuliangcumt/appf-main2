/*
 * 微信交互封装
 */

//@dart=2.9
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluwx/fluwx.dart' as fluwx;

import 'AgoraUtil.dart';
import 'BaseUtil.dart';
import 'HttpUtil.dart';

class WxUtil {
  StreamSubscription streamSubscription;
  Function cbLogin;
  Function cbPay;
  Function cbShare;

  bool bIniting = false;
  bool bInitRet = false;

  dynamic lastShare = {};

  static WxUtil mInstance;

  static WxUtil getInstance() {
    if (null == mInstance) {
      mInstance = WxUtil();
      mInstance.setCbLogin(mInstance.defaultCbLogin);
      mInstance.setCbPay(mInstance.defaultCbPay);
      mInstance.setCbShare(mInstance.defaultCbShare);
      mInstance.bIniting = false;
      mInstance.bInitRet = false;
    }
    return mInstance;
  }

  Future<int> init() async {
    /// 正在初始化, 跳过
    if (bIniting) {
      return 1;
    }
    /// 如果已经初始化成功了, 直接返回
    if(bInitRet) {
      return 0;
    }
    var appId = BaseUtil.gServerConfig["wxAppId"];
    var wxAppleUL = BaseUtil.gServerConfig["wxAppleUniversalLink"];
    if (appId == null || appId.length < 1 || wxAppleUL == null || wxAppleUL.length < 1) {
      CustomSnackBar(BaseUtil.gNavigatorKey.currentContext, Text("未加载到配置信息, 无法启动微信"));
      return -1;  /// 配置信息为空
    }
    bIniting = true;
    bInitRet = false;
    try {
      await fluwx.registerWxApi(
          appId: appId,
          doOnAndroid: true,
          doOnIOS: true,
          universalLink: wxAppleUL
      );
      var result = await fluwx.isWeChatInstalled;
      print("is installed $result");
      bIniting = false;
      bInitRet = result;
      if (bInitRet) {
        startListen();
        return 0;
      } else {
        CustomSnackBar(BaseUtil.gNavigatorKey.currentContext, Text("微信环境未能顺利初始化"));
        return -3;
      }
    } catch (e) {
      bIniting = false;
      bInitRet = false;
      CustomSnackBar(BaseUtil.gNavigatorKey.currentContext, Text("启动微信发生异常错误"));
      return -2;  /// 初始化报错了
    }
  }

  void exit() {
    stopListen();
  }

  void startListen() {
    if (streamSubscription != null) {
      stopListen();
    }
    streamSubscription = fluwx.weChatResponseEventHandler.distinct((a, b) => a == b).listen((res) {
      if (res is fluwx.WeChatAuthResponse) {
        print("微信登录：" + res.toString());
        if (cbLogin != null) {
          cbLogin(res);
        }
      }
      else if (res is fluwx.WeChatPaymentResponse ) {
        print("微信支付：" + res.toString());
        if (cbPay != null) {
          cbPay(res);
        }
      }
      else if (res is fluwx.WeChatShareResponse ) {
        print("微信分享：" + res.toString());
        if (cbShare != null) {
          cbShare(res);
        }
      }
    });
  }

  void stopListen() {
    if (streamSubscription != null) {
      streamSubscription.cancel();
      streamSubscription = null;
    }
  }

  void setCbLogin(cb) {
    cbLogin = cb;
  }
  void setCbPay(cb) {
    cbPay = cb;
  }
  void setCbShare(cb) {
    cbShare = cb;
  }

  Future<int> login(errorCb) async {
    int ret = await mInstance.init();
    if (ret != 0) {
      return ret;
    }
    print("准备微信登录");
    fluwx.sendWeChatAuth(scope: "snsapi_userinfo", state: "wechat_sdk_demo_test").then((data) {
      if (data == null) {
        errorCb();
      }
      print("拉取微信用户信息：" + data.toString());
    }).catchError((e) {
      print('weChatLogin  e  $e');
    });
    return ret;
  }

  Future<int> payWithWeChat(appId, partnerId, prePayId, package, nonceStr, timeStamp, strSign, cb) async {
    int ret = await mInstance.init();
    if (ret != 0) {
      return ret;
    }
    print("准备微信登录");
    fluwx.payWithWeChat(
        appId: appId,
        partnerId: partnerId,
        prepayId: prePayId,
        packageValue: package,
        nonceStr: nonceStr,
        timeStamp: timeStamp,
        sign: strSign
    ).then((res) {
      cb(res);
    });
    return ret;
  }

  Future<int> shareLive() async {
    int ret = await mInstance.init();
    if (ret != 0) {
      return ret;
    }
    var strCover = AgoraUtil.liveInfo['liveCoverImage'] == null ? BaseUtil.gDefaultImage : BaseUtil.gBaseUrl + AgoraUtil.liveInfo['liveCoverImage'];
    lastShare["userId"] = BaseUtil.gStUser["id"];
    lastShare["source"] = 1;
    lastShare["contentId"] = AgoraUtil.liveInfo['liveId'];
    var model = fluwx.WeChatShareWebPageModel(
      "${BaseUtil.gBaseUrl}/app/openShare?userid=${BaseUtil.gStUser["id"]}&source=0&contentid=${AgoraUtil.liveInfo['liveId']}",
      // "${BaseUtil.gServerConfig["wxAppDownLoadUrl"]}?userid=${BaseUtil.gStUser["id"]}&source=0&contentid=${AgoraUtil.liveInfo['liveId']}",
      title: "动感单车直播间",
      thumbnail: fluwx.WeChatImage.network(strCover),
      scene: fluwx.WeChatScene.SESSION,
      description: AgoraUtil.liveTitle
    );
    fluwx.shareToWeChat(model);
    return ret;
  }

  Future<int> shareVideo(video) async {
    int ret = await mInstance.init();
    if (ret != 0) {
      return ret;
    }
    var strCover = video['videoCover'] == null ? BaseUtil.gDefaultImage : BaseUtil.gBaseUrl + video['videoCover'];
    lastShare["userId"] = BaseUtil.gStUser["id"];
    lastShare["source"] = 1;
    lastShare["contentId"] = video['videoId'];
    var model = fluwx.WeChatShareWebPageModel(
      "${BaseUtil.gBaseUrl}/app/openShare?userid=${BaseUtil.gStUser["id"]}&source=1&contentid=${video['videoId']}",
      // "${BaseUtil.gServerConfig["wxAppDownLoadUrl"]}?userid=${BaseUtil.gStUser["id"]}&source=1&contentid=${video['videoId']}",
      title: "动感单车视频点播",
      thumbnail: fluwx.WeChatImage.network(strCover),
      scene: fluwx.WeChatScene.SESSION,
      description: video["videoName"]
    );
    fluwx.shareToWeChat(model);
    return ret;
  }

  Future<int> shareMatch(match) async {
    int ret = await mInstance.init();
    if (ret != 0) {
      return ret;
    }
    var strCover = match['image'] == null ? BaseUtil.gDefaultImage : BaseUtil.gBaseUrl + match['image'];
    lastShare["userId"] = BaseUtil.gStUser["id"];
    lastShare["source"] = 1;
    lastShare["contentId"] = match['image'];
    var model = fluwx.WeChatShareWebPageModel(
      "${BaseUtil.gBaseUrl}/app/openShare?userid=${BaseUtil.gStUser["id"]}&source=2&contentid=${match['videoId']}",
        //"${BaseUtil.gServerConfig["wxAppDownLoadUrl"]}?userid=${BaseUtil.gStUser["id"]}&source=2&contentid=${match['id']}",
        title: "动感单车比赛",
        thumbnail: fluwx.WeChatImage.network(strCover),
        scene: fluwx.WeChatScene.SESSION,
        description: match["name"]
    );
    fluwx.shareToWeChat(model);
    return ret;
  }

  void defaultCbLogin(res) {
    CustomSnackBar(BaseUtil.gNavigatorKey.currentContext, Text(res.errStr));
  }

  void defaultCbPay(res) {
    CustomSnackBar(BaseUtil.gNavigatorKey.currentContext, Text(res.errStr));
  }

  void defaultCbShare(res) {
    HttpUtil.getInstance().postJson(API.shareToWX, params: {
      "userId": lastShare["userId"],
      "source": lastShare["source"],
      "contentId": lastShare["contentId"],
    });
  }

}