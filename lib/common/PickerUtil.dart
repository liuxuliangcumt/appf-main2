/// 选择器
// @dart=2.9
import 'package:flutter/material.dart';
import 'package:dong_gan_dan_che/common/BaseUtil.dart';
import 'package:flutter_picker/Picker.dart';
import 'package:flutter_picker/flutter_picker.dart';

enum PickerUtilDateType {
  YMD, // y,m,d
  YM, // y,m
  YMD_HM, //y,m,d,hh,mm
  YMD_AP_HM, //y,m,d,ap,hh,mm
}

class PickerUtil{
  static double dPickerHeight = BaseUtil.dp(216);
  static double dPickerItemHeight = BaseUtil.dp(40);
  static Color clrPickerBtnOK = Color(0xFF000000);
  static Color clrPickerBtnCancel = Color(0xFF999999);
  static Color clrPickerTitle = Color(0xFF000000);
  static double dPickerFontSize = BaseUtil.dp(20);
  static double dPickerBtnFontSize = BaseUtil.dp(16);
  static double dPickerTitleFontSize = BaseUtil.dp(18);
  //单列
  static void showStringPicker<T>(
      BuildContext context,{
        @required List<T> data,
        String title,
        int normalIndex,
        PickerDataAdapter adapter,
        @required Function clickCallBack,  /// 回调参数(int selectIndex,dynamic selectStr);
      }) {
    openModalPicker(context, adapter: adapter??PickerDataAdapter(pickerdata: data,isArray: false), clickCallBack: (Picker picker,List<int> selecteds) {
      // 触摸收起键盘
      FocusScope.of(context).requestFocus(FocusNode());
      clickCallBack(selecteds[0],data[selecteds[0]]);
    }, selecteds: [normalIndex??0],title: title);
  }

  //多列
  static void showArrayPicker<T>(
      BuildContext context,{
        @required List<T> data,
        String title,
        List<int> normalIndex,
        PickerDataAdapter adapter,
        @required Function clickCallBack, /// 回调参数(List<int> arrSelected, List<dynamic> arrData);
      }) {
    openModalPicker(context, adapter: adapter??PickerDataAdapter(
        pickerdata: data,isArray: true
    ), clickCallBack: (Picker picker,List<int> selecteds) {
      // 触摸收起键盘
      FocusScope.of(context).requestFocus(FocusNode());
      clickCallBack(selecteds,picker.getSelectedValues());
    },selecteds: normalIndex,title: title);


  }

  static void openModalPicker(
      BuildContext context,{
        @required PickerAdapter adapter,
        String title,
        List<int>  selecteds,
        @required PickerConfirmCallback clickCallBack,
      }) {
    new Picker(
        adapter: adapter,
        title: new Text(title??"请选择",style: TextStyle(color: clrPickerTitle,fontSize: dPickerTitleFontSize),),
        selecteds: selecteds,
        cancelText: '取消',
        confirmText: "确定",
        cancelTextStyle: TextStyle(color: clrPickerBtnCancel,fontSize: dPickerBtnFontSize),
        confirmTextStyle: TextStyle(color: clrPickerBtnOK,fontSize: dPickerBtnFontSize),
        textAlign: TextAlign.right,
        itemExtent: dPickerItemHeight,
        height: dPickerHeight,
        selectedTextStyle: TextStyle(color: Colors.black),
        onConfirm: clickCallBack
    ).showModal(context);
  }

  //日期选择器
  static void showDatePicker(
      BuildContext context,{
        PickerUtilDateType dateType,
        String title,
        DateTime maxValue,
        DateTime minValue,
        DateTime value,
        DateTimePickerAdapter adapter,
        @required Function clickCallBack,} /// 回调参数(dynamic selectDateStr,dynamic selectData);
      ) {
    int timeType;
    if(dateType==PickerUtilDateType.YM) {
      timeType=PickerDateTimeType.kYM;
    }else if(dateType==PickerUtilDateType.YMD_HM){
      timeType=PickerDateTimeType.kYMDHM;
    }else if(dateType==PickerUtilDateType.YMD_AP_HM) {
      timeType=PickerDateTimeType.kYMD_AP_HM;
    }else {
      timeType=PickerDateTimeType.kYMD;
    }
    openModalPicker(context, adapter: adapter?? DateTimePickerAdapter(
      type: timeType,
      isNumberMonth: true,
      yearSuffix: "年",
      monthSuffix: "月",
      daySuffix: "日",
      strAMPM: const["上午","下午"],
      maxValue: maxValue,
      minValue: minValue,
      value: value??DateTime.now(),
    ), title: title,
      clickCallBack: (Picker picker,List<int> selecteds){
        var time=(picker.adapter as DateTimePickerAdapter).value;
        var timeStr;
        if(dateType==PickerUtilDateType.YM) {
          timeStr=time.year.toString()+"年"+time.month.toString()+"月";
        }else if(dateType==PickerUtilDateType.YMD_HM){
          timeStr =time.year.toString()+"年"+time.month.toString()+"月"+time.day.toString()+"日"+time.hour.toString()+"时"+time.minute.toString()+"分";
        }else if(dateType == PickerUtilDateType.YMD_AP_HM) {
          var str = time.hour > 12 ? "上午":"下午";
          timeStr =time.year.toString()+"年"+time.month.toString()+"月"+time.day.toString()+"日"+str+time.hour.toString()+"时"+time.minute.toString()+"分";
        }else {
          timeStr =time.year.toString()+"年"+time.month.toString()+"月"+time.day.toString()+"日";
        }
        // 触摸收起键盘
        FocusScope.of(context).requestFocus(FocusNode());
        clickCallBack(timeStr,picker.adapter.text);
      });
  }

}