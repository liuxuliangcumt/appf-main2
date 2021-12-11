/*
 * 隐私政策按钮相关内容
 */
// @dart=2.9
import 'package:dong_gan_dan_che/common/BaseUtil.dart';

import 'package:flutter/material.dart';


class PrivateManager extends StatefulWidget {
  @override
  _PrivateManager createState() => _PrivateManager();
}

class _PrivateManager extends State<PrivateManager> {
  @override
  void initState() {
    BaseUtil.gCheckPrivacy = true;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: BaseUtil.dp(20)),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text("")),
          GestureDetector(
            onTap: () {
              setState(() {
                BaseUtil.gCheckPrivacy = !BaseUtil.gCheckPrivacy;
              });
            },
            child: Image(
              width: BaseUtil.dp(16),
              fit: BoxFit.fill,
              image: AssetImage(BaseUtil.gCheckPrivacy ? 'assets/images/common/circle-checked.png' : 'assets/images/common/circle.png')
            ),
          ),
          Padding(padding: EdgeInsets.only(left: BaseUtil.dp(8))),
          Text(
              "我已阅读并同意",
              style: TextStyle(
                  fontSize: BaseUtil.dp(12),
                  color: Color(0xFF333333)
              )
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, "/privacy");
            },
            child: Text(
              "《用户协议和隐私政策》",
              style: TextStyle(
                color: Color(0xFF01927C),
                fontSize: BaseUtil.dp(12)
              )
            ),
          ),
          Expanded(flex: 1,child: Text("")),
        ],
      ),
    );
  }
}
