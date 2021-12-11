/*
 * 修改签名
 */
// @dart=2.9
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:dong_gan_dan_che/pages/index/admin/header.dart';

class AdminSettingRemarkPage extends StatefulWidget {
  final Function onSwitchParentType;       /// 切换上级状态
  AdminSettingRemarkPage({ @required this.onSwitchParentType });
  
  @override
  _AdminSettingRemarkPage createState() => _AdminSettingRemarkPage();
}

class _AdminSettingRemarkPage extends State<AdminSettingRemarkPage> {
  TextEditingController controllerRemark = TextEditingController();

  @override
  void initState() {
    var strRemark = BaseUtil.gStUser['remark'] == null ? "" : BaseUtil.gStUser['remark'];
    controllerRemark.text = strRemark;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Color(0xFFF9F9F9),
      child: Column(
        children: [
          AdminHeaderPage(title: "修改签名", onBack: () { widget.onSwitchParentType(110); }),
          Padding(padding: EdgeInsets.only(top: BaseUtil.dp(5))),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: BaseUtil.dp(16), vertical: BaseUtil.dp(15)),
              child: Column(
                children: [
                  Container (
                    alignment: Alignment.bottomLeft,
                    child: TextField(
                      controller: controllerRemark,
                      keyboardType: TextInputType.text,
                      maxLines: 8,
                      style: TextStyle(
                          fontSize: 14.0,
                          color: Color(0xFF333333)
                      ),
                      decoration: InputDecoration(
                        hintText: "输入签名",
                        hintStyle: TextStyle(fontSize: 14.0),
                        border: InputBorder.none
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(255)
                      ],
                    ),
                  ),
                  Expanded(flex: 1, child: Text("")),
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
            )
          )
        ],
      ),
    );
  }

  void save() {
    HttpUtil.getInstance().postJson(API.updateUserInfo, params: {
      "id": BaseUtil.gStUser["id"],
      "remark": controllerRemark.text,
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
      BaseUtil.gStUser['remark'] = controllerRemark.text;
      widget.onSwitchParentType(110);
    });
  }
}