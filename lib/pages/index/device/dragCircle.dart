/*
 * 绘制阻力的圆圈
 */
// @dart=2.9
import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:dong_gan_dan_che/common/BaseUtil.dart';

class DrawDragCircle extends StatefulWidget {
  final radius;   /// 圆圈画多大
  final val;      /// 当前阻力值
  final maxVal;   /// 最大阻力值
  DrawDragCircle({Key key, this.radius = 0, this.val = 0, this.maxVal = 180}) : super(key: key);

  @override
  _DrawDragCircle createState() => _DrawDragCircle();
}

class _DrawDragCircle extends State<DrawDragCircle> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double val = this.widget.val;
    return GestureDetector(
      child: Container(
        width: BaseUtil.dp(this.widget.radius),
        height: BaseUtil.dp(this.widget.radius),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(BaseUtil.dp(this.widget.radius)),
            ),
          ),
        ),
        child: CustomPaint(
          child: Column(
            children: [
              Padding(padding: EdgeInsets.only(top: BaseUtil.dp(28))),
              Center(
                child: Text(
                  BaseUtil.gNumberFormat1.format(val),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: BaseUtil.dp(40),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.only(top: BaseUtil.dp(5))),
              Center(
                child: Text(
                  "单车阻力",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: BaseUtil.dp(12),
                  ),
                ),
              ),
            ],
          ),
          painter: CircleProgressBarPainter(this.widget.val, this.widget.maxVal),
        ),
      ),
    );
  }
}

// 画布绘制
class CircleProgressBarPainter extends CustomPainter {
  // Paint _paintBackground;
  Paint _paintBack;
  Paint _paintFore;
  double val;
  double maxVal;

  CircleProgressBarPainter(this.val, this.maxVal) {
    double penSize = BaseUtil.dp(6);
    _paintBack = Paint()
      ..color = Color(0xFFB1FEE6)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = penSize
      ..isAntiAlias = true;
    _paintFore = Paint()
      ..color = Color(0xFF43D2AE)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = penSize
      ..isAntiAlias = true;
  }
  @override
  void paint(Canvas canvas, Size size) {
    /* canvas.DrawDragCircle(Offset(size.width / 2, size.height / 2), size.width / 2,
        _paintBackground); */
    Rect rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2,
    );
    canvas.drawArc(rect, 0.0, 2 * Math.pi, false, _paintBack);
    canvas.drawArc(rect, Math.pi * 0.83, val / this.maxVal * Math.pi * 2, false, _paintFore);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}