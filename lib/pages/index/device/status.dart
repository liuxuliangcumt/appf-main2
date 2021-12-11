/*
 * 设备状态效果界面，包含调整阻力功能
 */
// @dart=2.9
import 'dart:ui';

import 'package:dong_gan_dan_che/common/BleUtil.dart';
import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:flutter/material.dart';

import 'package:dong_gan_dan_che/pages/index/device/dragCircle.dart';
import 'package:dong_gan_dan_che/pages/index/device/speedCircle.dart';

class DeviceStatusPage extends StatefulWidget {
  final bool updateTimeFlag;
  final dynamic bicycleLog;
  DeviceStatusPage({ this.updateTimeFlag, this.bicycleLog });

  @override
  _DeviceStatusPage createState() => _DeviceStatusPage();
}

class _DeviceStatusPage extends State<DeviceStatusPage> {
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
    var log = widget.bicycleLog;
    var fv = widget.bicycleLog["fv"];
    if (fv == null) {
      fv = 0;
    }
    var cal = widget.bicycleLog["cal"];
    if (cal == null) {
      cal = 0;
    }
    var drag = widget.bicycleLog["drag"];
    if (drag == null) {
      drag = 0;
    }
    return Column(
      children: [
        Padding(padding: EdgeInsets.only(top: BaseUtil.dp(10))),
        Center(
          child: DeviceStatusSpeed(bicycleLog: log,),
        ),
        Padding(padding: EdgeInsets.only(top: BaseUtil.dp(20))),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        child: Text(
                          '${BaseUtil.gNumberFormat.format(fv)}w',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: BaseUtil.dp(30),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: BaseUtil.dp(24),
                            height: BaseUtil.dp(24),
                            child: Image.asset("assets/images/drag/gl.png", fit: BoxFit.cover,),
                          ),
                          Text(
                            "单车功率",
                            style: TextStyle(
                              color: Color(0xFFCCCCCC),
                              fontSize: BaseUtil.dp(10),
                            ),
                          ),
                        ],
                      )
                    ]
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        child: DeviceStatusTime(updateTimeFlag: widget.updateTimeFlag, bicycleLog: widget.bicycleLog,),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: BaseUtil.dp(24),
                            height: BaseUtil.dp(24),
                            child: Image.asset("assets/images/drag/time.png", fit: BoxFit.cover,),
                          ),
                          Text(
                            "骑行时间",
                            style: TextStyle(
                              color: Color(0xFFCCCCCC),
                              fontSize: BaseUtil.dp(10),
                            ),
                          ),
                        ],
                      )
                    ]
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        child: Text(
                          BaseUtil.gNumberFormat2.format(cal),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: BaseUtil.dp(30),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: BaseUtil.dp(24),
                            height: BaseUtil.dp(24),
                            child: Image.asset("assets/images/drag/cal.png", fit: BoxFit.cover,),
                          ),
                          Text(
                            "消耗千卡",
                            style: TextStyle(
                              color: Color(0xFFCCCCCC),
                              fontSize: BaseUtil.dp(10),
                            ),
                          ),
                        ],
                      )
                    ]
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(""),
        ),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(padding: EdgeInsets.only(left: BaseUtil.dp(30))),
              GestureDetector(
                onTap: onSubZl,
                child: Container(
                  width: BaseUtil.dp(58),
                  height: BaseUtil.dp(58),
                  child: Image.asset("assets/images/drag/sub.png", fit: BoxFit.cover,),
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: DrawDragCircle(radius: BaseUtil.dp(110), val: drag * 1.0, maxVal: 12.0),
                ),
              ),
              GestureDetector(
                onTap: onAddZl,
                child: Container(
                  width: BaseUtil.dp(58),
                  height: BaseUtil.dp(58),
                  child: Image.asset("assets/images/drag/add.png", fit: BoxFit.cover,),
                ),
              ),
              Padding(padding: EdgeInsets.only(right: BaseUtil.dp(30))),
            ],
          ),
        ),
        Padding(padding: EdgeInsets.only(top: BaseUtil.dp(30))),
      ],
    );
  }

  /// 增加阻力
  void onAddZl() {
    var drag = widget.bicycleLog["drag"];
    if (drag == null) {
      drag = 0;
    }
    if (drag < 12.5) {
      drag += 1;
      sendToBle(drag);
    }
  }

  /// 减小阻力
  void onSubZl() {
    var drag = widget.bicycleLog["drag"];
    if (drag == null) {
      drag = 0;
    }
    if (drag > 0.5) {
      drag -= 1;
      sendToBle(drag);
    }
  }

  Future<void> sendToBle(drag) async {
    widget.bicycleLog["drag"] = drag;
    var id = widget.bicycleLog["userId"];
    if (id == null) {
      this.setState(() {});
      return;
    } else {
      var cur = BaseUtil.gStBicycleLog["userId"];
      if (cur != null && cur == id) {
        int d = drag.floor();
        BleUtil.sendDataToBle([ 0x55, 0xAA, 0x02, 0x02, 0x00 , d]);
      } else {
        HttpUtil.getInstance().postJson(API.batchUpdateBicycleDrag, params: {
          "userIds": id,
          "drag": drag
        }).then((response) {
          this.setState(() {});
        });
      }
    }
  }

}

///////////////////////////////////////////////////////////////////////////////
// 速度
class DeviceStatusSpeed extends StatefulWidget {
  final dynamic bicycleLog;
  DeviceStatusSpeed({ this.bicycleLog });

  @override
  _DeviceStatusSpeed createState() => _DeviceStatusSpeed();
}

class _DeviceStatusSpeed extends State<DeviceStatusSpeed> {
  @override
  Widget build(BuildContext context) {
    var speed = widget.bicycleLog["speed"];
    if (speed == null) {
      speed = 0;
    }
    speed = speed * 60.0 / 1000.0;
    return Container(
      width: 300,
      height: 230,
      child: Stack(
        children: [
          Center(
            child: Image.asset("assets/images/drag/panel.png", fit: BoxFit.cover),
          ),
          Container(
            alignment: Alignment.center,
            child: DrawSpeedCircle(val: speed, maxVal: 40.0),
          )
        ],
      ),
    );
  }
}

///////////////////////////////////////////////////////////////////////////////
// 时间
class DeviceStatusTime extends StatefulWidget {
  final bool updateTimeFlag;
  final dynamic bicycleLog;
  DeviceStatusTime({ this.updateTimeFlag, this.bicycleLog });

  @override
  _DeviceStatusTime createState() => _DeviceStatusTime();
}

class _DeviceStatusTime extends State<DeviceStatusTime> {
  @override
  void initState() {
    super.initState();
    if (widget.updateTimeFlag) {
      BleUtil.callbackTimer = () {
        setState(() {});
      };
    }
  }

  @override
  void dispose() {
    if (widget.updateTimeFlag) {
      BleUtil.callbackTimer = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var rideTime = BaseUtil.formatTime(widget.bicycleLog["rideTime"]);
    return Text(
      rideTime,
      style: TextStyle(
        color: Colors.white,
        fontSize: BaseUtil.dp(30),
        fontWeight: FontWeight.bold,
      ),
    );
  }
}