/*
蓝牙通信封装
*/

// @dart=2.9

import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:async';


class BleUtil {
  //region 静态变量
  /// 操作蓝牙的根对象
  static FlutterBlue flutterBlue;
  /// 搜索到的设备列表
  static List arrBleDevice;
  /// 搜索蓝牙后当前选择连接的设备
  static BluetoothDevice deviceCurrent;
  /// 重连时,根据当前连接设备的Mac地址查询到的设备
  static BluetoothDevice deviceReconnect;
  /// 用于监听接收蓝牙数据的对象
  static BluetoothCharacteristic characteristicRead;
  /// 用于向蓝牙发送数据的对象
  static BluetoothCharacteristic characteristicWrite;

  /// 监听手机蓝牙状态的回调函数,用于收到手机的蓝牙状态变化时,通知外部业务处理
  static Function callbackBleState;
  /// 监听搜索蓝牙设备的回调函数,用于点击搜索蓝牙后,通知外部设备列表变更了,应该进行具体的业务处理了
  static Function callbackScan;
  /// 接收蓝牙设备数据的回调函数,用于蓝牙设备发过数据时,通知外部业务处理
  static Function callbackData;
  /// 蓝牙日志变更时,通知外部处理逻辑, 测试时使用
  static Function callbackLog;
  /// 使用时间定时器回调, 用于更新当前连接的设备使用时间
  static Function callbackTimer;

  /// 监听蓝牙状态的控制, 启动新监听之前,需要先关闭旧监听
  static StreamSubscription streamSubscriptionBleState;
  /// 监听扫描的控制, 启动新监听之前,需要先关闭旧监听
  static StreamSubscription streamSubscriptionScan;
  /// 监听设备状态的控制, 启动新监听之前,需要先关闭旧监听
  static StreamSubscription streamSubscriptionDeviceState;
  /// 监听设备数据读取的控制, 启动新监听之前,需要先关闭旧监听
  static StreamSubscription streamSubscriptionRead;

  /// 当前设备使用时间定时器, 定时记录使用时间
  static Timer _timerUsed;
  /// 延时执行手机蓝牙状态切换的定时器, 因为启动蓝牙时会先触发蓝牙状态关闭, 然后切换成蓝牙状态开启,
  /// 所以需要使用定时器,只响应短时间内最后一次状态
  static Timer _timerDelayBleState;
  /// 延时执行设备相关变化的定时器, 因为蓝牙设备连接时, 也会先触发断开, 然后在变成连接
  /// 所以需要使用定时器,只响应短时间内最后一次
  static Timer _timerDelayDevice;

  /// 是否已经初始化过了
  static bool bInitialized = false;
  /// 当前蓝牙状态, 手机蓝牙开着是true, 否则是false
  static bool bBleStateCurrent = false;
  /// -1表示不重连或者结束重连，0表示开始重连，大于0表示重连次数
  static int nReconnectCount = -1;

  /// 设备连接后累计使用了多少秒
  static int nUsedSecond = 0;
  /// 日志
  static String gLog = "";
  //endregion

  //region 初始化和析构
  /// 初始化蓝牙环境
  static void initBle() {
    if (bInitialized) {
      return;
    }
    bInitialized = true;
    flutterBlue = FlutterBlue.instance;
    arrBleDevice = [];
    deviceCurrent = null;
    deviceReconnect = null;
    characteristicRead = null;
    characteristicWrite = null;

    callbackBleState = null;
    callbackScan = null;
    callbackData = null;
    callbackLog = null;
    callbackTimer = null;

    streamSubscriptionBleState = null;
    streamSubscriptionScan = null;
    streamSubscriptionDeviceState = null;
    streamSubscriptionRead = null;

    _timerUsed = null;
    _timerDelayBleState = null;
    _timerDelayDevice = null;

    bBleStateCurrent = false;

    nReconnectCount = -1;
    gLog = "";
  }

  /// 退出蓝牙环境
  static void exitBle() {
    bInitialized = false;
    flutterBlue = null;
    arrBleDevice = [];

    if (streamSubscriptionBleState != null) {
      streamSubscriptionBleState.cancel();
    }
    if (streamSubscriptionScan != null) {
      streamSubscriptionScan.cancel();
    }
    if (streamSubscriptionDeviceState != null) {
      streamSubscriptionDeviceState.cancel();
    }
    if (streamSubscriptionRead != null) {
      streamSubscriptionRead.cancel();
    }
    if (deviceCurrent != null) {
      deviceCurrent.disconnect();
    }
    if (_timerUsed != null) {
      _timerUsed.cancel();
    }
    if (_timerDelayBleState != null) {
      _timerDelayBleState.cancel();
    }
    if (_timerDelayDevice != null) {
      _timerDelayDevice.cancel();
    }

    deviceCurrent = null;
    deviceReconnect = null;
    characteristicRead = null;
    characteristicWrite = null;

    callbackBleState = null;
    callbackScan = null;
    callbackData = null;
    callbackLog = null;
    callbackTimer = null;

    streamSubscriptionBleState = null;
    streamSubscriptionScan = null;
    streamSubscriptionDeviceState = null;
    streamSubscriptionRead = null;

    _timerUsed = null;
    _timerDelayBleState = null;
    _timerDelayDevice = null;

    bBleStateCurrent = false;

    nReconnectCount = -1;
    gLog = "";
  }
  //endregion

  //region 开始监听和停止监听
  /// 开始监听手机蓝牙状态变更
  static Future<void> startListenBleState() async {
    stopListenBleState();
    addBleLog('开始监听蓝牙状态');
    streamSubscriptionBleState = flutterBlue.state.listen((state){
      if(state == BluetoothState.on){
        addBleLog('当前蓝牙状态为开启');
        bBleStateCurrent = true;
      }else if(state == BluetoothState.off){
        addBleLog('当前蓝牙状态为关闭');
        bBleStateCurrent = false;
      }
      /// 如果上一次状态切换还未处理,则先取消定时处理
      if (_timerDelayBleState != null) {
        _timerDelayBleState.cancel();
        _timerDelayBleState = null;
      }
      if (callbackBleState != null) {
        /// 延迟执行状态提示
        _timerDelayBleState = Timer(Duration(milliseconds: 500),() async {
          callbackBleState(bBleStateCurrent);
          _timerDelayBleState.cancel();
          _timerDelayBleState = null;
        });
      }
    });
  }
  /// 停止监听手机蓝牙状态变更
  static Future<void> stopListenBleState() async {
    if (streamSubscriptionBleState != null) {
      addBleLog("停止监听蓝牙状态");
      streamSubscriptionBleState.cancel();
      streamSubscriptionBleState = null;
    }
    if (_timerDelayBleState != null) {
      _timerDelayBleState.cancel();
      _timerDelayBleState = null;
    }
  }

  /// 开始扫描设备
  static Future<void> startScan() async {
    await stopScan();
    addBleLog("开始搜索蓝牙设备");
    /// 设置扫描时间4秒
    flutterBlue.startScan(timeout: Duration(seconds: 4));
    /// 监听扫描结果
    streamSubscriptionScan = flutterBlue.scanResults.listen((results) {
      arrBleDevice = [];
      /// 扫描结果 可扫描到的所有蓝牙设备
      for (ScanResult r in results) {
        if (r == null || r.device == null) {
          continue;
        }
        arrBleDevice.add(r.device);
      }
      if (callbackScan != null) {
        callbackScan();
      }
    });
  }
  /// 停止扫描设备
  static Future<void> stopScan() async {
    if (streamSubscriptionScan != null) {
      addBleLog("停止搜索蓝牙设备");
      await flutterBlue.stopScan();
      streamSubscriptionScan.cancel();
      streamSubscriptionScan = null;
    }
  }

  /// 开始监听设备连接状态
  static void startListenDeviceState() {
    stopListenDeviceState();
    if (deviceCurrent == null) {
      addBleLog("未连接蓝牙设备, 无法监听");
      return;
    }
    addBleLog("开始监听设备连接状态");
    streamSubscriptionDeviceState = deviceCurrent.state.listen((state){
      if(state == BluetoothDeviceState.disconnected){
        addBleLog("设备${deviceCurrent.id.id}断开连接");
        if (deviceCurrent != null) {
          nReconnectCount = 0;
        }
      } else if(state == BluetoothDeviceState.connected){
        addBleLog("设备${deviceCurrent.id.id}连接成功");
        nReconnectCount = -1;
      } else if(state == BluetoothDeviceState.connecting){
        addBleLog("设备${deviceCurrent.id.id}正在连接中。。。");
        nReconnectCount = -1;
      } else if(state == BluetoothDeviceState.disconnecting){
        addBleLog("设备${deviceCurrent.id.id}正在断开连接。。。");
      }
      stopReconnectTimer();
      _timerDelayDevice = Timer(Duration(seconds: 3),() async {
        if (nReconnectCount == 0) {
          startReconnect();
          stopListenDeviceData();
        }
      });
    });
  }
  /// 停止监听设备连接状态
  static void stopListenDeviceState() {
    if (streamSubscriptionDeviceState != null) {
      addBleLog("停止监听设备连接状态");
      streamSubscriptionDeviceState.cancel();
      streamSubscriptionDeviceState = null;
    }
  }

  /// 开始监听设备数据
  static Future<void> startListenDeviceData() async {
    stopListenDeviceData();
    if (characteristicRead == null) {
      addBleLog("未找到动感单车协议对应的设备数据读取通道,连接的设备可能不是动感单车哦!");
      return;
    }
    addBleLog("开始监听设备数据");
    streamSubscriptionRead = characteristicRead.value.listen((value) {
      try {
        if (value == null) {
          addBleLog("我是蓝牙返回数据 - 空！！");
        } else {
          if (value.length != null && value.length > 9 && BaseUtil.gStBicycleLog != null && BaseUtil.gStBicycleLog['id'] > 0) {
            /// 数据0-1：同步头；2：消息类型；3、数据长度；4-5、转速(单位rpm表示每分钟转几圈)；6-7、功率（单位w）；8-9、当前阻力；10-11、当前转向值
            BaseUtil.gStBicycleLog["speed"] = concatIntToRadix(value[4], value[5]) * 1.0;
            BaseUtil.gStBicycleLog["fv"] = concatIntToRadix(value[6], value[7]) * 1.0;
            BaseUtil.gStBicycleLog["drag"] = concatIntToRadix(value[8], value[9]) * 1.0;
            /// 因为更新频率是200ms/次, 因此当前里程等于里程数 + 当前分钟速度 / 一分钟60秒 / 一秒5次 / 1000(从米转换成千米)
            BaseUtil.gStBicycleLog["mileage"] = BaseUtil.gStBicycleLog["mileage"] + BaseUtil.gStBicycleLog["speed"] / 60.0 / 5.0 / 1000.0;
            BaseUtil.gStBicycleLog["cal"] = BaseUtil.gStBicycleLog["cal"] + BaseUtil.gStBicycleLog["speed"] / 60.0 / 5.0 / 1000.0 * 0.1 * (BaseUtil.gStBicycleLog["drag"] + 1);
          }
          if (callbackData != null) {
            /// 返回原始数据和处理后的数据
            callbackData(value);
          }
        }
      } catch(e) {
        addBleLog("接收蓝牙数据,处理异常" + e.toString());
      }
    });
    try {
      await characteristicRead.setNotifyValue(true);
    } catch(e) {
      addBleLog("设置监听设备数据变化异常,处理异常" + e.toString());
    }
  }
  /// 停止监听设备数据
  static void stopListenDeviceData() {
    if (streamSubscriptionRead != null) {
      addBleLog("停止监听设备数据");
      streamSubscriptionRead.cancel();
      streamSubscriptionRead = null;
    }
  }
  //endregion

  //region 主动连接和断开连接
  /// 主动连接
  static Future<void> connectionDevice(BluetoothDevice d, bool bResetUsedTime) async {
    /// 停止继续扫描
    await stopScan();
    /// 断开原来的连接
    disConnectionDevice();
    /// 关联设备
    deviceCurrent = d;
    /// 监听设备的状态变化
    startListenDeviceState();
    addBleLog("连接上蓝牙设备...延迟连接");
    // 连接设备
    deviceCurrent.connect(autoConnect: false, timeout: Duration(seconds: 10)).then((value) {
      /// 查找蓝牙设备服务对应动感单车蓝牙协议的信息
      discoverServices();
    }, onError: (error) {
      addBleLog("设备连接失败：${error}");
      /// 取消状态监听
      stopListenDeviceState();
      /// 开始重连
      nReconnectCount = 0;
      startReconnect();
    });
    if (bResetUsedTime) {
      /// 初始化设备使用时间
      nUsedSecond = 0;
    }
    /// 启动设备使用时间定时器
    startUsedTimer();
  }
  /// 主动断开连接
  static Future<void> disConnectionDevice() async {
    addBleLog("断开蓝牙设备连接，清理各种变量状态");
    /// 停止监听数据
    stopListenDeviceData();
    /// 停止监听当前设备的状态变更
    stopListenDeviceState();
    /// 清理设备通信对象
    characteristicRead = null;
    characteristicWrite = null;
    /// 将设备还原成空的
    if (deviceCurrent != null) {
      deviceCurrent.disconnect();
      deviceCurrent = null;
    }
    /// 停止重连操作
    stopReconnect();
    /// 停止使用时间定时器
    stopUsedTimer();
  }

  /// 处理蓝牙设备服务和特征值
  static Future<void> discoverServices() async {
    addBleLog("处理蓝牙设备服务和特征值");
    List<BluetoothService> services = await deviceCurrent.discoverServices();
    addBleLog("获取到蓝牙设备服务列表");
    services.forEach((service) {
      try {
        var value = service.uuid.toString();
        addBleLog("所有服务值 --- $value");
        String str = value.toUpperCase().substring(4, 8);
        if (str == "FFF0") {
          List<BluetoothCharacteristic> characteristics = service.characteristics;
          characteristics.forEach((characteristic) {
            var valuex = characteristic.uuid.toString();
            addBleLog("所有特征值 --- $valuex");
            str = valuex.toUpperCase().substring(4, 8);
            if (str == "FFF1") {
              addBleLog("匹配到接收蓝牙数据的特征值");
              if (characteristicRead == characteristic) {
                return;
              }
              characteristicRead = characteristic;
              /// 延时1秒后监听蓝牙设备数据
              Future.delayed(Duration(seconds: 1), () {
                startListenDeviceData();
              });
            }
            else if (str == "FFF2") {
              addBleLog("匹配到发送蓝牙数据的特征值");
              characteristicWrite = characteristic;
            }
          });
        }
      } catch(e) {
        addBleLog("————————读取服务特征值失败$e");
      }
    });
  }

  /// 启动使用计时器
  static void startUsedTimer() {
    stopUsedTimer();
    const oneSec = const Duration(seconds: 1);
    var callback = (timer) {
      nUsedSecond++;
      if (BaseUtil.gStBicycleLog != null && BaseUtil.gStBicycleLog['id'] > 0) {
        BaseUtil.gStBicycleLog["rideTime"] = nUsedSecond;
      }
      if (callbackTimer != null) {
        callbackTimer();
      }
    };
    _timerUsed = Timer.periodic(oneSec, callback);
  }
  /// 停止使用计时器
  static void stopUsedTimer() {
    if (_timerUsed != null) {
      _timerUsed.cancel();
      _timerUsed = null;
    }
  }
  //endregion

  //region 断点重连
  /// 开始断点重连
  static void startReconnect() {
    /// 需要重连，并且当前是主动连接中未主动断开，并且曾经有连接设备，才需要重连
    if (nReconnectCount < 0 || deviceCurrent == null) {
      return;
    }
    /// 设置监听扫描
    callbackScan = () {
      /// 根据旧设备的Mac地址，找新设备
      for(int i = 0; i < arrBleDevice.length; i++) {
        var b = arrBleDevice[i];
        if(deviceCurrent.id.id == b.id.id) {
          deviceReconnect = b;
          break;
        }
      }
      /// 找到了Mac地址对应的新设备
      if (deviceReconnect != null) {
        addBleLog("重新搜索到原来的蓝牙设备，准备开始进行连接");
        /// 搜索到了设备
        callbackScan = null;
        /// 重新连接上设备
        connectionDevice(deviceReconnect, false);
      }
    };
    /// 设置重连设备为空
    deviceReconnect = null;
    /// 开始重连的扫描
    startReconnectTimer();
  }
  /// 停止断点重连
  static Future<void> stopReconnect() async {
    /// 停止重连定时器
    stopReconnectTimer();
    /// 停止扫描蓝牙设备
    await stopScan();
    /// 搜索到了设备
    callbackScan = null;
  }

  /// 重连的时候的设备搜索
  static bool startReconnectTimer() {
    stopReconnectTimer();
    /// 需要重连，并且当前是主动连接中未主动断开，并且曾经有连接设备，才需要重连
    if (nReconnectCount < 0 || deviceCurrent == null) {
      return false;
    }
    nReconnectCount++;
    if (nReconnectCount > 3) {
      addBleLog("连续3次扫描设备重连失败，停止重连,请手动搜索更换设备连接");
      nReconnectCount = -1;
      /// 停止重连
      stopReconnect();
      return false;
    } else {
      addBleLog("第$nReconnectCount次扫描设备重连");
    }
    /// 开始扫描
    startScan();
    /// 一次搜索有效期4秒，如果4秒后没搜索到，
    _timerDelayDevice = Timer(Duration(seconds: 4),() async {
      startReconnectTimer();
    });
    return true;
  }
  /// 停止断点重连定时器, 避免任务重复执行
  static void stopReconnectTimer() {
    if (_timerDelayDevice != null) {
      _timerDelayDevice.cancel();
      _timerDelayDevice = null;
    }
  }
  //endregion

  //region 公共功能
  /// 记录日志
  static void addBleLog(str) {
    print(str);
    gLog = gLog + str + "\n\r";
    if (callbackLog != null) {
      callbackLog(gLog);
    }
  }

  /// 写数据
  static void sendDataToBle(List<int> value) async {
    if (characteristicWrite != null) {
      addBleLog("写入数据：$value");
      try {
        await characteristicWrite.write(value);
      } catch (e) {
        addBleLog("给蓝牙发送数据失败");
      }
    }
  }

  /// 将两个数字转换成16进制后拼接成字符串,再将16进制字符串转换成int返回
  static int concatIntToRadix(int i1, int i2) {
    String s1 = i1.toRadixString(16);
    if (s1.length < 2) {
      s1 = "0" + s1;
    }
    String s2 = i2.toRadixString(16);
    if (s2.length < 2) {
      s2 = "0" + s2;
    }
    return int.parse(s1 + s2, radix: 16);
  }
  //endregion

}