/*
 * 个人资料修改
 */
// @dart=2.9
import 'dart:ui';
import 'package:dong_gan_dan_che/common/PickerUtil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:dong_gan_dan_che/pages/index/admin/header.dart';

class AdminSettingInfoPage extends StatefulWidget {
  final Function onSwitchParentType;       /// 切换上级状态
  AdminSettingInfoPage({ @required this.onSwitchParentType });
  
  @override
  _AdminSettingInfoPage createState() => _AdminSettingInfoPage();
}

class _AdminSettingInfoPage extends State<AdminSettingInfoPage> {
  TextEditingController controllerName = TextEditingController();

  int nUserType = 102;
  int nSex = 1;
  int nAge = 1;

  List<String> arrSex = [
    "未知", "男", "女",
  ];

  List<String> arrAge = ["0", "1"];

  @override
  void initState() {
    nUserType = BaseUtil.gStUser["userType"] == null ? 102 : BaseUtil.gStUser["userType"];
    nSex = BaseUtil.gStUser["sex"] == null ? 1 : int.parse(BaseUtil.gStUser["sex"]);
    nAge = BaseUtil.gStUser["age"] == null ? 18 : BaseUtil.gStUser["age"];
    arrAge = [];
    for(int i = 0; i < 120; i++) {
      arrAge.add("$i");
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    BaseUtil.changeSystemBarColorType('dark');
    var strAvatar = BaseUtil.gStUser['avatar'] == null || BaseUtil.gStUser['avatar'] == "" ? BaseUtil.gDefaultAvatar : BaseUtil.gBaseUrl + BaseUtil.gStUser['avatar'];
    var strUserName = BaseUtil.gStUser['nickName'] == null || BaseUtil.gStUser['nickName'] == "" ? "教练" : BaseUtil.gStUser['nickName'];
    var strRemark = BaseUtil.gStUser['remark'] == null || BaseUtil.gStUser['remark'] == "" ? "每晚8点不见不散哦~" : BaseUtil.gStUser['remark'];
    Widget avatar = GestureDetector(
        child:Container(
          height: 34,
          width: 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(34),
            color: Colors.orange,
            border: Border.all(
              color: Colors.white,
              width: 1,
            ),
          ),
          child: ClipOval(
            child: Image.network(
              strAvatar,
              fit: BoxFit.cover,
            ),
          ),
        )
    );
    
    return Container(
      color: Color(0xFFF9F9F9),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AdminHeaderPage(title: "个人资料", onBack: () { widget.onSwitchParentType(100); }),
          Padding(padding: EdgeInsets.only(top: BaseUtil.dp(5))),
          Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: BaseUtil.dp(16), vertical: BaseUtil.dp(10)),
            child: Column(
              children: [
                GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () { widget.onSwitchParentType(111); },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: BaseUtil.dp(10)),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  width: 1,
                                  color: Color(0xFFEEEEEE)
                              )
                          )
                      ),
                      child: Row(
                        children: [
                          Text(
                            "头像",
                            style: TextStyle(
                                color: Color(0xFF333333),
                                fontSize: BaseUtil.dp(14)
                            ),
                          ),
                          Expanded(flex: 1, child: Text("")),
                          avatar,
                          Padding(padding: EdgeInsets.only(left: BaseUtil.dp(20))),
                          Image.asset('assets/images/common/dg.webp',
                            height: BaseUtil.dp(16),
                          ),
                        ],
                      ),
                    )
                ),
                GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () { showChangeNickNameDlg(); },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: BaseUtil.dp(15)),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  width: 1,
                                  color: Color(0xFFEEEEEE)
                              )
                          )
                      ),
                      child: Row(
                        children: [
                          Text(
                            "昵称",
                            style: TextStyle(
                                color: Color(0xFF333333),
                                fontSize: BaseUtil.dp(14)
                            ),
                          ),
                          Expanded(flex: 1, child: Text("")),
                          Text(
                            strUserName,
                            style: TextStyle(
                                color: Color(0xFF999999),
                                fontSize: BaseUtil.dp(12)
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(left: BaseUtil.dp(20))),
                          Image.asset('assets/images/common/dg.webp',
                            height: BaseUtil.dp(16),
                          ),
                        ],
                      ),
                    )
                ),
                GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () { widget.onSwitchParentType(112); },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: BaseUtil.dp(15)),
                      child: Row(
                        children: [
                          Text(
                            "签名",
                            style: TextStyle(
                                color: Color(0xFF333333),
                                fontSize: BaseUtil.dp(14)
                            ),
                          ),
                          Expanded(flex: 1, child: Text("")),
                          Text(
                            strRemark,
                            style: TextStyle(
                                color: Color(0xFF999999),
                                fontSize: BaseUtil.dp(12)
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(left: BaseUtil.dp(20))),
                          Image.asset('assets/images/common/dg.webp',
                            height: BaseUtil.dp(16),
                          ),
                        ],
                      ),
                    )
                ),
                GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      PickerUtil.showStringPicker(context, title: '请选择用户账号类型', normalIndex: nUserType - 101, data: gArrUserType, clickCallBack: (selectIndex, selectStr) {
                        setState(() {
                          nUserType = selectIndex + 101;
                          saveUserType();
                        });
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: BaseUtil.dp(15)),
                      child: Row(
                        children: [
                          Text(
                            "账号类型",
                            style: TextStyle(
                                color: Color(0xFF333333),
                                fontSize: BaseUtil.dp(14)
                            ),
                          ),
                          Expanded(flex: 1, child: Text("")),
                          Text(
                            gMapUserType[nUserType],
                            style: TextStyle(
                                color: Color(0xFF999999),
                                fontSize: BaseUtil.dp(12)
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(left: BaseUtil.dp(20))),
                          Image.asset('assets/images/common/dg.webp',
                            height: BaseUtil.dp(16),
                          ),
                        ],
                      ),
                    )
                ),
                GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      PickerUtil.showStringPicker(context, title: '请选择性别', normalIndex: nSex, data: arrSex, clickCallBack: (selectIndex, selectStr) {
                        setState(() {
                          nSex = selectIndex;
                          saveSex();
                        });
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: BaseUtil.dp(15)),
                      child: Row(
                        children: [
                          Text(
                            "性别",
                            style: TextStyle(
                                color: Color(0xFF333333),
                                fontSize: BaseUtil.dp(14)
                            ),
                          ),
                          Expanded(flex: 1, child: Text("")),
                          Text(
                            arrSex[nSex],
                            style: TextStyle(
                                color: Color(0xFF999999),
                                fontSize: BaseUtil.dp(12)
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(left: BaseUtil.dp(20))),
                          Image.asset('assets/images/common/dg.webp',
                            height: BaseUtil.dp(16),
                          ),
                        ],
                      ),
                    )
                ),
                GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      PickerUtil.showStringPicker(context, title: '请选择年龄', normalIndex: nAge, data: arrAge, clickCallBack: (selectIndex, selectStr) {
                        setState(() {
                          nAge = selectIndex;
                          saveAge();
                        });
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: BaseUtil.dp(15)),
                      child: Row(
                        children: [
                          Text(
                            "年龄",
                            style: TextStyle(
                                color: Color(0xFF333333),
                                fontSize: BaseUtil.dp(14)
                            ),
                          ),
                          Expanded(flex: 1, child: Text("")),
                          Text(
                            arrAge[nAge],
                            style: TextStyle(
                                color: Color(0xFF999999),
                                fontSize: BaseUtil.dp(12)
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(left: BaseUtil.dp(20))),
                          Image.asset('assets/images/common/dg.webp',
                            height: BaseUtil.dp(16),
                          ),
                        ],
                      ),
                    )
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void showChangeNickNameDlg() {
    var strUserName = BaseUtil.gStUser['nickName'] == null || BaseUtil.gStUser['nickName'] == "" ? "教练" : BaseUtil.gStUser['nickName'];
    controllerName.text = strUserName;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, dlgState) {
              return Material(
                type: MaterialType.transparency,
                child: GestureDetector(
                  onTap: () {
                    // 触摸收起键盘
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          width: BaseUtil.dp(343),
                          height: BaseUtil.dp(200),
                          padding: EdgeInsets.all(BaseUtil.dp(30),),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          child: Column(
                            children: [
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "修改昵称",
                                    style: TextStyle(
                                        color: Color(0xFF333333),
                                        fontSize: BaseUtil.dp(16)
                                    ),
                                  )
                              ),
                              Container(
                                padding: EdgeInsets.only(top: BaseUtil.dp(25)),
                                child: Stack(
                                  children: [
                                    Container (
                                      alignment: Alignment.bottomLeft,
                                      child: TextField(
                                        controller: controllerName,
                                        keyboardType: TextInputType.text,
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            color: Color(0xFF333333)
                                        ),
                                        decoration: InputDecoration(
                                          /// 设置输入框高度
                                            isCollapsed: true,
                                            contentPadding: EdgeInsets.fromLTRB(BaseUtil.dp(0), BaseUtil.dp(0), BaseUtil.dp(58), BaseUtil.dp(10)),
                                            hintText: "输入昵称",
                                            hintStyle: TextStyle(fontSize: 14.0)
                                        ),
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(50)
                                        ],
                                        onChanged: (val) {
                                          dlgState((){});
                                        },
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        dlgState((){
                                          controllerName.text = "";
                                        });
                                      },
                                      child: Container(
                                        alignment: Alignment.bottomRight,
                                        padding: EdgeInsets.only(bottom: BaseUtil.dp(8), right: BaseUtil.dp(38)),
                                        child: Container(
                                          width: BaseUtil.dp(14),
                                          height: BaseUtil.dp(14),
                                          child: Image.asset('assets/images/admin/setting/close.png',
                                            width: BaseUtil.dp(14),
                                            height: BaseUtil.dp(14),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                        alignment: Alignment.bottomRight,
                                        child: Text(
                                          "${controllerName.text.length} / 50",
                                          style: TextStyle(
                                              color: Color(0xFF999999),
                                              fontSize: BaseUtil.dp(12)
                                          ),
                                        )
                                    ),
                                  ],
                                ),
                              ),
                              Padding(padding: EdgeInsets.only(top: BaseUtil.dp(15))),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: [
                                      Expanded(flex: 1, child: Text("")),
                                      RawMaterialButton (
                                        constraints: BoxConstraints(minHeight: BaseUtil.dp(28), minWidth: BaseUtil.dp(66)),
                                        fillColor: Color(0xFFCCCCCC),
                                        elevation: 0,
                                        highlightElevation: 0,
                                        highlightColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(5)),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Center(
                                          child: Text('取消',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(padding: EdgeInsets.only(left: BaseUtil.dp(16))),
                                      RawMaterialButton (
                                        constraints: BoxConstraints(minHeight: BaseUtil.dp(28), minWidth: BaseUtil.dp(66)),
                                        fillColor: BaseUtil.gDefaultColor,
                                        elevation: 0,
                                        highlightElevation: 0,
                                        highlightColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(5)),
                                        ),
                                        onPressed: () {
                                          saveNickName(context);
                                        },
                                        child: Center(
                                          child: Text('保存',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                              ),
                            ],
                          )
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
    );
  }

  void saveNickName(context) {
    if (controllerName.text == null || controllerName.text.length == 0) {
      CustomSnackBar(context, Text("昵称不能为空"));
    }
    HttpUtil.getInstance().postJson(API.updateUserInfo, params: {
      "id": BaseUtil.gStUser["id"],
      "nickName": controllerName.text,
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
      Navigator.pop(context);
      setState(() {
        BaseUtil.gStUser['nickName'] = controllerName.text;
      });
    });
  }

  void saveUserType() {
    HttpUtil.getInstance().postJson(API.updateUserInfo, params: {
      "id": BaseUtil.gStUser["id"],
      "userType": nUserType,
    }).then((response) {
      setState(() {
        BaseUtil.gStUser['userType'] = nUserType;
      });
    });
  }
  void saveSex() {
    HttpUtil.getInstance().postJson(API.updateUserInfo, params: {
      "id": BaseUtil.gStUser["id"],
      "sex": nSex,
    }).then((response) {
      BaseUtil.gStUser['sex'] = nSex.toString();
    });
  }
  void saveAge() {
    HttpUtil.getInstance().postJson(API.updateUserInfo, params: {
      "id": BaseUtil.gStUser["id"],
      "age": nAge,
    }).then((response) {
      BaseUtil.gStUser['age'] = nAge;
    });
  }
}