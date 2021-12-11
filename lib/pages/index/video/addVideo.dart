/*
 * 添加上传视频界面
 */
// @dart=2.9
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:video_player/video_player.dart';

import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:dong_gan_dan_che/common/ImageUtil.dart';
import 'package:dong_gan_dan_che/common/VideoUtil.dart';

class DlgAddVideo extends Dialog {

  final state;
  DlgAddVideo({Key key, this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        onTap: () {
          // 触摸收起键盘
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DlgAddVideoBody()
          ],
        ),
      ),
    );
  }
}

class DlgAddVideoBody extends StatefulWidget {
  @override
  _DlgAddVideoBody createState() => _DlgAddVideoBody();
}

class _DlgAddVideoBody extends State<DlgAddVideoBody> {
  String strVideoName = "";
  String strCoverImagePath = "";
  String strVideoPath = "";
  String strHttpCover = "";
  String strHttpVideo = "";
  TextEditingController controllerVideoName = TextEditingController(text: "");
  //定义一个VideoPlayerController
  VideoPlayerController _controller;

  @override
  void dispose() {
    super.dispose();
    strVideoName = "";
    strCoverImagePath = "";
    strVideoPath = "";
    if (_controller != null) {
      _controller.pause();
      _controller?.dispose();
      _controller = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
          width: BaseUtil.dp(320),
          height: BaseUtil.dp(380),
          padding: EdgeInsets.only(
            left: BaseUtil.dp(30),
            right: BaseUtil.dp(30),
            top: BaseUtil.dp(15),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
          child: Column(
            children: [
              Container(
                child: Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: Text('发布视频',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              )
                          )
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Image.asset('assets/images/common/close.webp',
                          width: BaseUtil.dp(15),
                        ),
                      ),
                    ]
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: BaseUtil.dp(15), bottom: BaseUtil.dp(5)),
                alignment: Alignment.centerLeft,
                child: Text(
                  "视频名称",
                  style: TextStyle(
                      fontSize: BaseUtil.dp(14),
                      color: Color(0xFF333333)
                  ),
                ),
              ),
              Container (
                alignment: Alignment.bottomLeft,
                child: TextField(
                  controller: controllerVideoName,
                  keyboardType: TextInputType.text,
                  style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.black
                  ),
                  decoration: InputDecoration(
                    /// 设置输入框高度
                      isCollapsed: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: BaseUtil.dp(8), vertical: BaseUtil.dp(5)),
                      hintText: "输入视频名称",
                      hintStyle: TextStyle(fontSize: 14.0)
                  ),
                  onSubmitted: (_) {
//                              focusNodePwd.requestFocus();
                  },
                  textInputAction: TextInputAction.go,
                ),
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container (
                        padding: EdgeInsets.only(top: BaseUtil.dp(15), bottom: BaseUtil.dp(10)),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "选择封面",
                          style: TextStyle(
                              fontSize: BaseUtil.dp(14),
                              color: Color(0xFF333333)
                          ),
                        ),
                      ),
                      Container (
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () {
                            strVideoName = controllerVideoName.text;
                            ImageUtil.showSelectPicker(context, (file) {
                              setState((){
                                strCoverImagePath = file.path;
                              });
                            });
                          },
                          child: Container(
                              alignment: Alignment.bottomLeft,
                              child: Stack(
                                children: [
                                  Container(
                                      width: BaseUtil.dp(120),
                                      height: BaseUtil.dp(100),
                                      padding: EdgeInsets.only(top: BaseUtil.dp(10), bottom: BaseUtil.dp(10), left: BaseUtil.dp(10), right: BaseUtil.dp(10)),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1,
                                            color: Color(0xFFDDDDDD),
                                            style: BorderStyle.solid
                                        ),
                                      ),
                                      child: ImageUtil.buildCameraImage(strCoverImagePath, BoxFit.cover)
                                  ),
                                ],
                              )
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(""),
                  ),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container (
                          padding: EdgeInsets.only(top: BaseUtil.dp(15), bottom: BaseUtil.dp(10)),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "选择视频",
                            style: TextStyle(
                                fontSize: BaseUtil.dp(14),
                                color: Color(0xFF333333)
                            ),
                          ),
                        ),
                        Container (
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () {
                              strVideoName = controllerVideoName.text;
                              VideoUtil.showSelectPicker(context, (file) {
                                strVideoPath = file.path;
                                loadVideoInfo();
                              });
                            },
                            child: Container (
                                alignment: Alignment.bottomLeft,
                                child: Stack(
                                  children: [
                                    Container (
                                        width: BaseUtil.dp(120),
                                        height: BaseUtil.dp(100),
                                        padding: EdgeInsets.only(top: BaseUtil.dp(10), bottom: BaseUtil.dp(10), left: BaseUtil.dp(10), right: BaseUtil.dp(10)),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 1,
                                              color: Color(0xFFDDDDDD),
                                              style: BorderStyle.solid
                                          ),
                                        ),
                                        child: Stack(
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(top: BaseUtil.dp(1), bottom: BaseUtil.dp(1), left: BaseUtil.dp(1), right: BaseUtil.dp(3)),
                                              child: _controller != null && _controller.value.isInitialized
                                                  ? Center(child: AspectRatio(
                                                aspectRatio: _controller?.value?.aspectRatio,
                                                child: VideoPlayer(_controller),
                                              ))
                                                  : Container(),
                                            ),
                                            strVideoPath == null || strVideoPath == "" ?
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                              ),
                                              child: Image.asset("assets/images/common/camera.png", fit: BoxFit.cover),
                                            ): Container(
                                              child: Center(
                                                child: Opacity(
                                                  opacity: 0.3,
                                                  child: FloatingActionButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        _controller.value.isPlaying
                                                            ? _controller.pause()
                                                            : _controller.play();
                                                      });
                                                    },
                                                    child: Icon(
                                                      _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        )
                                    ),
                                  ],
                                )
                            ),
                          ),
                        ),
                      ]
                  )
                ],
              ),
              Expanded(
                flex: 1,
                child: Text(""),
              ),
              RawMaterialButton (
                fillColor: BaseUtil.gDefaultColor,
                elevation: 0,
                highlightElevation: 0,
                highlightColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                onPressed: () {
                  // 上传视频
                  uploadVideo(context);
                },
                child: Container(
                  height: BaseUtil.dp(40),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(BaseUtil.dp(4))),
                  ),
                  child: Center(
                    child: Text('上传发布',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: BaseUtil.dp(30)),
              )
            ],
          )
      );
  }

  void loadVideoInfo() async {
    if (strVideoPath == null || strVideoPath == "") {
      return;
    }
    try {
      if (_controller != null) {
        _controller.pause();
        await _controller?.dispose();
        _controller = null;
      }
      var cb = (_){
        _controller.play();
        setState((){});
      };
      if (strVideoPath.indexOf("http") > -1) {
        _controller = VideoPlayerController.network(strVideoPath)..initialize().then(cb);
      } else {
        _controller = VideoPlayerController.file(File(strVideoPath))..initialize().then(cb);
      }
    } catch (e) {

    }
  }

  void uploadVideo(context) {
    if (strVideoPath == null || strVideoPath == "") {
      CustomSnackBar(context, Text("请选择视频文件"));
      return;
    }
    EasyLoading.show(status: "视频上传中...");
    HttpUtil.getInstance().uploadFile(API.uploadVideo, "file", strVideoPath).then((response) {
      EasyLoading.dismiss();
      if (response == null) {
        CustomSnackBar(context, Text("上传失败"));
        return;
      }
      //先转json
      var json = jsonDecode(response.toString());
      if (json["code"] == null || json["code"] != 200) {
        CustomSnackBar(context, Text("上传失败"));
        return;
      }
      strHttpVideo = json["fileName"];
      uploadCoverImage(context);
    });
  }

  void uploadCoverImage(context) {
    EasyLoading.show(status: "封面上传中...");
    HttpUtil.getInstance().uploadFile(API.uploadFile, "file", strCoverImagePath).then((response) {
      EasyLoading.dismiss();
      if (response == null) {
        CustomSnackBar(context, Text("上传失败"));
        return;
      }
      //先转json
      var json = jsonDecode(response.toString());
      if (json["code"] == null || json["code"] != 200) {
        CustomSnackBar(context, Text("上传失败"));
        return;
      }
      strHttpCover = json["fileName"];
      addVideo(context);
    });
  }

  void addVideo(context) {
    EasyLoading.show(status: "数据保存中...");
    HttpUtil.getInstance().postJson(API.addVideo, params: {
      "videoName": controllerVideoName.text,
      "videoCover": strHttpCover,
      "videoPath": strHttpVideo,
      "times": _controller.value.duration.inSeconds
    }).then((response) {
      EasyLoading.dismiss();
      if (response == null) {
        CustomSnackBar(context, Text("上传失败"));
        return;
      }
      //先转json
      var json = jsonDecode(response.toString());
      if (json["code"] == null || json["code"] != 200) {
        CustomSnackBar(context, Text("上传失败"));
        return;
      }
      Navigator.pop(context);
    });
  }
}