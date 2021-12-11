/*
 * 视频点播列表
 */

// @dart=2.9
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:dong_gan_dan_che/pages/common/service.dart';

class VideoListPage extends StatefulWidget {
  final String type;
  final int userId;
  final refreshController;
  final needInit;
  VideoListPage(this.type, this.userId, this.refreshController, { this.needInit = true });

  @override
  _VideoListPage createState() => _VideoListPage();
}

class _VideoListPage extends State<VideoListPage> {
  StreamSubscription streamSubscription;

  @override
  void initState() {
    super.initState();
    var that = this;
    /// 接收到更新消息
    streamSubscription = EventUtil.gEventBus.on<UpdateIndexListEvent>().listen((event) {
      if (event.type == that.widget.type) {
        that.setState(() {});
      }
    });
    if (widget.needInit) {
      Future.delayed(Duration(milliseconds: 100),() async {
        var params = { "userId": widget.userId.toString() };
        DongGanDanCheService.onRefresh(widget.type, params, widget.refreshController);
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
    return buildVideoList(context);
  }

  // 跳转观看视频
  void _goToPlayVideo(context, item) {
    var strVideoPath = item["videoPath"];
    if (strVideoPath == null || strVideoPath == "") {
      CustomSnackBar(context, Text("视频被外星人抓走了！！"));
      return;
    }
    Navigator.pushNamed(context, '/PlayVideo', arguments: item);
  }

  // 视频列表
  Widget buildVideoList(context) {
    List videoData = DongGanDanCheService.gMapPageList[widget.type].arr;
    if (videoData == null) {
      return Text("");
    }
    List<Widget> liveList = [];
    var fontStyle = TextStyle(
      color: Colors.white,
      fontSize: BaseUtil.dp(12),
    );
    var boxWidth = BaseUtil.dp(164);
    var imageHeight = BaseUtil.dp(200);
    var boxMargin = (BaseUtil.dp(375) - boxWidth * 2) / 3 / 2;

    videoData.asMap().keys.forEach((index) {
      var item = videoData[index];
      var strCover = item['videoCover'] == null || item['videoCover'] == "" ? BaseUtil.gDefaultImage : BaseUtil.gBaseUrl + item['videoCover'];
      var playNum = item['playNum'] == null ? "0" : item['playNum'].toString();
      var liveTitle = item['videoName'] == null ? "" : item['videoName'];
      var authorNickName = item['authorName'] == null ? "" : item['authorName'];
      liveList.add(
        GestureDetector(
          onTap: () {
            _goToPlayVideo(context, item);
          },
          child: Padding(
            key: ObjectKey(item['id']),
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
                                width: BaseUtil.dp(120),
                                height: BaseUtil.dp(18),
                                padding: EdgeInsets.only(right: BaseUtil.dp(6)),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment(-.4, 0.0),
                                    end: Alignment(1, 0.0),
                                    colors: <Color>[
                                      Color.fromRGBO(0, 0, 0, 0),
                                      Color.fromRGBO(0, 0, 0, .6),
                                    ],
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Image.asset(
                                      'assets/images/common/hot.png',
                                      height: BaseUtil.dp(14),
                                    ),
                                    Padding(padding: EdgeInsets.only(right: BaseUtil.dp(3))),
                                    Text(
                                      playNum,
                                      style: fontStyle,
                                    ),
                                  ],
                                ),
                              ),
                              top: 0,
                              right: 0,
                            ),
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

    return Wrap(
      children: liveList,
    );
  }
}