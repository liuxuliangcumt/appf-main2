import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:dong_gan_dan_che/common/BleUtil.dart';
import 'package:dong_gan_dan_che/pages/common/service.dart';
import 'package:dong_gan_dan_che/pages/index/device/index.dart';
import 'package:dong_gan_dan_che/pages/index/device/info.dart';
import 'package:dong_gan_dan_che/pages/index/device/list.dart';
import 'package:dong_gan_dan_che/pages/index/device/none.dart';
import 'package:dong_gan_dan_che/pages/index/device/scan.dart';
import 'package:dong_gan_dan_che/pages/index/device/wait.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PrepareMatch extends StatefulWidget {
  final arguments;
  final String type = "Video";

  PrepareMatch({Key? key, this.arguments}) : super(key: key);

  @override
  _PrepareMatchState createState() => _PrepareMatchState();
}

class _PrepareMatchState extends State<PrepareMatch> {
  late StreamSubscription streamSubscription;
  int nStateType = 0;

  /// 0、等待搜索设备；1、搜索设备；2、未找到设备；3、选择设备进行连接；4、连上设备接收设备信息
  List arrBlueName = [];
  int nScanCount = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (BaseUtil.gStBicycleLog != null &&
        BaseUtil.gStBicycleLog["id"] != null &&
        BaseUtil.gStBicycleLog["id"] > 0) {
      nStateType = 4;
    } else {
      BleUtil.initBle();
      BleUtil.startListenBleState();
    }
    streamSubscription =
        EventUtil.gEventBus.on<SwitchIndexPageEvent>().listen((event) {
      if (event.pageIndex != 2) {
        return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body = DeviceNonePage();
    switch (nStateType) {
      case 0:
        body = DeviceWaitPage(onSwitchParentType: switchType);

        break;

      /// 0、等待搜索设备；
      case 1:
        body = DeviceScanPage(onSwitchParentType: switchType);

        break;

      /// 1、搜索设备
      case 2:
        body = DeviceNonePage(onSwitchParentType: switchType);

        break;

      /// 2、未找到设备
      case 3:
        body = DeviceListPage(
            onSwitchParentType: switchType, arrBlueName: arrBlueName);

        break;

      /// 3、选择设备进行连接
      case 4:
        body = DeviceInfoPage(onSwitchParentType: switchType);

        break;

      /// 4、连上设备接收设备信息
    }
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: CustomScrollView(
            physics: BouncingScrollPhysics(),
            semanticChildCount: 3,
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    if (index == 0) {
                      return addVideo();
                    } else if (index == 1) {
                      return Container(
                        height: 700,
                        child: body,
                      );
                    } else {
                      return Container(
                        height: 50,
                        padding: EdgeInsets.only(
                            left: BaseUtil.dp(20), right: BaseUtil.dp(20)),
                        child: RawMaterialButton(
                          constraints:
                              BoxConstraints(minHeight: BaseUtil.dp(46)),
                          fillColor: BaseUtil.gDefaultColor,
                          elevation: 0,
                          highlightElevation: 0,
                          highlightColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(23)),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, "/match/room",
                                arguments: widget.arguments);
                          },
                          child: Center(
                            child: Text(
                              '开始比赛',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: BaseUtil.dp(16)),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                  childCount: 3,
                ),
              ),
            ],
          ),
        ));
    // Expanded(child: body)  addvideo
  }

  void switchType(type) {
    setState(() {
      nStateType = type;
    });
    switch (type) {
      case 1:
        {
          startScan();
        }
        break;
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
      } else if (nScanCount > 20) {
        nStateType = 2;
      }
      setState(() {});
    };

    /// 开始扫描
    BleUtil.startScan();
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    super.dispose();
  }

  Widget addVideo() {
    List videoData = DongGanDanCheService.gMapPageList[widget.type]!.arr;

    List<Widget> liveList = [];
    List data = [
      {
        "id": 1,
        "imageUrl":
            "https://pica.zhimg.com/80/v2-7d0f126696a83ee0075a3cf28ad48b15_1440w.jpg?source=1940ef5c"
      },
      {
        "id": 2,
        "imageUrl":
            "https://pica.zhimg.com/80/v2-7d0f126696a83ee0075a3cf28ad48b15_1440w.jpg?source=1940ef5c"
      }
    ];

    data.forEach((element) {
      liveList.add(InkWell(
        onTap: () {
          print(" inkwell zhixingle");
          CustomSnackBar(context, Text("选中了" + element["id"].toString()));
        },
        child: Container(
          child: Image.asset(
            'assets/images/common/default.jpg',
            height: 120,
            fit: BoxFit.fill,
          ),
        ),
      ));
    });

    return Container(
      height: 300,
      child: ListView(
        children: liveList,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}
