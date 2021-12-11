/*
 * 比赛列表
 */

// @dart=2.9
import 'dart:async';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:dong_gan_dan_che/pages/common/service.dart';

class MatchListPage extends StatefulWidget {
  final String type;
  final int userId;
  final refreshController;
  final needInit;

  MatchListPage(this.type, this.userId, this.refreshController,
      {this.needInit = true});

  @override
  _MatchListPage createState() => _MatchListPage();
}

class _MatchListPage extends State<MatchListPage> {
  StreamSubscription streamSubscription;

  @override
  void initState() {
    super.initState();
    var that = this;

    /// 接收到更新消息
    streamSubscription =
        EventUtil.gEventBus.on<UpdateIndexListEvent>().listen((event) {
      if (event.type == that.widget.type) {
        that.setState(() {});
      }
    });
    if (widget.needInit) {
      Future.delayed(Duration(milliseconds: 100), () async {
        var params = {"userId": widget.userId.toString()};
        DongGanDanCheService.onRefresh(
            widget.type, params, widget.refreshController);
      });
    }
  }

  @override
  void dispose() {
    streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildMatchList(context);
  }

  // 跳转观看视频
  void _goToMatchDetail(context, item) {
    Navigator.pushNamed(context, '/match/detail', arguments: item);
    FocusScope.of(context).requestFocus(FocusNode());
  }

  // 直播列表详情
  Widget buildMatchList(context) {
    List matchData = DongGanDanCheService.gMapPageList[widget.type].arr;
    if (matchData == null) {
      return Text("");
    }
    List<Widget> matchList = [];

    var boxWidth = BaseUtil.dp(343);
    var boxHeight = BaseUtil.dp(146);

    matchData.asMap().keys.forEach((index) {
      var item = matchData[index];
      var strImage = item['image'] == null || item['image'].length < 10
          ? BaseUtil.gDefaultImage
          : BaseUtil.gBaseUrl + item['image'];
      var startTime =
          item['startTime'] == null ? "2021-10-01 10:10:10" : item['startTime'];
      startTime =
          DateFormat("yyyy-MM-dd HH:mm").format(DateTime.parse(startTime));
      var name = item['name'] == null ? "" : item['name'];
      var matchType = item["type"] == null ? 1 : int.parse(item["type"]);
      var strTypeName = gArrMatchType[matchType - 1];
      var nMaxPeople = item["maxPeople"] == null ? 2 : item["maxPeople"];
      var strPeopleTypeName = "";
      switch (nMaxPeople) {
        case 2:
          {
            strPeopleTypeName = gArrMatchPeopleType[0];
          }
          break;
        case 3:
          {
            strPeopleTypeName = gArrMatchPeopleType[1];
          }
          break;
        case 6:
          {
            strPeopleTypeName = gArrMatchPeopleType[2];
          }
          break;
        default:
          {
            strPeopleTypeName = gArrMatchPeopleType[3];
          }
          break;
      }
      var status = item["status"] == null ? '0' : item["status"];

      /// 学员比赛未开始，显示提示报名
      var showTip = BaseUtil.gStUser["userType"] == 102 &&
          status == '0' &&
          DateTime.parse(startTime).difference(DateTime.now()).inSeconds > 0;
      matchList.add(
        GestureDetector(
          onTap: () {
            _goToMatchDetail(context, item);
          },
          child: Padding(
            key: ObjectKey(item['id']),
            padding: EdgeInsets.only(bottom: BaseUtil.dp(15)),
            child: ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular(BaseUtil.dp(8)),
                ),
                child: Container(
                  width: boxWidth,
                  color: Color(0xFFEEEBE9),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(BaseUtil.dp(14),
                            BaseUtil.dp(16), BaseUtil.dp(14), BaseUtil.dp(16)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              constraints:
                                  BoxConstraints(maxWidth: BaseUtil.dp(150)),
                              child: Text(
                                name,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: BaseUtil.dp(16)),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: BaseUtil.dp(10)),
                            ),
                            Container(
                              child: Text(
                                startTime,
                                style: TextStyle(
                                    color: Color(0xFF666666),
                                    fontSize: BaseUtil.dp(12)),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: BaseUtil.dp(16)),
                            ),
                            Container(
                                child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: BaseUtil.dp(4),
                                      horizontal: BaseUtil.dp(16)),
                                  decoration: BoxDecoration(
                                      color: BaseUtil.gDefaultColor,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(BaseUtil.dp(23)))),
                                  child: Text(
                                    strPeopleTypeName,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: BaseUtil.dp(10)),
                                  ),
                                )
                              ],
                            )),
                            Padding(
                              padding: EdgeInsets.only(top: BaseUtil.dp(10)),
                            ),
                            Container(
                                child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: BaseUtil.dp(4),
                                      horizontal: BaseUtil.dp(16)),
                                  decoration: BoxDecoration(
                                      color: BaseUtil.gDefaultColor,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(BaseUtil.dp(23)))),
                                  child: Text(
                                    strTypeName,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: BaseUtil.dp(10)),
                                  ),
                                )
                              ],
                            )),
                            Padding(
                              padding: EdgeInsets.only(top: BaseUtil.dp(14)),
                            ),
                            showTip
                                ? Container(
                                    child: Text(
                                      "点击报名 > ",
                                      style: TextStyle(
                                          color: BaseUtil.gDefaultColor,
                                          fontSize: BaseUtil.dp(12)),
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: CachedNetworkImage(
                          imageUrl: strImage,
                          imageBuilder: (context, imageProvider) => Container(
                            height: boxHeight,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                          ),
                          placeholder: (context, url) => Image.asset(
                            'assets/images/common/default.jpg',
                            height: boxHeight,
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ),
        ),
      );
    });

    return Wrap(
      children: matchList,
    );
  }
}
