// @dart=2.9
import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:flutter/material.dart';

class DongGanDanCheLiveHeader extends StatefulWidget {
  final Function onClose;
  final Function onShowAuthor;
  final Function onShowPeopleList;
  const DongGanDanCheLiveHeader({
    Key key,
    this.onClose,
    this.onShowAuthor,
    this.onShowPeopleList,
  }) : super(key: key);

  @override
  _DongGanDanCheLiveHeader createState() => _DongGanDanCheLiveHeader();
}

class _DongGanDanCheLiveHeader extends State<DongGanDanCheLiveHeader> {
  @override
  void initState(){
    super.initState();

    Future.delayed(Duration(milliseconds: 1000),(){
      HttpUtil.getInstance().postJson(API.enterLiveAfter, params: {
        "liveId": AgoraUtil.liveId,
        "liveCode": AgoraUtil.liveCode
      }).then((response) {
        if (response == null) {
          CustomSnackBar(context, Text("设置失败"));
          return;
        }
        //先转json
        var json = jsonDecode(response.toString());
        if (json["code"] == null || json["code"] != 200) {
          CustomSnackBar(context, Text("获取失败"));
          return;
        }
        AgoraUtil.liveInfo = json["data"];
        getIsFollow();
      });
    });
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var item = AgoraUtil.liveInfo;
    if (item == null) {
      return Text("");
    }
    var strAvatar = item['authorAvatar'] == null || item['authorAvatar'] == "" ? BaseUtil.gDefaultAvatar : BaseUtil.gBaseUrl + item['authorAvatar'];
//    var onlineNum = item['onlineNum'] == null || item['onlineNum'] == "" ? "0" : item['onlineNum'].toString();
    var authorNickName = item['authorNickName'] == null ? "" : item['authorNickName'];
    var arrPeople = item["arrPeople"] == null ? [] : item["arrPeople"];

    Widget avatar = GestureDetector(
        onTap: this.widget.onShowAuthor,
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
    List<Widget> arrHead = [];
    for (int i = 0; i < arrPeople.length && i < 3; i++) {
      var p = arrPeople[i];
      var avatar = p['avatar'] == null || p['avatar'] == "" ? BaseUtil.gDefaultAvatar : BaseUtil.gBaseUrl + p['avatar'];
      arrHead.add(GestureDetector(
          onTap: this.widget.onShowPeopleList,
          child: Container(
            margin: EdgeInsets.fromLTRB(0, 5, 5, 5),
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              color: Colors.orange,
              border: Border.all(
                color: Colors.white,
                width: 1,
              ),
            ),
            child: ClipOval(
              child: Image.network(
                avatar,
                fit: BoxFit.cover,
              ),
            ),
          )
      ));
    }
    arrHead.add(Container(
      margin: EdgeInsets.fromLTRB(0, 5, 2, 5),
      height: 32,
      width: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Color(0x33000000),
      ),
      child: Center(child:Text(arrPeople.length.toString(), style: TextStyle(color: Colors.white, fontSize: 14)),)
    ));

    return Container(
      height: BaseUtil.dp(50),
      margin: EdgeInsets.only(top: BaseUtil.dp(20)),
      padding: EdgeInsets.only(left: BaseUtil.dp(10), right: BaseUtil.dp(10)),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Row(
              children: [
                avatar,
                Padding(padding: EdgeInsets.only(right: BaseUtil.dp(7)),),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(padding: EdgeInsets.only(top: BaseUtil.dp(5)),),
                    Text(
                      authorNickName,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: BaseUtil.dp(13.5),
                      ),
                    ),
                    Text(
                      '${arrPeople.length}热度',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: BaseUtil.dp(13.5),
                      ),
                    ),
                  ],
                ),
                Padding(padding: EdgeInsets.only(right: BaseUtil.dp(7)),),
                AgoraUtil.bIsAuthor ? Text("") : GestureDetector(
                  onTap: setFollow,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: BaseUtil.dp(5.0), horizontal: BaseUtil.dp(12.0)),
                    decoration: BoxDecoration(
                        color: AgoraUtil.bIsFavorite ? Color(0xFFFFA083) : Color(0xFFFF5E2C),
                        borderRadius: BorderRadius.circular(BaseUtil.dp(40.0))
                    ),
                    child: Text(
                        AgoraUtil.bIsFavorite ? '已关注' : '关注',
                        style: TextStyle(color: Colors.white, fontSize: BaseUtil.dp(15))
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.only(right: BaseUtil.dp(7)),),
              ],
            ),
          ),
          Row(
            children: arrHead
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onClose,
            child: Icon(
              Icons.close,
              color: Colors.white.withOpacity(0.66),
              size: BaseUtil.dp(30),
            ),
          )
        ],
      ),
    );
  }

  void getIsFollow() {
    HttpUtil.getInstance().postJson(API.getIsFollow, params: {
      "userId": AgoraUtil.liveInfo["authorId"],
    }).then((response) {
      if (response == null) {
        CustomSnackBar(context, Text("获取失败"));
        return;
      }
      //先转json
      var json = jsonDecode(response.toString());
      if (json["success"] == null || json["success"] != true) {
        CustomSnackBar(context, Text("获取失败"));
        return;
      }
      setState(() {
        AgoraUtil.bIsFavorite = json["data"] != null;
      });
    });
  }

  // 设置收藏关注
  void setFollow() {
    HttpUtil.getInstance().postJson(API.setFollow, params: {
      "liveId": AgoraUtil.liveInfo["liveId"],
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
