/*
 * 唯一充值界面, 各个充值入口都显示这个界面
 */

// @dart=2.9
import 'dart:async';

import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:dong_gan_dan_che/common/WxUtil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DongGanDanCheRechargePage extends StatefulWidget {
  final arguments;
  DongGanDanCheRechargePage({Key key, this.arguments}) : super(key: key);

  @override
  _DongGanDanCheRechargePage createState() => _DongGanDanCheRechargePage();
}

class _DongGanDanCheRechargePage extends State<DongGanDanCheRechargePage> {
  TextEditingController controllerMoney = TextEditingController();
  FocusNode focusNodeMoney = FocusNode();
  dynamic currentType;
  int nPayType = 1;
  List<dynamic> arrTypeData = [];
  dynamic preOrder = {};
  bool isPrePay = false;

  @override
  void initState() {
    isPrePay = false;
    arrTypeData = [
      { "type" : 1, "num": 50, "money": 5.0 },
      { "type" : 2, "num": 100, "money": 10.0 },
      { "type" : 3, "num": 500, "money": 50.0 },
      { "type" : 4, "num": 1000, "money": 100.0 },
      { "type" : 5, "num": 5000, "money": 500.0 },
      { "type" : 0, "num": 100, "money": 10.0 },
    ];
    super.initState();
    focusNodeMoney.addListener(() {
      if (focusNodeMoney.hasFocus) {
        changeType(arrTypeData[5]);
      }
    });
    Future.delayed(Duration(milliseconds: 100),() async {
      changeType(arrTypeData[0]);
    });
  }

  void changeType(item) {
    currentType = item;
    if (currentType["type"] > 0) {
      // 触摸收起键盘
      FocusScope.of(context).requestFocus(FocusNode());
    }
    EventUtil.gEventBus.fire(UpdateRechargeMoneyEvent(currentType["money"]));
  }

  void updateByTextField() {
    var item = arrTypeData[5];
    String val = controllerMoney.text;
    if (val == null || val.isEmpty) {
      item['num'] = 0;
      item['money'] = 0;
    } else {
      item['num'] = int.parse(val);
      item['money'] = item['num'] * 0.1;
    }
    EventUtil.gEventBus.fire(UpdateRechargeMoneyEvent(item["money"]));
  }

  @override
  void dispose() {
    rx.unSubscribe('chooseArea', name: 'DongGanDanCheRechargePage');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    BaseUtil.changeSystemBarColorType('dark');
    return WillPopScope(
      onWillPop: () async {
        if (widget.arguments != null) {
          widget.arguments();
        }
        return true;
      },
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                // 触摸收起键盘
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Color(0xFFF9F9F9),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      color: Color(0xFFEDEDED),
                      padding: EdgeInsets.fromLTRB(BaseUtil.dp(16), BaseUtil.dp(30), BaseUtil.dp(16), BaseUtil.dp(10)),
                      child: Row(
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              Navigator.pop(context);
                              if (widget.arguments != null) {
                                widget.arguments();
                              }
                            },
                            child: Container(
                              width: BaseUtil.dp(32),
                              height: BaseUtil.dp(32),
                              color: Color(0xFFEDEDED),
                              child: Icon(
                                FontAwesomeIcons.angleLeft,
                                color: Color(0xFF333333),
                                size: BaseUtil.dp(20.0),
                              ),
                            ),
                          ),
                          Expanded(
                              flex: 1,
                              child: Center(
                                child: Text(
                                  "充值",
                                  style: TextStyle(
                                    color: Color(0xFF333333),
                                    fontSize: BaseUtil.dp(16),
                                  ),
                                ),
                              )
                          ),
                          Padding(padding: EdgeInsets.only(left: BaseUtil.dp(32))),
                        ],
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: BaseUtil.dp(5))),
                    Expanded(
                      flex: 1,
                      child: Container(
                          color: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: BaseUtil.dp(10)),
                          child: SingleChildScrollView(
                              physics: const ClampingScrollPhysics(),
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(left: BaseUtil.dp(16), right: BaseUtil.dp(16), bottom: BaseUtil.dp(10)),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                width: 1,
                                                color: Color(0xFFEEEEEE)
                                            )
                                        )
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          "账户余额",
                                          style: TextStyle(
                                            color: Color(0xFF333333),
                                            fontSize: BaseUtil.dp(14),
                                          ),
                                        ),
                                        Expanded(flex: 1, child: Text("")),
                                        Text(
                                          BaseUtil.gStUser["amount"] == null ? "0" : BaseUtil.gStUser["amount"].toString(),
                                          style: TextStyle(
                                            color: Color(0xFF333333),
                                            fontSize: BaseUtil.dp(30),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Padding(padding: EdgeInsets.only(right: BaseUtil.dp(8))),
                                        Container(
                                          width: BaseUtil.dp(21),
                                          height: BaseUtil.dp(21),
                                          child: Image.asset('assets/images/gift/b.png'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.only(top: BaseUtil.dp(20))),
                                  Wrap(
                                    children: buildTypeList(),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: BaseUtil.dp(10)),
                                    padding: EdgeInsets.only(top: BaseUtil.dp(5)),
                                    color: Color(0xFFF9F9F9),
                                  ),
                                  Container(
                                    child: Column(
                                      children: [
                                        GestureDetector(
                                          child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: BaseUtil.dp(20), vertical: BaseUtil.dp(16)),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: BaseUtil.dp(19),
                                                    height: BaseUtil.dp(19),
                                                    child: Image.asset('assets/images/common/wx.png'),
                                                  ),
                                                  Padding(padding: EdgeInsets.only(right: BaseUtil.dp(10))),
                                                  Text(
                                                    "微信支付",
                                                    style: TextStyle(
                                                      color: Color(0xFF333333),
                                                      fontSize: BaseUtil.dp(12),
                                                    ),
                                                  ),
                                                  Expanded(flex: 1, child: Text("")),
                                                  Container(
                                                    width: BaseUtil.dp(14),
                                                    height: BaseUtil.dp(14),
                                                    child: Image.asset(nPayType == 1 ? 'assets/images/common/circle-checked.png' : 'assets/images/common/circle.png'),
                                                  ),
                                                ],
                                              )
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                      padding: EdgeInsets.symmetric(horizontal: BaseUtil.dp(20), vertical: BaseUtil.dp(16)),
                                      alignment: Alignment.centerLeft,
                                      child: DongGanDanCheRechargeMoney()
                                  ),
                                ],
                              )
                          )
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: BaseUtil.dp(20))),
                    Container(
                      padding: EdgeInsets.only(left: BaseUtil.dp(20), right: BaseUtil.dp(20)),
                      child: RawMaterialButton (
                        constraints: BoxConstraints(minHeight: BaseUtil.dp(46)),
                        fillColor: BaseUtil.gDefaultColor,
                        elevation: 0,
                        highlightElevation: 0,
                        highlightColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(23)),
                        ),
                        onPressed: () {
                          readyPay();
                        },
                        child: Center(
                          child: Text('立即支付',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: BaseUtil.dp(20))),
                  ],
                ),
              )
          )
      )
    );
  }

  List<Widget> buildTypeList() {
    List<Widget> arrRet = [];
    var boxWidth = BaseUtil.dp(119);
    var boxHeight = BaseUtil.dp(75);
    var boxMargin = (BaseUtil.dp(375) - boxWidth * 3) / 4 / 2;

    arrTypeData.forEach((item) {
      arrRet.add(
        GestureDetector(
          onTap: () {
            setState(() {
              changeType(item);
            });
          },
          child: Padding(
            key: ObjectKey(item['num']),
            padding: EdgeInsets.only(
                left: boxMargin,
                right: boxMargin,
                bottom: boxMargin
            ),
            child: Container(
              width: boxWidth,
              height: boxHeight,
              child: Stack(
                children: [
                  currentType == item ? Container(
                    width: boxWidth,
                    height: boxHeight,
                    child: Image.asset('assets/images/admin/border.png', fit: BoxFit.cover),
                  ) : Container(
                    margin: EdgeInsets.symmetric(horizontal: BaseUtil.dp(9), vertical: BaseUtil.dp(9)),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: BaseUtil.dp(1),
                        color: Color(0xFFCCCCCC)
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(BaseUtil.dp(8)),
                      ),
                    ),
                  ),
                  Container(
                    width: boxWidth,
                    height: boxHeight,
                    alignment: Alignment.center,
                    child: item["type"] == 0 ? Container(
                      margin: EdgeInsets.symmetric(horizontal: BaseUtil.dp(15)),
                      child: TextField(
                        controller: controllerMoney,
                        focusNode: focusNodeMoney,
                        cursorColor: BaseUtil.gDefaultColor,
                        keyboardType: TextInputType.numberWithOptions(),
                        textAlign: TextAlign.center,
                        cursorWidth: 1.5,
                        style: TextStyle(
                          color: Color(0xff333333),
                          fontSize: 14.0,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          /// 设置输入框高度
                          isCollapsed: true,
                          contentPadding: EdgeInsets.only(top: BaseUtil.dp(6), bottom: BaseUtil.dp(6)),
                          hintText: '自定义金额',
                        ),
                        onChanged: (_) {
                          updateByTextField();
                        },
                      ),
                    ) : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "${item['num']}",
                              style: TextStyle(
                                color: Color(0xFF333333),
                                fontSize: BaseUtil.dp(17),
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(left: BaseUtil.dp(5))),
                            Container(
                              width: BaseUtil.dp(12),
                              height: BaseUtil.dp(12),
                              child: Image.asset('assets/images/gift/b.png', fit: BoxFit.cover),
                            )
                          ],
                        ),
                        Text(
                          "￥${item['money']}",
                          style: TextStyle(
                            color: Color(0xFF666666),
                            fontSize: BaseUtil.dp(12),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
          ),
        ),
      );
    });
    return arrRet;
  }

  void readyPay() {
    if (isPrePay) {
      return;
    }
    isPrePay = true;
    /**
     * 支付流程:
     * 1、App通知后端，生成预付单，缓存记录预付单信息，并且返回下发给App（后端应该一直在监听微信支付相关操作的异步返回结果）
     * 2、App根据预付单信息，调用fluwx接口，打开微信，进行支付
     * 3、微信支付过程中根据用户操作触发的流程是：（此流程是微信支付流程，不涉及App对应的业务后端）
     * 3.1、微信客户端发起支付请求，通知微信服务端进行验证
     * 3.2、微信服务端验证支付参数、支付权限等信息，然后通知微信客户端验证结果
     * 3.3、微信客户端得到验证结果后，用户从微信客户端输入密码确认支付
     * 3.4、微信客户端确认支付后，将支付授权信息发送到微信服务端，
     * 3.5、微信服务端处理完结果后，通知微信客户端支付结果，同时触发App对应的业务后端监听的异步返回结果接口
     * 4、结果处理，注意4.1和4.2的流程
     * 4.1、业务后端接收到微信支付相关操作的异步返回结果，保存支付信息，并且调用接口通知微信服务端这个结果已经被处理了，不需要再次发送（如果没有发送已处理，微信服务端会间隔一段时间循环发送结果）
     * 4.2、App触发fluwx接口的then，调用业务后端接口，从微信服务端查询支付结果，根据查询结果，判断是否需要从业务后台更新数据
     */
    setWxCb();
    HttpUtil.getInstance().postJson(API.getPrePayOrder, params: {
      "orderTitle": "充值车币",
      "orderBody": "${BaseUtil.gStUser['nickName']}充值${currentType['num']}车币",
      "money": BaseUtil.gNumberFormat1.format(currentType['money']),
      "num": currentType['num']
    }).then((response) {
      isPrePay = false;
      if (response == null) {
        return;
      }
      var result = jsonDecode(response.toString());
      var data = result["data"];
      preOrder = data;
      WxUtil.getInstance().payWithWeChat(
          data['appid'].toString(),
          data['partnerid'].toString(),
          data['prepayid'].toString(),
          data['package'].toString(),
          data['noncestr'].toString(),
          data['timestamp'],
          data['sign'].toString(), (res) {
        if (res == false) {
          CustomSnackBar(context, Text("支付异常"));
        }
      });
    });
  }

  void setWxCb() {
    WxUtil.getInstance().setCbPay((res) {
      if(res.errCode != 0 ) {
        CustomSnackBar(context, Text("充值未成功，错误码：${res.errCode}" ));
        return;
      }
      /// 充值成功，根据 preOrder 向后端发起请求，验证是否成功
      HttpUtil.getInstance().postJson(API.queryOrder, params: {
        "outTradeNo": preOrder["out_trade_no"],
      }).then((response) {
        if (response == null) {
          return;
        }
        var result = jsonDecode(response.toString());
        if (result["success"] == false) {
          CustomSnackBar(context, Text("充值未成功，${result["message"]}" ));
          return;
        }
        var data = result["data"];
        if (data["return_code"] != "SUCCESS") {
          CustomSnackBar(context, Text("充值未成功，错误码：${data["return_msg"]}" ));
          return;
        }
        CustomSnackBar(context, Text("充值成功"));
        BaseUtil.gStUser["amount"] = BaseUtil.gStUser["amount"] + preOrder["num"];
        setState(() {});
      });
    });
  }
}

///////////////////////////////////////////////////////////////////////////////
// 支付金额
class DongGanDanCheRechargeMoney extends StatefulWidget {
  @override
  _DongGanDanCheRechargeMoney createState() => _DongGanDanCheRechargeMoney();
}

class _DongGanDanCheRechargeMoney extends State<DongGanDanCheRechargeMoney> {
  StreamSubscription streamSubscription;
  double money = 0.0;

  @override
  void initState() {
    super.initState();
    var that = this;
    streamSubscription = EventUtil.gEventBus.on<UpdateRechargeMoneyEvent>().listen((event) {
      that.setState(() {
        money = event.money;
      });
    });
  }

  @override
  void dispose() {
    streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '支付金额: ￥' + BaseUtil.gNumberFormat1.format(money),
      style: TextStyle(
        color: Color(0xFF333333),
        fontSize: BaseUtil.dp(12),
      ),
    );
  }
}