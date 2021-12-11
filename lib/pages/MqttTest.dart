import 'dart:async';
import 'dart:convert';

import 'package:dong_gan_dan_che/common/MqttTool.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';

class MqttPage extends StatefulWidget {
  const MqttPage({Key? key}) : super(key: key);

  @override
  _MqttPageState createState() => _MqttPageState();
}

class _MqttPageState extends State<MqttPage> {
  int _counter = 0;
  String topic = "TOPIC.ZYKJ";

  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>?
      _listenSubscription;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              CupertinoButton(
                onPressed: () {
                  connect();
                },
                child: Text("建立连接"),
              ),
              Container(
                child: RaisedButton(
                  onPressed: _subscribeTopic,
                  child: Text(
                    "subscribe topic",
                    style: TextStyle(fontSize: 20, color: Colors.purple),
                  ),
                ),
              ),
              Container(
                child: RaisedButton(
                  onPressed: _publishTopic,
                  child: Text(
                    "publish topic",
                    style: TextStyle(fontSize: 20, color: Colors.purple),
                  ),
                ),
              ),
              Container(
                child: RaisedButton(
                  onPressed: _startListen,
                  child: Text(
                    "start listen",
                    style: TextStyle(fontSize: 20, color: Colors.purple),
                  ),
                ),
              ),
              Container(
                child: RaisedButton(
                  onPressed: _disconnect,
                  child: Text(
                    "disconnect",
                    style: TextStyle(fontSize: 20, color: Colors.purple),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

//  建立连接
  connect() async {
    String server = "app2.cylon.top";
    int port = 1883;
    String clientId = "rfghyjgfdedgfgfg";
    String userName = "admin";
    String password = "a9572EEV";
    MqttTool.getInstance()
        .connect(server, port, clientId, userName, password)
        .then((v) {
      if (v!.returnCode == MqttConnectReturnCode.connectionAccepted) {
        print("恭喜你~ ====mqtt连接成功");
      } else if (v.returnCode == MqttConnectReturnCode.badUsernameOrPassword) {
        print("有事做了~ ====mqtt连接失败 --密码错误!!!");
      } else {
        print("有事做了~ ====mqtt连接失败!!!");
      }
    });
  }

//  订阅主题
  _subscribeTopic() {
    String clientId = "86-1885999fuehxz5f3ced1e";

    MqttTool.getInstance().subscribeMessage(topic);
  }

//  取消订阅
  _unSubscribeTopic() {
    String clientId = "86-1885999fuehxz5f3ced1e";
    MqttTool.getInstance().unsubscribeMessage(topic);
  }

//  发布消息
  _publishTopic() {
    String str1 = "你看我是不是中文";

    MqttTool.getInstance().publishMessage(topic, str1);
  }

//  监听消息的具体实现
  _onData(List<MqttReceivedMessage<MqttMessage>> data) {
    // final MqttPublishMessage recMess = data[0].payload;
    //final MqttPublishMessage recMess = data[0].payload;
    print("监听收到的消息 kaishi");

    final MqttPublishMessage recMess = data[0].payload as MqttPublishMessage;
    //服务器返回的数据信息
    final String ptbefor =
        MqttPublishPayload.bytesToString(recMess.payload.message);

    String pt = Utf8Decoder().convert(recMess.payload.message);
    final String topic = data[0].topic;
    String desString = "topic is <$topic>, payload is <-- $pt -->";
    print("监听收到的消息 size =${pt}  message");

    print("监听收到的消息 string =$desString message");

    Map p = Map();
    p["topic"] = topic;
    p["type"] = "string";
    p["payload"] = pt;
    //   ListEventBus.getDefault().post(p);
  }

//  开启监听消息
  _startListen() {
    _listenSubscription = MqttTool.getInstance().updates()!.listen(_onData);
  }

//  断开连接
  _disconnect() {
    MqttTool.getInstance().disconnect();
  }
}
