/*
 * 查看比赛成绩
 */

// @dart=2.9
import 'package:dong_gan_dan_che/common/WxUtil.dart';
import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';


class DongGanDanCheMatchResultPage extends StatefulWidget {
  final arguments;
  DongGanDanCheMatchResultPage({Key key, this.arguments}) : super(key: key);

  @override
  _DongGanDanCheMatchResultPage createState() => _DongGanDanCheMatchResultPage();
}

class _DongGanDanCheMatchResultPage extends State<DongGanDanCheMatchResultPage> {
  List<dynamic> arrPeople = [];

  @override
  void initState() {
    super.initState();
    getMatchPeopleList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String title = '比赛成绩';
    List<Widget> arrWidget = [];
    arrWidget.add(_buildHeader(title));
    arrWidget.add(Padding(padding: EdgeInsets.only(top: BaseUtil.dp(15))));
    arrWidget.add(Expanded(
      flex: 1,
      child: SingleChildScrollView(
        child: Container (
          child: Column(
            children: _buildMatchPeopleList(),
          ),
        ),
      ),
    ));
    arrWidget.add(Padding(padding: EdgeInsets.only(top: BaseUtil.dp(10))));
    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pushNamedAndRemoveUntil("/index", (Route<dynamic> route) => false, arguments: 3);
          return false;
        },
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: Container(
              child: Column(
                children: arrWidget,
              ),
            )
        )
    );
  }

  /// 生成标题栏
  Widget _buildHeader(title) {
    return Container(
        padding: EdgeInsets.only(top: BaseUtil.dp(30), left: BaseUtil.dp(20), right: BaseUtil.dp(20)),
        height:  BaseUtil.dp(60),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil("/index", (Route<dynamic> route) => false, arguments: 3);
              },
              child: Container(
                child: Center(
                  child: Image.asset('assets/images/common/back.webp',
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
                          fontWeight: FontWeight.bold
                      ),
                    )
                )
            ),
            GestureDetector(
              onTap: () {
                WxUtil.getInstance().shareMatch(widget.arguments);
              },
              child: Container(
                child: Center(
                  child: Image.asset('assets/images/common/share.png',
                    width: BaseUtil.dp(30),
                  ),
                ),
              ),
            ),
          ],
        )
    );
  }

  /// 生成列表
  List<Widget> _buildMatchPeopleList() {
    List<Widget> ret = [];
    var boxWidth = BaseUtil.dp(343);
    var boxHeight = BaseUtil.dp(146);
    if (arrPeople.length > 0) {
      /// 比赛成绩
      arrPeople.forEach((people) {
        ret.add(_buildMatchPeople(people, boxWidth, boxHeight));
      });
    } else {
      ret.add(Padding(
        padding: EdgeInsets.only(
            bottom: BaseUtil.dp(15)
        ),
        child: ClipRRect(
            borderRadius: BorderRadius.all(
              Radius.circular(BaseUtil.dp(8)),
            ),
            child: Container(
              width: boxWidth,
              height: boxHeight,
              alignment: Alignment.center,
              color: Color(0xFFEEEBE9),
              child: Text(
                  "无成绩"
              ),
            )
        ),
      ));
    }
    return ret;
  }

  Widget _buildMatchPeople(people, boxWidth, boxHeight) {
    var strNickName = people["nickName"] == null ? "学员" : people["nickName"];
    return Padding(
        padding: EdgeInsets.only(bottom: BaseUtil.dp(15)),
        child: ClipRRect(
          borderRadius: BorderRadius.all(
            Radius.circular(BaseUtil.dp(8)),
          ),
          child: Container(
            width: boxWidth,
            color: Color(0xFFEEEBE9),
            padding: EdgeInsets.symmetric(horizontal: BaseUtil.dp(14), vertical: BaseUtil.dp(16)),
            child: Column (
              children: [
                Row (
                  children: [
                    Container(
                      child: Text(
                        strNickName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: BaseUtil.dp(16)
                        ),
                      ),
                    ),
                    Expanded(
                        flex: 1,
                        child: Text("")
                    ),
                    _buildMatchPeopleRunk(people),
                  ],
                ),
                Padding (padding: EdgeInsets.only(top: BaseUtil.dp(10)),),
                _buildMatchPeopleUsed(people)
              ],
            ),
          ),
        )
    );
  }

  Widget _buildMatchPeopleRunk(people) {
    var clr = BaseUtil.gArrArtWordColor[0];
    var rank = people["rank"] == null ? "无" : people["rank"];
    return Container(
      alignment: Alignment.topRight,
      child: Text(
          "第$rank名",
          style: TextStyle(
            color: clr["text"],
            fontSize: BaseUtil.dp(30),
            shadows: <Shadow>[
              Shadow(
                offset: Offset(-1.0, -1.0),
                blurRadius: 5.0,
                color: clr["shadowLeftTop"],
              ),
              Shadow(
                offset: Offset(1.0, 1.0),
                blurRadius: 3.0,
                color: clr["shadowRightBottom"],
              )
            ],
          )
      )
    );
  }

  Widget _buildMatchPeopleUsed(people) {
    var mileage = people["mileage"] == null ? 0.0 : people["mileage"];
    mileage = BaseUtil.gNumberFormat3.format(mileage);
    var strMileage = "$mileage";
    int s = people["second"] == null ? 0 : people["second"];
    int m = (s / 60).floor();
    s = s % 60;
    var strTime = m > 0 ? "$m分$s秒" : "$s秒";
    return Container(
      child: Row (
        children: [
          Text(
            "里程: ",
            style: TextStyle(
                color: Colors.black,
                fontSize: BaseUtil.dp(16)
            ),
          ),
          Text(
            "$strMileage",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: BaseUtil.dp(16)
            ),
          ),
          Text(
            "公里",
            style: TextStyle(
                color: Colors.black,
                fontSize: BaseUtil.dp(16)
            ),
          ),
          Expanded(flex: 1, child: Text("")),
          Text(
            "用时: ",
            style: TextStyle(
                color: Colors.black,
                fontSize: BaseUtil.dp(16)
            ),
          ),
          Text(
            "$strTime",
            style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: BaseUtil.dp(16)
            ),
          ),
        ],
      ),
    );
  }

  /// 查询成绩
  void getMatchPeopleList() {
    HttpUtil.getInstance().postJson(API.getMatchPeopleList, params: {
      "matchId": widget.arguments['id'],
    }).then((response) {
      if (response == null) {
        CustomSnackBar(context, Text("获取失败"));
        return;
      }
      //先转json
      var json = jsonDecode(response.toString());
      setState(() {
        arrPeople = json["data"];
      });
    });
  }

}
