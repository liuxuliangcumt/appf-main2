// @dart=2.9
/*
 * @discripe: 开播弹出窗口
 */

import 'package:dong_gan_dan_che/common/AgoraUtil.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';

import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:dong_gan_dan_che/common/ImageUtil.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:permission_handler/permission_handler.dart';


class DlgOpenLive extends Dialog {

  final state;
  DlgOpenLive({Key key, this.state}) : super(key: key);

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
            DlgOpenLiveBody()
          ],
        ),
      ),
    );
  }

}


class DlgOpenLiveBody extends StatefulWidget {
  @override
  _DlgOpenLiveBody createState() => _DlgOpenLiveBody();
}

class _DlgOpenLiveBody extends State<DlgOpenLiveBody> {
  String strLiveName = "";
  String strCoverImagePath = "";
  String strHttpFile = "";
  TextEditingController controllerLiveName = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    strLiveName = "";
    strCoverImagePath = "";
    strHttpFile = "";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: BaseUtil.dp(300),
      height: BaseUtil.dp(360),
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
                      child: Text('开启直播',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          )
                      )
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      AgoraUtil.liveTitle = "";
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
              "直播间名称",
              style: TextStyle(
                  fontSize: BaseUtil.dp(14),
                  color: Color(0xFF333333)
              ),
            ),
          ),
          Container (
            alignment: Alignment.bottomLeft,
            child: TextField(
              controller: controllerLiveName,
              keyboardType: TextInputType.text,
              style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.black
              ),
              decoration: InputDecoration(
//                      border: InputBorder.none,,
                  isCollapsed: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  hintText: "输入直播间名称",
                  hintStyle: TextStyle(fontSize: 14.0)
              ),
              onSubmitted: (_) {
              },
              textInputAction: TextInputAction.go,
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: BaseUtil.dp(15), bottom: BaseUtil.dp(10)),
            alignment: Alignment.centerLeft,
            child: Text(
              "直播间封面",
              style: TextStyle(
                  fontSize: BaseUtil.dp(14),
                  color: Color(0xFF333333)
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
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
              switchToLive(context);
            },
            child: Container(
              height: BaseUtil.dp(40),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(BaseUtil.dp(4))),
              ),
              child: Center(
                child: Text('开始直播',
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
      ),
    );
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
      strHttpFile = json["fileName"];
      getAgoraToken(context);
    });
  }

  void getAgoraToken(context) async {
    EasyLoading.show(status: "准备开始直播...");
    HttpUtil.getInstance().postJson(API.openLive, params: {
      "liveTitle": controllerLiveName.text,
      "liveCoverImage": strHttpFile
    }).then((response) async {
      EasyLoading.dismiss();
      if (response == null) {
        CustomSnackBar(context, Text("获取失败"));
        return;
      }
      var json = jsonDecode(response.toString());
      if (json["code"] != 200) {
        CustomSnackBar(context, Text(json["msg"]));
        return;
      }
      var data = json["data"];
      AgoraUtil.agoraAppId = data["agoraAppId"];
      AgoraUtil.agoraToken = data["agoraToken"];
      AgoraUtil.liveTitle = data["liveTitle"];
      AgoraUtil.liveId = data["liveId"];
      AgoraUtil.liveCode = data["liveCode"];
      AgoraUtil.bIsAuthor = true;
      AgoraUtil.liveInfo = data;
      /// 先判断有没有相机使用权限, 如果没有,弹出提示
      if(await Permission.camera.request().isGranted) {
        /// 麦克风权限
        if (await Permission.microphone.request().isGranted) {
          Navigator.of(context).pop();
          Navigator.pushNamed(context, '/AgoraLive', arguments: {
            "channelName": AgoraUtil.liveCode, // 房间号
            "role": ClientRole.Broadcaster
          });
        }
      }
    });
  }

  void switchToLive(context) {
    if (strCoverImagePath == null || strCoverImagePath.length < 10) {
      CustomSnackBar(context, Text("请选择封面"));
      return;
    }
    AgoraUtil.liveTitle = strLiveName;
    uploadCoverImage(context);
  }
}
