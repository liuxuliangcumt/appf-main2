/*
 * 个人设置的主界面
 */
// @dart=2.9
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:dong_gan_dan_che/pages/index/admin/header.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class AdminSettingIndexPage extends StatefulWidget {
  final Function onSwitchParentType;       /// 切换上级状态
  AdminSettingIndexPage({ @required this.onSwitchParentType });
  
  @override
  _AdminSettingIndexPage createState() => _AdminSettingIndexPage();
}

class _AdminSettingIndexPage extends State<AdminSettingIndexPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    EasyLoading.dismiss();
    BaseUtil.changeSystemBarColorType('dark');
    List<Widget> arrWidget = [];
    arrWidget.add(GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () { widget.onSwitchParentType(110); },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: BaseUtil.dp(16), vertical: BaseUtil.dp(10)),
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
              Container(
                width: BaseUtil.dp(24),
                height: BaseUtil.dp(24),
                child: Image.asset("assets/images/admin/setting/info.png", fit: BoxFit.cover),
              ),
              Padding(padding: EdgeInsets.only(left: BaseUtil.dp(8))),
              Text(
                "个人资料",
                style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: BaseUtil.dp(14)
                ),
              ),
              Expanded(flex: 1, child: Text("")),
              Text(
                "修改资料",
                style: TextStyle(
                    color: Color(0xFF999999),
                    fontSize: BaseUtil.dp(12)
                ),
              ),
              Padding(padding: EdgeInsets.only(left: BaseUtil.dp(20))),
              Image.asset('assets/images/common/dg.webp',
                height: BaseUtil.dp(16),
              ),
            ],
          ),
        )
    ));
    arrWidget.add(GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () { widget.onSwitchParentType(120); },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: BaseUtil.dp(16), vertical: BaseUtil.dp(10)),
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
              Container(
                width: BaseUtil.dp(24),
                height: BaseUtil.dp(24),
                child: Image.asset("assets/images/admin/setting/lock.png", fit: BoxFit.cover),
              ),
              Padding(padding: EdgeInsets.only(left: BaseUtil.dp(8))),
              Text(
                "修改密码",
                style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: BaseUtil.dp(14)
                ),
              ),
              Expanded(flex: 1, child: Text("")),
              Text(
                "",
                style: TextStyle(
                    color: Color(0xFF999999),
                    fontSize: BaseUtil.dp(12)
                ),
              ),
              Padding(padding: EdgeInsets.only(left: BaseUtil.dp(20))),
              Image.asset('assets/images/common/dg.webp',
                height: BaseUtil.dp(16),
              ),
            ],
          ),
        )
    ));
    /// 本来应该是非会员非教练显示成为教练、成为会员按钮，目前先调整成为后台管理系统主动设置角色
    // if (BaseUtil.gStUser["userType"] != 101 && BaseUtil.gStUser["userType"] != 102) {
    //   arrWidget.add(GestureDetector(
    //       behavior: HitTestBehavior.opaque,
    //       onTap: () { widget.onSwitchParentType(130); },
    //       child: Container(
    //         padding: EdgeInsets.symmetric(horizontal: BaseUtil.dp(16), vertical: BaseUtil.dp(5)),
    //         decoration: BoxDecoration(
    //             border: Border(
    //                 bottom: BorderSide(
    //                     width: 1,
    //                     color: Color(0xFFEEEEEE)
    //                 )
    //             )
    //         ),
    //         child: Row(
    //           children: [
    //             Container(
    //               width: BaseUtil.dp(24),
    //               height: BaseUtil.dp(24),
    //               child: Image.asset("assets/images/admin/setting/toCoach.png", fit: BoxFit.cover),
    //             ),
    //             Padding(padding: EdgeInsets.only(left: BaseUtil.dp(8))),
    //             Text(
    //               "成为教练",
    //               style: TextStyle(
    //                   color: Color(0xFF333333),
    //                   fontSize: BaseUtil.dp(14)
    //               ),
    //             ),
    //             Expanded(flex: 1, child: Text("")),
    //             Text(
    //               "立即申请",
    //               style: TextStyle(
    //                   color: Color(0xFF999999),
    //                   fontSize: BaseUtil.dp(12)
    //               ),
    //             ),
    //             Padding(padding: EdgeInsets.only(left: BaseUtil.dp(20))),
    //             Image.asset('assets/images/common/dg.webp',
    //               height: BaseUtil.dp(16),
    //             ),
    //           ],
    //         ),
    //       )
    //   ));
    //   arrWidget.add(GestureDetector(
    //       behavior: HitTestBehavior.opaque,
    //       onTap: () { widget.onSwitchParentType(140); },
    //       child: Container(
    //         padding: EdgeInsets.symmetric(horizontal: BaseUtil.dp(16), vertical: BaseUtil.dp(5)),
    //         decoration: BoxDecoration(
    //             border: Border(
    //                 bottom: BorderSide(
    //                     width: 1,
    //                     color: Color(0xFFEEEEEE)
    //                 )
    //             )
    //         ),
    //         child: Row(
    //           children: [
    //             Container(
    //               width: BaseUtil.dp(24),
    //               height: BaseUtil.dp(24),
    //               child: Image.asset("assets/images/admin/setting/toStudent.png", fit: BoxFit.cover),
    //             ),
    //             Padding(padding: EdgeInsets.only(left: BaseUtil.dp(8))),
    //             Text(
    //               "成为学员",
    //               style: TextStyle(
    //                   color: Color(0xFF333333),
    //                   fontSize: BaseUtil.dp(14)
    //               ),
    //             ),
    //             Expanded(flex: 1, child: Text("")),
    //             Text(
    //               "立即申请",
    //               style: TextStyle(
    //                   color: Color(0xFF999999),
    //                   fontSize: BaseUtil.dp(12)
    //               ),
    //             ),
    //             Padding(padding: EdgeInsets.only(left: BaseUtil.dp(20))),
    //             Image.asset('assets/images/common/dg.webp',
    //               height: BaseUtil.dp(16),
    //             ),
    //           ],
    //         ),
    //       )
    //   ));
    // }
    arrWidget.add(GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () { showExitDlg(); },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: BaseUtil.dp(16), vertical: BaseUtil.dp(10)),
          child: Row(
            children: [
              Container(
                width: BaseUtil.dp(24),
                height: BaseUtil.dp(24),
                child: Image.asset("assets/images/admin/setting/exit.png", fit: BoxFit.cover),
              ),
              Padding(padding: EdgeInsets.only(left: BaseUtil.dp(8))),
              Text(
                "退出登录",
                style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: BaseUtil.dp(14)
                ),
              ),
              Expanded(flex: 1, child: Text("")),
              Image.asset('assets/images/common/dg.webp',
                height: BaseUtil.dp(16),
              ),
            ],
          ),
        )
    ));

    return Container(
      color: Color(0xFFF9F9F9),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AdminHeaderPage(title: "个人设置", onBack: () { widget.onSwitchParentType(0); }),
          Padding(padding: EdgeInsets.only(top: BaseUtil.dp(5))),
          Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: BaseUtil.dp(16), vertical: BaseUtil.dp(5)),
            child: Column(
              children: arrWidget,
            ),
          )
        ],
      ),
    );
  }


  void showExitDlg() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, state) {
            return Material(
              type: MaterialType.transparency,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      width: BaseUtil.dp(250),
                      height: BaseUtil.dp(140),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: BaseUtil.dp(85),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 1,
                                  color: Color(0xFFEEEEEE)
                                )
                              )
                            ),
                            child: Text(
                              "确定退出登录?",
                              style: TextStyle(
                                color: Color(0xFF333333),
                                fontSize: BaseUtil.dp(16)
                              ),
                            )
                          ),
                          Expanded(
                            flex: 1,
                            child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () { Navigator.pop(context); },
                                  child: Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "取消",
                                        style: TextStyle(
                                            color: Color(0xFF333333),
                                            fontSize: BaseUtil.dp(14)
                                        ),
                                      )
                                  ),
                                ),
                              ),
                              Container(
                                  width: BaseUtil.dp(1),
                                  color: Color(0xFFEEEEEE)
                              ),
                              Expanded(
                                flex: 1,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () { _exit(); },
                                  child: Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "确定",
                                        style: TextStyle(
                                            color: Color(0xFF333333),
                                            fontSize: BaseUtil.dp(14)
                                        ),
                                      )
                                  ),
                                ),
                              ),
                            ],
                          )
                          )
                        ],
                      )
                  ),
                ],
              ),
            );
          },
        );
      }
    );
  }

  Future<void> _exit() async {
    await HttpUtil.getInstance().clearToken();

    WebSocketUtil.exitSocket();

    Navigator.of(context).pushNamedAndRemoveUntil("/", (Route<dynamic> route) => false);
  }
}