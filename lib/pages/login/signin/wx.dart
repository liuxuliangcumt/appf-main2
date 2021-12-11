/*
 * 微信登录界面显示模块
 */
// @dart=2.9
import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:dong_gan_dan_che/common/WxUtil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignInWX extends StatelessWidget {

  final nUserType;
  final loginCallBack;

  const SignInWX({Key key, this.nUserType, this.loginCallBack }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          child: Text(
              "快速登录",
              style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: BaseUtil.dp(14)
              )
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: BaseUtil.dp(20)),
          child: Row(
            children: [
              Expanded(
                  flex: 1,
                  child: Text("")
              ),
              GestureDetector(
                onTap: () {
                  loginWX();
                },
                child: Icon(
                  FontAwesomeIcons.weixin,
                  color: Colors.black,
                  size: BaseUtil.dp(28.0),
                ),
              ),
//          Padding(padding: EdgeInsets.only(left: BaseUtil.dp(50))),
//          GestureDetector(
//            onTap: () {
//              this.widget.pageController.animateToPage(1,
//                  duration: const Duration(milliseconds: 500), curve: Curves.decelerate);
//            },
//            child: Icon(
//              FontAwesomeIcons.qq,
//              color: Colors.black,
//              size: BaseUtil.dp(28.0),
//            ),
//          ),
              Expanded(
                  flex: 1,
                  child: Text("")
              ),
            ],
          ),
        )
      ],
    );
  }

  ///微信登录
  void loginWX() {
    WxUtil.getInstance().setCbLogin((res) {
      if (res.code == null || res.code == "") {
        CustomSnackBar(BaseUtil.gNavigatorKey.currentContext, Text("登录失败"));
        return;
      }
      EasyLoading.show(status: '登录中...');
      HttpUtil.getInstance().postJson(API.doLoginByWX, params: {
        "code": res.code,
        'userType': nUserType
      }, hasToken: false).then(loginCallBack);
    });
    WxUtil.getInstance().login(() {
      CustomSnackBar(BaseUtil.gNavigatorKey.currentContext, Text("未检测到微信用户信息"));
    });
  }
}