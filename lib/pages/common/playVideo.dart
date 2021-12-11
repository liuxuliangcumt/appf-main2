/*
 * 视频播放页面封装
 */

// @dart=2.9
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:dong_gan_dan_che/common/BaseUtil.dart';

class PlayVideoTool extends StatefulWidget {
  // 类型: 1、网络，2、文件，3、项目资源
  final int urlType;
  // 工具栏样式：1、下方显示播放按钮+进度条+时间；2、居中显示播放按钮
  final int barType;
  // 路径
  final String strUrl;
  // 容器宽度
  final double boxWidth;
  // 容器高度
  final double boxHeight;
  // 初始化回调
  final Function initCb;
  // 初始化回调
  final Function errorCb;

  const PlayVideoTool({
    Key key,
    this.urlType,
    this.barType,
    this.strUrl,
    this.boxWidth,
    this.boxHeight,
    this.initCb,
    this.errorCb,
  }) : super(key: key);

  @override
  _PlayVideoTool createState() => _PlayVideoTool();
}

class _PlayVideoTool extends State<PlayVideoTool> {
  ///定义一个VideoPlayerController
  VideoPlayerController _controller;
  ///视频播放比
  var _playPos;

  @override
  void initState() {
    super.initState();

    initPlay();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void initPlay() {
    _playPos = 0.0;
    if (widget.strUrl == null || widget.strUrl == "") {
      return;
    }
    try {
      var cb = (_){
        setState((){});
        widget?.initCb();
        _controller.play();
      };
      switch (widget.urlType) {
        case 1: {
          _controller = VideoPlayerController.network(widget.strUrl)..initialize().then(cb);
        } break;
        case 2: {
          _controller = VideoPlayerController.file(File(widget.strUrl))..initialize().then(cb);
        } break;
      }
      /// 执行监听，只要有内容就会刷新
      _controller.addListener(() {
        setState(() {
          if (_controller.value.duration.inSeconds > 0) {
            /// 进度条的播放进度，用当前播放时间除视频总长度得到
            _playPos = _controller.value.position.inSeconds / _controller.value.duration.inSeconds;
          }
        });
      });
    } catch (e) {
      CustomSnackBar(context, Text("视频加载失败"));
    }
  }

  @override
  Widget build(BuildContext context) {
    var bIsInitialized = _controller != null && _controller.value != null && _controller.value.isInitialized;
    List<Widget> arr = [];
    if (bIsInitialized) {
      arr.add(Container(
        child:Center(
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
        ),
      ));
    } else {
      arr.add(Container(
        child:Center(
          //视频加载时的圆型进度条
          child: CircularProgressIndicator(
            strokeWidth: 4.0,
            backgroundColor: Colors.white54,
            // value: 0.2,
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ));
    }
    switch (widget.barType) {
      case 1: {
        var strPos = "${_controller.value.position}";
        strPos = strPos.split(".")[0];
        var strLen = "${_controller.value.duration}";
        strLen = strLen.split(".")[0];

        arr.add(Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
                alignment: Alignment.bottomCenter,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _controller.value.isPlaying
                              ? _controller.pause()
                              : _controller.play();
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.only(left: BaseUtil.dp(16), right: BaseUtil.dp(6)),
                        child: _controller != null ? Icon(
                          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                        ) : Container(),
                      ),
                    ),
                    Expanded (
                      flex: 1,
                      child: Container(
                        child: LinearProgressIndicator( /// 视频进度条
                          backgroundColor: Colors.white54,
                          value: _playPos,
                          valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(left: BaseUtil.dp(10)),),
                    Text(
                      "$strPos / $strLen",
                      style: TextStyle(
                        color: Colors.white
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(left: BaseUtil.dp(16)),)
                  ],
                )
            )
        ));
      } break;
      case 2: {
        arr.add(Container(
          child: Center (
            child: Opacity(
              opacity: 0.5,
              child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
                child: _controller != null ? Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                ) : Container(),
              ),
            ),
          ),
        ));
      } break;
    }
    return Container(
      width: widget.boxWidth,
      height: widget.boxHeight,
      child: Stack(
        children: arr,
      ),
    );
  }
}