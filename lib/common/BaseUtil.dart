// @dart=2.9
library base;

/*
 * @discripe: 全局公共类管理
 */
import 'dart:ui';

import 'package:flutter/services.dart';
import "package:intl/intl.dart";
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

export 'rx.dart';
export 'HttpUtil.dart';
export 'WebSocketUtil.dart';
export 'LocalUtil.dart';
export 'EventUtil.dart';
export 'AgoraUtil.dart';
export 'dart:convert';
export 'package:dong_gan_dan_che/pages/common/snackbar.dart';

class UserInfo {
  num userId;
  int userType;
  String userName;
  String nickName;
  String realName;
  String phone;
  String email;
  String qq;
  String wechat;
  String idCard;
  String avatar;
  String remark;
  int fansNum;
  int followNum;
  int amount;
  int exerciseDays;
  int exerciseTime;
  int exerciseCount;
  String mac;
  double drag;
  double speend;

  UserInfo(
      {this.userId,
      this.userType,
      this.userName,
      this.nickName,
      this.realName,
      this.phone,
      this.email,
      this.qq,
      this.wechat,
      this.idCard,
      this.avatar,
      this.remark,
      this.fansNum,
      this.followNum,
      this.amount,
      this.exerciseDays,
      this.exerciseTime,
      this.exerciseCount,
      this.mac,
      this.drag,
      this.speend});
}

// 所有Widget继承的抽象类
abstract class BaseUtil {
  static final GlobalKey<NavigatorState> gNavigatorKey =
      new GlobalKey<NavigatorState>();
  // 阅读并同意用户协议和隐私政策
  static bool gCheckPrivacy = false;
  // 全局处理返回按键的功能, 接收到处理之后就清空
  static Function gOnBackspace;

  static String gBaseSchema = 'http';
  // 发布路径
  //   http://zykj.vaiwan.com
  //   app2.cylon.top
  static String gBaseHost = 'app2.cylon.top';
  // http://wps-demo.vaiwan.com
//  static String gBaseHost = 'wps-demo.vaiwan.com';

  //app2.cylon.top
  static String gBasePort = '8082';
//  本地开发测试路径
//   static String gBaseHost = '192.168.2.4';
//   static String gBasePort = '8082';
  static String gBaseUrl =
      '${BaseUtil.gBaseSchema}://${BaseUtil.gBaseHost}:${BaseUtil.gBasePort}';

  //  static String gBaseUrl = '${BaseUtil.gBaseSchema}://${BaseUtil.gBaseHost}';
  // 默认主题色
  static final gDefaultColor = Color(0xFF42D3AD);
  // 初始化设计稿尺寸
  static final double gDesignWidth = 375.0;
  static final double gDesignHeight = 1335.0;

  static final double gStatusBarHeight =
      MediaQueryData.fromWindow(window).padding.top;

  /// 当前登录用户账号信息
  static Map<String, dynamic> gStUser = new Map<String, dynamic>();

  /// 当前用户使用的设备记录信息
  static Map<String, dynamic> gStBicycleLog = new Map<String, dynamic>();

  /// 服务器端的配置信息
  static Map<String, dynamic> gServerConfig = new Map<String, dynamic>();

  static List<String> gArrFollow = [
    '刘备',
    '关羽',
    '张飞',
    '赵云',
    '黄忠',
    '马超',
    '诸葛亮',
    '曹操',
    '孙权',
    '董卓',
    '吕布'
  ];
  static String gDefaultAvatar =
      "https://www.reciprocalaffection.com/uploads/DongGanDanChe/default.jpg";
  static String gDefaultImage =
      "https://www.reciprocalaffection.com/uploads/DongGanDanChe/default.jpg";

  static NumberFormat gNumberFormat3 = new NumberFormat("0.000");
  static NumberFormat gNumberFormat2 = new NumberFormat("0.00");
  static NumberFormat gNumberFormat1 = new NumberFormat("0.0");
  static NumberFormat gNumberFormat = new NumberFormat("0");
  //////////////////////////////////////////////////////////////////////////////
  // 公共接口
  // flutter_screenutil px转dp
  static double dp(double dessignValue) => ScreenUtil().setWidth(dessignValue);

  // 设置后台通信URL地址
  static void setBaseUrl(schema, host, port) {
    gBaseSchema = schema;
    gBaseHost = host;
    gBasePort = port;
    gBaseUrl = '${BaseUtil.gBaseSchema}://${BaseUtil.gBaseHost}';
    if (port != null && port.length > 1) {
      gBaseUrl = gBaseUrl + ':${BaseUtil.gBasePort}';
    }
  }

  /// System overlays should be drawn with a light color. Intended for
  /// applications with a dark background.
  static const SystemUiOverlayStyle lightSystemUiOverlayStyle =
      SystemUiOverlayStyle(
    systemNavigationBarColor: Color(0xFF000000),
    systemNavigationBarDividerColor: Colors.transparent,
    statusBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );

  /// System overlays should be drawn with a dark color. Intended for
  /// applications with a light background.
  static const SystemUiOverlayStyle darkSystemUiOverlayStyle =
      SystemUiOverlayStyle(
    systemNavigationBarColor: Color(0xFF000000),
    systemNavigationBarDividerColor: Colors.transparent,
    statusBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  );

  /// 设置顶部系统栏颜色类型: light, dark
  static void changeSystemBarColorType(String clrType) {
    if (clrType == "light") {
      SystemChrome.setSystemUIOverlayStyle(lightSystemUiOverlayStyle);
    } else {
      SystemChrome.setSystemUIOverlayStyle(darkSystemUiOverlayStyle);
    }
  }

  /// 检查是否是邮箱格式
  static bool isEmail(String input) {
    if (input == null || input.isEmpty) return false;

    /// 邮箱正则
    final String regexEmail =
        "^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*\$";
    return new RegExp(regexEmail).hasMatch(input);
  }

  ///大陆手机号码11位数，匹配格式：前三位固定格式+后8位任意数
  static bool isPhone(String input) {
    if (input == null || input.isEmpty) return false;

    /// 手机正则
    return new RegExp(
            r'^((13[0-9])|(14[0-9])|(15[0-9])|(16[0-9])|(17[0-9])|(18[0-9])|(19[0-9]))\d{8}$')
        .hasMatch(input);
  }

  static String formatTime(timeCount) {
    if (timeCount == null) {
      return "00:00";
    }
    var ret = "";
    var s = int.parse(timeCount.toString());
    var h = (s / 3600).floor();
    var m = (s % 3600 / 60).floor();
    s = s % 60;
    if (h > 0) {
      ret = ret + (h > 9 ? "$h:" : "0$h:");
    }
    ret = ret + (m > 9 ? "$m:" : "0$m:");
    ret = ret + (s > 9 ? "$s" : "0$s");
    return ret;
  }

  static var gArrArtWordColor = [
    {
      "text": Color(0xFFFFF700),
      "shadowLeftTop": Color(0xFFFF7800),
      "shadowRightBottom": Color(0xAAFF0000),
    },
    {
      "text": Color(0xFFe54d42),
      "shadowLeftTop": Color(0xFF9c26b0),
      "shadowRightBottom": Color(0xAA6739b6),
    },
    {
      "text": Color(0xFFf37b1d),
      "shadowLeftTop": Color(0xFF9c26b0),
      "shadowRightBottom": Color(0xAA6739b6),
    },
    {
      "text": Color(0xFFfbbd08),
      "shadowLeftTop": Color(0xFF9c26b0),
      "shadowRightBottom": Color(0xAA6739b6),
    },
    {
      "text": Color(0xFFa5673f),
      "shadowLeftTop": Color(0xFF9c26b0),
      "shadowRightBottom": Color(0xAA6739b6),
    },
  ];
}

Map<int, String> gMapUserType = {
  101: "教练",
  102: "学员",
  103: "准学员",
};

List<String> gArrUserType = [
  "教练",
  "学员",
  "准学员",
];

/// 比赛类型
List<String> gArrMatchType = ["固定时间竞速赛", "固定里程竞速赛"];

/// 参数人数类型
List<String> gArrMatchPeopleType = [
  "两人赛",
  "三人赛",
  "六人赛",
  "多人赛",
];
