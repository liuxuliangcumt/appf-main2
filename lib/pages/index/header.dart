/*
 * app首页通用头部组件，主要包含查询输入框
 */
// @dart=2.9
import 'dart:ui';

import 'package:flutter/material.dart';
// import 'package:barcode_scan/barcode_scan.dart';
// import 'package:flutter/services.dart';

import 'package:dong_gan_dan_che/common/BaseUtil.dart';

class DongGanDanCheHeader extends StatefulWidget {
  final Function addCallBack;
  final Function searchCallBack;
  final num height;
  final num opacity;
  final BoxDecoration decoration;
  DongGanDanCheHeader(
      {this.addCallBack,
      this.searchCallBack,
      this.height,
      this.opacity = 1.0,
      this.decoration});

  @override
  _DongGanDanCheHeader createState() => _DongGanDanCheHeader();
}

class _DongGanDanCheHeader extends State<DongGanDanCheHeader> {
  TextEditingController _search = TextEditingController();
  // ScanResult _scanResult;

  // Future _scan() async {
  //   try {
  //     _scanResult = await BarcodeScanner.scan();
  //     if (_scanResult.rawContent != '') {
  //       _search.text = _scanResult.rawContent;
  //     }
  //   } on PlatformException catch (e) {
  //     if (e.code == BarcodeScanner.cameraAccessDenied) {
  //       DYdialog.alert(context, text: '设备未获得权限');
  //     } else {
  //       DYdialog.alert(context, text: '未捕获的错误: $e');
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    List<Widget> arrRowChild = [];
    arrRowChild.add(Expanded(
      flex: 1,
      child: Container(
        height: BaseUtil.dp(35),
        padding: EdgeInsets.only(left: BaseUtil.dp(5), right: BaseUtil.dp(5)),
        decoration: BoxDecoration(
          color: Color(0xFFF2F2F2),
          border: Border.all(
              color: Color(0xFFCCCCCC), width: 1, style: BorderStyle.solid),
          borderRadius: BorderRadius.all(
            Radius.circular(BaseUtil.dp(35 / 2)),
          ),
        ),
        child: Row(
          children: <Widget>[
            // 搜索ICON
            Image.asset(
              'assets/images/common/search.webp',
              width: BaseUtil.dp(25),
              height: BaseUtil.dp(15),
            ),
            // 搜索输入框
            Expanded(
              flex: 1,
              child: TextField(
                controller: _search,
                cursorColor: BaseUtil.gDefaultColor,
                cursorWidth: 1.5,
                style: TextStyle(
                  color: BaseUtil.gDefaultColor,
                  fontSize: 14.0,
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  contentPadding: EdgeInsets.all(0),
                  hintText: '请输入搜索内容',
                ),
                onSubmitted: (val) {
                  if (widget.searchCallBack != null) {
                    widget.searchCallBack(val);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    ));
    // if (BaseUtil.gStUser["userType"] == 101) {
    arrRowChild.add(GestureDetector(
      onTap: () {
        if (widget.addCallBack != null) {
          widget.addCallBack();
        }
      },
      child: Container(
        padding: EdgeInsets.only(left: BaseUtil.dp(10)),
        child: Icon(
          Icons.add,
          size: 40,
          color: Color(0xFF333333),
        ),
      ),
    ));
    //  }

    return Container(
      height: BaseUtil.dp(40),
      width: screenWidth,
      decoration: widget.decoration != null
          ? widget.decoration
          : BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  Colors.white,
                  Colors.white,
                ],
              ),
            ),
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          Positioned(
            child: Opacity(
              opacity: widget.opacity,
              child: SizedBox(
                width: screenWidth - BaseUtil.dp(30),
                height: BaseUtil.dp(40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: arrRowChild,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
