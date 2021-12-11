/*
 * 绘制速度的圆圈
 */
// @dart=2.9
import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:dong_gan_dan_che/common/BaseUtil.dart';

class DrawSpeedCircle extends StatefulWidget {
  final val;    /// 当前速度
  final maxVal; /// 最大速度
  final width;  /// 画布宽度
  final height; /// 画布高度
  final radius; /// 速度的圆弧半径
  final unitText;   /// 单位文本
  final unitFontSize; /// 单位字体大小
  final numberFontSize; /// 速度的数字字体大小
  final tipText;  /// 提示文本
  final tipFontSize;  /// 提示文本字体大小
  final penBorderSize;  /// 画笔宽度, 就是速度的圆弧的宽度
  DrawSpeedCircle({Key key,
    this.val = 12.56,
    this.maxVal = 40.0,
    this.width = 280.0,
    this.height = 220.0,
    this.radius = 190.0,
    this.unitText = "km/h",
    this.unitFontSize = 10.0,
    this.numberFontSize = 40.0,
    this.tipText = "实时速度",
    this.tipFontSize = 14.0,
    this.penBorderSize = 6.0,
  }) : super(key: key);

  @override
  _DrawSpeedCircle createState() => _DrawSpeedCircle();
}

class _DrawSpeedCircle extends State<DrawSpeedCircle> with SingleTickerProviderStateMixin {
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
    var margin = widget.radius - widget.unitFontSize - widget.numberFontSize - widget.tipFontSize;
    /// 分成4份, 得到均分的间距
    margin = margin / 4.0;
    /// 中间间距等于均分减去两条边框
    var padding = margin - widget.penBorderSize - widget.penBorderSize;
    return GestureDetector(
      child: Container(
        width: widget.width,
        height: widget.height,
        // decoration: BoxDecoration(
        //   border: Border.all(
        //     color: Colors.white,
        //     width: 1,
        //   ),
        // ),
        child: CustomPaint(
          size: Size(widget.width, widget.height),
          child: Column(
            children: [
              Padding(padding: EdgeInsets.only(top: margin + widget.height - widget.radius + 16.0)),
              Center(
                child: Text(
                  'km/h',
                  style: TextStyle(
                    color: Color(0xFFCCCCCC),
                    fontSize: widget.unitFontSize,
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.only(top: padding)),
              Center(
                child: Text(
                  BaseUtil.gNumberFormat2.format(widget.val),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: widget.numberFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.only(top: padding)),
              Center(
                child: Text(
                  "实时速度",
                  style: TextStyle(
                    color: Color(0xFFCCCCCC),
                    fontSize: widget.tipFontSize,
                  ),
                ),
              ),
            ],
          ),
          painter: CircleProgressBarPainter(
            widget.val,
            widget.maxVal,
            widget.width,
            widget.height,
            widget.radius,
            widget.penBorderSize,
          ),
        ),
      ),
    );
  }
}

// 画布绘制
class CircleProgressBarPainter extends CustomPainter {
  List<Paint> _arrPaintTemp = [];
  Paint _paintBack;
  Paint _paintFore;
  double val;
  double maxVal;
  double width;
  double height;
  double radius;
  double penBorderSize;
  double margin = 16; /// 线距离两端的间距
  double longLineHeight = 20.0;
  double shortLineHeight = 16.0;
  double padding = 18; /// 圈和线的间距
  CircleProgressBarPainter(
    this.val,
    this.maxVal,
    this.width,
    this.height,
    this.radius,
    this.penBorderSize,
  ) {
    double penSize = penBorderSize;
    List arrColor = [
      Color(0xFFEF5B9C),
      Color(0xFFF47920),
      Color(0xFF817936),
      Color(0xFF444693),
      Color(0xFFB1FEE6),
    ];
    arrColor.forEach((element) {
      var t = Paint()
        ..color = element
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..isAntiAlias = true;
      _arrPaintTemp.add(t);
    });

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
    // Rect rectFrame = Rect.fromLTRB(left, top, size.width, size.height);
    // canvas.drawRect(rectFrame, _arrPaintTemp[0]);
    var r = radius - penBorderSize;
    var left = (size.width - radius) / 2.0 + penBorderSize / 2.0;
    var top = margin + longLineHeight + padding;
    Rect circleRect = Rect.fromLTRB(left, top, left + r, top + r);
    // canvas.drawRect(circleRect, _arrPaintTemp[1]);
    // var centerX = left + radius / 2.0;
    // var centerY = top + radius / 2.0;
    // Offset pStart = Offset(centerX + , centerY);
    // canvas.drawLine(pStart, Offset(pStart.dx + longLineHeight, centerY), _arrPaintTemp[4]);

    Rect rect = circleRect;
    canvas.drawArc(rect, Math.pi * 0.83, 1.34 * Math.pi, false, _paintBack);
    canvas.drawArc(rect, Math.pi * 0.83, val / this.maxVal * 1.34 * Math.pi, false, _paintFore);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}