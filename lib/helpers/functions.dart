import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/date_machine_util.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

void nextScreen(BuildContext context, Widget widget) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => widget,
    ),
  );
}

void changeScreen(BuildContext context, Widget widget) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => widget,
      fullscreenDialog: true,
    ),
  );
}

void overlayScreen(BuildContext context, Widget widget) {
  showMaterialModalBottomSheet(
    expand: true,
    enableDrag: false,
    context: context,
    builder: (context) => widget,
  );
}

String randomString(int length) {
  const _randomChars =
      "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
  const _charsLength = _randomChars.length;
  final rand = Random();
  final codeUnits = List.generate(
    length,
    (index) {
      final n = rand.nextInt(_charsLength);
      return _randomChars.codeUnitAt(n);
    },
  );
  return String.fromCharCodes(codeUnits);
}

Future<String> getPrefs({String key}) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  return _prefs.getString(key) ?? '';
}

Future<void> setPrefs({String key, String value}) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  _prefs.setString(key, value);
}

Future<void> removePrefs({String key}) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  _prefs.remove(key);
}

String twoDigits(int n) => n.toString().padLeft(2, '0');

String addTime(String left, String right) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  List<String> _lefts = left.split(':');
  List<String> _rights = right.split(':');
  double _hm = (int.parse(_lefts.last) + int.parse(_rights.last)) / 60;
  int _m = (int.parse(_lefts.last) + int.parse(_rights.last)) % 60;
  int _h = (int.parse(_lefts.first) + int.parse(_rights.first)) + _hm.toInt();
  if (_h.toString().length == 1) {
    return '${twoDigits(_h)}:${twoDigits(_m)}';
  } else {
    return '$_h:${twoDigits(_m)}';
  }
}

String subTime(String left, String right) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  List<String> _lefts = left.split(':');
  List<String> _rights = right.split(':');
  // 時 → 分
  int _leftM = (int.parse(_lefts.first) * 60) + int.parse(_lefts.last);
  int _rightM = (int.parse(_rights.first) * 60) + int.parse(_rights.last);
  // 分で引き算
  int _diffM = _leftM - _rightM;
  // 分 → 時
  double _h = _diffM / 60;
  int _m = _diffM % 60;
  return '${twoDigits(_h.toInt())}:${twoDigits(_m)}';
}

// 時間の切捨
String roundDownTime(String time, int per) {
  List<String> _timeList = time.split(':');
  String _hour = _timeList.first;
  String _minute = _timeList.last;
  double _num = int.parse(_minute) / per;
  int _minuteNew = _num.floor() * per;
  return '$_hour:${_minuteNew.toString().padLeft(2, '0')}';
}

// 時間の切上
String roundUpTime(String time, int per) {
  List<String> _timeList = time.split(':');
  String _hour = _timeList.first;
  String _minute = _timeList.last;
  double _num = int.parse(_minute) / per;
  int _minuteNew = _num.ceil() * per;
  if (_minuteNew == 60) {
    int _h = int.parse(_hour) + 1;
    _hour = _h.toString().padLeft(2, '0');
    _minuteNew = 0;
  }
  return '$_hour:${_minuteNew.toString().padLeft(2, '0')}';
}

// 1ヶ月間の配列作成
List<DateTime> generateDays(DateTime month) {
  List<DateTime> _days = [];
  var _dateMap = DateMachineUtil.getMonthDate(month, 0);
  DateTime _start = DateTime.parse('${_dateMap['start']}');
  DateTime _end = DateTime.parse('${_dateMap['end']}');
  for (int i = 0; i <= _end.difference(_start).inDays; i++) {
    _days.add(_start.add(Duration(days: i)));
  }
  return _days;
}
