/*
 * 互动记录
 */
// @dart=2.9
import 'dart:async';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:dong_gan_dan_che/pages/index/admin/header.dart';
import 'package:dong_gan_dan_che/pages/common/service.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';

class AdminRecordInteractPage extends StatefulWidget {
  final Function onSwitchParentType;       /// 切换上级状态
  AdminRecordInteractPage({ @required this.onSwitchParentType });
  
  @override
  _AdminRecordInteractPage createState() => _AdminRecordInteractPage();
}

class _AdminRecordInteractPage extends State<AdminRecordInteractPage> {
  List<dynamic> arrRecordData = [];
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  StreamSubscription streamSubscription;
  String _listType = "RecordComment";
  int nCurrentType = 2;

  @override
  void initState() {
    super.initState();
    var that = this;
    /// 接收到更新消息
    streamSubscription = EventUtil.gEventBus.on<UpdateIndexListEvent>().listen((event) {
      if (event.type == _listType) {
        that.setState(() {
          arrRecordData = DongGanDanCheService.gMapPageList[_listType].arr;
        });
      }
    });
    _listType = "RecordComment";
    nCurrentType = 2;
    DongGanDanCheService.onRefresh(_listType, { "userId": BaseUtil.gStUser["id"] }, _refreshController);
  }

  @override
  void dispose() {
    _refreshController?.dispose();
    streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    BaseUtil.changeSystemBarColorType('dark');
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AdminHeaderPage(title: "互动记录", onBack: () { widget.onSwitchParentType(0); }),
          Padding(padding: EdgeInsets.only(top: BaseUtil.dp(5))),
          Container(
            padding: EdgeInsets.symmetric(horizontal: BaseUtil.dp(16)),
            child: Row(
              children: buildTabList(),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: BaseUtil.dp(10))),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              child: ScrollConfiguration(
                behavior: DongGanDanCheBehaviorNull(),
                child: RefreshConfiguration(
                  headerTriggerDistance: BaseUtil.dp(55),
                  maxOverScrollExtent : BaseUtil.dp(100),
                  footerTriggerDistance: BaseUtil.dp(50),
                  maxUnderScrollExtent: 0,
                  headerBuilder: () => DongGanDanCheRefreshHeader(),
                  footerBuilder: () => DongGanDanCheRefreshFooter(),
                  child: SmartRefresher(
                    enablePullDown: true,
                    enablePullUp: true,
                    footer: DongGanDanCheRefreshFooter(bgColor: Color(0xfff1f5f6),),
                    controller: _refreshController,
                    onRefresh: () { DongGanDanCheService.onRefresh(_listType, { "userId": BaseUtil.gStUser["id"] }, _refreshController); },
                    onLoading: () { DongGanDanCheService.onLoading(_listType, { "userId": BaseUtil.gStUser["id"] }, _refreshController); },
                    child: CustomScrollView(
                      slivers: <Widget>[
                        SliverToBoxAdapter(
                          child: Container(
                            child: Column(
                              children: buildDataList(),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildTabList() {
    List<Widget> arrRet = [];
    List arrTabData = [
      { "type": 2, "label": "评论", "code": "RecordComment" },
    //  { "type": 0, "label": "点赞", "code": "RecordLike" },
      { "type": 1, "label": "转发", "code": "RecordForward" },
    ];
    arrRet.add(Expanded(flex: 1, child: Text("")));
    arrTabData.forEach((tab) {
      arrRet.add(GestureDetector(
        onTap: () {
          setState(() {
            nCurrentType = tab["type"];
            _listType = tab["code"];
            DongGanDanCheService.onRefresh(_listType, { "userId": BaseUtil.gStUser["id"] }, _refreshController);
          });
        },
        child: Container(
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                    width: 2,
                    color: tab["type"] == nCurrentType ? Color(0xFF333333) : Color(0x00666666),
                  )
              )
          ),
          child: Text(
            tab["label"],
            style: TextStyle(
                color: tab["type"] == nCurrentType ? Color(0xFF333333) : Color(0xFF666666),
                fontSize: BaseUtil.dp(14),
                fontWeight: tab["type"] == nCurrentType ? FontWeight.bold : FontWeight.normal
            ),
          ),
        ),
      ));
      if (tab["type"] != 1) {
        arrRet.add(Expanded(flex: 1, child: Text("")));
      }
    });
    arrRet.add(Expanded(flex: 1, child: Text("")));
    return arrRet;
  }

  List<Widget> buildDataList() {
    List<Widget> arrRet = [];
    arrRecordData.forEach((recordData) {
      var strUserName = recordData['nickName'] == null ? "" : recordData['nickName'];
      var strAvatar = recordData['avatar'] == null || recordData['avatar'] == "" ? BaseUtil.gDefaultAvatar : BaseUtil.gBaseUrl + recordData['avatar'];
      var strCoverImage = recordData['coverImage'] == null || recordData['coverImage'] == "" ? BaseUtil.gDefaultAvatar : BaseUtil.gBaseUrl + recordData['coverImage'];
      var strComment = recordData['comment'] == null ? "" : recordData['comment'];
      var strContentTitle = recordData['contentTitle'] == null ? "" : recordData['contentTitle'];
      var strAuthorName = recordData["authorNickName"] == null ? "" : recordData["authorNickName"];
      String strTime = DateFormat("yyyy-MM-dd HH:mm").format(DateTime.parse(recordData["createTime"]));
      bool bIsAuthor = BaseUtil.gStUser["id"].toString() == recordData["authorId"].toString();
      bool bIsUser = BaseUtil.gStUser["id"].toString() == recordData["userId"].toString();
      String strOpt = "";
      String strSource = "";
      bool bIsVideo = false;
      switch (int.parse(recordData['type'])) {
        case 0: { strOpt = "赞了"; } break;
        case 1: { strOpt = "转发了"; } break;
        case 2: { strOpt = "评论了"; } break;
      }
      switch (int.parse(recordData['source'])) {
        case 0: { strSource = "直播"; } break;
        case 1: { strSource = "视频"; bIsVideo = true; } break;
        case 2: { strSource = "比赛"; } break;
      }
      List<Widget> arrTitleText = [];
      if (bIsAuthor && bIsUser) {
        arrTitleText.add(Text (
          "你$strOpt自己的$strSource",
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: BaseUtil.dp(14),
          ),
        ));
      } else if (bIsAuthor) {
        arrTitleText.add(Text (
          strUserName,
          style: TextStyle(
              color: Color(0xFF333333),
              fontSize: BaseUtil.dp(14),
              fontWeight: FontWeight.bold
          ),
        ));
        if (recordData['type'] == "2") {
          arrTitleText.add(Text (
            "$strOpt你的$strSource",
            style: TextStyle(
              color: Color(0xFF333333),
              fontSize: BaseUtil.dp(14),
            ),
          ));
        }
      } else {
        arrTitleText.add(Text (
          "你$strOpt",
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: BaseUtil.dp(14),
          ),
        ));
        arrTitleText.add(Text (
          strAuthorName,
          style: TextStyle(
              color: Color(0xFF333333),
              fontSize: BaseUtil.dp(14),
              fontWeight: FontWeight.bold
          ),
        ));
        arrTitleText.add(Text (
          "的$strSource",
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: BaseUtil.dp(14),
          ),
        ));
      }
      Widget avatar = GestureDetector(
          child:Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              color: Colors.orange,
              border: Border.all(
                color: Colors.white,
                width: 1,
              ),
            ),
            child: ClipOval(
              child: Image.network(
                strAvatar,
                fit: BoxFit.cover,
              ),
            ),
          )
      );
      Widget coverImage = GestureDetector(
          child:Container(
            height: 46,
            width: 46,
            child: Image.network(
              strCoverImage,
              fit: BoxFit.cover,
            ),
          )
      );
      arrRet.add(GestureDetector(
        onTap: () {
          if (bIsVideo) {
            var id = recordData['contentId'] == null ? 0 : recordData['contentId'];
            _goToPlayVideo(id);
          }
        },
        child: Container(
          padding: EdgeInsets.all(BaseUtil.dp(16)),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 1,
                color: Color(0xFFEEEEEE),
              )
            )
          ),
          child: Column(
            children: [
              Container(
                child: Row(
                  children: [
                    avatar,
                    Padding(padding: EdgeInsets.only(left: BaseUtil.dp(10))),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row (
                          children: arrTitleText
                        ),
                        Padding(padding: EdgeInsets.only(top: BaseUtil.dp(10))),
                        Text(
                          strTime,
                          style: TextStyle(
                            color: Color(0xFF999999),
                            fontSize: BaseUtil.dp(10),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              recordData['type'] == 2 ? Container(
                padding: EdgeInsets.symmetric(vertical: BaseUtil.dp(16)),
                alignment: Alignment.centerLeft,
                child: Text (
                  strComment,
                  style: TextStyle(
                      color: Color(0xFF333333),
                      fontSize: BaseUtil.dp(14),
                  ),
                ),
              ) : Padding(padding: EdgeInsets.only(top: BaseUtil.dp(16))),
              Container(
                padding: EdgeInsets.all(BaseUtil.dp(10)),
                color: Color(0xFFF9F9F9),
                child: Row(
                  children: [
                    coverImage,
                    Padding(padding: EdgeInsets.only(left: BaseUtil.dp(20))),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text (
                              strContentTitle,
                              style: TextStyle(
                                  color: Color(0xFF333333),
                                  fontSize: BaseUtil.dp(14),
                              ),
                            ),
                          ],
                        ),
                        Padding(padding: EdgeInsets.only(top: BaseUtil.dp(7))),
                        Text(
                          strAuthorName,
                          style: TextStyle(
                            color: Color(0xFF666666),
                            fontSize: BaseUtil.dp(12),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ));
    });
    return arrRet;
  }

  // 跳转观看视频
  void _goToPlayVideo(id) {
    if (id == null || id <= 0) {
      return;
    }
    HttpUtil.getInstance().postJson(API.getVideoInfo, params: {
      "videoId": id
    }).then((response) {
      if (response == null) {
        return;
      }
      var obj = jsonDecode(response.toString());
      var data = obj["data"];
      if (data == null) {
        CustomSnackBar(context, Text("视频被外星人抓走了！！"));
        return;
      }
      var strVideoPath = data["videoPath"];
      if (strVideoPath == null || strVideoPath == "") {
        CustomSnackBar(context, Text("视频被外星人抓走了！！"));
        return;
      }
      Navigator.pushNamed(context, '/PlayVideo', arguments: data);
    });
  }

}