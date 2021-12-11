/*
 * 我的收藏
 */

// @dart=2.9
import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:dong_gan_dan_che/pages/index/admin/header.dart';
import 'package:dong_gan_dan_che/pages/common/service.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AdminCollectionPage extends StatefulWidget {
  final Function onSwitchParentType;       /// 切换上级状态
  AdminCollectionPage({ @required this.onSwitchParentType });
  
  @override
  _AdminCollectionPage createState() => _AdminCollectionPage();
}

class _AdminCollectionPage extends State<AdminCollectionPage> {
  List<dynamic> arrRecordData = [];
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  StreamSubscription streamSubscription;

  @override
  void initState() {
    super.initState();
    var that = this;
    /// 接收到更新消息
    streamSubscription = EventUtil.gEventBus.on<UpdateIndexListEvent>().listen((event) {
      if (event.type == "RecordCollection") {
        that.setState(() {
          arrRecordData = DongGanDanCheService.gMapPageList["RecordCollection"].arr;
        });
      }
    });
    DongGanDanCheService.onRefresh("RecordCollection", { "userId": BaseUtil.gStUser["id"] }, _refreshController);
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
          AdminHeaderPage(title: "我的收藏", onBack: () { widget.onSwitchParentType(0); },),
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
                    onRefresh: () { DongGanDanCheService.onRefresh("RecordCollection", { "userId": BaseUtil.gStUser["id"] }, _refreshController); },
                    onLoading: () { DongGanDanCheService.onLoading("RecordCollection", { "userId": BaseUtil.gStUser["id"] }, _refreshController); },
                    child: CustomScrollView(
                      slivers: <Widget>[
                        SliverToBoxAdapter(
                          child: Container(
                            padding: EdgeInsets.only(top: BaseUtil.dp(20)),
                            child: Wrap(
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
    var fontStyle = TextStyle(
      color: Colors.white,
      fontSize: BaseUtil.dp(12),
    );
    var boxWidth = BaseUtil.dp(164);
    var imageHeight = BaseUtil.dp(200);
    var boxMargin = (BaseUtil.dp(375) - boxWidth * 2) / 3 / 2;

    arrRecordData.forEach((item) {
      var strCover = item['coverImage'] == null || item['coverImage'] == "" ? BaseUtil.gDefaultImage : BaseUtil.gBaseUrl + item['coverImage'];
      var liveTitle = item['collectionTitle'] == null ? "" : item['collectionTitle'];
      var authorNickName = item['authorName'] == null ? "" : item['authorName'];
      arrRet.add(
        GestureDetector(
          onTap: () {
            _goTo(context, item);
          },
          child: Padding(
            key: ObjectKey("${item['id']}type${item['type']}"),
            padding: EdgeInsets.only(
                left: boxMargin,
                right: boxMargin,
                bottom: boxMargin * 2
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.all(
                Radius.circular(BaseUtil.dp(10)),
              ),
              child: Container(
                width: boxWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    CachedNetworkImage(
                      imageUrl: strCover,
                      imageBuilder: (context, imageProvider) => Container(
                        height: imageHeight,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          children: <Widget>[
                            Positioned(
                              child: Container(
                                width: boxWidth,
                                height: BaseUtil.dp(25),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment(0, -.5),
                                    end: Alignment(0, 1.3),
                                    colors: <Color>[
                                      Color.fromRGBO(0, 0, 0, 0),
                                      Color.fromRGBO(0, 0, 0, .6),
                                    ],
                                  ),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: BaseUtil.dp(6),
                                          top: BaseUtil.dp(4)
                                      ),
                                      child:  Image.asset(
                                        'assets/images/common/member.png',
                                        height: BaseUtil.dp(12),
                                      ),
                                    ),
                                    Padding(padding: EdgeInsets.only(right: BaseUtil.dp(3))),
                                    Text(
                                      authorNickName,
                                      style: fontStyle,
                                    ),
                                  ],
                                ),
                              ),
                              bottom: 0,
                              left: 0,
                            ),
                          ],
                        ),
                      ),
                      placeholder: (context, url) => Image.asset(
                        'assets/images/common/default.jpg',
                        height: imageHeight,
                        fit: BoxFit.fill,
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.only(top: BaseUtil.dp(10), left: BaseUtil.dp(6), right: BaseUtil.dp(6)),
                            width: boxWidth,
                            child: Text(
                              liveTitle,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: BaseUtil.dp(14),
                                  color: Color(0xFF333333)
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
    return arrRet;
  }

  // 跳转直播间
  void _goTo(context, item) {
    Navigator.pushNamed(context, '/PlayVideo', arguments: item);
  }

}