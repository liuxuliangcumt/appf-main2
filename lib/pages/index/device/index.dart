/*
 * 蓝牙设备连接主界面
 */
// @dart=2.9

import 'dart:async';

import 'package:dong_gan_dan_che/pages/index/device/info.dart';
import 'package:dong_gan_dan_che/pages/index/device/list.dart';
import 'package:dong_gan_dan_che/pages/index/device/none.dart';
import 'package:dong_gan_dan_che/pages/index/device/scan.dart';
import 'package:dong_gan_dan_che/pages/index/device/wait.dart';
import 'package:flutter/material.dart';
import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:dong_gan_dan_che/common/BleUtil.dart';


class DevicePage extends StatefulWidget {
  @override
  _DevicePage createState() => _DevicePage();
}

class _DevicePage extends State<DevicePage> {
  StreamSubscription streamSubscription;
  int nStateType = 0; /// 0、等待搜索设备；1、搜索设备；2、未找到设备；3、选择设备进行连接；4、连上设备接收设备信息
  List arrBlueName = [];
  int nScanCount = 0;

  @override
  void initState() {
    super.initState();
    if (BaseUtil.gStBicycleLog != null && BaseUtil.gStBicycleLog["id"] != null && BaseUtil.gStBicycleLog["id"] > 0) {
      nStateType = 4;
    } else {
      BleUtil.initBle();
      BleUtil.startListenBleState();
    }
    streamSubscription = EventUtil.gEventBus.on<SwitchIndexPageEvent>().listen((event) {
      if (event.pageIndex != 2) {
        return;
      }
    });
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    switch (nStateType) {
      case 0: { body = DeviceWaitPage(onSwitchParentType: switchType); } break; /// 0、等待搜索设备；
      case 1: { body = DeviceScanPage(onSwitchParentType: switchType); } break; /// 1、搜索设备
      case 2: { body = DeviceNonePage(onSwitchParentType: switchType); } break; /// 2、未找到设备
      case 3: { body = DeviceListPage(onSwitchParentType: switchType, arrBlueName: arrBlueName); } break; /// 3、选择设备进行连接
      case 4: { body = DeviceInfoPage(onSwitchParentType: switchType); } break; /// 4、连上设备接收设备信息
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: body
    );
  }

  void switchType(type) {
    setState(() {
      nStateType = type;
    });
    switch (type) {
      case 1: { startScan(); } break;
    }
  }

  /// 开始搜索蓝牙设备
  void startScan() async {
    /// 设置监听扫描
    BleUtil.callbackScan = () {
      var ab = BleUtil.arrBleDevice;
      if (ab.length == arrBlueName.length) {
        nScanCount++;
      } else {
        nScanCount = 0;
      }
      arrBlueName = ab;
      if (ab.length > 0) {
        nStateType = 3;
      } else if(nScanCount > 20) {
        nStateType = 2;
      }
      setState(() {});
    };
    /// 开始扫描
    BleUtil.startScan();
  }
}
