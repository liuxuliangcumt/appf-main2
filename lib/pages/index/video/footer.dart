/*
 * 视频点播播放时的底部组件，主要显示评论、打赏、分享等信息
 */
// @dart=2.9
import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:dong_gan_dan_che/common/AgoraUtil.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DongGanDanCheVideoFooter extends StatefulWidget {
  final bool bIsAuthor;
  final Function onSendVideoMessage;
  final Function onVideoShare;
  const DongGanDanCheVideoFooter({
    Key key,
    this.bIsAuthor,
    this.onSendVideoMessage,
    this.onVideoShare,
  }) : super(key: key);

  @override
  _DongGanDanCheVideoFooter createState() => _DongGanDanCheVideoFooter();
}

class _DongGanDanCheVideoFooter extends State<DongGanDanCheVideoFooter> {
  TextEditingController controllerMsg = TextEditingController();
  final FocusNode focusNodeMsg = FocusNode();
  TextEditingController controllerNumber = TextEditingController(text: "1");
  final FocusNode focusNodeNumber = FocusNode();

  final List<GiftTypeInfo> arrGiftType = [];
  GiftTypeInfo currentGiftTypeInfo = GiftTypeInfo(0,"", "", 0, 0, "", "", "");
  int nMoney = BaseUtil.gStUser["amount"] == null ? 0 : BaseUtil.gStUser["amount"];

  @override
  void initState(){
    super.initState();
    HttpUtil.getInstance().postJson(API.getGiftTypeList, params: {}).then((response) {
      if (response == null) {
        return;
      }
      var json = jsonDecode(response.toString());
      var data = json["data"];
      arrGiftType.clear();
      data.forEach((item) {
        var gti = GiftTypeInfo(
            item["id"], item["giftName"],
            item["giftType"], item["giftMoney"],
            item["giftNum"], item["giftImg"],
            item["giftGifImg"], item["remark"]
        );
        arrGiftType.add(gti);
      });
    });
  }
  @override
  void dispose() {
    focusNodeMsg.dispose();
    focusNodeNumber.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> arr = [];
    /// 输入
    arr.add(Expanded(
      flex: 1,
      child: GestureDetector(
        child: Container(
          padding: EdgeInsets.only(left: BaseUtil.dp(20)),
          alignment: Alignment.centerLeft,
          height: BaseUtil.dp(40),
          decoration: BoxDecoration(
            color: Color(0x66000000),
            borderRadius: BorderRadius.circular(40),
          ),
          child: TextField (
            focusNode: focusNodeMsg,
            controller: controllerMsg,
            keyboardType: TextInputType.text,
            style: TextStyle(
                color: Colors.white
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "说点什么...",
              hintStyle: TextStyle(
                  color: Colors.white
              ),
            ),
            onSubmitted: (_) {
              // 发送消息
              widget.onSendVideoMessage(controllerMsg.text);
              controllerMsg.text = "";
            },
            textInputAction: TextInputAction.go,
          ),
        )
      )
    ));
    arr.add(Container(
      margin: EdgeInsets.only(left: BaseUtil.dp(5)),
      height: BaseUtil.dp(40),
      width: BaseUtil.dp(40),
      child: FloatingActionButton(
        backgroundColor: Color(0x66000000),
        onPressed: () {
          if (controllerMsg.text == "") {
            return;
          }
          // 触摸收起键盘
          FocusScope.of(context).requestFocus(FocusNode());
          setState(() {
            // 发送消息
            widget.onSendVideoMessage(controllerMsg.text);
            controllerMsg.text = "";
          });
        },
        child: Icon(
          Icons.send
        ),
      )
    ));
    arr.add(GestureDetector(
        onTap: widget.onVideoShare,
        child: Container(
          margin: EdgeInsets.only(left: BaseUtil.dp(5)),
          height: BaseUtil.dp(40),
          width: BaseUtil.dp(40),
          child: Image.asset('assets/images/common/share.png'),
        )
      )
    );
    if (widget.bIsAuthor) {
//      arr.add(GestureDetector(
//          onTap: screenRecord,
//          child: Container(
//            margin: EdgeInsets.only(left: BaseUtil.dp(5)),
//            height: BaseUtil.dp(40),
//            width: BaseUtil.dp(40),
//            decoration: BoxDecoration(
//              color: Color(0x00000000),
//              borderRadius: BorderRadius.circular(40),
//            ),
//            child: Image.asset('assets/images/common/sceen.png'),
//          )
//        )
//      );
    } else {
      arr.add(GestureDetector(
          onTap: () {
            showGiftList(context, () {});
          },
          child: Container(
            margin: EdgeInsets.only(left: BaseUtil.dp(5)),
            height: BaseUtil.dp(40),
            width: BaseUtil.dp(40),
            child: Image.asset('assets/images/common/gift.png'),
          )
        )
      );
    }
    return Container(
      margin: EdgeInsets.only(bottom: BaseUtil.dp(40), left: BaseUtil.dp(10), right: BaseUtil.dp(10)),
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child:  Row(
          children: arr
      ),
    );
  }

  /// 显示打赏列表
  showGiftList(context, callback) async {
    showModalBottomSheet(
      backgroundColor: Colors.black45,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(BaseUtil.dp(16)),
          topRight: Radius.circular(BaseUtil.dp(16))
        ),
      ),
      context: context,
      builder: (context){
        return StatefulBuilder(
          builder: (context, bottomState) {
            List<Widget> arrGift = [];
            /// 测试使用测试服务器地址,否则使用BaseUtil.baseUrl
            String strBaseUrl = "https://www.reciprocalaffection.com/uploads/DongGanDanChe/gift";
            //    String strBaseUrl = BaseUtil.baseUrl;

            var boxWidth = BaseUtil.dp(86);
            var imageHeight = BaseUtil.dp(66);

            /// 根据礼物类型, 生成显示对象
            arrGiftType.forEach((gt) {
              arrGift.add(GestureDetector(
                  onTap: () {
                    bottomState(() {
                      currentGiftTypeInfo = gt;
                    });
                  },
                  child: Padding(
                    key: ObjectKey(gt.id),
                    padding: EdgeInsets.only(bottom: BaseUtil.dp(0)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(
                        Radius.circular(BaseUtil.dp(8)),
                      ),
                      child: Container(
                        padding: EdgeInsets.only(bottom: BaseUtil.dp(8)),
                        decoration: BoxDecoration(
                          color: currentGiftTypeInfo.id == gt.id ? Color(0x33FFFFFF): Color(0x00000000),
                        ),
                        width: boxWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(bottom: BaseUtil.dp(5)),
                            ),
                            CachedNetworkImage(
                              imageUrl: strBaseUrl + gt.giftImg,
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
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: BaseUtil.dp(5)),
                            ),
                            Container(
                              alignment: Alignment.center,
                              child: Text(
                                gt.giftName,
                                style: TextStyle(
                                    fontSize: BaseUtil.dp(12),
                                    color: Colors.white
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: BaseUtil.dp(5)),
                            ),
                            Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(right: BaseUtil.dp(3)),
                                      child: Text(
                                        gt.giftMoney.toString(),
                                        style: TextStyle(
                                            fontSize: BaseUtil.dp(12),
                                            color: Colors.white
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: BaseUtil.dp(16),
                                      height: BaseUtil.dp(16),
                                      child: Image.asset('assets/images/gift/b.png'),
                                    )
                                  ],
                                )
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ));
            });
            return Container(
                height: BaseUtil.dp(337),
                padding: EdgeInsets.only(top: BaseUtil.dp(6), bottom: BaseUtil.dp(16)),
                alignment: Alignment.centerLeft,
                child: Column(
                  children: <Widget>[
                    Container(
                        padding: EdgeInsets.only(left: BaseUtil.dp(16), right: BaseUtil.dp(16), bottom: BaseUtil.dp(5)),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "打赏礼物",
                          style: TextStyle(
                              fontSize: BaseUtil.dp(16),
                              color: Colors.white
                          ),
                        )
                    ),
                    Expanded(
                      flex: 1,
                      child: Wrap(
                        children: arrGift,
                      ),
                    ),
                    Container(
                      height: BaseUtil.dp(28),
                      padding: EdgeInsets.only(left: BaseUtil.dp(16), right: BaseUtil.dp(16)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: BaseUtil.dp(24),
                            height: BaseUtil.dp(24),
                            child: Image.asset('assets/images/gift/b.png'),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: BaseUtil.dp(3), right: BaseUtil.dp(15)),
                            child: Text(
                              '$nMoney',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: BaseUtil.dp(14),
                                  color: Colors.white
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              recharge();
                            },
                            child: Container(
                              padding: EdgeInsets.only(left: BaseUtil.dp(3), right: BaseUtil.dp(5), bottom: BaseUtil.dp(2)),
                              child: Text(
                                "充值 >",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: BaseUtil.dp(14),
                                    color: Color(0xFFFF5E2C)
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text("")
                          ),
                          Container(
                            padding: EdgeInsets.only(left: BaseUtil.dp(5), right: BaseUtil.dp(5)),
                            child: Text(
                              '数量',
                              style: TextStyle(
                                  fontSize: BaseUtil.dp(14),
                                  color: Colors.white
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              width: BaseUtil.dp(60),
                              height: BaseUtil.dp(28),
                              padding: EdgeInsets.only(left: BaseUtil.dp(5), right: BaseUtil.dp(5), bottom: BaseUtil.dp(2)),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  width: 1,
                                  color: Color(0xFFFE5B27),
                                  style: BorderStyle.solid
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextField(
                                focusNode: focusNodeNumber,
                                controller: controllerNumber,
                                keyboardType: TextInputType.numberWithOptions(),
                                style: TextStyle(
                                  fontSize: 14.0,
//                                  color: Colors.white
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              sendVideoGift();
                            },
                            child: Container(
                              margin: EdgeInsets.only(left: BaseUtil.dp(10)),
                              width: BaseUtil.dp(60),
                              decoration: BoxDecoration(
                                color: Color(0xFFFF5E2C),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  "赠送",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: BaseUtil.dp(14),
                                    color: Colors.white
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                )
            );
          }
        );
      }
    );
  }

  /// 充值
  void recharge() {
    Navigator.pushNamed(context, "/recharge", arguments: () {
      setState(() {});
    });
  }

  /// 赠送礼物
  void sendVideoGift() {
    int count = int.parse(controllerNumber.text);
    if (currentGiftTypeInfo.id <= 0) {
      showDialogFunction("请选择要赠送的礼物类型");
      return;
    }
    if (count * currentGiftTypeInfo.giftMoney > nMoney) {
      showDialogFunction("余额不足，请先充值");
      return;
    }
    nMoney = nMoney - count * currentGiftTypeInfo.giftMoney;
    BaseUtil.gStUser["amount"] = nMoney;
    if (currentGiftTypeInfo.id > 0) {
      WebSocketUtil.sendMessage("giveVideoGift", {
        "giftId": currentGiftTypeInfo.id,
        "giftName": currentGiftTypeInfo.giftName,
        "giftMoney": currentGiftTypeInfo.giftMoney,
        "giftNumber": count,
        "giftPath": currentGiftTypeInfo.giftImg,
      });
    }
    Navigator.of(context).pop();
    CustomSnackBar(BaseUtil.gNavigatorKey.currentContext, Text("完成礼物赠送"));
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
