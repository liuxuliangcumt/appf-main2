/*
 * 轮播图, 目前直播和比赛都有轮播图, 都用的这个
 */
// @dart=2.9
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:url_launcher/url_launcher.dart';

class SwiperListPage extends StatefulWidget {
  final int type;
  SwiperListPage(this.type);

  @override
  _SwiperListPage createState() => _SwiperListPage();
}

class _SwiperListPage extends State<SwiperListPage> {
  List<dynamic> mSrcList = [];
  List<dynamic> mArrList = [];
  final arrDefaultSwiper = [
    "https://www.reciprocalaffection.com/uploads/DongGanDanChe/banner/1.jpg",
    "https://www.reciprocalaffection.com/uploads/DongGanDanChe/banner/2.jpg"
  ];

  @override
  void initState() {
    super.initState();
    try {
      HttpUtil.getInstance().postJson(API.getSwiperList, params: {
        "type": widget.type
      }).then((response) {
        setState(() {
          mArrList = _findSwiperList(response);
        });
      });
    } catch(e) {
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(BaseUtil.dp(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.all(
          Radius.circular(BaseUtil.dp(10)),
        ),
        child: Container(
          height: BaseUtil.dp(130),
          child: _waitSwiperData(),
        ),
      ),
    );
  }

  List _findSwiperList(response) {
    if (response == null) {
      return arrDefaultSwiper;
    }
    var data = jsonDecode(response.toString());
    if (data["success"] != true) {
      CustomSnackBar(context, Text("获取轮播图失败"));
      return arrDefaultSwiper;
    }
    var list = data["data"];
    if (list == null || list.length == 0) {
      return arrDefaultSwiper;
    }
    mSrcList = list;
    var arr = [];
    list.forEach((item) {
      arr.add(BaseUtil.gBaseUrl + item["imgPath"]);
    });
    return arr;
  }

  Widget _waitSwiperData() {
    if (mArrList == null || mArrList.length == 0) {
      return Image.asset(
        'assets/images/common/default.jpg',
      );
    }
    return Swiper(
      itemBuilder: (BuildContext context, int index) {
        return buildWidget(context, index);
      },
      itemCount: mArrList.length,
      pagination: SwiperPagination(
          builder: DotSwiperPaginationBuilder(
            color: Colors.white,
            size: BaseUtil.dp(6),
            activeSize: BaseUtil.dp(9),
            activeColor: BaseUtil.gDefaultColor,
          ),
          margin: EdgeInsets.only(
            right: BaseUtil.dp(10),
            bottom: BaseUtil.dp(5),
          ),
          alignment: Alignment.bottomRight
      ),
      scrollDirection: Axis.horizontal,
      autoplay: true,
      onTap: onClick,
    );
  }

  Widget buildWidget(BuildContext context, int index) {
    var def = Image.asset("assets/images/common/default.jpg", fit: BoxFit.cover);
    if (mArrList[index] == null || mArrList[index] == "") {
      return def;
    }
    try {
      return CachedNetworkImage(
        imageUrl: mArrList[index],
        placeholder: (context, url) => def,
        errorWidget: (context, url, err) => def,
        fit: BoxFit.cover,
      );
    } catch(e) {
      return def;
    }
  }

  void onClick(index) {
    if (mSrcList.length <= index) {
      onLaunch("https://www.baidu.com");
      return;
    }
    var item = mSrcList[index];
    if (item["navType"] == '10') {
      onLaunch(item["navUrl"]);
    }
  }

  void onLaunch(url) async {
    if(await canLaunch(url)){
      await launch(url);
    }else{
      CustomSnackBar(context, Text("无法打开链接"));
    }
  }

}
