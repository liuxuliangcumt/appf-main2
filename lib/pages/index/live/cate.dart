/*
 * 当前账户关注的主播列表
 */
// @dart=2.9
import 'dart:async';

import 'package:flutter/material.dart';


// import 'package:cached_network_image/cached_network_image.dart';

import '../../../common/BaseUtil.dart';
import '../../common/service.dart';

class CateList extends StatefulWidget {
  @override
  _CateList createState() => _CateList();
}

class _CateList extends State<CateList> {
  StreamSubscription streamSubscription;
  double scrollRatio = 0;
  List<dynamic> mArrList = [];
  String _listType = "Follow";
  final arrDefaultSwiper = [
    "https://www.reciprocalaffection.com/uploads/DongGanDanChe/banner/1.jpg",
    "https://www.reciprocalaffection.com/uploads/DongGanDanChe/banner/2.jpg"
  ];

  @override
  void initState() {
    super.initState();
    var that = this;
    /// 接收到更新消息
    streamSubscription = EventUtil.gEventBus.on<UpdateIndexListEvent>().listen((event) {
      if (event.type == _listType) {
        that.setState(() {
          mArrList = DongGanDanCheService.gMapPageList[_listType].arr;
        });
      }
    });
    DongGanDanCheService.onRefresh(_listType, { "userId": BaseUtil.gStUser["id"] }, null);
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _renderWidget(context);
  }

  Widget _renderWidget(context) {
    if (mArrList.isEmpty) {
      return Text("");
    }
    List<Widget> tabList = [];
    mArrList.forEach((item) {
      var strAvatar = item["avatar"] == null || item["avatar"] == "" ? BaseUtil.gDefaultAvatar : BaseUtil.gBaseUrl + item["avatar"];
      var strName = item["nickName"] == null ? "" : item["nickName"];
      var avatar = Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white,
            width: 1,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.white,
              offset: Offset(0.0, 0.0),
              blurRadius: 3.0,
            ),
          ],
        ),
        child: ClipOval(
            child: DongGanDanCheService.tryBuildImage(strAvatar, BoxFit.cover)
        ),
      );
      tabList.add(InkWell(
        onTap: () => DongGanDanCheDialog.alert(
            context,
            title: strName,
            text: '年轻人不讲武德，偷袭！\n我还没上线呢...',
            yes: '😭 好的,下次再战'
        ),
        child: Container(
          width: BaseUtil.dp(375 / 5),
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              avatar,
              Padding(padding: EdgeInsets.only(top: BaseUtil.dp(7)),),
              Container(
                width: BaseUtil.dp(40),
                child: Text(
                  strName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xff888888),
                    fontSize: BaseUtil.dp(13.5),
                  ),
                ),
              )
            ],
          ),
        ),
      ));
    });
    double indicatorBoxWidth = BaseUtil.dp(34);
    double indicatorHeight = BaseUtil.dp(3.5);
    double indicatorWidth = BaseUtil.dp(15);
    double scrollValue = scrollRatio * (indicatorBoxWidth - indicatorWidth);

    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.only(left: BaseUtil.dp(15)),
          child: Text(
              '我的关注',
              style: TextStyle(
                color: Color(0xff333333),
                fontSize: BaseUtil.dp(18),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left
          ),
        ),
        Container(
          height: BaseUtil.dp(80),
          child: NotificationListener(
            onNotification: (ScrollNotification note) {
              setState(() {
                scrollRatio = note.metrics.pixels / note.metrics.maxScrollExtent;
              });
              return true;
            },
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.all(0),
              children: tabList,
            ),
          ),
        ),
        SizedBox(
          height: BaseUtil.dp(18),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.all(
                Radius.circular(indicatorHeight / 2),
              ),
              child: Container(
                width: indicatorBoxWidth,
                height: indicatorHeight,
                color: Color(0xffd0d0d0),
                child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Positioned(
                        left: scrollValue,
                        child: Container(
                          width: indicatorWidth,
                          height: indicatorHeight,
                          color: Color(0xffff5d24),
                        ),
                      )
                    ]
                ),
              ),
            ),
          ),
        ),
        Padding(padding: EdgeInsets.only(top: BaseUtil.dp(6)),)
      ],
    );
  }

}