/*
 * 车币界面: 点击个人中心的车币数量显示车币信息
 */
// @dart=2.9
import 'dart:async';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:dong_gan_dan_che/pages/common/service.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdminBiPage extends StatefulWidget {
  final Function onSwitchParentType;       /// 切换上级状态
  AdminBiPage({ @required this.onSwitchParentType });
  
  @override
  _AdminBiPage createState() => _AdminBiPage();
}

class _AdminBiPage extends State<AdminBiPage> {
  List<dynamic> arrRecordData = [];
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  StreamSubscription streamSubscription;
  String _listType = "RecordPay";

  @override
  void initState() {
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
    DongGanDanCheService.onRefresh(_listType, { "userId": BaseUtil.gStUser["id"] }, _refreshController);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    BaseUtil.changeSystemBarColorType('light');
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF9F9F9),
      ),
      child: Stack(
        children: [
          Container(
            height: BaseUtil.dp(233),
            child: Image.asset("assets/images/admin/bg.png", fit: BoxFit.cover,)
          ),
          Container(
            height: BaseUtil.dp(100),
            padding: EdgeInsets.fromLTRB(BaseUtil.dp(16), BaseUtil.dp(0), BaseUtil.dp(24), BaseUtil.dp(0)),
            child: Row(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () { widget.onSwitchParentType(0); },
                  child: Container(
                    width: BaseUtil.dp(32),
                    height: BaseUtil.dp(32),
                    child: Icon(
                      FontAwesomeIcons.angleLeft,
                      color: Colors.white,
                      size: BaseUtil.dp(20.0),
                    ),
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: Center(
                      child: Text(
                        "我的车币",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: BaseUtil.dp(16),
                        ),
                      ),
                    )
                ),
                Padding(padding: EdgeInsets.only(left: BaseUtil.dp(32))),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: BaseUtil.dp(157),
            margin: EdgeInsets.fromLTRB(BaseUtil.dp(16), BaseUtil.dp(133), BaseUtil.dp(16), BaseUtil.dp(0)),
            padding: EdgeInsets.all(BaseUtil.dp(16)),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(BaseUtil.dp(8)))
            ),
            child: Column(
              children: [
                Text(
                  "车币",
                  style: TextStyle(
                      color: Color(0xFF333333),
                      fontSize: BaseUtil.dp(16)
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: BaseUtil.dp(16))),
                Row(
                  children: [
                    Expanded(flex: 1, child: Text("")),
                    Text(
                      BaseUtil.gStUser["amount"] == null ? "0" : BaseUtil.gStUser["amount"].toString(),
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontSize: BaseUtil.dp(40),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(right: BaseUtil.dp(8))),
                    Container(
                      alignment: Alignment.bottomCenter,
                      padding: EdgeInsets.only(top: BaseUtil.dp(10)),
                      child: Text(
                        "个",
                        style: TextStyle(
                          color: Color(0xFF333333),
                          fontSize: BaseUtil.dp(16),
                        ),
                      ),
                    ),
                    Expanded(flex: 1, child: Text("")),
                  ],
                ),
                Padding(padding: EdgeInsets.only(top: BaseUtil.dp(16))),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: BaseUtil.dp(16)),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () { widget.onSwitchParentType(631); },
                        child: Row(
                          children: [
                            Container(
                              width: BaseUtil.dp(20),
                              height: BaseUtil.dp(20),
                              margin: EdgeInsets.only(right: BaseUtil.dp(10)),
                              child: Image.asset('assets/images/admin/recharge_record.png', fit: BoxFit.cover),
                            ),
                            Container(
                              child: Text(
                                "充值记录",
                                style: TextStyle(
                                  color: Color(0xFF333333),
                                  fontSize: BaseUtil.dp(14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(flex: 1, child: Text("")),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, "/recharge", arguments: () {
                            setState(() {});
                          });
                        },
                        child: Row(
                          children: [
                            Container(
                              width: BaseUtil.dp(20),
                              height: BaseUtil.dp(20),
                              margin: EdgeInsets.only(right: BaseUtil.dp(10)),
                              child: Image.asset('assets/images/admin/recharge.png', fit: BoxFit.cover),
                            ),
                            Container(
                              margin: EdgeInsets.only(right: BaseUtil.dp(10)),
                              child: Text(
                                "充值",
                                style: TextStyle(
                                  color: Color(0xFF333333),
                                  fontSize: BaseUtil.dp(14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(top: BaseUtil.dp(306)),
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(BaseUtil.dp(16)),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 1,
                        color: Color(0xFFEEEEEE),
                      )
                    )
                  ),
                  child: Text(
                    "车币记录",
                    style: TextStyle(
                      color: Color(0xFF333333),
                      fontSize: BaseUtil.dp(16)
                    ),
                  )
                ),
                Expanded(
                  flex: 1,
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
                        onRefresh: () { DongGanDanCheService.onRefresh(_listType, { "userId": BaseUtil.gStUser["id"] }, _refreshController); },
                        onLoading: () { DongGanDanCheService.onLoading(_listType, { "userId": BaseUtil.gStUser["id"] }, _refreshController); },
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
                )
              ],
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