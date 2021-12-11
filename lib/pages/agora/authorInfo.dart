// @dart=2.9
import 'dart:async';

import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:dong_gan_dan_che/pages/common/service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';   //引入ui库，因为ImageFilter Widget在这个里边。
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:dong_gan_dan_che/pages/index/video/list.dart';


class DongGanDanCheLiveAuthorInfo extends StatefulWidget {
  final Function onClose;
  const DongGanDanCheLiveAuthorInfo({
    Key key,
    this.onClose
  }) : super(key: key);

  @override
  _DongGanDanCheLiveAuthorInfo createState() => _DongGanDanCheLiveAuthorInfo();
}

class _DongGanDanCheLiveAuthorInfo extends State<DongGanDanCheLiveAuthorInfo> {
  Map mUserInfo = {};
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState(){
    super.initState();
    HttpUtil.getInstance().postJson(API.getUserInfoById, params: {
      "userId": AgoraUtil.liveInfo["authorId"]
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
        var u = json["data"];
        mUserInfo = new Map<String, dynamic>.from(u);
      });
    });
  }
  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var strAvatar = mUserInfo['avatar'] == null || mUserInfo['avatar'] == "" ? BaseUtil.gDefaultAvatar : BaseUtil.gBaseUrl + mUserInfo['avatar'];
    var strUserName = mUserInfo['nickName'] == null || mUserInfo['nickName'] == "" ? "教练" : mUserInfo['nickName'];
    var strRemark = mUserInfo['remark'] == null || mUserInfo['remark'] == "" ? "每晚8点不见不散哦~" : mUserInfo['remark'];
    var nFans = mUserInfo["FansNum"] == null ? 0 : mUserInfo["FansNum"];
    var nFollow = mUserInfo["FollowNum"] == null ? 0 : mUserInfo["FollowNum"];
    Widget avatar = GestureDetector(
        child:Container(
          height: BaseUtil.dp(80),
          width: BaseUtil.dp(80),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(BaseUtil.dp(80)),
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

    Widget stack = Stack(
      children: [
        ConstrainedBox( //约束盒子组件，添加额外的限制条件到 child上。
          constraints: BoxConstraints.expand(height: BaseUtil.dp(320)), //限制条件，可扩展的。
          child:Image.network(strAvatar, fit: BoxFit.cover,)
        ),
        ClipRect(  //裁切长方形
          child: BackdropFilter(   //背景滤镜器
            filter: ImageFilter.blur(sigmaX: 12.0,sigmaY: 12.0), //图片模糊过滤，横向竖向都设置12.0
            child: Column(
              children: [
                Padding(padding: EdgeInsets.only(top: BaseUtil.dp(20))),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.only(left: BaseUtil.dp(65)),
                        child:  Center(
                          child: Text(
                            "个人主页",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: BaseUtil.dp(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          widget.onClose();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: BaseUtil.dp(5), horizontal: BaseUtil.dp(16)),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: BaseUtil.dp(30),
                          ),
                        )

                    )
                  ],
                ),
                Padding(padding: EdgeInsets.only(top: BaseUtil.dp(30))),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: BaseUtil.dp(16)),
                  child: Row(
                    children: [
                      avatar,
                      Expanded(
                        flex: 1,
                        child: Text("")
                      ),
                      AgoraUtil.bIsAuthor ? Text("") : GestureDetector(
                        onTap: setFollow,
                        child: Container(
                          width: BaseUtil.dp(66),
                          height: BaseUtil.dp(28),
                          decoration: BoxDecoration(
                              color: AgoraUtil.bIsFavorite ? Color(0xFFFFA083) : Color(0xFFFF5E2C),
                              borderRadius: BorderRadius.circular(BaseUtil.dp(16.0))
                          ),
                          child: Center(child: Text(
                              AgoraUtil.bIsFavorite ? '已关注' : '关注',
                              style: TextStyle(color: Colors.white, fontSize: BaseUtil.dp(14))
                          ),),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: BaseUtil.dp(14))),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: BaseUtil.dp(16)),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    strUserName,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: BaseUtil.dp(20),
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: BaseUtil.dp(8))),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: BaseUtil.dp(16)),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    strRemark,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: BaseUtil.dp(14),
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: BaseUtil.dp(20))),
                DongGanDanCheLiveAuthorInfoHeader(
                  nFans: nFans,
                  nFollow: nFollow,
                ),
                Padding(padding: EdgeInsets.only(top: BaseUtil.dp(20))),
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.white,
                    child: _buildVideoList(),
                  )
                )
              ],
            )
          ),
        ),
      ],
    );

    Widget body = Container(
      child: stack
    );

    if (widget.onClose == null) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        body: body
      );
    } else {
      return body;
    }
  }

  /// 视频列表
  Widget _buildVideoList() {
    return ScrollConfiguration(
      behavior: DongGanDanCheBehaviorNull(),
      child: RefreshConfiguration(
        headerTriggerDistance: BaseUtil.dp(55) + 49,
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
          onRefresh: () { DongGanDanCheService.onRefresh("Video", { "userId": mUserInfo['id'] }, _refreshController); },
          onLoading: () { DongGanDanCheService.onLoading("Video", { "userId": mUserInfo['id'] }, _refreshController); },
          child: CustomScrollView(
            // physics: BouncingScrollPhysics(),
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Container(
                  child: Column(
                    children: [
                      Padding(padding: EdgeInsets.only(top: BaseUtil.dp(10))),
                      VideoListPage("Video", mUserInfo['id'], _refreshController)
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

  // 设置收藏关注
  void setFollow() {
    HttpUtil.getInstance().postJson(API.setFollow, params: {
      "liveId": AgoraUtil.liveInfo["id"],
      "userId": AgoraUtil.liveInfo["authorId"],
      "isFollow": !AgoraUtil.bIsFavorite
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
        AgoraUtil.bIsFavorite = !AgoraUtil.bIsFavorite;
      });
    });
  }
}


class DongGanDanCheLiveAuthorInfoHeader extends StatefulWidget {
  final int nFans;
  final int nFollow;

  const DongGanDanCheLiveAuthorInfoHeader({Key key, this.nFans, this.nFollow}) : super(key: key);

  @override
  _DongGanDanCheLiveAuthorInfoHeader createState() => _DongGanDanCheLiveAuthorInfoHeader();

}

class _DongGanDanCheLiveAuthorInfoHeader extends State<DongGanDanCheLiveAuthorInfoHeader> {
  StreamSubscription streamSubscription;

  @override
  void initState(){
    super.initState();
    var that = this;
    /// 接收到更新消息
    streamSubscription = EventUtil.gEventBus.on<UpdateIndexListEvent>().listen((event) {
      if (event.type == "Video") {
        that.setState(() {});
      }
    });
  }
  @override
  void dispose() {
    streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var nFans = widget.nFans == null ? 0 : widget.nFans;
    var nFollow = widget.nFollow == null ? 0 : widget.nFollow;
    var nVideo = DongGanDanCheService.gMapPageList["Video"].nTotal;
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(padding: EdgeInsets.only(left: BaseUtil.dp(16))),
          Text(
            "视频",
            style: TextStyle(
                color: Colors.white,
                fontSize: BaseUtil.dp(14),
                fontWeight: FontWeight.bold
            ),
          ),
          Padding(padding: EdgeInsets.only(left: BaseUtil.dp(10))),
          Expanded(
            flex: 1,
            child: Text(
              "$nVideo",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: BaseUtil.dp(20),
                  fontWeight: FontWeight.bold
              ),
            ),
          ),
          Text(
            "粉丝",
            style: TextStyle(
                color: Colors.white,
                fontSize: BaseUtil.dp(14),
                fontWeight: FontWeight.bold
            ),
          ),
          Padding(padding: EdgeInsets.only(left: BaseUtil.dp(10))),
          Expanded(
            flex: 1,
            child: Text(
              "$nFans",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: BaseUtil.dp(20),
                  fontWeight: FontWeight.bold
              ),
            ),
          ),
          Text(
            "关注",
            style: TextStyle(
                color: Colors.white,
                fontSize: BaseUtil.dp(14),
                fontWeight: FontWeight.bold
            ),
          ),
          Padding(padding: EdgeInsets.only(left: BaseUtil.dp(10))),
          Expanded(
            flex: 1,
            child: Text(
              "$nFollow",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: BaseUtil.dp(20),
                  fontWeight: FontWeight.bold
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(left: BaseUtil.dp(16))),
        ],
      );
  }

}