/*
 * 界面业务层方法
 */

// @dart=2.9
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dong_gan_dan_che/common/BaseUtil.dart';

class PageListInfo {
  String strAPI;
  int nPageNum;
  int nTotal;
  List<dynamic> arr;
  PageListInfo(this.strAPI, this.nPageNum, this.nTotal, this.arr);
}

abstract class DongGanDanCheService {
  static Map<String, PageListInfo> gMapPageList = {
    "Live": PageListInfo('/app/getLiveList', 1, 0, []),             /// 直播列表
    "LiveCollection": PageListInfo('/app/getLiveCollectionList', 1, 0, []),       /// 关注主播列表
    "Video": PageListInfo('/app/getVideoList', 1, 0, []),            /// 点播视频列表
    "VideoCollection": PageListInfo('/app/getVideoCollectionList', 1, 0, []),      /// 关注点播视频列表
    "Follow": PageListInfo('/app/getFollowList', 1, 0, []),      /// 我的关注列表
    "Fans": PageListInfo('/app/getFansList', 1, 0, []),          /// 我的粉丝列表
    "Match": PageListInfo('/app/getMatchList', 1, 0, []),            /// 比赛列表
    "RecordMatch": PageListInfo('/app/getRecordMatchList', 1, 0, []),      /// 比赛记录列表
    "RecordPay": PageListInfo('/app/getRecordPayList', 1, 0, []),        /// 交易记录列表
    "RecordLike": PageListInfo('/app/getRecordLikeList', 1, 0, []),       /// 点赞记录列表
    "RecordComment": PageListInfo('/app/getRecordCommentList', 1, 0, []),    /// 评论记录列表
    "RecordForward": PageListInfo('/app/getRecordForwardList', 1, 0, []),    /// 转发记录列表
    "RecordRecharge": PageListInfo('/app/getRecordRechargeList', 1, 0, []),   /// 充值记录列表
    "RecordCollection": PageListInfo('/app/getCollectionList', 1, 0, []), /// 收藏记录列表
  };

  static void search(type, int pageNum, dynamic params, Function callback, { bool bNoCache = false }) {
    EasyLoading.show(status: '加载中...');
    try {
      pageNum = pageNum == null ? 1 : pageNum;
      params["pageSize"] = '10';
      params["pageNum"] = '$pageNum';
      params["pageIndex"] = '$pageNum';
      params["userId"] = params["userId"];
      params["searchKey"] = params["searchKey"];
      PageListInfo stPageListInfo = gMapPageList[type];
      int lastPageNum = stPageListInfo.nPageNum;
      stPageListInfo.nPageNum = pageNum;
      HttpUtil.getInstance().postJson(stPageListInfo.strAPI, params: params,
          option: (pageNum == 1 && bNoCache == false) ? buildCacheOptions(Duration(minutes: 30),) : null
      ).then((response) {
        EasyLoading.dismiss();
        if (response == null) {
          return;
        }
        /// 转换成JSON
        var data = jsonDecode(response.toString());
        var nTotal = data["total"] == null ? 0 : data["total"];
        var arr = data["rows"] == null ? ( data["data"] == null ? [] : data["data"] ) : data["rows"];
        stPageListInfo.nTotal = nTotal;
        /// 动态加载数据
        if (pageNum == 1) {
          stPageListInfo.arr = arr;
        } else if (lastPageNum < pageNum) {
          stPageListInfo.arr.addAll(arr);
        }
        stPageListInfo.nPageNum = pageNum;
        EventUtil.gEventBus.fire(UpdateIndexListEvent(type));
        callback(nTotal, arr);
      });
    } catch(e) {
      EasyLoading.dismiss();
      print(e);
    }
  }

  /// 下拉刷新
  static void onRefresh(type, params, refreshController, { bool bNoCache = true  }) {
    search(type, 1, params, (total, arr){}, bNoCache: bNoCache);
    if (refreshController != null) {
      refreshController.refreshCompleted();
    }
  }

  /// 下拉刷新
  static void onLoading(type, params, refreshController, { bool bNoCache = true  }) {
    PageListInfo stPageListInfo = gMapPageList[type];
    int nIndex = stPageListInfo.nPageNum;
    if (nIndex * 10 < stPageListInfo.nTotal) {
      nIndex++;
    }
    if (stPageListInfo.nPageNum == nIndex && nIndex > 1) {
      refreshController.loadNoData();
      return;
    }
    search(type, nIndex, params, (total, arr){
      refreshController.loadComplete();
    }, bNoCache: bNoCache);
  }

  /// 格式化数值
  static String formatNum(int number) {
    if (number > 10000) {
      var str = DongGanDanCheService._formatNum(number / 10000, 1);
      if (str.split('.')[1] == '0') {
        str = str.split('.')[0];
      }
      return str + '万';
    }
    return number.toString();
  }
  static String _formatNum(double number, int postion) {
    if((number.toString().length - number.toString().lastIndexOf(".") - 1) < postion) {
      // 小数点后有几位小数
      return ( number.toStringAsFixed(postion).substring(0, number.toString().lastIndexOf(".")+postion + 1).toString());
    } else {
      return ( number.toString().substring(0, number.toString().lastIndexOf(".") + postion + 1).toString());
    }
  }

  /// 格式化时间
  static String formatTime(int timeSec) {
    var date = DateTime.fromMillisecondsSinceEpoch(timeSec * 1000);
    var now = DateTime.now();
    var yesterday = DateTime.fromMillisecondsSinceEpoch(now.millisecondsSinceEpoch - 24 * 60 * 60 * 1000);

    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return '今天${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      return '昨天${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.year.toString()}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  /// 生成随机串
  static dynamic randomBit(int len, { String type }) {
    String character = type == 'num' ? '0123456789' : 'qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM';
    String left = '';
    for (var i = 0; i < len; i++) {
      left = left + character[Random().nextInt(character.length)]; 
    }
    return type == 'num' ? int.parse(left) : left;
  }


  static Widget tryBuildImage(String strFilePath, BoxFit fit) {
    if (strFilePath == null || strFilePath.length < 10) {
      return Image.asset("assets/images/common/default.jpg", fit: fit,);
    } else {
      try {
        if (strFilePath.indexOf("http") > -1) {
          try {
            Image ret = Image.network(
              strFilePath,
              fit: BoxFit.cover,
            );
            return ret;
          } catch(e) {
            return Image.asset("assets/images/common/default.jpg", fit: fit,);
          }
        } else {
          return Image.file(
            File(strFilePath),
            fit: BoxFit.cover,
          );
        }
      } catch(e) {
        return Image.asset("assets/images/common/default.jpg", fit: fit,);
      }
    }
  }

  static Widget buildImage(String strFilePath, BoxFit fit, double nWidth, double nHeight) {
    if (strFilePath == null || strFilePath.length < 10) {
      return Image.asset(
        'assets/images/common/default.jpg',
        fit: fit,
        width: nWidth,
        height:nHeight,
      );
    } else if (strFilePath.indexOf("http") > -1) {
      return CachedNetworkImage(
        imageUrl: strFilePath,
        placeholder: (context, url) => Image.asset(
          'assets/images/common/default.jpg',
          fit: fit,
        ),
        fit: fit,
      );
    } else {
      return Image.asset(
        strFilePath,
        fit: fit,
        width: nWidth,
        height:nHeight,
      );
    }

  }
}

abstract class DongGanDanCheDialog {
    // 默认弹窗alert
  static void alert(context, {
    @required String text, String title = '提示', String yes = '确定',
    Function yesCallBack
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(text),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(yes),
              onPressed: () {
                if (yesCallBack != null) yesCallBack();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    ).then((val) {});
  }

}

// 禁用点击水波纹
class NoSplashFactory extends InteractiveInkFeatureFactory {
  @override
  InteractiveInkFeature create({
    MaterialInkController controller,
    RenderBox referenceBox,
    Offset position,
    Color color,
    TextDirection textDirection,
    bool containedInkWell = false,
    rectCallback,
    BorderRadius borderRadius,
    ShapeBorder customBorder,
    double radius,
    onRemoved
  }) {
    return NoSplash(
      controller: controller,
      referenceBox: referenceBox,
    );
  }
}

class NoSplash extends InteractiveInkFeature {
  NoSplash({
    @required MaterialInkController controller,
    @required RenderBox referenceBox,
  }) : super(
    color: Colors.white,
    controller: controller,
    referenceBox: referenceBox,
  );

  @override
  void paintFeature(Canvas canvas, Matrix4 transform) {}
}

// 去除安卓滚动视图水波纹
class DongGanDanCheBehaviorNull extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    if (Platform.isAndroid || Platform.isFuchsia) {
      return child;
    } else {
      return super.buildViewportChrome(context,child,axisDirection);
    }
  }
}

// 下拉刷新头部、底部组件                                                            
class DongGanDanCheRefreshHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomHeader(
      refreshStyle: RefreshStyle.Follow,
      builder: (BuildContext context, RefreshStatus status) {
        bool swimming = (status == RefreshStatus.refreshing || status == RefreshStatus.completed);
        return Container(
          height: BaseUtil.dp(40),
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              swimming ? SizedBox() : Image.asset(
                'assets/images/common/fun_home_pull_down.png',
                height: BaseUtil.dp(40),
              ),
             // Offstage(
             //   offstage: !swimming,
             //   child: refreshing,
             // ),
            ]
          )
        );
      }
    );
  }
}

class DongGanDanCheRefreshFooter extends StatelessWidget {
  final bgColor;
  DongGanDanCheRefreshFooter({this.bgColor});

  @override
  Widget build(BuildContext context) {
    final height = BaseUtil.dp(40);

    return CustomFooter(
      height: height,
      builder: (BuildContext context, LoadStatus mode){
        final textStyle = TextStyle(
          color: Color(0xffA7A7A7),
          fontSize: BaseUtil.dp(13),
        );
        Widget body;
        Widget loading = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
//            Lottie.network(
//              '${BaseData.baseUrl}/static/loading.json',
//              height: BaseData.dp(34)
//            ),
            Text(
              '用力加载中...',
              style: textStyle,
            ),
          ],
        );
        if(mode==LoadStatus.idle){
          body = loading;
        }
        else if(mode==LoadStatus.loading){
          body = loading;
        }
        else if(mode == LoadStatus.failed){
          body = Text(
            '网络出错啦 😭',
            style: textStyle,
          );
        }
        else if(mode == LoadStatus.canLoading){
          body = loading;
        }
        else{
          body = Text(
            '我是有底线的 😭',
            style: textStyle,
          );
        }
        return Container(
          color: bgColor,
          height: height,
          child: Center(child:body),
        );
      },
    );
  }
}

