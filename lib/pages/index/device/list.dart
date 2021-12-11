/*
 * 扫描到可连接的
 */
// @dart=2.9
import 'dart:ui';

import 'package:dong_gan_dan_che/common/BleUtil.dart';
import 'package:flutter/material.dart';
import 'package:dong_gan_dan_che/common/BaseUtil.dart';

class DeviceListPage extends StatefulWidget {
  /// 设备名称列表
  final List arrBlueName;
  final Function onSwitchParentType;       /// 切换上级状态
  DeviceListPage({ @required this.onSwitchParentType, @required this.arrBlueName });

  @override
  _DeviceListPage createState() => _DeviceListPage();
}

class _DeviceListPage extends State<DeviceListPage> {

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
    List<Widget> arrWidgetBlue = [];
    arrWidgetBlue.add(Padding(
      padding: EdgeInsets.only(top: BaseUtil.dp(30)),
    ));
    widget.arrBlueName.forEach((device) {
      var deviceName = device.name.length == 0 ? device.id.id : device.name;
      arrWidgetBlue.add(Container(
        padding: EdgeInsets.symmetric(horizontal: BaseUtil.dp(16)),
        alignment: Alignment.center,
        child: Row(
          children: [
            Expanded(flex: 1,
              child: Text(
                deviceName,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: BaseUtil.dp(14)
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(left: BaseUtil.dp(16))),
            GestureDetector(
              onTap: () {
                /// 设备连接, 通知后端进行初始化
                HttpUtil.getInstance().postJson(API.connectBicycle, params: {
                  "blueMac": device.id.id,
                  "blueName": device.name
                }).then((response) {
                  if (response == null) {
                    return;
                  }
                  var json = jsonDecode(response.toString());
                  if (json["success"] != true) {
                    return;
                  }
                  BleUtil.connectionDevice(device, true);
                  widget.onSwitchParentType(4);
                  BaseUtil.gStBicycleLog = json["data"];
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: BaseUtil.dp(4), horizontal: BaseUtil.dp(16)),
                decoration: BoxDecoration(
                    color: BaseUtil.gDefaultColor,
                    borderRadius: BorderRadius.all(Radius.circular(BaseUtil.dp(23)))
                ),
                child: Text(
                  "连接",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: BaseUtil.dp(10)
                  ),
                ),
              ),
            ),
          ],
        ),
      ));
      arrWidgetBlue.add(Container(
        margin: EdgeInsets.symmetric(vertical: BaseUtil.dp(15)),
        height: BaseUtil.dp(1),
        color: Color(0xFFEEEEEE),
      ));
    });
    return Container(
      padding: EdgeInsets.symmetric(vertical: BaseUtil.dp(30)),
      child: Column(
        children: [
          Container(
            child: Row(
              children: [
                Padding(padding: EdgeInsets.only(left: BaseUtil.dp(50))),
                Expanded(flex: 1,
                    child: Center(
                      child: Text(
                        "连接设备",
                        style: TextStyle(
                          color: Color(0xFF333333),
                          fontSize: BaseUtil.dp(16),
                        ),
                      ),
                    )
                ),
                GestureDetector(
                  onTap: () {
                    BleUtil.startScan();
                  },
                  child: Container(
                    padding: EdgeInsets.only(right: BaseUtil.dp(16)),
                    child: Icon(
                      Icons.refresh,
                      color: Colors.black,
                      size: BaseUtil.dp(30),
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              child: Container (
                child: Column(
                    children: arrWidgetBlue
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
