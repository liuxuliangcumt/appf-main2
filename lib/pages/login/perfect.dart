/*
 * 未注册账号第一次登录后完善个人信息界面
 */
// @dart=2.9
import 'dart:io';

import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:dong_gan_dan_che/common/ImageUtil.dart';
import 'package:dong_gan_dan_che/common/PickerUtil.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DongGanDanChePerfectUserPage extends StatefulWidget {
  @override
  _DongGanDanChePerfectUserPageState createState() => _DongGanDanChePerfectUserPageState();
}

class _DongGanDanChePerfectUserPageState extends State<DongGanDanChePerfectUserPage> with SingleTickerProviderStateMixin  {
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerPwd = TextEditingController();
  TextEditingController controllerRe = TextEditingController();
  final FocusNode focusNodeName = FocusNode();
  final FocusNode focusNodePwd = FocusNode();
  final FocusNode focusNodeRe = FocusNode();
  static String strAvatarImagePath = "";
  bool mIsSave = false;
  int nUserType = 102;
  int nSex = 1;
  int nAge = 1;

  List<String> arrSex = [
    "未知", "男", "女",
  ];

  List<String> arrAge = ["0", "1"];

  @override
  void initState(){
    super.initState();
    mIsSave = false;
    controllerName.text = "";
    strAvatarImagePath = "";
    nUserType = 102;
    nSex = 1;
    arrAge = [];
    for(int i = 0; i < 120; i++) {
      arrAge.add("$i");
    }
    nAge = 18;
  }
  @override
  void dispose() {
    focusNodeName.dispose();
    focusNodePwd.dispose();
    focusNodeRe.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    BaseUtil.changeSystemBarColorType('dark');
    Widget avatar = GestureDetector(
      onTap: () {
        ImageUtil.showSelectPicker(context, (file) {
          setState((){
            strAvatarImagePath = file.path;
          });
        });
      },
      child:Container(
        height: BaseUtil.dp(120),
        width: BaseUtil.dp(120),
        padding: EdgeInsets.all(BaseUtil.dp(3)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(BaseUtil.dp(120)),
          border: Border.all(
            color: Color(0xFFDDDDDD),
            width: 1,
          ),
          color: Colors.white,
          boxShadow:  <BoxShadow>[
            BoxShadow(
              color: Color(0xFFAAAAAA),
              offset: Offset(0.0, 0.0),
              blurRadius: 3.0,
            ),
          ],
        ),
        child: strAvatarImagePath == null || strAvatarImagePath.length < 10
            ? Container(
          alignment: Alignment.center,
          child: Image.asset("assets/images/common/camera.png", fit: BoxFit.fill, width: BaseUtil.dp(80)),
        ) : ClipOval(
          child: Image.file(File(strAvatarImagePath), fit: BoxFit.cover,),
        ),
      )
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(BaseUtil.dp(16), BaseUtil.dp(30), BaseUtil.dp(16), BaseUtil.dp(10)),
        child: Column (
          children: [
            Container(
              child: Center(
                child: Text(
                  "完善个人信息",
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: BaseUtil.dp(16),
                  ),
                ),
              )
            ),
            Padding(padding: EdgeInsets.only(top: BaseUtil.dp(15))),
            Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: BaseUtil.dp(16)),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(top: BaseUtil.dp(30), bottom: BaseUtil.dp(15)),
                            color: Colors.white,
                            child: avatar
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(bottom: BaseUtil.dp(10)),
                          child: Text(
                            "请上传头像",
                            style: TextStyle(
                                fontSize: BaseUtil.dp(14),
                                color: Color(0xFF333333)
                            ),
                          ),
                        ),
                        Container(
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
                            margin: EdgeInsets.only(left: BaseUtil.dp(30), right: BaseUtil.dp(30)),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(right: BaseUtil.dp(10)),
                                  child: Text(
                                    "昵称",
                                    style: TextStyle(
                                        fontSize: BaseUtil.dp(16),
                                        color: Colors.black
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: TextField(
                                    focusNode: focusNodeName,
                                    controller: controllerName,
                                    keyboardType: TextInputType.text,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                        fontSize: BaseUtil.dp(16),
                                        color: Colors.black),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "请输入昵称",
                                      hintStyle: TextStyle(
                                        fontSize: BaseUtil.dp(16),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                        ),
                        Container(
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
                            margin: EdgeInsets.only(left: BaseUtil.dp(30), right: BaseUtil.dp(30)),
                            padding: EdgeInsets.only(bottom: BaseUtil.dp(10)),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(right: BaseUtil.dp(10)),
                                  child: Text(
                                    "类型",
                                    style: TextStyle(
                                        fontSize: BaseUtil.dp(16),
                                        color: Colors.black
                                    ),
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
                                )
                              ],
                            )
                        ),
                        Container(
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
                            margin: EdgeInsets.only(left: BaseUtil.dp(30), right: BaseUtil.dp(30)),
                            padding: EdgeInsets.only(bottom: BaseUtil.dp(10)),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(right: BaseUtil.dp(10)),
                                  child: Text(
                                    "性别",
                                    style: TextStyle(
                                        fontSize: BaseUtil.dp(16),
                                        color: Colors.black
                                    ),
                                  ),
                                ),
                                Expanded(
                                    flex: 1,
                                    child: GestureDetector(
                                      onTap: () {
                                        PickerUtil.showStringPicker(context, title: '请选择性别', normalIndex: nSex, data: arrSex, clickCallBack: (selectIndex, selectStr) {
                                          setState(() {
                                            nSex = selectIndex;
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
                                              arrSex[nSex],
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  color: Colors.black
                                              )
                                          ),
                                        ],
                                      ),
                                    )
                                )
                              ],
                            )
                        ),
                        Container(
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
                            margin: EdgeInsets.only(left: BaseUtil.dp(30), right: BaseUtil.dp(30)),
                            padding: EdgeInsets.only(bottom: BaseUtil.dp(10)),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(right: BaseUtil.dp(10)),
                                  child: Text(
                                    "年龄",
                                    style: TextStyle(
                                        fontSize: BaseUtil.dp(16),
                                        color: Colors.black
                                    ),
                                  ),
                                ),
                                Expanded(
                                    flex: 1,
                                    child: GestureDetector(
                                      onTap: () {
                                        PickerUtil.showStringPicker(context, title: '请选择年龄', normalIndex: nAge, data: arrAge, clickCallBack: (selectIndex, selectStr) {
                                          setState(() {
                                            nAge = selectIndex;
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
                                              arrAge[nAge],
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  color: Colors.black
                                              )
                                          ),
                                        ],
                                      ),
                                    )
                                )
                              ],
                            )
                        ),
                      ],
                    ),
                )
              )
            ),
            Padding(padding: EdgeInsets.only(top: BaseUtil.dp(10))),
            Container(
              margin: EdgeInsets.only(top: BaseUtil.dp(30)),
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
                      "立即体验",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: BaseUtil.dp(16),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                onPressed: () => _toggleButton(),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: BaseUtil.dp(10))),
          ],
        ),
      )
    );
  }

  void _toggleButton() {
    if (mIsSave) {
      return;
    }
    if (strAvatarImagePath.length < 10) {
      CustomSnackBar(context, Text("请选择头像"));
      return;
    }
    mIsSave = true;

    HttpUtil.getInstance().uploadFile(API.avatar, "avatarfile", strAvatarImagePath).then((response) {
      if (response == null) {
        mIsSave = false;
        CustomSnackBar(context, Text("上传失败"));
        return;
      }
      //先转json
      var json = jsonDecode(response.toString());
      if (json["code"] == null || json["code"] != 200) {
        CustomSnackBar(context, Text("上传失败"));
        return;
      }
      HttpUtil.getInstance().postJson(API.updateUserInfo, params: {
        'id': BaseUtil.gStUser['id'],
        'nickName': controllerName.text,
        "userType": nUserType,
        "sex": nSex,
        "age": nAge,
      }, hasToken: true).then((response) {
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
        HttpUtil.getInstance().getUserInfo(context);
      });
    });
  }

}
