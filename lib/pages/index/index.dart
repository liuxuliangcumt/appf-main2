/*
 * app主体界面，登录后的首页
 */
// @dart=2.9
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'live/index.dart';
import 'video/index.dart';
import 'device/index.dart';
import 'match/index.dart';
import 'admin/index.dart';

class DongGanDanCheIndexPage extends StatefulWidget {
  final arguments;
  DongGanDanCheIndexPage({Key key, this.arguments}) : super(key: key);

  @override
  _DongGanDanCheIndexPageState createState() => _DongGanDanCheIndexPageState();
}

class _DongGanDanCheIndexPageState extends State<DongGanDanCheIndexPage> {
  final _bottomNavList = ["直播", "点播", "设备", "比赛", "我的"]; // 底部导航
  final arrDefualtSwiper = [
    "https://www.reciprocalaffection.com/uploads/DongGanDanChe/banner/1.jpg",
    "https://www.reciprocalaffection.com/uploads/DongGanDanChe/banner/2.jpg"
  ];

  DateTime _lastCloseApp; //上次点击返回按钮时间
  int _currentIndex = 0;  // 底部导航当前页面
  ScrollController _scrollController = ScrollController();  // 首页整体滚动控制器
  PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.arguments;
    Future.delayed(Duration(milliseconds: 200),() async {
      _pageController.jumpToPage(_currentIndex);
      EventUtil.gEventBus.fire(SwitchIndexPageEvent(_currentIndex));
    });
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (BaseUtil.gOnBackspace != null) {
          BaseUtil.gOnBackspace();
          BaseUtil.gOnBackspace = null;
          return false;
        }
        if (_lastCloseApp == null || DateTime.now().difference(_lastCloseApp) > Duration(seconds: 1)) {
          _lastCloseApp = DateTime.now();
          Fluttertoast.showToast(msg: '再按一次退出动感单车');
          return false;
        }
        await HttpUtil.getInstance().clearToken();
        WebSocketUtil.exitSocket();
        return true;
      },
      child: Scaffold(
        // 底部导航栏
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: BaseUtil.gDefaultColor,
          unselectedItemColor: Color(0xff333333),
          selectedFontSize: BaseUtil.dp(12),
          unselectedFontSize: BaseUtil.dp(12),
          onTap: (index) {
            if (mounted)
            setState(() {
              _currentIndex = index;
            });
            _pageController.jumpToPage(index);
            Future.delayed(Duration(milliseconds: 100),() async {
              EasyLoading.dismiss();
              EventUtil.gEventBus.fire(SwitchIndexPageEvent(_currentIndex));
            });
          },
          items: [
            BottomNavigationBarItem(
                label: _bottomNavList[0],
                icon: _currentIndex == 0
                    ? _bottomIcon('assets/images/nav/index-sel.png')
                    : _bottomIcon('assets/images/nav/index.png')),
            BottomNavigationBarItem(
                label: _bottomNavList[1],
                icon: _currentIndex == 1
                    ? _bottomIcon('assets/images/nav/video-sel.png')
                    : _bottomIcon('assets/images/nav/video.png')),
            BottomNavigationBarItem(
                label: _bottomNavList[2],
                icon: _currentIndex == 2
                    ? _bottomIcon('assets/images/nav/match-sel.png')
                    : _bottomIcon('assets/images/nav/match.png')),
            BottomNavigationBarItem(
                label: _bottomNavList[3],
                icon: _currentIndex == 3
                    ? _bottomIcon('assets/images/nav/device-sel.png')
                    : _bottomIcon('assets/images/nav/device.png')),
            BottomNavigationBarItem(
                label: _bottomNavList[4],
                icon: _currentIndex == 4
                    ? _bottomIcon('assets/images/nav/admin-sel.png')
                    : _bottomIcon('assets/images/nav/admin.png')),
          ]
        ),
        body: GestureDetector(
          onTap: () {
            // 触摸收起键盘
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: _currentPage(),
        ),
//        floatingActionButton: btnFloat,
        resizeToAvoidBottomInset: false,
      ),
    );
  }

  // 底部导航对应的页面
  Widget _currentPage() {
    var _pages = [
      LiveIndexPage(_scrollController),
      VideoIndexPage(_scrollController),
      DevicePage(),
      MatchIndexPage(_scrollController),
      AdminPage(),
    ];

    return PageView.builder(
      physics: NeverScrollableScrollPhysics(),
      controller: _pageController,
      itemCount: _pages.length,
      itemBuilder: (context,index)=>_pages[index]
    );
  }

  Widget _bottomIcon(path) {
    return Padding(
      padding: EdgeInsets.only(bottom: BaseUtil.dp(4)),
      child: Image.asset(
        path,
        width: BaseUtil.dp(25),
        height: BaseUtil.dp(25),
        repeat:ImageRepeat.noRepeat,
        fit: BoxFit.contain,
        alignment: Alignment.center,
      )
    );
  }
}
