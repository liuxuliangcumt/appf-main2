/*
 * 修改头像
 */

// @dart=2.9
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:dong_gan_dan_che/common/ImageUtil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdminSettingAvatarPage extends StatefulWidget {
  final Function onSwitchParentType;       /// 切换上级状态
  AdminSettingAvatarPage({ @required this.onSwitchParentType });
  
  @override
  _AdminSettingAvatarPage createState() => _AdminSettingAvatarPage();
}

class _AdminSettingAvatarPage extends State<AdminSettingAvatarPage> {

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
    BaseUtil.changeSystemBarColorType('light');
    var strAvatar = BaseUtil.gStUser['avatar'] == null || BaseUtil.gStUser['avatar'] == "" ? BaseUtil.gDefaultAvatar : BaseUtil.gBaseUrl + BaseUtil.gStUser['avatar'];
    Widget avatar = GestureDetector(
      child:Container(
        height: MediaQuery.of(context).size.width,
        width: MediaQuery.of(context).size.width,
        child: Image.network(
          strAvatar,
          fit: BoxFit.cover,
        ),
      )
    );
    return Container(
      color: Color(0xFF4B4B4B),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(BaseUtil.dp(16), BaseUtil.dp(30), BaseUtil.dp(24), BaseUtil.dp(0)),
            child: Row(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () { widget.onSwitchParentType(110); },
                  child: Container(
                    width: BaseUtil.dp(32),
                    height: BaseUtil.dp(32),
                    child: Icon(
                      FontAwesomeIcons.angleLeft,
                      color: Colors.white,
                      size: BaseUtil.dp(20.0),
                    ),
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: Center(
                      child: Text(
                        "修改头像",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: BaseUtil.dp(16),
                        ),
                      ),
                    )
                ),
                Padding(padding: EdgeInsets.only(left: BaseUtil.dp(32))),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.center,
              child: avatar
            )
          ),
          GestureDetector(
            child: Container(
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
                  ImageUtil.showSelectPicker(context, (file) {
                    save(file.path);
                  });
                },
                child: Center(
                  child: Text('更换头像',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: BaseUtil.dp(20)))
        ],
      ),
    );
  }

  void save(String strPath) {
    HttpUtil.getInstance().uploadFile(API.avatar, "avatarfile", strPath).then((response) {
      if (response == null) {
        CustomSnackBar(context, Text("上传失败"));
        return;
      }
      //先转json
      var json = jsonDecode(response.toString());
      if (json["code"] == null || json["code"] != 200) {
        CustomSnackBar(context, Text("上传失败"));
        return;
      }
      setState((){
        BaseUtil.gStUser['avatar'] = json["imgUrl"];
      });
    });
  }

}