/*
 * 连接设备后的信息展示界面
 */
// @dart=2.9
import 'dart:ui';

import 'package:dong_gan_dan_che/common/BleUtil.dart';
import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:dong_gan_dan_che/pages/index/device/status.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DeviceInfoPage extends StatefulWidget {
  final Function onSwitchParentType;       /// 切换上级状态
  DeviceInfoPage({ @required this.onSwitchParentType });

  @override
  _DeviceInfoPage createState() => _DeviceInfoPage();
}

class _DeviceInfoPage extends State<DeviceInfoPage> {
  @override
  void initState() {
    super.initState();
    /// 收到蓝牙数据后更新界面显示
    BleUtil.callbackData = (src) {
      setState(() {});
    };
    // BleUtil.callbackLog = (src) {
    //   setState(() {});
    // };
  }

  @override
  void dispose() {
    /// 退出前先通知蓝牙模块,收到数据不用再通知这个界面更新了
    BleUtil.callbackData = null;
    BleUtil.callbackLog = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var deviceName = "";
    if (BleUtil.deviceCurrent != null) {
      deviceName = BleUtil.deviceCurrent.name.length == 0 ? BleUtil.deviceCurrent.id.id : BleUtil.deviceCurrent.name;
    } else {
      deviceName = "未连接设备";
    }
    return Container(
      decoration: BoxDecoration(
        color: Color(0xEE000000),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Padding(padding: EdgeInsets.only(top: BaseUtil.dp(40))),
              Container(
                padding: EdgeInsets.symmetric(horizontal: BaseUtil.dp(16)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex:1,
                      child: Text(
                        deviceName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: BaseUtil.dp(18),
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(left: BaseUtil.dp(16))),
                    GestureDetector(
                      onTap: () {
                        /// 设备断开连接, 通知后端
                        HttpUtil.getInstance().postJson(API.disconnectBicycle, params: BaseUtil.gStBicycleLog).then((response) {
                          BaseUtil.gStBicycleLog = {};
                          BleUtil.disConnectionDevice();
                          widget.onSwitchParentType(0);
                          if (response == null) {
                            return;
                          }
                          var json = jsonDecode(response.toString());
                          if (json["success"] != true) {
                            return;
                          }
                        });
                      },
                      child: Text(
                        "断开连接",
                        style: TextStyle(
                            fontSize: BaseUtil.dp(14),
                            color: Colors.white
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.only(top: BaseUtil.dp(10))),
              Expanded(
                  flex: 1,
                  child: Container(
                    child: DeviceStatusPage(updateTimeFlag: true, bicycleLog: BaseUtil.gStBicycleLog,),
                  )
              ),
              Padding(padding: EdgeInsets.only(top: BaseUtil.dp(30))),
            ],
          ),
          // Opacity(
          //   opacity: 0.8,
          //   child: Container(
          //     padding: EdgeInsets.only(top: BaseUtil.dp(80), bottom: BaseUtil.dp(150)),
          //     child: SingleChildScrollView(
          //       physics: const ClampingScrollPhysics(),
          //       child: Container(
          //         padding: EdgeInsets.symmetric(horizontal: BaseUtil.dp(16)),
          //         child: Text(
          //           BleUtil.gLog,
          //           maxLines: 20000,
          //           style: TextStyle(
          //             color: Colors.lightBlue
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }
}
