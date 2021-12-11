/*
 * 视频点播首页
 */
// @dart=2.9
import 'dart:async';

import 'package:dong_gan_dan_che/pages/index/video/list.dart';
import 'package:flutter/material.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../common/BaseUtil.dart';
import '../../common/service.dart';
import '../header.dart';
import 'addVideo.dart';

class VideoIndexPage extends StatefulWidget {
  final _scrollController;
  VideoIndexPage(this._scrollController);

  @override
  _VideoListPage createState() => _VideoListPage(this._scrollController);
}

class _VideoListPage extends State<VideoIndexPage> with AutomaticKeepAliveClientMixin  {
  final GlobalKey<NestedScrollViewState> _viewKey = new GlobalKey<NestedScrollViewState>();
  StreamSubscription streamSubscription;
  RefreshController _refresh1 = RefreshController(initialRefresh: false);
  RefreshController _refresh2 = RefreshController(initialRefresh: false);
  String _strSearchKey = "";
  final _scrollController;

  _VideoListPage(this._scrollController);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _strSearchKey = "";
    super.initState();
    streamSubscription = EventUtil.gEventBus.on<SwitchIndexPageEvent>().listen((event) {
      if (event.pageIndex != 1) {
        return;
      }
      if (DefaultTabController.of(_viewKey.currentContext).index == 1) {
        var params = { "searchKey": _strSearchKey, "userId": BaseUtil.gStUser["id"] };
        DongGanDanCheService.onRefresh("VideoCollection", params, _refresh2);
      } else {
        var params = { "searchKey": _strSearchKey };
        DongGanDanCheService.onRefresh("Video", params, _refresh1);
      }
    });
  }

  @override
  void dispose() {
    _refresh1?.dispose();
    _refresh2?.dispose();
    streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    BaseUtil.changeSystemBarColorType('dark');
    super.build(context);
    List navList = ["全部", "关注"];
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          margin: EdgeInsets.only(top: BaseUtil.dp(30)),
          child: DefaultTabController(
            length: navList.length,
            child: NestedScrollView(  // 嵌套式滚动视图
              key: _viewKey,
              controller: _scrollController,
              headerSliverBuilder: (context, innerScrolled) => <Widget>[
                MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  /// 使用[SliverAppBar]组件实现下拉收起头部的效果
                  child: SliverAppBar(
                    backgroundColor: Colors.white,
                    brightness: Brightness.dark,
                    pinned: true,
                    floating: true,
                    snap: true,
                    actions: <Widget>[
                      DongGanDanCheHeader(
                        addCallBack: () {
                          addVideo();
                        },
                        searchCallBack: (val) {
                          _strSearchKey = val;
                          if (DefaultTabController.of(_viewKey.currentContext).index == 1) {
                            var params = { "searchKey": _strSearchKey, "userId": BaseUtil.gStUser["id"] };
                            DongGanDanCheService.onRefresh("VideoCollection", params, _refresh2);
                          } else {
                            var params = { "searchKey": _strSearchKey };
                            DongGanDanCheService.onRefresh("Video", params, _refresh1);
                          }
                        },
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                        ),
                      ),
                    ],
                    expandedHeight: BaseUtil.dp(89), // 40 + 49
                    bottom: PreferredSize(
                      preferredSize: Size.fromHeight(BaseUtil.dp(49)),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(left: BaseUtil.dp(16)),
                        child: TabBar(
                          isScrollable: true,
                          //设置tab文字得类型
                          unselectedLabelStyle: TextStyle(
                            fontSize: 15,
                          ),
                          labelStyle: TextStyle(
                            fontSize: 18,
                          ),
                          //设置tab选中得颜色
                          labelColor: Colors.black,
                          //设置tab未选中得颜色
                          unselectedLabelColor: Color(0xFF666666),
                          //设置自定义tab的指示器，CustomUnderlineTabIndicator
                          //若不需要自定义，可直接通过
                          indicatorColor: Colors.black87,  // 设置指示器颜色
                          indicatorWeight: 3,  // 设置指示器厚度
                          //indicatorPadding
                          //indicatorSize  设置指示器大小计算方式
                          ///指示器大小计算方式，TabBarIndicatorSize.label跟文字等宽,TabBarIndicatorSize.tab跟每个tab等宽
                          // indicatorSize: TabBarIndicatorSize.label,
                          tabs: navList.map((e) => Tab(text: e)).toList(),
                        ),
                      ),
                    ),
                    forceElevated: innerScrolled,
                  )
                ),
              ],
              body: TabBarView(
                children: navList.asMap().map((i, tab) => MapEntry(i, Builder(
                  builder: (context) => Container(
                    color: Colors.white,
                    child: ScrollConfiguration(
                      behavior: DongGanDanCheBehaviorNull(),
                      child: RefreshConfiguration(
                        headerTriggerDistance: BaseUtil.dp(89), // 40 + 49
                        maxOverScrollExtent : BaseUtil.dp(89),
                        footerTriggerDistance: BaseUtil.dp(40),
                        maxUnderScrollExtent: 0,
                        headerBuilder: () => DongGanDanCheRefreshHeader(),
                        footerBuilder: () => DongGanDanCheRefreshFooter(),
                        child: SmartRefresher(
                          enablePullDown: true,
                          enablePullUp: true,
                          footer: DongGanDanCheRefreshFooter(bgColor: Color(0xfff1f5f6),),
                          controller: i == 0 ? _refresh1 : _refresh2,
                          onRefresh: () {
                            if (DefaultTabController.of(_viewKey.currentContext).index == 1) {
                              var params = { "searchKey": _strSearchKey, "userId": BaseUtil.gStUser["id"] };
                              DongGanDanCheService.onRefresh("VideoCollection", params, _refresh2);
                            } else {
                              var params = { "searchKey": _strSearchKey };
                              DongGanDanCheService.onRefresh("Video", params, _refresh1);
                            }
                          },
                          onLoading: () {
                            if (DefaultTabController.of(_viewKey.currentContext).index == 1) {
                              var params = { "searchKey": _strSearchKey, "userId": BaseUtil.gStUser["id"] };
                              DongGanDanCheService.onLoading("VideoCollection", params, _refresh2);
                            } else {
                              var params = { "searchKey": _strSearchKey };
                              DongGanDanCheService.onLoading("Video", params, _refresh1);
                            }
                          },
                          child: CustomScrollView(
                            // physics: BouncingScrollPhysics(),
                            slivers: <Widget>[
                              SliverToBoxAdapter(
                                child: Container(
                                  child: Column(
                                    children: [
                                      Padding(padding: EdgeInsets.only(top: BaseUtil.dp(10))),
                                      VideoListPage(i == 0 ? "Video" : "VideoCollection", 0, i == 0 ? _refresh1 : _refresh2, needInit: false),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),),
                ).values.toList(),
              ),
            ),
          ),
        )
    );
  }

  /// 添加视频
  void addVideo() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, state) {
              return DlgAddVideo(state: state);
            },
          );
        }
    );
  }

}