/// 视频拣选
// @dart=2.9
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'BaseUtil.dart';

abstract class VideoUtil {
  /// 调用相机
  static takePhoto() async {
    var picker = ImagePicker();
    var video = await picker.pickVideo(source: ImageSource.camera);
    return video;
  }
  /// 打开文件选择
  static openGallery() async {
    var picker = ImagePicker();
    var video = await picker.pickVideo(source: ImageSource.gallery);
    return video;
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
                      child: Text("拍摄"),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  width: 1,
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
                      height: BaseUtil.dp(50),
                      child: Text("选择本地文件"),
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

}


