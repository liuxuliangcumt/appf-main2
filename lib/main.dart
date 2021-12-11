/*
 * @discripe: 程序入口
 */

// @dart=2.9
import 'package:dong_gan_dan_che/common/WxUtil.dart';
import 'package:dong_gan_dan_che/pages/MqttTest.dart';
import 'package:dong_gan_dan_che/pages/agora/live.dart';
import 'package:dong_gan_dan_che/pages/agora/close.dart';
import 'package:dong_gan_dan_che/pages/index/match/prepare_match.dart';
import 'package:dong_gan_dan_che/pages/index/match/result.dart';
import 'package:dong_gan_dan_che/pages/index/match/room.dart';
import 'package:dong_gan_dan_che/pages/login/privacy.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:wakelock/wakelock.dart';

import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:dong_gan_dan_che/common/BleUtil.dart';
import 'package:dong_gan_dan_che/pages/index/index.dart';
import 'package:dong_gan_dan_che/pages/login/login.dart';
import 'package:dong_gan_dan_che/pages/login/perfect.dart';
import 'package:dong_gan_dan_che/pages/index/video/play.dart';
import 'package:dong_gan_dan_che/pages/index/admin/recharge.dart';
import 'package:dong_gan_dan_che/pages/index/match/editInfo.dart';
import 'package:dong_gan_dan_che/pages/index/match/detail.dart';

class DongGanDanCheApp extends StatefulWidget {
  const DongGanDanCheApp({Key key}) : super(key: key);

  @override
  _DongGanDanCheAppState createState() => _DongGanDanCheAppState();
}

class _DongGanDanCheAppState extends State<DongGanDanCheApp> {
  // 路由路径匹配
  Route<dynamic> buildRoute(RouteSettings settings) {
    Map<String, WidgetBuilder> routes = {
      '/': (BuildContext context) => DongGanDancLoginPage(),
      '/privacy': (BuildContext context) => PrivacyPage(),
      '/perfect': (BuildContext context) => DongGanDanChePerfectUserPage(),
      '/AgoraLive': (BuildContext context) =>
          AgoraLivePage(arguments: settings.arguments),
      '/PlayVideo': (BuildContext context) =>
          PlayVideoPage(arguments: settings.arguments),
      '/liveClose': (BuildContext context) => DongGanDanCheLiveClose(),
      '/index': (BuildContext context) =>
          DongGanDanCheIndexPage(arguments: settings.arguments),
      '/match/edit': (BuildContext context) =>
          DongGanDanCheMatchEditInfo(arguments: settings.arguments),
      '/match/detail': (BuildContext context) =>
          DongGanDanCheMatchDetailPage(arguments: settings.arguments),
      '/match/room': (BuildContext context) =>
          DongGanDanCheMatchRoomPage(arguments: settings.arguments),
      '/match/result': (BuildContext context) =>
          DongGanDanCheMatchResultPage(arguments: settings.arguments),
      '/recharge': (BuildContext context) =>
          DongGanDanCheRechargePage(arguments: settings.arguments),
      '/match/prepare_match': (BuildContext context) =>
          PrepareMatch(arguments: settings.arguments),
      '/mqttPage': (BuildContext context) => MqttPage(),
    };
    var widget = routes[settings.name];

    if (widget != null) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: widget,
      );
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
  }

  @override
  void dispose() {
    Wakelock.disable();
    super.dispose();
    WebSocketUtil.exitSocket();
    BleUtil.exitBle();
    WxUtil.getInstance().exit();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // 填入设计稿中设备的屏幕尺寸,单位dp
    return ScreenUtilInit(
        designSize: Size(BaseUtil.gDesignWidth, BaseUtil.gDesignHeight),
        builder: () => MaterialApp(
              navigatorKey: BaseUtil.gNavigatorKey,
              debugShowCheckedModeBanner: false,
              title: '动感单车',
              theme: ThemeData(
                  // This is the theme of your application.
                  //
                  // Try running your application with "flutter run". You'll see the
                  // application has a blue toolbar. Then, without quitting the app, try
                  // changing the primarySwatch below to Colors.green and then invoke
                  // "hot reload" (press "r" in the console where you ran "flutter run",
                  // or simply save your changes to "hot reload" in a Flutter IDE).
                  // Notice that the counter didn't reset back to zero; the application
                  // is not restarted.
                  primarySwatch: Colors.green,
                  //要支持下面这个需要使用第一种初始化方式
                  textTheme: TextTheme(button: TextStyle(fontSize: 45.sp)),
                  appBarTheme: AppBarTheme(
                    textTheme: TextTheme(
                      headline6: TextStyle(
                        color: Colors.black,
                        fontSize: BaseUtil.dp(18),
                      ),
                      bodyText1: TextStyle(color: Colors.black),
                    ),
                  )),
              onGenerateRoute: buildRoute,
              builder: EasyLoading.init(),
            ));
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 强制竖屏
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(DongGanDanCheApp());
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent));
}
