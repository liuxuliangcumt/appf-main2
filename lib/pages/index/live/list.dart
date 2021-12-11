/*
 * 正在直播列表
 */
// @dart=2.9
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:dong_gan_dan_che/pages/common/service.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:dong_gan_dan_che/common/AgoraUtil.dart';


class LiveListPage extends StatefulWidget {
  final refreshController;

  LiveListPage(this.refreshController);

  @override
  _LiveListPage createState() => _LiveListPage();
}

class _LiveListPage extends State<LiveListPage> {
  StreamSubscription streamSubscription;

  @override
  void initState() {
    super.initState();
    var that = this;
    /// 接收到更新消息
    streamSubscription = EventUtil.gEventBus.on<UpdateIndexListEvent>().listen((event) {
      if (event.type == "Live") {
        that.setState(() {});
      }
    });
  }

  @override
  void dispose() {
    streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xfff1f5f6),
      child: Column(
          children: <Widget>[
            buildLiveHeader(context),
            buildLiveList(context),
          ]
      ),
    );
  }

  // 跳转直播间
  void _goToLiveRoom(context, item) {
    AgoraUtil.bIsAuthor = BaseUtil.gStUser["id"] == item["authorId"];
    AgoraUtil.watchLive(item, (channelName) {
      Navigator.pushNamed(context, '/AgoraLive', arguments: {
        "channelName": channelName,
        "role": AgoraUtil.bIsAuthor ? ClientRole.Broadcaster : ClientRole.Audience
      });
    });
  }

  Iterable<Widget> _numberList() {
    int liveDataLen = DongGanDanCheService.gMapPageList["Live"].nTotal;
    String liveDataLenStr = liveDataLen.toString();
    return liveDataLenStr.split('').map((number) => Image.asset(
      'assets/images/num/$number.webp',
      height: BaseUtil.dp(13),
    ));
  }

  // 直播人数信息
  Widget buildLiveHeader(context) {
    var numberList = _numberList();
    return Container(
      height: BaseUtil.dp(52),
      margin: EdgeInsets.only(
        left: BaseUtil.dp(15),
        right: BaseUtil.dp(15),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: BaseUtil.dp(25),
            margin: EdgeInsets.only(right: BaseUtil.dp(5)),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/common/cqe.webp'),
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '猜你喜欢',
              style: TextStyle(
                  color: Color(0xff333333),
                  fontSize: BaseUtil.dp(18),
                  fontWeight: FontWeight.bold
              ),
            ),
          ),
          Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: BaseUtil.dp(1.5)),
                child:  Text(
                  '当前',
                  style: TextStyle(
                    color: Color(0xfff8632e),
                    fontSize: BaseUtil.dp(13),
                  ),
                ),
              ),
              ...numberList,
              Padding(
                padding: EdgeInsets.only(left: BaseUtil.dp(1.5)),
                child: Text(
                  '位主播',
                  style: TextStyle(
                    color: Color(0xfff8632e),
                    fontSize: BaseUtil.dp(13),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: BaseUtil.dp(5)),
                child: Image.asset(
                  'assets/images/common/cfk.webp',
                  height: BaseUtil.dp(14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 直播列表
  Widget buildLiveList(context) {
    List liveData = DongGanDanCheService.gMapPageList["Live"].arr;
    if (liveData == null || liveData.length == null) {
      return Text("");
    }
    List<Widget> liveList = [];
    var fontStyle = TextStyle(
      color: Colors.white,
      fontSize: BaseUtil.dp(12),
    );
    var boxWidth = BaseUtil.dp(164);
    var imageHeight = BaseUtil.dp(170);
    var boxMargin = (BaseUtil.dp(375) - boxWidth * 2) / 3 / 2;
    liveData.asMap().keys.forEach((index) {
      var item = liveData[index];
      var strCover = item['liveCoverImage'] == null || item['liveCoverImage'] == "" ? BaseUtil.gDefaultImage : BaseUtil.gBaseUrl + item['liveCoverImage'];
      var onlineNum = item['onlineNum'] == null ? "0" : item['onlineNum'].toString();
      var liveTitle = item['liveTitle'] == null ? "" : item['liveTitle'];
      var authorNickName = item['authorNickName'] == null ? "" : item['authorNickName'];
      liveList.add(
        GestureDetector(
          onTap: () {
            _goToLiveRoom(context, item);
          },
          child: Padding(
            key: ObjectKey(item['liveId']),
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
                                      onlineNum,
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
                          SizedBox(
                            height: BaseUtil.dp(27),
                            child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(left: BaseUtil.dp(6), right: BaseUtil.dp(6)),
                                    width: boxWidth,
                                    child: Text(
                                      liveTitle,
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: BaseUtil.dp(13),
                                      ),
                                    ),
                                  )
                                ]
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(bottom: BaseUtil.dp(7.5),))
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
