/*
 * 交易记录
 */
// @dart=2.9
import 'dart:async';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:dong_gan_dan_che/pages/index/admin/header.dart';
import 'package:dong_gan_dan_che/common/PickerUtil.dart';
import 'package:dong_gan_dan_che/pages/common/service.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';

class AdminRecordPayPage extends StatefulWidget {
  final Function onSwitchParentType;       /// 切换上级状态
  AdminRecordPayPage({ @required this.onSwitchParentType });
  
  @override
  _AdminRecordPayPage createState() => _AdminRecordPayPage();
}

class _AdminRecordPayPage extends State<AdminRecordPayPage> {
  DateTime timeFilter;
  List<dynamic> arrRecordData = [];
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  StreamSubscription streamSubscription;
  String _listType = "RecordPay";

  @override
  void initState() {
    timeFilter = null;
    super.initState();
    var that = this;
    /// 接收到更新消息
    streamSubscription = EventUtil.gEventBus.on<UpdateIndexListEvent>().listen((event) {
      if (event.type == _listType) {
        that.setState(() {
          arrRecordData = DongGanDanCheService.gMapPageList[_listType].arr;
        });
      }
    });
    DongGanDanCheService.onRefresh(_listType, { "userId": BaseUtil.gStUser["id"], "time": timeFilter == null ? null : DateFormat("yyyy-MM-dd HH:mm").format(timeFilter) }, _refreshController);
  }

  @override
  void dispose() {
    _refreshController?.dispose();
    streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    BaseUtil.changeSystemBarColorType('dark');
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
      child: Column(
        children: [
          AdminHeaderPage(title: "交易记录",
            onBack: () { widget.onSwitchParentType(0); },
            onFilter: () {
              DateTime t = timeFilter;
              if (t == null) {
                t = DateTime.now();
              }
              PickerUtil.showDatePicker(context, title: '请选择日期', dateType: PickerUtilDateType.YMD,
                value: t, clickCallBack: (dynamic selectDateStr,dynamic selectData) {
                  setState(() {
                    timeFilter = DateTime.parse(selectData);
                    DongGanDanCheService.onRefresh(_listType, { "userId": BaseUtil.gStUser["id"], "time": timeFilter == null ? null : DateFormat("yyyy-MM-dd HH:mm").format(timeFilter) }, _refreshController);
                  });
                }
              );
            },
          ),
          Padding(padding: EdgeInsets.only(top: BaseUtil.dp(5))),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              child: ScrollConfiguration(
                behavior: DongGanDanCheBehaviorNull(),
                child: RefreshConfiguration(
                  headerTriggerDistance: BaseUtil.dp(55),
                  maxOverScrollExtent : BaseUtil.dp(100),
                  footerTriggerDistance: BaseUtil.dp(50),
                  maxUnderScrollExtent: 0,
                  headerBuilder: () => DongGanDanCheRefreshHeader(),
                  footerBuilder: () => DongGanDanCheRefreshFooter(),
                  child: SmartRefresher(
                    enablePullDown: true,
                    enablePullUp: true,
                    footer: DongGanDanCheRefreshFooter(bgColor: Color(0xfff1f5f6),),
                    controller: _refreshController,
                    onRefresh: () { DongGanDanCheService.onRefresh(_listType, { "userId": BaseUtil.gStUser["id"], "time": timeFilter == null ? null : DateFormat("yyyy-MM-dd HH:mm").format(timeFilter)  }, _refreshController); },
                    onLoading: () { DongGanDanCheService.onLoading(_listType, { "userId": BaseUtil.gStUser["id"], "time": timeFilter == null ? null : DateFormat("yyyy-MM-dd HH:mm").format(timeFilter)  }, _refreshController); },
                    child: CustomScrollView(
                      slivers: <Widget>[
                        SliverToBoxAdapter(
                          child: Container(
                            padding: EdgeInsets.only(top: BaseUtil.dp(20)),
                            child: Column(
                              children: buildRecordList()
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildRecordList() {
    List<Widget> arrRet = [];
    arrRecordData.forEach((recordData) {
      String strNum = "";
      String strType = "";
      String strTime = DateFormat("yyyy-MM-dd HH:mm").format(DateTime.parse(recordData["createTime"]));
      switch (recordData["operateType"]) {
        case 1: {
          strNum = "+ ";
          strType = "充值车币";
        } break;
        case 2: {
          if(BaseUtil.gStUser["id"] == recordData["userId"]) {
            strNum = "+ ";
            strType = "直播被打赏";
          } else {
            strNum = "- ";
            strType = "打赏主播";
          }
        } break;
        case 3: {
          if(BaseUtil.gStUser["id"] == recordData["userId"]) {
            strNum = "+ ";
            strType = "视频被打赏";
          } else {
            strNum = "- ";
            strType = "打赏视频";
          }
        } break;
      }
      strNum = strNum + recordData["payMoney"].toString() + "车币";

      arrRet.add(Container(
        margin: EdgeInsets.symmetric(horizontal: BaseUtil.dp(16)),
        padding: EdgeInsets.symmetric(vertical: BaseUtil.dp(16)),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    width: 0.5,
                    color: Colors.black26
                )
            )
        ),
        child: Row(
          children: [
            Container(
              width: BaseUtil.dp(46),
              height: BaseUtil.dp(46),
              padding: EdgeInsets.all(BaseUtil.dp(5)),
              child: Image.asset('assets/images/gift/b.png'),
            ),
            Padding(padding: EdgeInsets.only(left: BaseUtil.dp(20))),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strNum,
                  style: TextStyle(
                      color: Color(0xFF333333),
                      fontSize: BaseUtil.dp(14),
                      fontWeight: FontWeight.bold
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: BaseUtil.dp(4))),
                Text(
                  strType,
                  style: TextStyle(
                    color: Color(0xFF999999),
                    fontSize: BaseUtil.dp(12),
                  ),
                )
              ],
            ),
            Expanded(flex: 1, child: Text("")),
            Container(
                alignment: Alignment.topRight,
                padding: EdgeInsets.all(BaseUtil.dp(5)),
                child: Text(
                  strTime,
                  style: TextStyle(
                    color: Color(0xFF666666),
                    fontSize: BaseUtil.dp(14),
                  ),
                )
            ),
          ],
        ),
      ));
    });
    return arrRet;
  }

}