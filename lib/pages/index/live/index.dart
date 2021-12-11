/*
 * 直播首页
 */
// @dart=2.9
import 'dart:async';

import 'package:flutter/material.dart';


import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../common/BaseUtil.dart';
import '../../common/service.dart';
import '../header.dart';
import 'swiper.dart';
import 'list.dart';
import 'cate.dart';

import 'package:dong_gan_dan_che/pages/agora/open.dart';

class LiveIndexPage extends StatefulWidget {
  final _scrollController;
  LiveIndexPage(this._scrollController);

  @override
  _LiveIndexPage createState() => _LiveIndexPage(this._scrollController);
}

class _LiveIndexPage extends State<LiveIndexPage> with AutomaticKeepAliveClientMixin  {
  StreamSubscription streamSubscription;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  String _strSearchKey = "";
  final _scrollController;

  _LiveIndexPage(this._scrollController);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _strSearchKey = "";
    streamSubscription = EventUtil.gEventBus.on<SwitchIndexPageEvent>().listen((event) {
      if (event.pageIndex != 0) {
        return;
      }
      DongGanDanCheService.onRefresh("Live", { "status": "1", "searchKey": _strSearchKey }, _refreshController);
    });
    if (_scrollController != null) {

    }
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
    super.build(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Padding(padding: EdgeInsets.only(top: BaseUtil.dp(30))),
            DongGanDanCheHeader(
              addCallBack: () {
                showOpenLive();
              },
              searchCallBack: (val) {
                _strSearchKey = val;
                DongGanDanCheService.onRefresh("Live", { "status": "1", "searchKey": _strSearchKey }, _refreshController);
              },
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
            ),
            Expanded(
              flex: 1,
              child: ScrollConfiguration(
                behavior: DongGanDanCheBehaviorNull(),
                child: RefreshConfiguration(
                  headerTriggerDistance: BaseUtil.dp(50),
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
                    onRefresh: () { DongGanDanCheService.onRefresh("Live", { "status": "1", "searchKey": _strSearchKey }, _refreshController); },
                    onLoading: () { DongGanDanCheService.onLoading("Live", { "status": "1", "searchKey": _strSearchKey }, _refreshController); },
                    child: CustomScrollView(
                      // physics: BouncingScrollPhysics(),
                      slivers: <Widget>[
                        SliverToBoxAdapter(
                          child: Container(
                            child: Column(
                              children: [
                                SwiperListPage(1),
                                CateList(),
                                // BroadcastSwiper(),
                                LiveListPage(_refreshController),
                              ],
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
    );
  }

  void showOpenLive() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, state) {
              return DlgOpenLive(state: state);
            },
          );
        }
    );
  }

}