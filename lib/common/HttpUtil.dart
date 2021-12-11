/*
 * 网络服务
 */
// @dart=2.9
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/material.dart';

import 'BaseUtil.dart';
import 'LocalUtil.dart';

// 接口URL
abstract class API {
  //////////////////////////////////////////////////////////////////////////////
  // 登录注册界面
  static const captchaImage = '/captchaImage'; // 获取验证码
  static const doLogin = '/login'; // 登录
  static const getPasswordCode = '/app/getPasswordCode'; // 获取密码对应的验证码
  static const getPhoneCode = '/app/getPhoneCode'; // 获取手机号短信验证码
  static const getResetPwdCode = '/app/getResetPwdCode'; // 获取手机号短信验证码
  static const doLoginByPhonePassword = '/app/doLoginByPhonePassword'; // 手机密码登录
  static const doLoginByPhoneCode = '/app/doLoginByPhoneCode'; // 手机验证码登录
  static const doLoginByQQ = '/app/doLoginByQQ'; // QQ登录
  static const getUserInfo = '/app/getUserInfo'; // 获取用户信息
  static const getUserInfoById = '/app/getUserInfoById'; // 获取用户信息

  //////////////////////////////////////////////////////////////////////////////
  // 微信
  static const doLoginByWX = '/app/doLoginByWX'; // 微信登录
  static const shareToWX = '/app/shareToWX'; // 分享到微信
  static const getPrePayOrder = '/pay/getPrePayOrder'; // 获取预付单信息
  static const payOrder = '/pay/payOrder'; // 支付订单
  static const queryOrder = '/pay/queryOrder'; // 查询订单

  //////////////////////////////////////////////////////////////////////////////
  // 直播
  static const openLive = '/app/openLive'; // 开播
  static const closeLive = '/app/closeLive'; // 关播
  static const watchLive = '/app/watchLive'; // 观看直播
  static const enterLiveAfter = '/app/enterLiveAfter'; // 进入直播间之后, 通知所有人更新直播间信息
  static const leaveLive = '/app/leaveLive'; // 退出直播
  static const getLiveInfo = '/app/getLiveInfo'; // 获取直播间信息
  static const getLiveList = '/app/getLiveList'; // 获取直播列表
  static const getFollowAnchorList = '/app/getFollowAnchorList'; // 获取关注的主播列表

  //////////////////////////////////////////////////////////////////////////////
  // 点播
  static const getVideoList = '/app/getVideoList'; // 获取视频列表
  static const addVideo = '/app/addVideo'; // 添加视频
  static const playVideo = '/app/playVideo'; // 开始播放视频
  static const closeVideo = '/app/closeVideo'; // 关闭视频
  static const getVideoInfo = '/app/getVideoInfo'; // 获取视频信息

  //////////////////////////////////////////////////////////////////////////////
  // 设备
  static const connectBicycle = '/app/connectBicycle'; // 连接设备
  static const disconnectBicycle = '/app/disconnectBicycle'; // 断开设备连接
  static const getLastBicycleLog = '/app/getLastBicycleLog'; // 获取系统配置信息
  static const batchUpdateBicycleDrag =
      '/app/batchUpdateBicycleDrag'; // 获取系统配置信息

  //////////////////////////////////////////////////////////////////////////////
  // 比赛
  static const getMatchList = '/app/getMatchList'; // 获取比赛列表
  static const addMatch = '/app/addMatch'; // 添加比赛
  static const updateMatch = '/app/updateMatch'; // 更新比赛
  static const getMatchInfo = '/app/getMatchInfo'; // 获取比赛
  static const joinMatch = '/app/joinMatch'; // 参加比赛
  static const getIsJoinMatch = '/app/getIsJoinMatch'; // 判断是否参加比赛
  static const createMatchRoom = '/app/createMatchRoom'; // 教练点击创建比赛房间
  static const enterMatchRoom = '/app/enterMatchRoom'; // 点击进入比赛房间, 如果是学员，表示准备
  static const leaveMatchRoom = '/app/leaveMatchRoom'; // 离开比赛房间
  static const beginMatch = '/app/beginMatch'; // 教练点击开始比赛
  static const endMatch = '/app/endMatch'; // 教练点击结束比赛
  static const finishPeopleMatch = '/app/finishPeopleMatch'; // 学员完成比赛, 固定里程的情况下
  static const getMatchPeopleList = '/app/getMatchPeopleList'; // 获取比赛人员列表

  //////////////////////////////////////////////////////////////////////////////
  // 我的
  static const updateUserInfo = '/app/updateUserInfo'; // 更新用户信息(头像、昵称、签名)
  static const updateAppPwd = '/app/updateAppPwd'; // 修改密码
  static const toCoach = '/app/toCoach'; // 申请成为教练
  static const toStudent = '/app/toStudent'; // 申请成为学员
  static const avatar = '/app/avatar'; // 设置头像
  static const getRecordPayList = '/app/getRecordPayList'; // 获取交易记录列表
  static const getRecordInteractList = '/app/getRecordInteractList'; // 获取互动记录列表
  static const getRecordMoneyList = '/app/getRecordMoneyList'; // 获取车币记录列表
  static const getRecordRechargeList = '/app/getRecordRechargeList'; // 获取充值记录列表
  static const getAppCollectionList = '/app/getAppCollectionList'; // 获取收藏列表
  static const getFansList = '/app/getFansList'; // 获取粉丝列表
  static const getFollowList = '/app/getFollowList'; // 获取关注列表

  //////////////////////////////////////////////////////////////////////////////
  // 其他
  static const uploadFile = '/common/upload'; // 上传文件路径
  static const uploadVideo = '/common/uploadVideo'; // 上传文件路径
  static const getSwiperList = '/app/getSwiperList'; // 获取直播轮播图列表
  static const getArealList = '/getArealList'; // 获取地区列表
  static const getAgoraToken = '/api/agora/getToken'; // 获取直播Token
  static const getGiftTypeList = '/app/searchGiftList'; // 获取礼物类型列表
  static const getIsCollection = '/app/getIsCollection'; // 判断是否收藏
  static const setCollection = '/app/setCollection'; // 收藏
  static const setFollow = '/app/setFollow'; // 设置关注或者取消关注
  static const getIsFollow = '/app/getIsFollow'; // 判断是否收藏
  static const getSystemConfigMap = '/system/getSystemConfigMap'; // 获取系统配置信息
}

// http请求
final dioManager = DioCacheManager(CacheConfig(skipDiskCache: true));

class HttpUtil {
  Dio mDio;

  // 身份认证
  String mToken = "";

  static HttpUtil mInstance;

  HttpUtil() {
    mDio = new Dio(BaseOptions(
      baseUrl: BaseUtil.gBaseUrl,
      connectTimeout: 15000,
      receiveTimeout: 10000,
    ));
    mDio.interceptors.add(dioManager.interceptor);
    InterceptorSendCallback cbRequest =
        (RequestOptions options, RequestInterceptorHandler handler) {
      print("\n================== 请求数据 ==========================");
      print("url = ${options.uri.toString()}");
      print("headers = ${options.headers}");
      print("params = ${options.data}");
      return handler.next(options);
    };
    InterceptorSuccessCallback cbResponse =
        (Response response, ResponseInterceptorHandler handler) {
      print("\n================== 响应数据 ==========================");
      print("code = ${response.statusCode}");
      print("data = ${response.data}");
      print("\n");
      return handler.next(response);
    };
    InterceptorErrorCallback cbError =
        (DioError e, ErrorInterceptorHandler handler) {
      print("\n================== 错误响应数据 ======================");
      print("type = ${e.type}");
      print("message = ${e.message}");
      print("stackTrace = ${e.error}");
      print("\n");
      return handler.next(e);
    };

    // 添加拦截器
    mDio.interceptors.add(InterceptorsWrapper(
        onRequest: cbRequest, onResponse: cbResponse, onError: cbError));
  }

  static HttpUtil getInstance() {
    if (null == mInstance) {
      mInstance = HttpUtil();
    }
    return mInstance;
  }

  Future<Response> getData(String url) async {
    return await mDio.get(url);
  }

  Future<Response> put(String url,
      {dynamic params, Options option, bool hasToken = true}) async {
    if (option == null) {
      option = Options();
    }
    option.method = "PUT";
    if (hasToken) {
      option.headers = {'Authorization': 'Bearer ' + mToken};
    }
    if (params != null) {
      params = Map<String, dynamic>.from(params);
    }
    return await mDio.put(url, queryParameters: params, options: option);
  }

  Future<Response> get(String url,
      {dynamic params, Options option, bool hasToken = true}) async {
    if (option == null) {
      option = Options();
    }
    option.method = "GET";
    if (hasToken) {
      option.headers = {'Authorization': 'Bearer ' + mToken};
    }
    if (params != null) {
      params = Map<String, dynamic>.from(params);
    }
    return await mDio.get(url, queryParameters: params, options: option);
  }

  Future<Response> postForm(String url,
      {dynamic params, Options option, bool hasToken = true}) async {
    if (option == null) {
      option = Options();
    }
    option.method = "POST";
    option.contentType = "application/x-www-form-urlencoded";
    if (hasToken) {
      option.headers = {'Authorization': 'Bearer ' + mToken};
    }
    if (params != null) {
      params = Map<String, dynamic>.from(params);
    }
    return await mDio.post(url, data: params, options: option);
  }

  Future<Response> postJson(String url,
      {dynamic params, Options option, bool hasToken = true}) async {
    if (option == null) {
      option = Options();
    }
    option.method = "POST";
    option.contentType = "application/json";
    if (hasToken) {
      option.headers = {'Authorization': 'Bearer ' + mToken};
    }
    if (params != null) {
      params = Map<String, dynamic>.from(params);
    }
    return await mDio.post(url, data: params, options: option);
  }

  /// 上传文件
  /// 注：file是服务端接受的字段字段，如果接受字段不是这个需要修改
  Future<Response> uploadFile(
      String strURL, String paramName, String strFilePath,
      {bool hasToken = true, ext = ""}) async {
    var strName = strFilePath.substring(
        strFilePath.lastIndexOf("/") + 1, strFilePath.length);
    if (ext != "") {
      strName = strName.substring(0, strName.lastIndexOf("."));
      strName = strName + "." + ext;
    }
    var postData = FormData.fromMap({
      paramName: await MultipartFile.fromFile(strFilePath, filename: strName)
    }); //file是服务端接受的字段字段，如果接受字段不是这个需要修改
    var option = Options(
        method: "POST",
        contentType: "multipart/form-data" // 上传文件的content-type 表单
        );
    if (hasToken) {
      option.headers = {'Authorization': 'Bearer ' + mToken};
    }
    return await mDio.post(
      strURL,
      data: postData,
      options: option,
      onSendProgress: (int sent, int total) {
//        print("上传进度：" +
//            NumUtil.getNumByValueDouble(sent / total * 100, 2)
//                .toStringAsFixed(2) +
//            "%"); //取精度，如：56.45%
      },
    );
  }

  /// 下载文件
  Future<Response> downloadFile(String resUrl, String savePath) async {
    //还好我之前写过服务端代码，不然我根本没有相对路劲的概念
    return await mDio.download(resUrl, savePath,
        onReceiveProgress: (int loaded, int total) {
//          print("下载进度：" +
//              NumUtil.getNumByValueDouble(loaded / total * 100, 2)
//                  .toStringAsFixed(2) +
//              "%"); //取精度，如：56.45%
    });
  }

  ///////////////////////////////////////////////////////////////////////////
  Future<void> setToken(String token) async {
    mToken = token;
    LocalUtil.gConfigData["token"] = token;
    LocalUtil.saveConfigFile();
  }

  Future<void> clearToken() async {
    mToken = "";
    LocalUtil.gConfigData["token"] = "";
    LocalUtil.saveConfigFile();
  }

  Future<void> reloadToken() async {
    await LocalUtil.readConfigFile();
    mDio.options.baseUrl = BaseUtil.gBaseUrl;
    if (LocalUtil.gConfigData.containsKey("token")) {
      mToken = LocalUtil.gConfigData["token"];
    } else {
      mToken = "";
    }
    loadServerConfig();
  }

  void loadServerConfig() {
    HttpUtil.getInstance()
        .postJson(API.getSystemConfigMap, hasToken: false)
        .then((response) {
      if (response == null) {
        return;
      }
      var json = jsonDecode(response.toString());
      BaseUtil.gServerConfig = json["data"];
    });
  }

  Future<bool> hasToken() async {
    reloadToken();
    return mToken != null && mToken.length > 10;
  }

  Future<void> getUserInfo(context) async {
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

      WebSocketUtil.initSocket();

      Navigator.of(context).pushNamedAndRemoveUntil(
          "/index", (Route<dynamic> route) => false,
          arguments: 0);
    });
  }
}
