/*
 * 配置服务器
 */
// @dart=2.9
import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:dong_gan_dan_che/common/HttpUtil.dart';

import 'package:flutter/material.dart';


class DlgServer extends Dialog {
  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ServerManager()
        ],
      ),
    );
  }
}


class ServerManager extends StatefulWidget {
  @override
  _ServerManager createState() => _ServerManager();
}

class _ServerManager extends State<ServerManager> {
  TextEditingController controllerSchema = TextEditingController();
  TextEditingController controllerHost = TextEditingController();
  TextEditingController controllerPort = TextEditingController();
  final FocusNode focusNodeSchema = FocusNode();
  final FocusNode focusNodeHost = FocusNode();
  final FocusNode focusNodePort = FocusNode();

  @override
  void initState() {
    controllerSchema.text = BaseUtil.gBaseSchema;
    controllerHost.text = BaseUtil.gBaseHost;
    controllerPort.text = BaseUtil.gBasePort;
    super.initState();
  }

  @override
  void dispose() {
    focusNodeSchema?.dispose();
    focusNodeHost?.dispose();
    focusNodePort?.dispose();
    super.dispose();
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
                  child: Text('配置服务端地址',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: BaseUtil.dp(20),
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
              "通信协议",
              style: TextStyle(
                  fontSize: BaseUtil.dp(14),
                  color: Color(0xFF333333)
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(BaseUtil.dp(0)),
            child: TextField(
              focusNode: focusNodeSchema,
              controller: controllerSchema,
              style: TextStyle(
                  fontSize: BaseUtil.dp(14), color: Colors.black),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "输入服务器通信协议",
                hintStyle: TextStyle(fontSize: BaseUtil.dp(14)),
              ),
              onSubmitted: (_) {
                focusNodeHost.requestFocus();
              },
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: BaseUtil.dp(15), bottom: BaseUtil.dp(5)),
            alignment: Alignment.centerLeft,
            child: Text(
              "域名或IP地址",
              style: TextStyle(
                  fontSize: BaseUtil.dp(14),
                  color: Color(0xFF333333)
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(BaseUtil.dp(0)),
            child: TextField(
              focusNode: focusNodeHost,
              controller: controllerHost,
              style: TextStyle(
                  fontSize: BaseUtil.dp(14), color: Colors.black),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "输入服务器通信域名",
                hintStyle: TextStyle(fontSize: BaseUtil.dp(14)),
              ),
              onSubmitted: (_) {
                focusNodePort.requestFocus();
              },
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: BaseUtil.dp(15), bottom: BaseUtil.dp(5)),
            alignment: Alignment.centerLeft,
            child: Text(
              "端口",
              style: TextStyle(
                  fontSize: BaseUtil.dp(14),
                  color: Color(0xFF333333)
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(BaseUtil.dp(0)),
            child: TextField(
              focusNode: focusNodePort,
              controller: controllerPort,
              style: TextStyle(
                  fontSize: BaseUtil.dp(14), color: Colors.black),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "输入服务器通信端口",
                hintStyle: TextStyle(fontSize: BaseUtil.dp(14)),
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
              if (controllerSchema.text == null ||
                  controllerSchema.text.length <
                      2) {
                CustomSnackBar(
                    context, Text("请传入服务端通信协议"));
                return;
              }
              if (controllerHost.text == null ||
                  controllerHost.text.length < 2) {
                CustomSnackBar(
                    context, Text("请传入服务端域名或IP地址"));
                return;
              }
              BaseUtil.setBaseUrl(
                  controllerSchema.text,
                  controllerHost.text,
                  controllerPort.text);
              HttpUtil.getInstance()
                  .mDio
                  .options
                  .baseUrl = BaseUtil.gBaseUrl;
              HttpUtil.getInstance().loadServerConfig();
              LocalUtil.saveConfigFile();
              CustomSnackBar(context, Text("设置成功"));
              Navigator.of(context).pop();
            },
            child: Container(
              height: BaseUtil.dp(40),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(BaseUtil.dp(4))),
              ),
              child: Center(
                child: Text('确认修改',
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
}
