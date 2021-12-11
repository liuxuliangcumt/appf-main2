/*
 * 登录界面入口，包含判断登录状态和切换服务器配置信息
 */
// @dart=2.9
import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:dong_gan_dan_che/common/HttpUtil.dart';
import 'package:dong_gan_dan_che/pages/common/dlgServer.dart';
import 'package:dong_gan_dan_che/pages/login/signin/index.dart';

import 'package:flutter/material.dart';

class DongGanDancLoginPage extends StatefulWidget {
  @override
  _DongGanDancLoginPageState createState() => _DongGanDancLoginPageState();
}

class _DongGanDancLoginPageState extends State<DongGanDancLoginPage>
    with SingleTickerProviderStateMixin {
  PageController controllerPage;

  Color left = Colors.black;
  Color right = Colors.white;

  void updateState() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _checkLogin();
    controllerPage = PageController();
  }

  @override
  void dispose() {
    controllerPage?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: BaseUtil.dp(60)),
                color: Colors.white,
                child: GestureDetector(
                  onDoubleTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return DlgServer();
                      }
                    );
                  },
                  child: Image(
                      width: BaseUtil.dp(93),
                      fit: BoxFit.fill,
                      image: const AssetImage('assets/images/login/logo.png')),
                ),
              ),
              Expanded(
                flex: 2,
                child: PageView(
                  controller: controllerPage,
                  physics: const ClampingScrollPhysics(),
                  onPageChanged: (int i) {
                    FocusScope.of(context).requestFocus(FocusNode());
                    if (i == 0) {
                      setState(() {
                        right = Colors.white;
                        left = Colors.black;
                      });
                    } else if (i == 1) {
                      setState(() {
                        right = Colors.black;
                        left = Colors.white;
                      });
                    }
                  },
                  children: <Widget>[
                    ConstrainedBox(
                      constraints: BoxConstraints.expand(),
                      child: SignIn(
                        onAfterChangeLanguage: updateState,
                        pageController: this.controllerPage,
                      ),
                    ),
//                        ConstrainedBox(
//                          constraints: const BoxConstraints.expand(),
//                          child: SignUp(
//                              pageController: this._pageController
//                          ),
//                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  void _checkLogin() async {
    await HttpUtil.getInstance().reloadToken();
    if (HttpUtil.getInstance().mToken == null ||
        HttpUtil.getInstance().mToken.length > 0) {
      HttpUtil.getInstance().getUserInfo(context);
    }
  }

}
