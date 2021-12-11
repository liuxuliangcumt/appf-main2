/*
 * 登录界面
 */
// @dart=2.9
import 'dart:async';

import 'package:dong_gan_dan_che/common/PickerUtil.dart';
import 'package:dong_gan_dan_che/common/WxUtil.dart';
import 'package:dong_gan_dan_che/pages/login/signin/private.dart';
import 'package:dong_gan_dan_che/pages/login/signin/wx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:dong_gan_dan_che/common/HttpUtil.dart';

class SignIn extends StatefulWidget {
  final Function onAfterChangeLanguage;
  final PageController pageController;
  const SignIn({Key key, this.onAfterChangeLanguage, this.pageController}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController controllerPhone = TextEditingController(text: "");
  TextEditingController controllerPwd = TextEditingController(text: "");
  TextEditingController controllerCode = TextEditingController();
  bool usePwd = false;
  int nUserType = 102;

  final FocusNode focusNodePhone = FocusNode();
  final FocusNode focusNodePwd = FocusNode();
  final FocusNode focusNodeCode = FocusNode();
  bool mObscurePwd = true;

  Timer _timer;
  int _countdownTime = 0;

  String uuid = "";

  bool mConfigInited = false;

  bool mIsSave = false;

  Image codeImage = Image(
      width: BaseUtil.dp(100),
      fit: BoxFit.fill,
      image: AssetImage("assets/images/common/default.jpg")
  );

  void updateState() {
    setState(() {});
    this.widget.onAfterChangeLanguage();
  }
  @override
  void initState(){
    nUserType = 102;
    mIsSave = false;
    super.initState();
  }
  @override
  void dispose() {
    focusNodePhone.dispose();
    focusNodePwd.dispose();
    focusNodeCode.dispose();
    if (_timer != null) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    BaseUtil.changeSystemBarColorType('dark');
    List<Widget> arrWidget = [];
    arrWidget.add(Container (
      height: BaseUtil.dp(45),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                width: 1,
                color: Colors.grey[400],
              )
          )
      ),
      child: Padding(
        padding: EdgeInsets.only(left: BaseUtil.dp(0), right: BaseUtil.dp(0)),
        child: Row(
          children: <Widget>[
            Text(
              '账号类型',
              style: TextStyle(
                  fontSize: 17.0,
                color: Colors.black54
              ),
            ),
            Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    PickerUtil.showStringPicker(context, title: '请选择用户账号类型', normalIndex: nUserType - 101, data: gArrUserType, clickCallBack: (selectIndex, selectStr) {
                      setState(() {
                        nUserType = selectIndex + 101;
                      });
                    });
                  },
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(""),
                      ),
                      Text(
                        gMapUserType[nUserType],
                        style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.black
                        )
                      ),
                    ],
                  ),
                )
            ),
          ],
        ),
      ))
    );
    if (usePwd) {
      arrWidget.add(Container (
        alignment: Alignment.bottomLeft,
        height: BaseUtil.dp(55),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                  width: 1,
                  color: Colors.grey[400],
                )
            )
        ),
        child: TextField(
          focusNode: focusNodePhone,
          controller: controllerPhone,
          keyboardType: TextInputType.phone,
          style: TextStyle(
              fontSize: 16.0,
              color: Colors.black),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "输入手机号",
            hintStyle: TextStyle(fontSize: 17.0),
          ),
          onSubmitted: (_) {
            focusNodePwd.requestFocus();
          },
          textInputAction: TextInputAction.go,
        ),
      ));
      arrWidget.add(Container (
        alignment: Alignment.bottomLeft,
        height: BaseUtil.dp(55),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                  width: 1,
                  color: Colors.grey[400],
                )
            )
        ),
        child: TextField(
          focusNode: focusNodePwd,
          controller: controllerPwd,
          obscureText: mObscurePwd,
          keyboardType: TextInputType.text,
          style: TextStyle(
              fontSize: 16.0,
              color: Colors.black),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "输入密码",
            hintStyle: TextStyle(fontSize: 17.0),
            suffixIcon: GestureDetector(
              onTap: () {
                setState(() {
                  mObscurePwd = !mObscurePwd;
                });
              },
              child: Icon(
                mObscurePwd
                    ? FontAwesomeIcons.eyeSlash
                    : FontAwesomeIcons.eye,
                size: 15.0,
                color: Colors.black,
              ),
            ),
          ),
          onSubmitted: (_) {
            focusNodeCode.requestFocus();
          },
          textInputAction: TextInputAction.go,
        ),
      ));
//      arrWidget.add(Container (
//        alignment: Alignment.centerLeft,
//        child: Container(
//          width: BaseUtil.dp(BaseUtil.dessignWidth - 60),
//          height: 1.0,
//          color: Colors.grey[400],
//        ),
//      ));
//      arrWidget.add(Container (
//        alignment: Alignment.bottomLeft,
//        height: BaseUtil.dp(55),
//        child: Row(
//          children: [
//            Expanded(
//              flex: 1,
//              child: TextField(
//                focusNode: focusNodeCode,
//                controller: controllerCode,
//                keyboardType: TextInputType.number,
//                style: TextStyle(
//                    fontSize: 16.0,
//                    color: Colors.black),
//                decoration: InputDecoration(
//                  border: InputBorder.none,
//                  hintText: "请输入验证码",
//                  hintStyle: TextStyle(fontSize: 17.0),
//                ),
//                onSubmitted: (_) {
//                  _toggleSignInButton();
//                },
//                textInputAction: TextInputAction.go,
//              ),
//            ),
//            GestureDetector(
//              onTap: getCode,
//              child: this.codeImage,
//            )
//          ],
//        )
//      ));
    }
    else {
      arrWidget.add(Container (
          alignment: Alignment.bottomLeft,
          height: BaseUtil.dp(55),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                    width: 1,
                    color: Colors.grey[400],
                  )
              )
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: TextField(
                  focusNode: focusNodePhone,
                  controller: controllerPhone,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "输入手机号",
                    hintStyle: TextStyle(fontSize: 17.0),
                  ),
                  onSubmitted: (_) {
                    focusNodeCode.requestFocus();
                  },
                  textInputAction: TextInputAction.go,
                ),
              ),
              GestureDetector(
                onTap: () {
                  getPhoneCode();
                },
                child: Text(
                  _countdownTime > 0 ? ('${_countdownTime}S后重新获取') : '发送验证码',
                  style: TextStyle(
                    fontSize: 14,
                    color: _countdownTime > 0
                        ? Color.fromARGB(255, 183, 184, 195)
                        :  Color(0xFF01927C),
                  ),
                ),
              ),
            ],
          )
      ));
      arrWidget.add(Container (
          alignment: Alignment.bottomLeft,
          height: BaseUtil.dp(55),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                    width: 1,
                    color: Colors.grey[400],
                  )
              )
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: TextField(
                  focusNode: focusNodeCode,
                  controller: controllerCode,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "输入验证码",
                    hintStyle: TextStyle(fontSize: 17.0),
                  ),
                  onSubmitted: (_) {
                    _toggleSignInButton();
                  },
                  textInputAction: TextInputAction.go,
                ),
              ),
            ],
          )
      ));
    }
    arrWidget.add(Container (
      alignment: Alignment.bottomRight,
      height: BaseUtil.dp(40),
      child: GestureDetector(
        onTap: () {
          setState(() {
            usePwd = !usePwd;
          });
        },
        child: Text(
          usePwd ? "手机验证码登录" : "密码登录",
          style: TextStyle(
              color: Color(0xFF01927C),
              fontSize: BaseUtil.dp(14)),
        ),
      ),
    ));
    arrWidget.add(Container(
      margin: EdgeInsets.only(top: BaseUtil.dp(20)),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
          color: BaseUtil.gDefaultColor
      ),
      child: MaterialButton(
        highlightColor: Colors.transparent,
        splashColor: Color(0xFF00CCFF),
        //shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
        child: Container (
          height: BaseUtil.dp(40),
          child: Center(
            child: Text(
              "立即登录",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: BaseUtil.dp(22),
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        onPressed: () => _toggleSignInButton(),
      ),
    ));
    arrWidget.add(Expanded(
      flex: 1,
      child: Text(""),
    ));
    arrWidget.add(SignInWX(nUserType: nUserType, loginCallBack: loginCallBack));
    arrWidget.add(PrivateManager());
    arrWidget.add(Padding(
      padding: EdgeInsets.only(bottom: BaseUtil.dp(30)),
    ));

    return Container(
      padding: EdgeInsets.only(top: BaseUtil.dp(10)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: BaseUtil.dp(30), right: BaseUtil.dp(30)),
            child: Column(
                children: arrWidget
            ),
          ),
        ],
      ),
    );
  }

  void getCode() {
    HttpUtil.getInstance().get(API.captchaImage, hasToken: false).then((response) {
      if (response == null) {
        return;
      }
      var json = jsonDecode(response.toString());
      var strUrl = json["img"];
      this.codeImage = Image.memory(
        base64Decode(strUrl),
        width: BaseUtil.dp(100),
        height: BaseUtil.dp(38),
        fit: BoxFit.fill,    //填充
        gaplessPlayback:true,
      );
      setState(() {});
    });
  }

  void initConfig() {
    mConfigInited = false;
    HttpUtil.getInstance().postJson(API.getSystemConfigMap, hasToken: false).then((response) {
      if (response == null) {
        CustomSnackBar(context, Text("请输入手机号"));
        return;
      }
      var json = jsonDecode(response.toString());
      BaseUtil.gServerConfig = json["data"];
      WxUtil.getInstance().init();
    });
  }


  void _toggleSignInButton() {
    if (mIsSave) {
      return;
    }
    EasyLoading.show(status: '登录中...');
    mIsSave = true;
    Future.delayed(Duration(milliseconds: 10000),(){
      if (mIsSave) {
        mIsSave = false;
      }
    });
    // 测试跳转
    String strName = controllerPhone.value.text;
    String strPwd = controllerPwd.value.text;
    String strCode = controllerCode.value.text;

    if (strName.isEmpty) {
      EasyLoading.dismiss();
      CustomSnackBar(context, Text("请输入手机号"));
      return;
    }
    if (usePwd) {
      HttpUtil.getInstance().postJson(API.doLoginByPhonePassword, params: {
        'phone': strName,
        'password': strPwd,
        'userType': nUserType
      }, hasToken: false).then(loginCallBack);
    }
    else {
      HttpUtil.getInstance().postJson(API.doLoginByPhoneCode, params: {
        'phone': strName,
        'code': strCode,
        'userType': nUserType
      }, hasToken: false).then(loginCallBack);
    }
  }

  void getPhoneCode() {
    FocusScope.of(context).requestFocus(FocusNode());
    if (_countdownTime > 0 || controllerPhone.text.isEmpty) {
      CustomSnackBar(context, Text("请输入手机号后重试"));
      return;
    }
    if (!BaseUtil.isPhone(controllerPhone.text)) {
      CustomSnackBar(context, Text("请输入正确的手机号码格式"));
      return;
    }
    HttpUtil.getInstance().postJson(API.getPhoneCode, params: {
      "phone" : controllerPhone.text
    }, hasToken: false).then((response) {
      if (response == null) {
        CustomSnackBar(context, Text("发送失败"));
        return;
      }
      var json = jsonDecode(response.toString());
      if (json["success"] != true) {
        CustomSnackBar(context, Text(json["message"]));
        return;
      }
      this.uuid = json["uuid"];
      setState(() {
        _countdownTime = 60;
      });
      // 开始倒计时
      startCountdownTimer();
    });
  }

  void startCountdownTimer() {
    const oneSec = const Duration(seconds: 1);
    var callback = (timer) => {
      setState(() {
        if (_countdownTime < 1) {
          _timer.cancel();
        } else {
          _countdownTime = _countdownTime - 1;
        }
      })
    };
    _timer = Timer.periodic(oneSec, callback);
  }

  /// 登录会回调
  void loginCallBack(response) {
    EasyLoading.dismiss();
    mIsSave = false;
    if (response == null) {
      CustomSnackBar(context, Text("登录失败"));
      return;
    }
    var json = jsonDecode(response.toString());
    if (json["success"] != true) {
      CustomSnackBar(context, Text(json["message"]));
      //  getCode();
      return;
    }
    HttpUtil.getInstance().setToken(json["token"]);
    if (json["isNew"] != null && json["isNew"] == true) {
      Navigator.pushNamed(context, '/perfect');
      BaseUtil.gStUser = json["user"];
    } else {
      HttpUtil.getInstance().getUserInfo(context);
    }
  }
}
