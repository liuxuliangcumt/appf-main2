/*
 * 添加或者编辑比赛
 */

// @dart=2.9
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:dong_gan_dan_che/common/ImageUtil.dart';
import 'package:dong_gan_dan_che/common/PickerUtil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';

class DongGanDanCheMatchEditInfo extends StatefulWidget {
  final arguments;
  DongGanDanCheMatchEditInfo({Key key, this.arguments}) : super(key: key);

  @override
  _DongGanDanCheMatchEditInfo createState() => _DongGanDanCheMatchEditInfo();
}

class _DongGanDanCheMatchEditInfo extends State<DongGanDanCheMatchEditInfo> {
  int id = 0;
  String strTitle = "";
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerFixData = TextEditingController();
  TextEditingController controllerRule = TextEditingController();
  int nMatchType = 1;
  int nPeopleType = 0;  /// 这个数据不保存
  int nMaxPeople = 2;
  int nPickerNumberStart = 7;
  List<String> arrPickerNumber = [];
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();
  String strImage = "";
  String strHttpImage = ""; /// 上传后返回的路径
  bool mSave = false;

  @override
  void initState() {
    mSave = false;
    id = widget.arguments["id"];
    if (id == 0) {
      strTitle = "添加比赛";
      nMatchType = 1;
      nPeopleType = 1;  /// 这个数据不保存, 保存时根据类型转换成MaxPeople
      nMaxPeople = 2;
      startTime = DateTime.now();
      endTime = DateTime.now();
      strImage = "";
      strHttpImage = "";
    } else {
      var info = widget.arguments["data"];
      strTitle = "编辑比赛";
      strHttpImage = info['image'] == null || info['image'].length < 10 ? "" : info['image'];
      strImage = BaseUtil.gBaseUrl + strHttpImage;
      startTime = DateTime.parse(info['startTime'] == null ? "2021-10-01 10:10:10" : info['startTime']);
      endTime = DateTime.parse(info['endTime'] == null ? "2021-10-01 10:10:10" : info['endTime']);
      controllerName.text = info['name'] == null ? "" : info['name'];
      nMatchType = info["type"] == null ? 1 : int.parse(info["type"]);
      nMaxPeople = info["maxPeople"] == null ? 2 : info["maxPeople"];
      switch (nMaxPeople) {
        case 2: { nPeopleType = 1; } break;
        case 3: { nPeopleType = 2; } break;
        case 6: { nPeopleType = 3; } break;
        default: { nPeopleType = 4; } break;
      }
      controllerRule.text = info["rule"] == null ? "无" : info["rule"];
      controllerFixData.text = info["fixData"] == null ? "" : info["fixData"].toString();
    }
    nPickerNumberStart = 7;
    for(var i = nPickerNumberStart; i <= 100; i++) {
      arrPickerNumber.add(i.toString());
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> arrWidget = [];
    /// 比赛名称
    arrWidget.add(Container(
      margin: EdgeInsets.only(top: BaseUtil.dp(18)),
      height: BaseUtil.dp(40),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            width: 0.5,
            color: Colors.black26
          )
        )
      ),
      child: Padding(
        padding: EdgeInsets.only(left: BaseUtil.dp(20), right: BaseUtil.dp(20)),
        child: Stack(
          children: <Widget>[
            Container(
              child: TextField(
                controller: controllerName,
                cursorColor: BaseUtil.gDefaultColor,
                cursorWidth: 1.5,
                textAlign: TextAlign.right,
                keyboardType: TextInputType.text,
                style: TextStyle(
                  color: Color(0xff333333),
                  fontSize: 14.0,
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none
                  ),
                  /// 设置输入框高度
                  isCollapsed: true,
                  contentPadding: EdgeInsets.only(left: BaseUtil.dp(70), top: BaseUtil.dp(6), bottom: BaseUtil.dp(6)),
                  hintText: '输入名称',
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: BaseUtil.dp(5), bottom: BaseUtil.dp(5)),
              child: Text(
                "比赛名称",
                style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: BaseUtil.dp(14)
                ),
              ),
            ),
          ],
        ),
      ),
    ));
    /// 比赛类型
    arrWidget.add(GestureDetector(
      child: Container(
        margin: EdgeInsets.only(top: BaseUtil.dp(18)),
        height: BaseUtil.dp(40),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              width: 0.5,
              color: Colors.black26
            )
          )
        ),
        child: Padding(
          padding: EdgeInsets.only(left: BaseUtil.dp(20), right: BaseUtil.dp(20)),
          child: Row(
            children: <Widget>[
              Text(
                '比赛类型',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: BaseUtil.dp(14)
                ),
              ),
              Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () {
                      PickerUtil.showStringPicker(context, title: '请选择比赛类型', normalIndex: nMatchType - 1, data: gArrMatchType, clickCallBack: (selectIndex, selectStr) {
                        setState(() {
                          nMatchType = selectIndex + 1;
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
                            gArrMatchType[nMatchType - 1]
                        ),
                        Padding(padding: EdgeInsets.only(left: BaseUtil.dp(10)),),
                        Image.asset('assets/images/common/dg.webp',
                          height: BaseUtil.dp(16),
                        ),
                      ],
                    ),
                  )
              ),
            ],
          ),
        ),
      ),
    ));
    /// 固定值
    arrWidget.add(Container(
      margin: EdgeInsets.only(top: BaseUtil.dp(18)),
      height: BaseUtil.dp(40),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            width: 0.5,
            color: Colors.black26
          )
        )
      ),
      child: Padding(
        padding: EdgeInsets.only(left: BaseUtil.dp(20), right: BaseUtil.dp(20)),
        child: Stack(
          children: <Widget>[
            Container(
              child: TextField(
                controller: controllerFixData,
                cursorColor: BaseUtil.gDefaultColor,
                cursorWidth: 1.5,
                textAlign: TextAlign.right,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: Color(0xff333333),
                  fontSize: 14.0,
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none
                  ),
                  /// 设置输入框高度
                  isCollapsed: true,
                  contentPadding: EdgeInsets.only(left: BaseUtil.dp(70), top: BaseUtil.dp(6), bottom: BaseUtil.dp(6)),
                  hintText: nMatchType == 1 ? "请输入时长" : "请输入里程",
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: BaseUtil.dp(5), bottom: BaseUtil.dp(5)),
              child: Text(
                nMatchType == 1 ? "比赛时长(分钟)" : "比赛里程(公里)",
                style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: BaseUtil.dp(14)
                ),
              ),
            ),
          ],
        ),
      ),
    ));
    /// 比赛人数
    arrWidget.add(GestureDetector(
      child: Container(
        margin: EdgeInsets.only(top: BaseUtil.dp(18)),
        height: BaseUtil.dp(40),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              width: 0.5,
              color: Colors.black26
            )
          )
        ),
        child: Padding(
          padding: EdgeInsets.only(left: BaseUtil.dp(20), right: BaseUtil.dp(20)),
          child: Row(
            children: <Widget>[
              Text(
                '比赛规模',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: BaseUtil.dp(14)
                ),
              ),
              Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () {
                      PickerUtil.showStringPicker(context, title: '请选择比赛规模', normalIndex: nPeopleType - 1, data: gArrMatchPeopleType, clickCallBack: (selectIndex, selectStr) {
                        setState(() {
                          nPeopleType = selectIndex + 1;
                          switch(selectIndex) {
                            case 0: { nMaxPeople = 2; } break;
                            case 1: { nMaxPeople = 3; } break;
                            case 2: { nMaxPeople = 6; } break;
                            case 3: { nMaxPeople = 7; } break;
                          }
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
                          gArrMatchPeopleType[nPeopleType - 1]
                        ),
                        Padding(padding: EdgeInsets.only(left: BaseUtil.dp(10)),),
                        Image.asset('assets/images/common/dg.webp',
                          height: BaseUtil.dp(16),
                        ),
                      ],
                    ),
                  )
              ),
            ],
          ),
        ),
      ),
    ));
    /// 最大人数
    if (nPeopleType == 4) {
      arrWidget.add(Container(
        margin: EdgeInsets.only(top: BaseUtil.dp(18)),
        height: BaseUtil.dp(40),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              width: 0.5,
              color: Colors.black26
            )
          )
        ),
        child: Padding(
          padding: EdgeInsets.only(left: BaseUtil.dp(20), right: BaseUtil.dp(20)),
          child: Row(
            children: <Widget>[
              Text(
                '最大人数',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: BaseUtil.dp(14)
                ),
              ),
              Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () {
                      PickerUtil.showStringPicker(context, title: '请选择最大参赛人数', normalIndex: nMaxPeople - nPickerNumberStart, data: arrPickerNumber, clickCallBack: (selectIndex, selectStr) {
                        setState(() {
                          nMaxPeople = selectIndex + nPickerNumberStart;
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
                            '$nMaxPeople人'
                        ),
                        Padding(padding: EdgeInsets.only(left: BaseUtil.dp(10)),),
                        Image.asset('assets/images/common/dg.webp',
                          height: BaseUtil.dp(16),
                        ),
                      ],
                    ),
                  )
              ),
            ],
          ),
        ),
      ));
    }
    /// 开始时间
    arrWidget.add(GestureDetector(
      child: Container(
        margin: EdgeInsets.only(top: BaseUtil.dp(18)),
        height: BaseUtil.dp(40),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              width: 0.5,
              color: Colors.black26
            )
          )
        ),
        child: Padding(
          padding: EdgeInsets.only(left: BaseUtil.dp(20), right: BaseUtil.dp(20)),
          child: Row(
            children: <Widget>[
              Text(
                '开始时间',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: BaseUtil.dp(14)
                ),
              ),
              Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () {
                      PickerUtil.showDatePicker(context, title: '请选择比赛开始时间', dateType: PickerUtilDateType.YMD_HM,
                          value: startTime, clickCallBack: (dynamic selectDateStr,dynamic selectData) {
                            setState(() {
                              startTime = DateTime.parse(selectData);
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
                            DateFormat("yyyy-MM-dd HH:mm").format(startTime)
                        ),
                        Padding(padding: EdgeInsets.only(left: BaseUtil.dp(10)),),
                        Image.asset('assets/images/common/dg.webp',
                          height: BaseUtil.dp(16),
                        ),
                      ],
                    ),
                  )
              ),
            ],
          ),
        ),
      ),
    ));
    /// 截止时间
    arrWidget.add(GestureDetector(
      child: Container(
        margin: EdgeInsets.only(top: BaseUtil.dp(18)),
        height: BaseUtil.dp(40),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              width: 0.5,
              color: Colors.black26
            )
          )
        ),
        child: Padding(
          padding: EdgeInsets.only(left: BaseUtil.dp(20), right: BaseUtil.dp(20)),
          child: Row(
            children: <Widget>[
              Text(
                '结束时间',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: BaseUtil.dp(14)
                ),
              ),
              Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () {
                      PickerUtil.showDatePicker(context, title: '请选择比赛结束时间', dateType: PickerUtilDateType.YMD_HM,
                          value: endTime, minValue: startTime, clickCallBack: (dynamic selectDateStr,dynamic selectData) {
                            setState(() {
                              endTime = DateTime.parse(selectData);
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
                            DateFormat("yyyy-MM-dd HH:mm").format(endTime)
                        ),
                        Padding(padding: EdgeInsets.only(left: BaseUtil.dp(10)),),
                        Image.asset('assets/images/common/dg.webp',
                          height: BaseUtil.dp(16),
                        ),
                      ],
                    ),
                  )
              ),
            ],
          ),
        ),
      ),
    ));
    /// 比赛规则说明
    arrWidget.add(Container(
      margin: EdgeInsets.only(top: BaseUtil.dp(18)),
      height: BaseUtil.dp(120),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            width: 0.5,
            color: Colors.black26
          )
        )
      ),
      child: Padding(
        padding: EdgeInsets.only(left: BaseUtil.dp(20), right: BaseUtil.dp(20)),
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(top: BaseUtil.dp(10), bottom: BaseUtil.dp(5),),
              child: Text(
                "比赛规则",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: BaseUtil.dp(14)
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                child: TextField(
                  controller: controllerRule,
                  cursorColor: BaseUtil.gDefaultColor,
                  cursorWidth: 1.5,
                  maxLines: 5,
                  style: TextStyle(
                    color: Color(0xff333333),
                    fontSize: 14.0,
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none
                    ),
                    contentPadding: EdgeInsets.only(left: BaseUtil.dp(15), top: BaseUtil.dp(3), bottom: BaseUtil.dp(3)),
                    hintText: '请输入比赛规则',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
    /// 比赛图片
    arrWidget.add(Container(
      padding: EdgeInsets.only(left: BaseUtil.dp(20), right: BaseUtil.dp(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container (
            padding: EdgeInsets.only(top: BaseUtil.dp(15), bottom: BaseUtil.dp(10)),
            alignment: Alignment.centerLeft,
            child: Text(
              '上传图片',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: BaseUtil.dp(14)
              ),
            ),
          ),
          Container (
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
                ImageUtil.showSelectPicker(context, (file) {
                  setState((){
                    strImage = file.path;
                  });
                });
              },
              child: Container(
                  alignment: Alignment.bottomLeft,
                  child: Stack(
                    children: [
                      Container(
                          width: BaseUtil.dp(120),
                          height: BaseUtil.dp(100),
                          padding: EdgeInsets.only(top: BaseUtil.dp(10), bottom: BaseUtil.dp(10), left: BaseUtil.dp(10), right: BaseUtil.dp(10)),
                          decoration: BoxDecoration(
                            border: Border.all(
                                width: 1,
                                color: Color(0xFFDDDDDD),
                                style: BorderStyle.solid
                            ),
                          ),
                          child: ImageUtil.buildCameraImage(strImage, BoxFit.cover)
                      ),
                    ],
                  )
              ),
            ),
          ),
        ],
      ),
    ));

    return WillPopScope(
      onWillPop: () async {
        FocusScope.of(BaseUtil.gNavigatorKey.currentContext).requestFocus(FocusNode());
        return true;
      },
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: PreferredSize(
            child: AppBar(
              title:Container(
                  padding: EdgeInsets.only(right: BaseUtil.dp(40)),
                  alignment: Alignment.center,
                  child: Text(strTitle)
              ),
              titleSpacing: 0,
              backgroundColor: Colors.white,
              brightness: Brightness.light,
              leading: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  color: Colors.white,
                  child: Center(
                    child: Image.asset('assets/images/common/back.webp',
                      width: BaseUtil.dp(8),
                    ),
                  ),
                ),
              ),
              elevation: 0,
            ),
            preferredSize: Size.fromHeight(BaseUtil.dp(55)),
          ),
          backgroundColor: Colors.white,
          body: GestureDetector(
            onTap: () {
              // 触摸收起键盘
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Container(
              child: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      child: Container (
                        child: Column(
                          children: arrWidget,
                        ),
                      ),
                    ),
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
                        save(context);
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
            ),
          )
      )
    );
  }

  /// 提交保存
  void save(context) {
    if (mSave) {
      CustomSnackBar(context, Text("数据保存中，请勿重复点击"));
      return;
    }
    if (controllerName.text == null || controllerName.text == "") {
      CustomSnackBar(context, Text("请输入比赛名称"));
      return;
    }
    if (controllerRule.text == null || controllerRule.text == "") {
      CustomSnackBar(context, Text("请输入比赛规则"));
      return;
    }
    if (strImage == null || strImage == "") {
      CustomSnackBar(context, Text("请选择比赛图片"));
      return;
    }
    mSave = true;
    if (id > 0 && strHttpImage == widget.arguments["data"]["image"]) {
      update(context);
    } else {
      uploadImage(context);
    }
  }

  /// 上传图片
  void uploadImage(context) {
    EasyLoading.show(status: "正在上传图片...");
    HttpUtil.getInstance().uploadFile(API.uploadFile, "file", strImage).then((response) {
      if (response == null) {
        mSave = false;
        EasyLoading.dismiss();
        CustomSnackBar(context, Text("上传失败"));
        return;
      }
      //先转json
      var json = jsonDecode(response.toString());
      if (json["code"] == null || json["code"] != 200) {
        mSave = false;
        EasyLoading.dismiss();
        CustomSnackBar(context, Text("上传失败"));
        return;
      }
      strHttpImage = json["fileName"];
      if (id > 0) {
        update(context);
      } else {
        add(context);
      }
    });
  }

  /// 调用保存接口
  void add(context) {
    EasyLoading.show(status: "正在添加...");
    HttpUtil.getInstance().postJson(API.addMatch, params: {
      "name": controllerName.text,
      "type": nMatchType,
      "fixData": controllerFixData.text,
      "startTime": DateFormat("yyyy-MM-dd HH:mm:00").format(startTime),
      "endTime": DateFormat("yyyy-MM-dd HH:mm:00").format(endTime),
      "maxPeople": nMaxPeople,
      "rule": controllerRule.text,
      "image": strHttpImage,
    }).then((response) {
      mSave = false;
      EasyLoading.dismiss();
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
      Navigator.pop(context);
      Future.delayed(Duration(milliseconds: 200),() async {
        EventUtil.gEventBus.fire(SwitchIndexPageEvent(3));
      });
    });
  }

  /// 调用保存接口
  void update(context) {
    EasyLoading.show(status: "正在保存...");
    HttpUtil.getInstance().postJson(API.updateMatch, params: {
      "id": id,
      "name": controllerName.text,
      "type": nMatchType,
      "fixData": BaseUtil.gNumberFormat1.format(controllerFixData.text),
      "startTime": DateFormat("yyyy-MM-dd HH:mm:00").format(startTime),
      "endTime": DateFormat("yyyy-MM-dd HH:mm:00").format(endTime),
      "maxPeople": nMaxPeople,
      "rule": controllerRule.text,
      "image": strHttpImage,
    }).then((response) {
      mSave = false;
      EasyLoading.dismiss();
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
      Navigator.pop(context);
      Future.delayed(Duration(milliseconds: 200),() async {
        EventUtil.gEventBus.fire(SwitchIndexPageEvent(3));
      });
    });
  }

}
