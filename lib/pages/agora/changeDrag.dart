/*
 * 直播间修改学员阻力
 */
// @dart=2.9
import 'dart:async';

import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:dong_gan_dan_che/pages/index/device/status.dart';
import 'package:flutter/material.dart';

class DongGanDanCheLiveChangeDrag extends StatefulWidget {
  final Function onClose;
  final studentId;
  const DongGanDanCheLiveChangeDrag({
    Key key,
    this.onClose,
    this.studentId
  }) : super(key: key);

  @override
  _DongGanDanCheLiveChangeDrag createState() => _DongGanDanCheLiveChangeDrag();
}

class _DongGanDanCheLiveChangeDrag extends State<DongGanDanCheLiveChangeDrag> {
  dynamic mBicycleLog = {};
  StreamSubscription streamSubscription;

  @override
  void initState(){
    super.initState();
    var that = this;
    /// 某个观众进入了直播间
    streamSubscription = EventUtil.gEventBus.on<SendUpdateStudentDeviceInfo>().listen((event) {
      that.setState(() {
        var data = event.data;
        if (widget.studentId.toString() == data["userId"].toString()) {
          mBicycleLog = data;
        }
      });
    });
    HttpUtil.getInstance().postJson(API.getLastBicycleLog, params: {
      "userId": widget.studentId
    }).then((res) {
      if (res == null) {
        return;
      }
      var data = jsonDecode(res.toString());
      // 如果没找到,或者找到的记录结束时间是非空,表示用完了的, 跳过
      if (data["success"] != true && data["data"]["endTime"] != null) {
        return;
      }
      that.setState(() {
        mBicycleLog = data["data"];
      });
    });
  }
  @override
  void dispose() {
    streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    BaseUtil.changeSystemBarColorType('light');
    var strAvatar = mBicycleLog['avatar'] == null || mBicycleLog['avatar'] == "" ? BaseUtil.gDefaultAvatar : BaseUtil.gBaseUrl + mBicycleLog['avatar'];
    var strUserName = mBicycleLog['nickName'] == null || mBicycleLog['nickName'] == "" ? "学员" : mBicycleLog['nickName'];
    var strBicycleName = mBicycleLog['bicycleName'] == null || mBicycleLog['bicycleName'] == "" ? "动感单车" : mBicycleLog['bicycleName'];
    Widget avatar = GestureDetector(
        child:Container(
          height: 55,
          width: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(55),
            color: Colors.orange,
            border: Border.all(
              color: Colors.white,
              width: 1,
            ),
          ),
          child: ClipOval(
            child: Image.network(
              strAvatar,
              fit: BoxFit.cover,
            ),
          ),
        )
    );
    Widget body = Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Color(0xEE000000),
      ),
      child: Column(
        children: [
          Padding(padding: EdgeInsets.only(top: BaseUtil.dp(40))),
          Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(padding: EdgeInsets.only(right: BaseUtil.dp(20))),
                avatar,
                Padding(padding: EdgeInsets.only(right: BaseUtil.dp(10))),
                Expanded(
                  flex: 1,
                  child: Container(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Text(
                              strUserName,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: BaseUtil.dp(18),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            child: Text(
                              strBicycleName,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: BaseUtil.dp(12),
                              ),
                            ),
                          ),
                        ]
                    ),
                  )
                ),
                Padding(padding: EdgeInsets.only(right: BaseUtil.dp(10))),
                widget.onClose == null ? Text("") :GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onClose,
                  child: Icon(
                    Icons.close,
                    color: Colors.white.withOpacity(0.66),
                    size: BaseUtil.dp(30),
                  ),
                ),
                Padding(padding: EdgeInsets.only(left: BaseUtil.dp(16))),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              child: DeviceStatusPage(updateTimeFlag: false, bicycleLog: mBicycleLog),
            )
          )
        ],
      ),
    );

    if (widget.onClose == null) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        body: body
      );
    } else {
      return GestureDetector(
        child: body
      );
    }
  }

}
