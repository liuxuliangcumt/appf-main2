/*
 * 图片拣选相关
 */
// @dart=2.9
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'BaseUtil.dart';

abstract class ImageUtil {
  // 拍照
  static takePhoto() async {
    var picker = ImagePicker();
    var image = await picker.pickImage(source: ImageSource.camera);
    return image;
  }
  // 打开相册
  static openGallery() async {
    var picker = ImagePicker();
    var image = await picker.pickImage(source: ImageSource.gallery);
    return image;
  }

  static showSelectPicker(context, callback) async {
    showModalBottomSheet(context: context,
      builder: (context){
        return Container(
          height: BaseUtil.dp(159),
          child: Column(
            children: <Widget>[
              InkWell(
                onTap: () async {
                  var file = await takePhoto();
                  FocusScope.of(context).requestFocus(FocusNode());
                  if(file != null){
                    callback(file);
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  height: BaseUtil.dp(50),
                  child: Text("拍照"),
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              width: 0.5,
                              color: Colors.black26
                          )
                      )
                  ),
                ),
              ),
              InkWell(
                onTap: ()  async {
                  var file = await openGallery();
                  FocusScope.of(context).requestFocus(FocusNode());
                  if(file!=null){
                    callback(file);
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  height: BaseUtil.dp(58),
                  child: Text("从相册选择"),
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              width: 8,
                              color: Color(0xFFF3F4F5)
                          )
                      )
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  Navigator.pop(context);
                },
                child: Container(
                  alignment: Alignment.center,
                  height: BaseUtil.dp(50),
                  child: Text("取消"),
                ),
              )
            ],
          )
        );
      }
    );
  }

  // 生成对应的相机图片
  static Widget buildCameraImage(String strFilePath, BoxFit fit) {
    if (strFilePath == null || strFilePath.length < 10) {
      return Image.asset("assets/images/common/camera.png", fit: fit,);
    } else {
      try {
        if (strFilePath.indexOf("http") > -1) {
          return Image.network(
            strFilePath,
            fit: BoxFit.cover,
          );
        } else {
          return Image.file(
            File(strFilePath),
            fit: BoxFit.cover,
          );
        }
      } catch(e) {
        return Image.asset("assets/images/common/camera.png", fit: fit,);
      }
    }
  }

}


