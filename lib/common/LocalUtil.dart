/*
 * 配置文件
 */
// @dart=2.9
import 'dart:collection';
import 'dart:io';
import 'dart:async';

import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'BaseUtil.dart';

class LocalUtil {
  static bool gInitFlag = false;
  static String gConfigFileData = "";
  static Map<String, dynamic> gConfigData = new HashMap();

  // 返回本地配置文件
  static Future<File> getLocalConfigFile() async {
    // 获取文档目录的路径
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String dir = appDocDir.path;
    final file = new File('$dir/config.ini');
    return file;
  }

  // 保存JSON格式的字符串到本地文件中
  static void saveConfigFile() async {
    gConfigData["baseSchema"] = BaseUtil.gBaseSchema;
    gConfigData["baseHost"] = BaseUtil.gBaseHost;
    gConfigData["basePort"] = BaseUtil.gBasePort;
    try {
      File f = await getLocalConfigFile();
      gConfigFileData = jsonEncode(gConfigData);
      print("保存文件：" + gConfigFileData);
      await f.writeAsString(gConfigFileData);
    } catch (e) {
      // 写入错误
      print(e);
    }
  }

  // 读取本地文件，回调中处理业务信息
  static readConfigFile() async {
    File file = await getLocalConfigFile();
    try {
      // 从文件中读取变量作为字符串，一次全部读完存在内存里面
      gConfigFileData = await file.readAsString();
      // 读取配置信息
      gConfigData = json.decode(gConfigFileData);
      // BaseUtil.setBaseUrl(gConfigData["baseSchema"], gConfigData["baseHost"], gConfigData["basePort"]);
    } catch (e) {
      // 写入错误
      print("读取失败，尝试创建文件");
      gConfigFileData = "";
    }
  }

  // 清空本地保存的文件
  static void clearConfigFile() async {
    File f = await getLocalConfigFile();
    await f.writeAsString('');
  }

  // 获取缓存目录
  static Future<String> getTempPath() async {
    var tempDir = await getTemporaryDirectory();
    return tempDir.path;
  }

  // 设置缓存
  static void setTempFile(fileName, [str = '']) async {
    String tempPath = await getTempPath();
    await File('$tempPath/$fileName.txt').writeAsString(str);
  }

  // 读取缓存
  static Future<dynamic> getTempFile(fileName) async {
    String tempPath = await getTempPath();
    try {
      String contents = await File('$tempPath/$fileName.txt').readAsString();
      return jsonDecode(contents);
    } catch(e) {
      print('$fileName:缓存不存在');
    }
  }

  // 清缓存
  static void clearCache() async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      await _delDir(tempDir);
      Fluttertoast.showToast(msg: '清除缓存成功');
    } catch (e) {
      Fluttertoast.showToast(msg: '清除缓存失败');
    } finally {}
  }

  // 递归方式删除目录
  static Future<Null> _delDir(FileSystemEntity file) async {
    try {
      if (file is Directory) {
        final List<FileSystemEntity> children = file.listSync();
        for (final FileSystemEntity child in children) {
          await _delDir(child);
        }
      }
      await file.delete();
    } catch (e) {
      print(e);
    }
  }

}
