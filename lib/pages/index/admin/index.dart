/*
 * 我的个人中心主界面
 */
// @dart=2.9
import 'dart:async';

import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:flutter/material.dart';

import 'base.dart';
import 'fans.dart';
import 'follow.dart';
import 'collection.dart';
import 'bi.dart';
import 'setting/index.dart';
import 'setting/info.dart';
import 'setting/avatar.dart';
import 'setting/remark.dart';
import 'setting/password.dart';
import 'setting/toCoach.dart';
import 'setting/toStudent.dart';
import 'record/interact.dart';
import 'record/pay.dart';
import 'record/recharge.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  StreamSubscription streamSubscription;
  /// 0 - 个人中心
  /// 100 - 个人设置
  /// 110 -- 个人资料
  /// 111 --- 修改头像
  /// 120 -- 修改密码
  /// 130 -- 成为教练
  /// 140 -- 成为学员
  /// 300 - 交易记录
  /// 400 - 互动记录
  /// 500 - 收藏
  /// 610 - 粉丝
  /// 620 - 关注
  /// 630 - 车币
  /// 631 - 充值记录
  int nStateType = 0;

  @override
  void initState() {
    nStateType = 0;
    super.initState();
    streamSubscription = EventUtil.gEventBus.on<SwitchIndexPageEvent>().listen((event) {
      if (event.pageIndex != 4) {
        return;
      }
      HttpUtil.getInstance().get(API.getUserInfo, params: {}).then((res) {
        if (res == null) {
          return;
        }
        var data = jsonDecode(res.toString());
        if (data["success"] != true) {
          return;
        }
        var u = data["data"];
        BaseUtil.gStUser = new Map<String, dynamic>.from(u);
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 当显示个人中心时, 点击返回是触发退出功能
    BaseUtil.gOnBackspace = nStateType == 0 ? null : onBackspace;
    Widget body = Text("");
    switch (nStateType) {
      case 0: { body = AdminBasePage(onSwitchParentType: onSwitchType); } break;
      case 100: { body = AdminSettingIndexPage(onSwitchParentType: onSwitchType); } break;
      case 110: { body = AdminSettingInfoPage(onSwitchParentType: onSwitchType); } break;
      case 111: { body = AdminSettingAvatarPage(onSwitchParentType: onSwitchType); } break;
      case 112: { body = AdminSettingRemarkPage(onSwitchParentType: onSwitchType); } break;
      case 120: { body = AdminSettingPasswordPage(onSwitchParentType: onSwitchType); } break;
      case 130: { body = AdminSettingToCoachPage(onSwitchParentType: onSwitchType); } break;
      case 140: { body = AdminSettingToStudentPage(onSwitchParentType: onSwitchType); } break;
      case 200: { body = AdminCollectionPage(onSwitchParentType: onSwitchType); } break;
      case 300: { body = AdminRecordPayPage(onSwitchParentType: onSwitchType); } break;
      case 400: { body = AdminRecordInteractPage(onSwitchParentType: onSwitchType); } break;
      case 610: { body = AdminFansPage(onSwitchParentType: onSwitchType); } break;
      case 620: { body = AdminFollowPage(onSwitchParentType: onSwitchType); } break;
      case 630: { body = AdminBiPage(onSwitchParentType: onSwitchType); } break;
      case 631: { body = AdminRecordRechargePage(onSwitchParentType: onSwitchType); } break;
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: body
    );
  }

  void onSwitchType(type) {
    setState(() {
      nStateType = type;
    });
  }

  void onBackspace() {
    switch (nStateType) {
      case 100:
      case 120:
      case 130:
      case 140:
      case 200:
      case 300:
      case 400:
      case 610:
      case 620:
      case 630: { onSwitchType(0); } break;
      case 110: { onSwitchType(100); } break;
      case 111:
      case 112: { onSwitchType(110); } break;
      case 631: { onSwitchType(630); } break;
    }
  }

}
