// @dart=2.9
import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DongGanDanCheLivePeopleList extends StatefulWidget {
  final Function onClose;
  final Function onShowChangeDrag;
  const DongGanDanCheLivePeopleList({
    Key key,
    this.onClose,
    this.onShowChangeDrag
  }) : super(key: key);

  @override
  _DongGanDanCheLivePeopleList createState() => _DongGanDanCheLivePeopleList();
}

class _DongGanDanCheLivePeopleList extends State<DongGanDanCheLivePeopleList> {
  List mArrSelected = [];

  @override
  void initState(){
    mArrSelected = [];
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var item = AgoraUtil.liveInfo;
    var arrPeople = item["arrPeople"] == null ? [] : item["arrPeople"];
    List<Widget> arrHead = [];
    var boxWidth = BaseUtil.dp(80);
    var imageHeight = BaseUtil.dp(80);
    arrPeople.forEach((people) {
      if (AgoraUtil.bIsAuthor && people["userType"] != 102) {
        return;
      }
      arrHead.add(_buildPeople(people, boxWidth, imageHeight));
    });
    if (widget.onClose == null) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        body: _buildBody(arrHead)
      );
    } else {
      return _buildBody(arrHead);
    }
  }

  Widget _buildBody(arrHead) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Colors.black87,
      ),
      child: Column(
        children: [
          Padding(padding: EdgeInsets.only(bottom: BaseUtil.dp(40))),
          Row(
            children: [
              Container (
                padding: EdgeInsets.only(left: BaseUtil.dp(20)),
                alignment: Alignment.centerLeft,
                child: Text(
                  "共有${arrHead.length}位" + (AgoraUtil.bIsAuthor ? "学员" : "观众"),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: BaseUtil.dp(16),
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
              mArrSelected.length > 0 ? GestureDetector(
                onTap: () {
                  this.widget.onShowChangeDrag(mArrSelected);
                },
                child: Container(
                  margin: EdgeInsets.only(left: BaseUtil.dp(10)),
                  padding: EdgeInsets.symmetric(vertical: BaseUtil.dp(5), horizontal: BaseUtil.dp(15)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        width: 1,
                        color: BaseUtil.gDefaultColor,
                        style: BorderStyle.solid
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(4.0),
                    ),
                  ),
                  child: Text(
                    "设置阻力",
                    style: TextStyle(
                        fontSize: BaseUtil.dp(12),
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ) : Text(""),
              Expanded(
                flex: 1,
                child: Text(""),
              ),
              widget.onClose == null ? Text("") : GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onClose,
                child: Icon(
                  Icons.close,
                  color: Colors.white.withOpacity(0.66),
                  size: BaseUtil.dp(30),
                ),
              ),
              Padding(padding: EdgeInsets.only(left: BaseUtil.dp(16))),
            ],
          ),
          Padding(padding: EdgeInsets.only(bottom: BaseUtil.dp(30))),
          Expanded(
              flex: 1,
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Wrap(
                  children: arrHead,
                ),
              )
          ),
        ],
      ),
    );
  }

  Widget _buildPeople(people, boxWidth, imageHeight) {
    var strAvatar = people['avatar'] == null || people['avatar'] == "" ? BaseUtil.gDefaultAvatar : BaseUtil.gBaseUrl + people['avatar'];
    var strName = people['name'] == null || people['name'] == "" ? "测试" : people['name'];
    var id = people["id"];
    bool bSel = false;
    for (var i = 0; i < mArrSelected.length; i++) {
      if (mArrSelected[i] == id) {
        bSel = true;
        break;
      }
    }
    return GestureDetector(
      onTap: () {
        if (!AgoraUtil.bIsAuthor) {
          return;
        }
        setState(() {
          for (var i = 0; i < mArrSelected.length; i++) {
            if (mArrSelected[i] == id) {
              mArrSelected.removeAt(i);
              return;
            }
          }
          mArrSelected.add(people["id"]);
        });
      },
      child: Padding(
        key: ObjectKey(people["id"]),
        padding: EdgeInsets.only(left: BaseUtil.dp(20), right: BaseUtil.dp(20), bottom: BaseUtil.dp(10)),
        child: ClipRRect(
          borderRadius: BorderRadius.all(
            Radius.circular(BaseUtil.dp(8)),
          ),
          child: Container(
            padding: EdgeInsets.only(bottom: BaseUtil.dp(8)),
//             decoration: BoxDecoration(
//                color: bSel ? Color(0x33FFFFFF): Color(0x00000000),
//             ),
            width: boxWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.orange,
                    border: Border.all(
                      color: bSel ? Color(0xFFFF9600): BaseUtil.gDefaultColor,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: strAvatar,
                        imageBuilder: (context, imageProvider) => Container(
                          height: BaseUtil.dp(66),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Text(""),
                        ),
                        placeholder: (context, url) => Image.asset(
                          'assets/images/common/default.jpg',
                          height: imageHeight,
                          fit: BoxFit.fill,
                        ),
                      )
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: BaseUtil.dp(10)),
                ),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    strName,
                    style: TextStyle(
                        fontSize: BaseUtil.dp(12),
                        color: Colors.white
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: BaseUtil.dp(5)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showDialogFunction(String strMsg) {
    showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("温馨提示"),
          //title 的内边距，默认 left: 24.0,top: 24.0, right 24.0
          //默认底部边距 如果 content 不为null 则底部内边距为0
          //            如果 content 为 null 则底部内边距为20
          titlePadding: EdgeInsets.all(10),
          //标题文本样式
          titleTextStyle: TextStyle(color: Colors.black87, fontSize: 16),
          //中间显示的内容
          content: Text(strMsg),
          //中间显示的内容边距
          //默认 EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0)
          contentPadding: EdgeInsets.all(10),
          //中间显示内容的文本样式
          contentTextStyle: TextStyle(color: Colors.black54, fontSize: 14),
          //底部按钮区域
          actions: <Widget>[
            TextButton(
              child: Text("确定"),
              onPressed: () {
                //关闭 返回true
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }
}
