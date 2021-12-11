/*
 * 个人中心基础信息界面
 */
// @dart=2.9
import 'dart:ui';
import 'package:dong_gan_dan_che/common/MqttTool.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:dong_gan_dan_che/pages/common/service.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:dong_gan_dan_che/pages/index/video/list.dart';

class AdminBasePage extends StatefulWidget {
  final Function onSwitchParentType;

  /// 切换上级状态
  AdminBasePage({@required this.onSwitchParentType});

  @override
  _AdminBasePage createState() => _AdminBasePage();
}

class _AdminBasePage extends State<AdminBasePage> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    BaseUtil.changeSystemBarColorType('light');
    List<Widget> arrMainWidget = [];
    arrMainWidget.add(Padding(padding: EdgeInsets.only(top: BaseUtil.dp(25))));
    arrMainWidget.add(_buildBtnList());
    arrMainWidget.add(Padding(padding: EdgeInsets.only(top: BaseUtil.dp(25))));
    String strTitle = "";
    Widget dataWidget;
    if (BaseUtil.gStUser["userType"] == 101) {
      strTitle = "我的视频";
      dataWidget = _buildVideoList();
    } else if (BaseUtil.gStUser["userType"] == 102) {
      strTitle = "我的运动";
      dataWidget = _buildSportInfo();
    }
    if (strTitle != "") {
      arrMainWidget.add(Container(
        padding: EdgeInsets.symmetric(horizontal: BaseUtil.dp(20)),
        alignment: Alignment.centerLeft,
        child: Text(strTitle,
            style: TextStyle(
                color: Color(0xFF333333),
                fontWeight: FontWeight.bold,
                fontSize: BaseUtil.dp(16))),
      ));
      arrMainWidget
          .add(Padding(padding: EdgeInsets.only(top: BaseUtil.dp(10))));
      arrMainWidget.add(Expanded(flex: 1, child: dataWidget));
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(BaseUtil.dp(20), BaseUtil.dp(60),
                BaseUtil.dp(20), BaseUtil.dp(30)),
            height: BaseUtil.dp(220),
            decoration: BoxDecoration(color: Color(0xFF262626)),
            child: Column(
              children: [
                _buildBaseInfo(),
                Expanded(flex: 1, child: Text("")),
                _buildExt(),
                Padding(padding: EdgeInsets.only(top: BaseUtil.dp(15))),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: BaseUtil.dp(200)),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(BaseUtil.dp(20)),
                    topRight: Radius.circular(BaseUtil.dp(20)))),
            child: Column(
              children: arrMainWidget,
            ),
          ),
        ],
      ),
    );
  }

  /// 头像
  Widget _buildAvatar(BuildContext context) {
    var str =
        BaseUtil.gStUser["avatar"] == null || BaseUtil.gStUser["avatar"] == ""
            ? ""
            : BaseUtil.gBaseUrl + BaseUtil.gStUser["avatar"];
    return Container(
      height: 68,
      width: 68,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.white,
            offset: Offset(0.0, 0.0),
            blurRadius: 5.0,
          ),
        ],
      ),
      child: ClipOval(
          child: DongGanDanCheService.tryBuildImage(str, BoxFit.cover)),
    );
  }

  /// 基础信息
  Widget _buildBaseInfo() {
    return Row(children: [
      _buildAvatar(context),
      Padding(padding: EdgeInsets.only(right: BaseUtil.dp(10))),
      Expanded(
          flex: 1,
          child: Container(
            alignment: Alignment.centerLeft,
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    BaseUtil.gStUser.containsKey("nickName")
                        ? BaseUtil.gStUser["nickName"]
                        : "你居然没有名字",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: BaseUtil.dp(20)),
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: BaseUtil.dp(5))),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    BaseUtil.gStUser.containsKey("remark")
                        ? BaseUtil.gStUser["remark"]
                        : "这个家伙很懒，什么也没有留下",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.white, fontSize: BaseUtil.dp(14)),
                  ),
                ),
              ],
            ),
          )),
      Padding(padding: EdgeInsets.only(right: BaseUtil.dp(10))),
      GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, "/recharge", arguments: () {
            setState(() {});
          });
        },
        child: Row(
          children: [
            Container(
              width: BaseUtil.dp(20),
              height: BaseUtil.dp(20),
              margin: EdgeInsets.only(right: BaseUtil.dp(10)),
              child: Image.asset('assets/images/admin/recharge.png',
                  fit: BoxFit.cover),
            ),
            Container(
              margin: EdgeInsets.only(right: BaseUtil.dp(10)),
              child: Text(
                "充值",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: BaseUtil.dp(14),
                ),
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  /// 附加信息
  Widget _buildExt() {
    return Row(children: [
      GestureDetector(
          onTap: () {
            widget.onSwitchParentType(610);
          },
          child: Row(
            children: [
              Text(
                BaseUtil.gStUser["fansNum"] == null
                    ? "0"
                    : BaseUtil.gStUser["fansNum"].toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: BaseUtil.dp(27),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(padding: EdgeInsets.only(right: BaseUtil.dp(8))),
              Text(
                "粉丝",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: BaseUtil.dp(14),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )),
      Expanded(flex: 1, child: Text("")),
      GestureDetector(
          onTap: () {
            widget.onSwitchParentType(620);
          },
          child: Row(
            children: [
              Text(
                BaseUtil.gStUser["followNum"] == null
                    ? "0"
                    : BaseUtil.gStUser["followNum"].toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: BaseUtil.dp(27),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(padding: EdgeInsets.only(right: BaseUtil.dp(8))),
              Text(
                "关注",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: BaseUtil.dp(14),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )),
      Expanded(flex: 1, child: Text("")),
      GestureDetector(
          onTap: () {
            widget.onSwitchParentType(630);
          },
          child: Row(
            children: [
              Text(
                BaseUtil.gStUser["amount"] == null
                    ? "0"
                    : BaseUtil.gStUser["amount"].toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: BaseUtil.dp(27),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(padding: EdgeInsets.only(right: BaseUtil.dp(8))),
              Text(
                "车币",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: BaseUtil.dp(14),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )),
      Expanded(flex: 1, child: Text("")),
    ]);
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
      if (v.returnCode == MqttConnectReturnCode.connectionAccepted) {
        print("恭喜你~ ====mqtt连接成功");
      } else if (v.returnCode == MqttConnectReturnCode.badUsernameOrPassword) {
        print("有事做了~ ====mqtt连接失败 --密码错误!!!");
      } else {
        print("有事做了~ ====mqtt连接失败!!!");
      }
    });
  }

  /// 按钮列表
  Widget _buildBtnList() {
    return Row(
      children: [
        Padding(padding: EdgeInsets.only(left: BaseUtil.dp(20))),
        GestureDetector(
          onTap: () {
            //    widget.onSwitchParentType(200);

            Navigator.pushNamed(context, '/mqttPage');
          },
          child: Column(
            children: [
              Container(
                width: BaseUtil.dp(42),
                height: BaseUtil.dp(42),
                child: Image.asset("assets/images/admin/collection.png",
                    fit: BoxFit.cover),
              ),
              Text(
                "我的收藏",
                style: TextStyle(
                    fontSize: BaseUtil.dp(12), color: Color(0xFF333333)),
              )
            ],
          ),
        ),
        Expanded(flex: 1, child: Text("")),
        GestureDetector(
          onTap: () {
            widget.onSwitchParentType(300);
          },
          child: Column(
            children: [
              Container(
                width: BaseUtil.dp(42),
                height: BaseUtil.dp(42),
                child: Image.asset("assets/images/admin/pay.png",
                    fit: BoxFit.cover),
              ),
              Text(
                "交易记录",
                style: TextStyle(
                    fontSize: BaseUtil.dp(12), color: Color(0xFF333333)),
              )
            ],
          ),
        ),
        Expanded(flex: 1, child: Text("")),
        GestureDetector(
          onTap: () {
            widget.onSwitchParentType(400);
          },
          child: Column(
            children: [
              Container(
                width: BaseUtil.dp(42),
                height: BaseUtil.dp(42),
                child: Image.asset("assets/images/admin/interact.png",
                    fit: BoxFit.cover),
              ),
              Text(
                "互动记录",
                style: TextStyle(
                    fontSize: BaseUtil.dp(12), color: Color(0xFF333333)),
              )
            ],
          ),
        ),
        Expanded(flex: 1, child: Text("")),
        GestureDetector(
          onTap: () {
            widget.onSwitchParentType(100);
          },
          child: Column(
            children: [
              Container(
                width: BaseUtil.dp(42),
                height: BaseUtil.dp(42),
                child: Image.asset("assets/images/admin/setting.png",
                    fit: BoxFit.cover),
              ),
              Text(
                "个人设置",
                style: TextStyle(
                    fontSize: BaseUtil.dp(12), color: Color(0xFF333333)),
              )
            ],
          ),
        ),
        Padding(padding: EdgeInsets.only(left: BaseUtil.dp(20))),
      ],
    );
  }

  /// 视频列表
  Widget _buildVideoList() {
    return ScrollConfiguration(
      behavior: DongGanDanCheBehaviorNull(),
      child: RefreshConfiguration(
        headerTriggerDistance: BaseUtil.dp(55) + 49,
        maxOverScrollExtent: BaseUtil.dp(100),
        footerTriggerDistance: BaseUtil.dp(50),
        maxUnderScrollExtent: 0,
        headerBuilder: () => DongGanDanCheRefreshHeader(),
        footerBuilder: () => DongGanDanCheRefreshFooter(),
        child: SmartRefresher(
          enablePullDown: true,
          enablePullUp: true,
          footer: DongGanDanCheRefreshFooter(
            bgColor: Color(0xfff1f5f6),
          ),
          controller: _refreshController,
          onRefresh: () {
            DongGanDanCheService.onRefresh("Video",
                {"userId": BaseUtil.gStUser['id']}, _refreshController);
          },
          onLoading: () {
            DongGanDanCheService.onLoading("Video",
                {"userId": BaseUtil.gStUser['id']}, _refreshController);
          },
          child: CustomScrollView(
            // physics: BouncingScrollPhysics(),
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Container(
                  child: Column(
                    children: [
                      Padding(padding: EdgeInsets.only(top: BaseUtil.dp(10))),
                      VideoListPage(
                          "Video", BaseUtil.gStUser['id'], _refreshController)
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// 运动信息
  Widget _buildSportInfo() {
    var exerciseDays = BaseUtil.gStUser["exerciseDays"] == null
        ? "0"
        : BaseUtil.gStUser["exerciseDays"];
    var exerciseTime = BaseUtil.gStUser["exerciseTime"] == null
        ? 0
        : BaseUtil.gStUser["exerciseTime"];
    var exerciseCount = BaseUtil.gStUser["exerciseCount"] == null
        ? "0"
        : BaseUtil.gStUser["exerciseCount"];

    return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(
          top: BaseUtil.dp(5), left: BaseUtil.dp(20), right: BaseUtil.dp(20)),
      child: Row(
        children: [
          GestureDetector(
            child: Column(
              children: [
                Text(
                  "运动天数",
                  style: TextStyle(
                      fontSize: BaseUtil.dp(12), color: Color(0xFF333333)),
                ),
                Padding(padding: EdgeInsets.only(top: BaseUtil.dp(5))),
                Text(
                  "$exerciseDays",
                  style: TextStyle(
                      fontSize: BaseUtil.dp(36), color: Color(0xFF333333)),
                )
              ],
            ),
          ),
          Expanded(flex: 1, child: Text("")),
          GestureDetector(
            child: Column(
              children: [
                Text(
                  "运动时长",
                  style: TextStyle(
                      fontSize: BaseUtil.dp(12), color: Color(0xFF333333)),
                ),
                Padding(padding: EdgeInsets.only(top: BaseUtil.dp(5))),
                Text(
                  formatTime(exerciseTime),
                  style: TextStyle(
                      fontSize: BaseUtil.dp(36), color: Color(0xFF333333)),
                )
              ],
            ),
          ),
          Expanded(flex: 1, child: Text("")),
          GestureDetector(
            child: Column(
              children: [
                Text(
                  "运动次数",
                  style: TextStyle(
                      fontSize: BaseUtil.dp(12), color: Color(0xFF333333)),
                ),
                Padding(padding: EdgeInsets.only(top: BaseUtil.dp(5))),
                Text(
                  "$exerciseCount",
                  style: TextStyle(
                      fontSize: BaseUtil.dp(36), color: Color(0xFF333333)),
                )
              ],
            ),
          ),
          Expanded(flex: 1, child: Text("")),
        ],
      ),
    );
  }

  String formatTime(timeCount) {
    if (timeCount == null) {
      return "无";
    }
    var ret = "";
    var s = int.parse(timeCount.toString());
    var h = (s / 3600).floor();
    var m = (s % 3600 / 60).floor();
    s = s % 60;
    if (h > 0) {
      ret = ret + (h > 9 ? "$h:" : "0$h:");
    }
    if (m > 0) {
      ret = ret + (m > 9 ? "$m:" : "0$m:");
    }
    ret = ret + (s > 9 ? "$s" : "0$s");
    return ret;
  }
}
