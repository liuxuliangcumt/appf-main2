/*
 * 视频点播播放界面
 */

// @dart=2.9
import 'package:dong_gan_dan_che/common/WxUtil.dart';
import 'package:dong_gan_dan_che/pages/common/playVideo.dart';
import 'package:dong_gan_dan_che/pages/common/showBarrageWall.dart';
import 'package:dong_gan_dan_che/pages/common/showGift.dart';
import 'package:dong_gan_dan_che/pages/index/video/header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'footer.dart';

class PlayVideoPage extends StatefulWidget {
  final arguments;

  const PlayVideoPage({Key key, this.arguments}) : super(key: key);

  @override
  _PlayVideoPage createState() => _PlayVideoPage();
}

class _PlayVideoPage extends State<PlayVideoPage> {
  @override
  void initState() {
    super.initState();
    initPlay();
  }

  @override
  void dispose() {
    BaseUtil.changeSystemBarColorType('dark');
    exitPlay();
    super.dispose();
  }

  void initPlay() {
    WebSocketUtil.gSocket.mVideoId = widget.arguments["videoId"];
    /// 记录播放信息
    HttpUtil.getInstance().postJson(API.playVideo, params: {
      "videoId": widget.arguments["videoId"]
    }).then((response) {
      if (response == null) {
        return;
      }
      //先转json
      var json = jsonDecode(response.toString());
      if (json["code"] == null || json["code"] != 200) {
        return;
      }
    });
  }

  void exitPlay() {
    HttpUtil.getInstance().postJson(API.closeVideo, params: {
      "videoId": widget.arguments["videoId"]
    }).then((response) {
      if (response == null) {
        return;
      }
      //先转json
      var json = jsonDecode(response.toString());
      if (json["code"] == null || json["code"] != 200) {
        return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    BaseUtil.changeSystemBarColorType('light');
    var strVideoPath = BaseUtil.gBaseUrl + widget.arguments["videoPath"];
    List<Widget> arrWidget = [];
    arrWidget.add(PlayVideoTool(
        urlType: 1,
        strUrl: strVideoPath,
        boxWidth: MediaQuery.of(context).size.width,
        boxHeight: MediaQuery.of(context).size.height,
        barType: 1,
        initCb: () {},
        errorCb: () { Navigator.pop(context); },
    ));
    arrWidget.add(ShowBarrageWallPage());
    arrWidget.add(Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: DongGanDanCheVideoHeader(arguments: widget.arguments, onClose: () {
          Navigator.pop(context);
        })
    ));
    arrWidget.add(Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: DongGanDanCheVideoFooter(
        bIsAuthor: widget.arguments["authorId"] == BaseUtil.gStUser['id'],
        onSendVideoMessage: (msg) {
          if(msg == null || msg == "") {
            return;
          }
          WebSocketUtil.sendMessage("sendVideoChat", {
            "message": msg,
          });
        },
        onVideoShare: () {
          WxUtil.getInstance().shareVideo(widget.arguments);
        },
      )
    ));
    arrWidget.add(ShowGiftPage());
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          // 触摸收起键盘
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Center(
          child: Stack(
              children: arrWidget
          ),
        ),
      ),
    );
  }
}