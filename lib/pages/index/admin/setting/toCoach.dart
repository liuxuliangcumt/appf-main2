/*
 * 成为教练, 目前没用到
 */
// @dart=2.9
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:dong_gan_dan_che/pages/index/admin/header.dart';

class AdminSettingToCoachPage extends StatefulWidget {
  final Function onSwitchParentType;       /// 切换上级状态
  AdminSettingToCoachPage({ @required this.onSwitchParentType });
  
  @override
  _AdminSettingToCoachPage createState() => _AdminSettingToCoachPage();
}

class _AdminSettingToCoachPage extends State<AdminSettingToCoachPage> {
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerPhone = TextEditingController();
  TextEditingController controllerIdCard = TextEditingController();
  TextEditingController controllerRemark = TextEditingController();
  final FocusNode focusNodeName = FocusNode();
  final FocusNode focusNodePhone = FocusNode();
  final FocusNode focusNodeIdCard = FocusNode();
  final FocusNode focusNodeRemark = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    focusNodeName.dispose();
    focusNodePhone.dispose();
    focusNodeIdCard.dispose();
    focusNodeRemark.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AdminHeaderPage(title: "成为教练", onBack: () { widget.onSwitchParentType(100); }),
          Padding(padding: EdgeInsets.only(top: BaseUtil.dp(5))),
          Expanded(
             flex: 1,
             child: SingleChildScrollView(
               physics: const ClampingScrollPhysics(),
               child: Column(
                 children: [
                   Container(
                     margin: EdgeInsets.only(top: BaseUtil.dp(18)),
                     padding: EdgeInsets.symmetric(horizontal: BaseUtil.dp(16)),
                     height: BaseUtil.dp(65),
                     child: Column(
                       children: [
                         Row(
                           children: [
                             Text("*", style: TextStyle(fontSize: BaseUtil.dp(12), color: Colors.red)),
                             Padding(padding: EdgeInsets.only(left: BaseUtil.dp(2))),
                             Text("姓名", style: TextStyle(fontSize: BaseUtil.dp(14), color: Color(0xFF333333))),
                           ],
                         ),
                         Padding(padding: EdgeInsets.only(top: BaseUtil.dp(10))),
                         TextField(
                           controller: controllerName,
                           cursorColor: BaseUtil.gDefaultColor,
                           cursorWidth: 1.5,
                           style: TextStyle(
                             color: Color(0xff333333),
                             fontSize: 14.0,
                           ),
                           decoration: InputDecoration(
                             /// 设置输入框高度
                             isCollapsed: true,
                             contentPadding: EdgeInsets.only(right: BaseUtil.dp(80), top: BaseUtil.dp(6), bottom: BaseUtil.dp(6)),
                             hintText: '输入姓名',
                           ),
                           onSubmitted: (_) {
                             focusNodePhone.requestFocus();
                           },
                         ),
                       ],
                     )
                   ),
                   Container(
                     margin: EdgeInsets.only(top: BaseUtil.dp(18)),
                     padding: EdgeInsets.symmetric(horizontal: BaseUtil.dp(16)),
                     height: BaseUtil.dp(65),
                     child: Column(
                       children: [
                         Row(
                           children: [
                             Text("*", style: TextStyle(fontSize: BaseUtil.dp(12), color: Colors.red)),
                             Padding(padding: EdgeInsets.only(left: BaseUtil.dp(2))),
                             Text("手机号", style: TextStyle(fontSize: BaseUtil.dp(14), color: Color(0xFF333333))),
                           ],
                         ),
                         Padding(padding: EdgeInsets.only(top: BaseUtil.dp(10))),
                         TextField(
                           controller: controllerPhone,
                           cursorColor: BaseUtil.gDefaultColor,
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
                             focusNodeIdCard.requestFocus();
                           },
                         ),
                       ],
                     )
                   ),
                   Container(
                     margin: EdgeInsets.only(top: BaseUtil.dp(18)),
                     padding: EdgeInsets.symmetric(horizontal: BaseUtil.dp(16)),
                     height: BaseUtil.dp(65),
                     child: Column(
                       children: [
                         Row(
                           children: [
                             Text("*", style: TextStyle(fontSize: BaseUtil.dp(12), color: Colors.red)),
                             Padding(padding: EdgeInsets.only(left: BaseUtil.dp(2))),
                             Text("身份证号", style: TextStyle(fontSize: BaseUtil.dp(14), color: Color(0xFF333333))),
                           ],
                         ),
                         Padding(padding: EdgeInsets.only(top: BaseUtil.dp(10))),
                         TextField(
                           controller: controllerIdCard,
                           cursorColor: BaseUtil.gDefaultColor,
                           cursorWidth: 1.5,
                           style: TextStyle(
                             color: Color(0xff333333),
                             fontSize: 14.0,
                           ),
                           decoration: InputDecoration(
                             /// 设置输入框高度
                             isCollapsed: true,
                             contentPadding: EdgeInsets.only(right: BaseUtil.dp(80), top: BaseUtil.dp(6), bottom: BaseUtil.dp(6)),
                             hintText: '输入身份证号',
                           ),
                           onSubmitted: (_) {
                             focusNodeRemark.requestFocus();
                           },
                         ),
                       ],
                     )
                   ),
                   Container(
                       margin: EdgeInsets.only(top: BaseUtil.dp(18)),
                       padding: EdgeInsets.symmetric(horizontal: BaseUtil.dp(16)),
                       height: BaseUtil.dp(65),
                       child: Column(
                         children: [
                           Row(
                             children: [
                               Text("备注", style: TextStyle(fontSize: BaseUtil.dp(14), color: Color(0xFF333333))),
                             ],
                           ),
                           Padding(padding: EdgeInsets.only(top: BaseUtil.dp(10))),
                           TextField(
                             controller: controllerName,
                             cursorColor: BaseUtil.gDefaultColor,
                             cursorWidth: 1.5,
                             style: TextStyle(
                               color: Color(0xff333333),
                               fontSize: 14.0,
                             ),
                             decoration: InputDecoration(
                               /// 设置输入框高度
                               isCollapsed: true,
                               contentPadding: EdgeInsets.only(right: BaseUtil.dp(80), top: BaseUtil.dp(6), bottom: BaseUtil.dp(6)),
                               hintText: '输入备注',
                             ),
                           ),
                         ],
                       )
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

  void save() {
    if (controllerName.text == null || controllerName.text.length == 0) {
      CustomSnackBar(context, Text("姓名不能为空"));
      return;
    }
    if (controllerPhone.text == null || controllerPhone.text.length == 0) {
      CustomSnackBar(context, Text("手机号不能为空"));
      return;
    }
    if (controllerIdCard.text == null || controllerIdCard.text.length == 0) {
      CustomSnackBar(context, Text("身份证不能为空"));
      return;
    }
    HttpUtil.getInstance().postJson(API.toCoach, params: {
      "userId": BaseUtil.gStUser["userId"],
      "realName": controllerName.text,
      "phone": controllerPhone.text,
      "idCard": controllerIdCard.text,
      "remark": controllerRemark.text,
    }).then((response) {
      if (response == null) {
        CustomSnackBar(context, Text("保存失败"));
        return;
      }
      //先转json
      var json = jsonDecode(response.toString());
      if (json["code"] == null || json["code"] != 200) {
        CustomSnackBar(context, Text("保存失败"));
        return;
      }
      widget.onSwitchParentType(100);
    });
  }
}