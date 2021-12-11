/*
 * 个人中心里面对应的返回按钮+标题的通用头模块
 */
// @dart=2.9
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdminHeaderPage extends StatefulWidget {
  final String title;           /// 标题
  final Function onBack;        /// 点击返回按钮
  final Function onFilter;      /// 点击删选按钮
  AdminHeaderPage({ this.title, this.onBack, this.onFilter });

  @override
  _AdminSettingPage createState() => _AdminSettingPage();
}

class _AdminSettingPage extends State<AdminHeaderPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(BaseUtil.dp(16), BaseUtil.dp(30), BaseUtil.dp(16), BaseUtil.dp(10)),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onBack,
            child: Container(
              width: BaseUtil.dp(32),
              height: BaseUtil.dp(32),
              color: Colors.white,
              child: Icon(
                FontAwesomeIcons.angleLeft,
                color: Color(0xFF333333),
                size: BaseUtil.dp(20.0),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                widget.title,
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: BaseUtil.dp(16),
                ),
              ),
            )
          ),
          widget.onFilter == null ? Padding(padding: EdgeInsets.only(left: BaseUtil.dp(24))) : GestureDetector(
            onTap: widget.onFilter,
            child: Container(
              height: BaseUtil.dp(24),
              width: BaseUtil.dp(24),
              child: Image.asset('assets/images/common/calendar.png'),
            ),
          ),
        ],
      ),
    );
  }

}