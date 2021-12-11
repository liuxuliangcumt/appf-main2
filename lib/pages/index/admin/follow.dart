/*
 * 我的关注
 */

// @dart=2.9
import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:dong_gan_dan_che/pages/index/admin/header.dart';
import 'package:dong_gan_dan_che/pages/common/service.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';

class AdminFollowPage extends StatefulWidget {
  final Function onSwitchParentType;       /// 切换上级状态
  AdminFollowPage({ @required this.onSwitchParentType });
  
  @override
  _AdminFollowPage createState() => _AdminFollowPage();
}

class _AdminFollowPage extends State<AdminFollowPage> {
  List<dynamic> arrRecordData = [];
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  StreamSubscription streamSubscription;
  String _listType = "Follow";

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
    DongGanDanCheService.onRefresh(_listType, { "userId": BaseUtil.gStUser["id"] }, _refreshController, bNoCache: true);
    // Future.delayed(Duration(seconds: 2), () {
    //   setRecordList([
    //     { "id": 1, "userName": "明溪。。", "userAvatar": "", "remark": "多多关注哦", "follow": true },
    //     { "id": 2, "userName": "史凯鸣12138", "userAvatar": "", "remark": "一入代码深似海！！！", "follow": true },
    //     { "id": 3, "userName": "咪咪酱", "userAvatar": "", "remark": "一入代码深似海！！！", "follow": true },
    //     { "id": 4, "userName": "阿斯加德", "userAvatar": "", "remark": "web开发工程师（简称挨踢码农）", "follow": true },
    //     { "id": 5, "userName": "小蜜蜂", "userAvatar": "", "remark": "我要飞到花丛中啊", "follow": true },
    //     { "id": 6, "userName": "温婉", "userAvatar": "", "remark": "恰恰恰！！！", "follow": true },
    //     { "id": 7, "userName": "正好微风", "userAvatar": "", "remark": "委婉", "follow": true },
    //   ]);
    //   setState(() {});
    // });
  }

  @override
  void dispose() {
    streamSubscription.cancel();
    _refreshController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    BaseUtil.changeSystemBarColorType('dark');
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
      child: Column(
        children: [
          AdminHeaderPage(title: "我的关注", onBack: () { widget.onSwitchParentType(0); },),
          Padding(padding: EdgeInsets.only(top: BaseUtil.dp(5))),
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
                            padding: EdgeInsets.only(top: BaseUtil.dp(20)),
                            child: Column(
                                children: buildRecordList()
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

  List<Widget> buildRecordList() {
    List<Widget> arrRet = [];
    arrRecordData.forEach((recordData) {
      var userId = recordData['id'];
      var strUserName = recordData['nickName'];
      var strAvatar = recordData['avatar'] == null || recordData['avatar'] == "" ? BaseUtil.gDefaultAvatar : BaseUtil.gBaseUrl + recordData['avatar'];
      var strRemark = recordData['remark'] == null ? "" : recordData['remark'];
      // var bIsFollow = recordData['follow'] == null ? false : recordData['follow'];
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
      arrRet.add(Container(
        margin: EdgeInsets.symmetric(horizontal: BaseUtil.dp(16)),
        padding: EdgeInsets.symmetric(vertical: BaseUtil.dp(16)),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    width: 0.5,
                    color: Colors.black26
                )
            )
        ),
        child: Row(
          children: [
            avatar,
            Padding(padding: EdgeInsets.only(left: BaseUtil.dp(20))),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strUserName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Color(0xFF333333),
                      fontSize: BaseUtil.dp(14),
                      fontWeight: FontWeight.bold
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: BaseUtil.dp(4))),
                Text(
                  strRemark,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF999999),
                    fontSize: BaseUtil.dp(12),
                  ),
                )
              ],
            ),
            Expanded(flex: 1, child: Text("")),
            GestureDetector(
              onTap: () {
                HttpUtil.getInstance().postJson(API.setFollow, params: {
                  "userId": userId,
                  "isFollow": false
                }).then((response) {
                  if (response == null) {
                    CustomSnackBar(context, Text("设置失败"));
                    return;
                  }
                  //先转json
                  var json = jsonDecode(response.toString());
                  if (json["success"] == null || json["success"] != true) {
                    CustomSnackBar(context, Text("设置失败"));
                    return;
                  }
                  setState(() {
                    arrRecordData.remove(recordData);
                    BaseUtil.gStUser["followNum"] = BaseUtil.gStUser["followNum"] - 1;
                  });
                });
              },
              child: Container(
                width: BaseUtil.dp(80),
                height: BaseUtil.dp(28),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Color(0xFFCCCCCC),
                    borderRadius: BorderRadius.all(Radius.circular(BaseUtil.dp(20)))
                ),
                child: Text(
                  "取消关注",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: BaseUtil.dp(14)
                  ),
                ),
              ),
            )
          ],
        ),
      ));
    });
    return arrRet;
  }

}