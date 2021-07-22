import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  return new String.fromCharCodes(codeUnits);
}

Future<String> getPrefs() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  return _prefs.getString('groupId') ?? '';
}

Future<void> setPrefs(String value) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  _prefs.setString('groupId', value);
}

Future<void> removePrefs() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  _prefs.remove('groupId');
}

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
  double _hm = (int.parse(_lefts.last) + int.parse(_rights.last)) / 60;
  int _m = (int.parse(_lefts.last) - int.parse(_rights.last)) % 60;
  int _h = int.parse(_lefts.first) - int.parse(_rights.first) - _hm.toInt();
  if (_h.toString().length == 1) {
    return '${twoDigits(_h)}:${twoDigits(_m)}';
  } else {
    return '$_h:${twoDigits(_m)}';
  }
}

// 法定内時間/法定外時間
List<String> legalList({String workTime, int legal}) {
  String _legal = '0$legal:00';
  String _legalTime = '00:00';
  String _nonLegalTime = '00:00';
  List<String> _hm = workTime.split(':');
  if (legal <= int.parse(_hm.first)) {
    // 法定内時間
    _legalTime = addTime(_legalTime, _legal);
    // 法定外時間
    String _tmp = subTime(workTime, _legal);
    _nonLegalTime = addTime(_nonLegalTime, _tmp);
  } else {
    // 法定内時間
    _legalTime = addTime(_legalTime, workTime);
    // 法定外時間
    _nonLegalTime = addTime(_nonLegalTime, '00:00');
  }
  return [_legalTime, _nonLegalTime];
}

// 深夜時間
List<String> nightList({
  DateTime startedAt,
  DateTime endedAt,
  String nightStart,
  String nightEnd,
}) {
  DateTime baseStartS = DateTime.parse(
    '${DateFormat('yyyy-MM-dd').format(startedAt)} $nightStart:00.000',
  );
  DateTime baseEndS = DateTime.parse(
    '${DateFormat('yyyy-MM-dd').format(startedAt)} $nightEnd:00.000',
  );
  DateTime baseStartE = DateTime.parse(
    '${DateFormat('yyyy-MM-dd').format(endedAt)} $nightStart:00.000',
  );
  DateTime baseEndE = DateTime.parse(
    '${DateFormat('yyyy-MM-dd').format(endedAt)} $nightEnd:00.000',
  );
  DateTime _dayS;
  DateTime _dayE;
  DateTime _nightS;
  DateTime _nightE;
  // 出勤時間05:00〜22:00
  if (startedAt.millisecondsSinceEpoch < baseStartS.millisecondsSinceEpoch &&
      startedAt.millisecondsSinceEpoch > baseEndS.millisecondsSinceEpoch) {
    // 退勤時間05:00〜22:00
    if (endedAt.millisecondsSinceEpoch < baseStartE.millisecondsSinceEpoch &&
        endedAt.millisecondsSinceEpoch > baseEndE.millisecondsSinceEpoch) {
      _dayS = startedAt;
      _dayE = endedAt;
      _nightS = DateTime.now();
      _nightE = DateTime.now();
    } else {
      _dayS = startedAt;
      _dayE = baseStartE;
      _nightS = baseStartE;
      _nightE = endedAt;
    }
    // 出勤時間が22:00〜05:00
  } else {
    // 退勤時間が05:00〜22:00
    if (endedAt.millisecondsSinceEpoch < baseStartE.millisecondsSinceEpoch &&
        endedAt.millisecondsSinceEpoch > baseEndE.millisecondsSinceEpoch) {
      _nightS = startedAt;
      _nightE = baseStartE;
      _dayS = baseStartE;
      _dayE = endedAt;
      // 退勤時間が22:00〜05:00
    } else {
      _dayS = DateTime.now();
      _dayE = DateTime.now();
      _nightS = startedAt;
      _nightE = endedAt;
    }
  }
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  // 通常時間
  Duration _dayDiff = _dayE.difference(_dayS);
  String _dayMinutes = twoDigits(_dayDiff.inMinutes.remainder(60));
  String _dayTime = '${twoDigits(_dayDiff.inHours)}:$_dayMinutes';
  // 深夜時間
  Duration _nightDiff = _nightE.difference(_nightS);
  String _nightMinutes = twoDigits(_nightDiff.inMinutes.remainder(60));
  String _nightTime = '${twoDigits(_nightDiff.inHours)}:$_nightMinutes';
  return [_dayTime, _nightTime];
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
