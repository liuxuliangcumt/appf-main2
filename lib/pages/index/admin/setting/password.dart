/*
 * 修改密码
 */
// @dart=2.9
import 'dart:ui';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:dong_gan_dan_che/pages/index/admin/header.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdminSettingPasswordPage extends StatefulWidget {
  final Function onSwitchParentType;       /// 切换上级状态
  AdminSettingPasswordPage({ @required this.onSwitchParentType });
  
  @override
  _AdminSettingPasswordPage createState() => _AdminSettingPasswordPage();
}

class _AdminSettingPasswordPage extends State<AdminSettingPasswordPage> {
  TextEditingController controllerPhone = TextEditingController();
  TextEditingController controllerCode = TextEditingController();
  TextEditingController controllerPwd = TextEditingController();
  TextEditingController controllerRePwd = TextEditingController();
  final FocusNode focusNodePhone = FocusNode();
  final FocusNode focusNodeCode = FocusNode();
  final FocusNode focusNodePwd = FocusNode();
  final FocusNode focusNodeRePwd = FocusNode();

  bool mObscurePwd = true;
  bool mObscureRePwd = true;

  Timer _timer;
  int _countdownTime = 0;

  String uuid = "";

  bool mIsSave = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    focusNodePhone.dispose();
    focusNodeCode.dispose();
    focusNodePwd.dispose();
    focusNodeRePwd.dispose();
    if (_timer != null) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
      child: Column(
        children: [
          AdminHeaderPage(title: "修改密码", onBack: () { widget.onSwitchParentType(100); }),
          Padding(padding: EdgeInsets.only(top: BaseUtil.dp(5))),
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: BaseUtil.dp(18)),
                    height: BaseUtil.dp(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: BaseUtil.dp(20), right: BaseUtil.dp(20)),
                      child: Stack(
                        children: <Widget>[
                          Container(
//                        color: Colors.blue,
                            child: TextField(
                              controller: controllerPhone,
                              cursorColor: BaseUtil.gDefaultColor,
                              keyboardType: TextInputType.phone,
                              cursorWidth: 1.5,
                              style: TextStyle(
                                color: Color(0xff333333),
                                fontSize: 14.0,
                              ),
                              decoration: InputDecoration(
                                /// 设置输入框高度
                                isCollapsed: true,
                                contentPadding: EdgeInsets.only(right: BaseUtil.dp(80), top: BaseUtil.dp(6), bottom: BaseUtil.dp(6)),
                                hintText: '输入手机号',
                              ),
                              onSubmitted: (_) {
                                focusNodeCode.requestFocus();
                              },
                            ),
                          ),
                          Container(
                            alignment: Alignment.bottomRight,
                            padding: EdgeInsets.only(bottom: BaseUtil.dp(14)),
                            child: GestureDetector(
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
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: BaseUtil.dp(18)),
                    height: BaseUtil.dp(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: BaseUtil.dp(20), right: BaseUtil.dp(20)),
                      child: Stack(
                        children: <Widget>[
                          Container(
//                        color: Colors.blue,
                            child: TextField(
                              controller: controllerCode,
                              cursorColor: BaseUtil.gDefaultColor,
                              cursorWidth: 1.5,
                              style: TextStyle(
                                color: Color(0xff333333),
                                fontSize: 14.0,
                              ),
                              decoration: InputDecoration(
                                /// 设置输入框高度
                                isCollapsed: true,
                                contentPadding: EdgeInsets.only(top: BaseUtil.dp(6), bottom: BaseUtil.dp(6)),
                                hintText: '输入验证码',
                              ),
                              onSubmitted: (_) {
                                focusNodePwd.requestFocus();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: BaseUtil.dp(18)),
                    height: BaseUtil.dp(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: BaseUtil.dp(20), right: BaseUtil.dp(20)),
                      child: Stack(
                        children: <Widget>[
                          Container(
//                        color: Colors.blue,
                            child: TextField(
                              controller: controllerPwd,
                              cursorColor: BaseUtil.gDefaultColor,
                              obscureText: mObscurePwd,
                              cursorWidth: 1.5,
                              style: TextStyle(
                                color: Color(0xff333333),
                                fontSize: 14.0,
                              ),
                              decoration: InputDecoration(
                                /// 设置输入框高度
                                isCollapsed: true,
                                contentPadding: EdgeInsets.only(top: BaseUtil.dp(6), bottom: BaseUtil.dp(6)),
                                hintText: '输入密码',
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
                                focusNodePwd.requestFocus();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: BaseUtil.dp(18)),
                    height: BaseUtil.dp(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: BaseUtil.dp(20), right: BaseUtil.dp(20)),
                      child: Stack(
                        children: <Widget>[
                          Container(
//                        color: Colors.blue,
                            child: TextField(
                              controller: controllerRePwd,
                              cursorColor: BaseUtil.gDefaultColor,
                              obscureText: mObscureRePwd,
                              cursorWidth: 1.5,
                              style: TextStyle(
                                color: Color(0xff333333),
                                fontSize: 14.0,
                              ),
                              decoration: InputDecoration(
                                /// 设置输入框高度
                                isCollapsed: true,
                                contentPadding: EdgeInsets.only(top: BaseUtil.dp(6), bottom: BaseUtil.dp(6)),
                                hintText: '确认密码',
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      mObscureRePwd = !mObscureRePwd;
                                    });
                                  },
                                  child: Icon(
                                    mObscureRePwd
                                        ? FontAwesomeIcons.eyeSlash
                                        : FontAwesomeIcons.eye,
                                    size: 15.0,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              onSubmitted: (_) {
                                save();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ),
          Padding(padding: EdgeInsets.only(top: BaseUtil.dp(10)),),
          Container(
            padding: EdgeInsets.only(left: BaseUtil.dp(20), right: BaseUtil.dp(20)),
            child: RawMaterialButton (
              constraints: BoxConstraints(minHeight: BaseUtil.dp(46)),
              fillColor: BaseUtil.gDefaultColor,
              elevation: 0,
              highlightElevation: 0,
              highlightColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(23)),
              ),
              onPressed: () {
                save();
              },
              child: Center(
                child: Text('提交',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: BaseUtil.dp(10)),),
        ],
      ),
    );
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
    HttpUtil.getInstance().postJson(API.getResetPwdCode, params: {
      "phone" : controllerPhone.text
    }).then((response) {
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

  void save() {
    if (controllerPhone.text == null || controllerPhone.text.length == 0) {
      CustomSnackBar(context, Text("手机号不能为空"));
      return;
    }
    if (controllerCode.text == null || controllerCode.text.length == 0) {
      CustomSnackBar(context, Text("验证码不能为空"));
      return;
    }
    if (controllerPwd.text == null || controllerPwd.text.length == 0
    || controllerRePwd.text == null || controllerRePwd.text.length == 0) {
      CustomSnackBar(context, Text("密码不能为空"));
      return;
    }
    if (controllerPwd.text != controllerRePwd.text) {
      CustomSnackBar(context, Text("两次密码不一致"));
      return;
    }
    HttpUtil.getInstance().postJson(API.updateAppPwd, params: {
      "id": BaseUtil.gStUser["id"],
      "phone": controllerPhone.text,
      "code": controllerCode.text,
      "password": controllerPwd.text,
    }).then((response) {
      if (response == null) {
        CustomSnackBar(context, Text("保存失败"));
        return;
      }
      //先转json
      var json = jsonDecode(response.toString());
      if (json["success"] == null || json["success"] != true) {
        CustomSnackBar(context, Text("保存失败"));
        return;
      }
      widget.onSwitchParentType(100);
    });
  }
}