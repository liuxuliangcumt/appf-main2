/*
 * 扫描设备进行中的提示界面
 */
// @dart=2.9
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:dong_gan_dan_che/common/BaseUtil.dart';

class DeviceScanPage extends StatefulWidget {
  final Function onSwitchParentType;       /// 切换上级状态
  DeviceScanPage({ @required this.onSwitchParentType });

  @override
  _DeviceScanPage createState() => _DeviceScanPage();
}

class _DeviceScanPage extends State<DeviceScanPage> {
  /// 设备名称列表
  List arrBlueName = [];
  int nScanCount = 0;

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
      padding: EdgeInsets.symmetric(vertical: BaseUtil.dp(30)),
      child: Column(
        children: [
          Container(
            child: Center(
              child: Text(
                "搜索设备",
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: BaseUtil.dp(16),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Stack(
              children: [
                Center(
                  child: Container(
                    margin: EdgeInsets.only(bottom: BaseUtil.dp(20)),
                    height: BaseUtil.dp(205),
                    width: BaseUtil.dp(205),
                    decoration: BoxDecoration(
                        color: Color(0xFFF9F9F9),
                        borderRadius: BorderRadius.all(Radius.circular(BaseUtil.dp(205)))
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    margin: EdgeInsets.only(bottom: BaseUtil.dp(20)),
                    height: BaseUtil.dp(120),
                    width: BaseUtil.dp(120),
                    decoration: BoxDecoration(
                        color: Color(0xFFEEEEEE),
                        borderRadius: BorderRadius.all(Radius.circular(BaseUtil.dp(120)))
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    margin: EdgeInsets.only(bottom: BaseUtil.dp(20)),
                    child: Image.asset(
                      'assets/images/device/scaning.png',
                      height: BaseUtil.dp(120),
                      width: BaseUtil.dp(120),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Center(
                  child: Container(
                      padding: EdgeInsets.only(top: BaseUtil.dp(220)),
                      child: Text(
                          "请确保您的手机蓝牙已经打开"
                      )
                  ),
                ),
                Center(
                  child: Container(
                      padding: EdgeInsets.only(top: BaseUtil.dp(255)),
                      child: Text(
                          "并尽量靠近单车"
                      )
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: BaseUtil.dp(46),
          ),
        ],
      ),
    );
  }
}
