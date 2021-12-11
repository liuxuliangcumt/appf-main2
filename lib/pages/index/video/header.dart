/*
 * 视频点播播放时的头部组件，主要显示视频发布者信息
 */
// @dart=2.9
import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:flutter/material.dart';

class DongGanDanCheVideoHeader extends StatefulWidget {
  final arguments;
  final Function onClose;
  const DongGanDanCheVideoHeader({
    Key key,
    this.arguments,
    this.onClose,
  }) : super(key: key);

  @override
  _DongGanDanCheVideoHeader createState() => _DongGanDanCheVideoHeader();
}

class _DongGanDanCheVideoHeader extends State<DongGanDanCheVideoHeader> {
  bool bIsAuthor = false;
  bool bIsCollection = false;

  @override
  void initState() {
    super.initState();
    bIsAuthor = widget.arguments["authorId"] == BaseUtil.gStUser['id'];
    if(!bIsAuthor) {
      getIsCollection();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var item = widget.arguments;
    if (item == null) {
      return Text("");
    }
    var strAvatar = item['authorAvatar'] == null || item['authorAvatar'] == ""
        ? BaseUtil.gDefaultAvatar
        : BaseUtil.gBaseUrl + item['authorAvatar'];
    var authorNickName =
        item['authorName'] == null ? "" : item['authorName'];
    Widget avatar = GestureDetector(
        onTap: () {},
        child: Container(
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
                Padding(
                  padding: EdgeInsets.only(right: BaseUtil.dp(7)),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: BaseUtil.dp(5)),
                    ),
                    Text(
                      authorNickName,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: BaseUtil.dp(13.5),
                      ),
                    ),
                    Text(
                      '播放',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: BaseUtil.dp(13.5),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(right: BaseUtil.dp(7)),
                ),
                bIsAuthor
                    ? Text("")
                    : GestureDetector(
                        onTap: setCollection,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: BaseUtil.dp(5.0),
                              horizontal: BaseUtil.dp(12.0)),
                          decoration: BoxDecoration(
                              color: bIsCollection
                                  ? Color(0xFFFFA083)
                                  : Color(0xFFFF5E2C),
                              borderRadius:
                                  BorderRadius.circular(BaseUtil.dp(40.0))),
                          child: Text(bIsCollection ? '已收藏' : '收藏',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: BaseUtil.dp(15))),
                        ),
                      ),
                Padding(
                  padding: EdgeInsets.only(right: BaseUtil.dp(7)),
                ),
              ],
            ),
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

  void getIsCollection() {
    HttpUtil.getInstance().postJson(API.getIsCollection, params: {
      "collectionType": "1",
      "collectionId": widget.arguments["id"],
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
        bIsCollection = json["data"] != null;
      });
    });
  }

  // 设置收藏
  void setCollection() {
    HttpUtil.getInstance().postJson(API.setCollection, params: {
      "collectionType": "1",
      "collectionId": widget.arguments["id"],
      "isCollection": !bIsCollection
    }).then((response) {
      if (response == null) {
        CustomSnackBar(context, Text("设置失败"));
        return;
      }
      //先转json
      var json = jsonDecode(response.toString());
      if (json["code"] == null || json["code"] != 200) {
        CustomSnackBar(context, Text("设置失败"));
        return;
      }
      setState(() {
        bIsCollection = !bIsCollection;
      });
    });
  }
}
