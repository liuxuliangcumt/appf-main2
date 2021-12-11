/*
 * 比赛详情
 */

// @dart=2.9
import 'package:dong_gan_dan_che/common/WxUtil.dart';
import 'package:dong_gan_dan_che/pages/common/service.dart';
import 'package:intl/intl.dart';
import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DongGanDanCheMatchDetailPage extends StatefulWidget {
  final arguments;

  DongGanDanCheMatchDetailPage({Key key, this.arguments}) : super(key: key);

  @override
  _DongGanDanCheMatchDetailPage createState() =>
      _DongGanDanCheMatchDetailPage();
}

class _DongGanDanCheMatchDetailPage
    extends State<DongGanDanCheMatchDetailPage> {
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerRule = TextEditingController();
  int nType = 1;
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();
  int nMaxPeople = 10;
  String strImage = "";
  String strHttpImage = "";

  /// 上传后返回的路径

  bool bIsJoined = false;

  @override
  void initState() {
    print("比赛详情参数 " + widget.arguments.toString());
    super.initState();
    getIsJoinMatch();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String title = '比赛详情';
    var strImage = widget.arguments['image'] == null ||
            widget.arguments['image'].length < 10
        ? BaseUtil.gDefaultImage
        : BaseUtil.gBaseUrl + widget.arguments['image'];
    var startTime = widget.arguments['startTime'] == null
        ? "2021-10-01 10:10:10"
        : widget.arguments['startTime'];
    startTime =
        DateFormat("yyyy-MM-dd HH:mm").format(DateTime.parse(startTime));
    var endTime = widget.arguments['endTime'] == null
        ? "2021-10-01 10:10:10"
        : widget.arguments['endTime'];
    endTime = DateFormat("yyyy-MM-dd HH:mm").format(DateTime.parse(endTime));
    var strName =
        widget.arguments['name'] == null ? "" : widget.arguments['name'];
    var matchType = widget.arguments["type"] == null
        ? 1
        : int.parse(widget.arguments["type"]);
    var strTypeName = gArrMatchType[matchType - 1];
    var nMaxPeople = widget.arguments["maxPeople"] == null
        ? 2
        : widget.arguments["maxPeople"];
    var nActual =
        widget.arguments["actual"] == null ? 0 : widget.arguments["actual"];
    var strRule =
        widget.arguments["rule"] == null ? "无" : widget.arguments["rule"];
    var fixData =
        widget.arguments["fixData"] == null ? 0.0 : widget.arguments["fixData"];
    var status = widget.arguments["status"];
    var bValidTime =
        DateTime.parse(endTime).difference(DateTime.now()).inSeconds > 0;
    print("bValidTime " + bValidTime.toString());
    print("startTime" + startTime);

    var bIsCreator = BaseUtil.gStUser["id"] == widget.arguments["userId"];
    List<Widget> arrWidget = [];
    List<Widget> arrHeader = [];
    arrHeader.add(Container(
      alignment: Alignment.bottomCenter,
      child: CachedNetworkImage(
        imageUrl: strImage,
        imageBuilder: (context, imageProvider) => Container(
          height: BaseUtil.dp(240),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        placeholder: (context, url) => Image.asset(
          'assets/images/common/default.jpg',
          height: BaseUtil.dp(240),
          fit: BoxFit.cover,
        ),
      ),
    ));
    arrHeader.add(Container(
        padding: EdgeInsets.only(
            top: BaseUtil.dp(30),
            left: BaseUtil.dp(20),
            right: BaseUtil.dp(20)),
        height: BaseUtil.dp(60),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                FocusScope.of(BaseUtil.gNavigatorKey.currentContext)
                    .requestFocus(FocusNode());
              },
              child: Container(
                child: Center(
                  child: Image.asset(
                    'assets/images/common/back.webp',
                    width: BaseUtil.dp(10),
                  ),
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(right: BaseUtil.dp(15))),
            Expanded(
                flex: 1,
                child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      title,
                      style: TextStyle(
                          color: Color(0xFF333333),
                          fontSize: BaseUtil.dp(16),
                          fontWeight: FontWeight.bold),
                    ))),
            GestureDetector(
              onTap: () {
                WxUtil.getInstance().shareMatch(widget.arguments);
              },
              child: Container(
                child: Center(
                  child: Image.asset(
                    'assets/images/common/share.png',
                    width: BaseUtil.dp(30),
                  ),
                ),
              ),
            ),
          ],
        )));
    if (bIsCreator && bValidTime && status == '0') {
      arrHeader.add(Container(
        alignment: Alignment.bottomRight,
        padding:
            EdgeInsets.only(bottom: BaseUtil.dp(16), right: BaseUtil.dp(20)),
        child: Container(
          width: BaseUtil.dp(32),
          height: BaseUtil.dp(32),
          child: FloatingActionButton(
            backgroundColor: Color(0x66000000),
            onPressed: () {
              Navigator.pushNamed(context, '/match/edit', arguments: {
                "id": widget.arguments["id"],
                "data": widget.arguments
              });
            },
            child: Icon(
              FontAwesomeIcons.pencilAlt,
              color: Colors.white,
              size: BaseUtil.dp(14.0),
            ),
          ),
        ),
      ));
    }
    arrWidget.add(Container(
      color: Color(0xFFEEEBE9),
      height: BaseUtil.dp(240),
      child: Stack(
        children: arrHeader,
      ),
    ));
    arrWidget.add(Expanded(
      flex: 1,
      child: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(BaseUtil.dp(16)),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          strName,
                          style: TextStyle(
                              color: Color(0xFF333333),
                              fontSize: BaseUtil.dp(20),
                              fontWeight: FontWeight.bold),
                        ),
                        Expanded(flex: 1, child: Text("")),
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: BaseUtil.dp(4),
                              horizontal: BaseUtil.dp(16)),
                          decoration: BoxDecoration(
                              color: BaseUtil.gDefaultColor,
                              borderRadius: BorderRadius.all(
                                  Radius.circular(BaseUtil.dp(23)))),
                          child: Text(
                            strTypeName,
                            style: TextStyle(
                                color: Colors.white, fontSize: BaseUtil.dp(10)),
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: BaseUtil.dp(12)),
                    ),
                    Row(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "$startTime 开始",
                            style: TextStyle(
                              color: Color(0xFF333333),
                              fontSize: BaseUtil.dp(14),
                            ),
                          ),
                        ),
                        Expanded(flex: 1, child: Text("")),
                        Container(
                          alignment: Alignment.centerRight,
                          child: Text(
                            matchType == 1
                                ? "比赛时长 $fixData分钟"
                                : "比赛里程 $fixData公里",
                            style: TextStyle(
                              color: Color(0xFF333333),
                              fontSize: BaseUtil.dp(14),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(padding: EdgeInsets.only(top: BaseUtil.dp(16))),
                    Container(height: BaseUtil.dp(1), color: Color(0xFFEEEEEE)),
                    Padding(padding: EdgeInsets.only(top: BaseUtil.dp(16))),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "参与人数: $nActual/$nMaxPeople",
                        style: TextStyle(
                          color: Color(0xFF333333),
                          fontSize: BaseUtil.dp(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(height: BaseUtil.dp(5), color: Color(0xFFEEEEEE)),
              // todo 比赛人头像 昵称

              getMatchPeopleList(),

              Container(
                padding: EdgeInsets.all(BaseUtil.dp(16)),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "规则介绍",
                          style: TextStyle(
                              color: Color(0xFF333333),
                              fontSize: BaseUtil.dp(16),
                              fontWeight: FontWeight.bold),
                        ),
                        Expanded(flex: 1, child: Text("")),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: BaseUtil.dp(16)),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        strRule,
                        maxLines: 100,
                        style: TextStyle(
                          color: Color(0xFF333333),
                          fontSize: BaseUtil.dp(14),
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: BaseUtil.dp(16))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ));
    // todo 添加比赛结果，如果比赛已经结束
    /**
     * 比赛状态=0：未开始
     *    比赛开始时间>现在: 正常未开始
     *		    创建比赛的教练可操作：编辑比赛、打开比赛房间准备开始比赛
     *		    未报名的学员：报名参加比赛
     *		比赛开始时间<现在:
     *        显示比赛过期
     * 比赛状态=1 或者 =2
     *	  创建比赛的教练：进入比赛房间
     *	  已经报名的学员：进入比赛房间
     *	  其他人显示：比赛进行中
     * 比赛状态=3：比赛结束
     *    查看比赛结果
     */
    if (status == '0') {
      if (bValidTime) {
        if (BaseUtil.gStUser["userType"] == 102) {
          arrWidget.add(Container(
            padding: EdgeInsets.symmetric(
                vertical: BaseUtil.dp(10), horizontal: BaseUtil.dp(20)),
            child: RawMaterialButton(
              constraints: BoxConstraints(minHeight: 40),
              fillColor: BaseUtil.gDefaultColor,
              elevation: 0,
              highlightElevation: 0,
              highlightColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(23)),
              ),
              onPressed: joinMatch,
              child: Center(
                child: bIsJoined
                    ? Text(
                        '已报名',
                        style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 16,
                        ),
                      )
                    : Text(
                        '立即报名',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ));
        } else if (bIsCreator) {
          arrWidget.add(Container(
            padding: EdgeInsets.symmetric(
                vertical: BaseUtil.dp(10), horizontal: BaseUtil.dp(20)),
            child: RawMaterialButton(
              constraints: BoxConstraints(minHeight: 40),
              fillColor: BaseUtil.gDefaultColor,
              elevation: 0,
              highlightElevation: 0,
              highlightColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(23)),
              ),
              onPressed: createMatchRoom,

              /// 点击开启比赛房间
              child: Center(
                child: Text(
                  '开启比赛房间',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ));
        }
      } else {
        arrWidget.add(Container(
          padding: EdgeInsets.symmetric(
              vertical: BaseUtil.dp(10), horizontal: BaseUtil.dp(20)),
          child: RawMaterialButton(
            constraints: BoxConstraints(minHeight: 40),
            fillColor: BaseUtil.gDefaultColor,
            elevation: 0,
            highlightElevation: 0,
            highlightColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(23)),
            ),
            onPressed: () {},

            /// 点击观看比赛
            child: Center(
              child: Text(
                '比赛已过期',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ));
      }
    } else if (status == '1' || status == '2') {
      if (bIsCreator || (BaseUtil.gStUser["userType"] == 102 && bIsJoined)) {
        arrWidget.add(Container(
          padding: EdgeInsets.symmetric(
              vertical: BaseUtil.dp(10), horizontal: BaseUtil.dp(20)),
          child: RawMaterialButton(
            constraints: BoxConstraints(minHeight: 40),
            fillColor: BaseUtil.gDefaultColor,
            elevation: 0,
            highlightElevation: 0,
            highlightColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(23)),
            ),
            onPressed: enterMatchRoom,

            /// 点击进入比赛房间,准备比赛
            child: Center(
              child: Text(
                '进入比赛房间',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ));
      } else {
        arrWidget.add(Container(
          padding: EdgeInsets.symmetric(
              vertical: BaseUtil.dp(10), horizontal: BaseUtil.dp(20)),
          child: RawMaterialButton(
            constraints: BoxConstraints(minHeight: 40),
            fillColor: BaseUtil.gDefaultColor,
            elevation: 0,
            highlightElevation: 0,
            highlightColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(23)),
            ),
            onPressed: watchMatch,

            /// 点击进入比赛房间
            child: Center(
              child: Text(
                '比赛进行中',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ));
      }
    } else if (status == '3') {
      arrWidget.add(Container(
        padding: EdgeInsets.symmetric(
            vertical: BaseUtil.dp(10), horizontal: BaseUtil.dp(20)),
        child: RawMaterialButton(
          constraints: BoxConstraints(minHeight: 40),
          fillColor: BaseUtil.gDefaultColor,
          elevation: 0,
          highlightElevation: 0,
          highlightColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(23)),
          ),
          onPressed: watchResult,

          /// 点击查看比赛成绩
          child: Center(
            child: Text(
              '查看成绩',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ));
    }
    return WillPopScope(
        onWillPop: () async {
          FocusScope.of(BaseUtil.gNavigatorKey.currentContext)
              .requestFocus(FocusNode());
          return true;
        },
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: Container(
              child: Column(
                children: arrWidget,
              ),
            )));
  }

//立即报名
  void joinMatch() {
    HttpUtil.getInstance().postJson(API.joinMatch, params: {
      "matchId": widget.arguments['id'],
      "userId": BaseUtil.gStUser['id'],
    }).then((response) {
      if (response == null) {
        CustomSnackBar(context, Text("获取失败"));
        return;
      }
      //先转json
      var json = jsonDecode(response.toString());
      if (json["data"] == null || json["data"] < 1) {
        CustomSnackBar(context, Text("参加失败, 人数达到上限"));
        return;
      }
      setState(() {
        bIsJoined = true;
        widget.arguments["actual"] = widget.arguments["actual"] + 1;
      });
    });
    // todo
    Navigator.pushNamed(context, "/match/prepare_match",
        arguments: widget.arguments);
  }

  void getIsJoinMatch() {
    HttpUtil.getInstance().postJson(API.getIsJoinMatch, params: {
      "matchId": widget.arguments['id'],
      "userId": BaseUtil.gStUser['id'],
    }).then((response) {
      if (response == null) {
        CustomSnackBar(context, Text("获取失败"));
        return;
      }
      //先转json
      var json = jsonDecode(response.toString());
      setState(() {
        bIsJoined = json["data"] != null;
      });
    });
  }

  /// 创建比赛房间
  void createMatchRoom() {
    var actual = widget.arguments["actual"];
    if (actual == null || actual <= 0) {
      CustomSnackBar(context, Text("还没有人参赛，无法开启比赛房间"));
      return;
    }
    HttpUtil.getInstance().postJson(API.createMatchRoom, params: {
      "matchId": widget.arguments['id'],
    }).then((response) {
      switchToRoom(1, response);
    });
  }

  /// 进入比赛房间
  void enterMatchRoom() {
    var bicycleLogId =
        BaseUtil.gStBicycleLog != null && BaseUtil.gStBicycleLog["id"] != null
            ? BaseUtil.gStBicycleLog["id"]
            : 0;

    /// 学员必须先连接设备，然后进入房间
    if (BaseUtil.gStUser["userType"] == 102 && bicycleLogId == 0) {
      CustomSnackBar(context, Text("请前往设备连接动感单车后，再来参加比赛哦！"));
      return;
    }
    HttpUtil.getInstance().postJson(API.enterMatchRoom, params: {
      "matchId": widget.arguments['id'],
      "userId": BaseUtil.gStUser["id"],
      "bicycleLogId": BaseUtil.gStBicycleLog["id"]
    }).then((response) {
      switchToRoom(2, response);
    });
  }

  /// 其他人观看比赛，TODO：暂不处理
  void watchMatch() {}

  /// 查看比赛结果
  void watchResult() {
    Navigator.pushNamed(context, "/match/result", arguments: widget.arguments);
  }

  /// 切换到比赛房间
  void switchToRoom(type, response) {
    if (response == null) {
      CustomSnackBar(context, Text("无返回数据"));
      return;
    }
    //先转json
    var json = jsonDecode(response.data.toString());
    if (json["success"] == null || json["success"] == false) {
      CustomSnackBar(context, Text(type == 1 ? "打开比赛房间失败" : "进入比赛房间失败"));
      return;
    }
    Navigator.pushNamed(context, "/match/room", arguments: widget.arguments);
  }

  Widget getMatchPeopleList() {
    List<Widget> widgetList = [];
    List data = [
      {"avator": "", "nike": "zhangsan", "time": "3.6"},
      {"avator": "", "nike": "wangwu", "time": "3.6"},
      {"avator": "", "nike": "lisi", "time": "4.6"}
    ];
    data.asMap().forEach((key, value) {
      widgetList.add(Container(
        padding: EdgeInsets.all(BaseUtil.dp(16)),
        child: Row(
          children: [
            _buildAvatar(),
            Text(value["nike"]),
            Expanded(
              child: Text(""),
            ),
            Text("比赛成绩：" + value["time"] + "分钟"),
          ],
        ),
      ));
    });

    return Wrap(
      children: widgetList,
    );
  }

  /// 头像
  Widget _buildAvatar() {
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
}
