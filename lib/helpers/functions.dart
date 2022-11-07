import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/date_machine_util.dart';
import 'package:hatarakujikan_web/helpers/define.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:month_picker_dialog_2/month_picker_dialog_2.dart';
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

Future<String?> getPrefs(String key) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  return _prefs.getString(key);
}

Future<void> setPrefs(String key, String value) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  _prefs.setString(key, value);
}

Future<void> removePrefs(String key) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  _prefs.remove(key);
}

DateTime rebuildDate(DateTime? date, DateTime? time) {
  DateTime _ret = DateTime.now();
  if (date != null && time != null) {
    String _date = dateText('yyyy-MM-dd', date);
    String _time = '${dateText('HH:mm', time)}:00.000';
    _ret = DateTime.parse('$_date $_time');
  }
  return _ret;
}

DateTime rebuildTime(BuildContext context, DateTime? date, String? time) {
  DateTime _ret = DateTime.now();
  if (date != null && time != null) {
    String _date = dateText('yyyy-MM-dd', date);
    String _time = '${time.padLeft(5, '0')}:00.000';
    _ret = DateTime.parse('$_date $_time');
  }
  return _ret;
}

List<int> timeToInt(DateTime? dateTime) {
  List<int> _ret = [0, 0];
  if (dateTime != null) {
    String _h = dateText('H', dateTime);
    String _m = dateText('m', dateTime);
    _ret = [int.parse(_h), int.parse(_m)];
  }
  return _ret;
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

// DateTime => Timestamp
Timestamp convertTimestamp(DateTime date, bool end) {
  String _dateTime = '${dateText('yyyy-MM-dd', date)} 00:00:00.000';
  if (end == true) {
    _dateTime = '${dateText('yyyy-MM-dd', date)} 23:59:59.999';
  }
  return Timestamp.fromMillisecondsSinceEpoch(
    DateTime.parse(_dateTime).millisecondsSinceEpoch,
  );
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

// 通常時間と深夜時間に分ける関数
List<DateTime> separateDayNight({
  required DateTime startedAt,
  required DateTime endedAt,
  required String nightStart,
  required String nightEnd,
}) {
  DateTime? _dayS;
  DateTime? _dayE;
  DateTime? _nightS;
  DateTime? _nightE;
  String _startedDate = dateText('yyyy-MM-dd', startedAt);
  String _endedDate = dateText('yyyy-MM-dd', endedAt);
  DateTime _ss = DateTime.parse('$_startedDate $nightStart:00.000');
  DateTime _se = DateTime.parse('$_startedDate $nightEnd:00.000');
  DateTime _es = DateTime.parse('$_endedDate $nightStart:00.000');
  DateTime _ee = DateTime.parse('$_endedDate $nightEnd:00.000');
  // 開始時間は通常時間帯
  if (startedAt.millisecondsSinceEpoch < _ss.millisecondsSinceEpoch &&
      startedAt.millisecondsSinceEpoch > _se.millisecondsSinceEpoch) {
    // 終了時間は日跨ぎ
    if (DateTime.parse('$_startedDate') != DateTime.parse('$_endedDate')) {
      // 退勤時間は通常時間帯
      if (endedAt.millisecondsSinceEpoch < _es.millisecondsSinceEpoch &&
          endedAt.millisecondsSinceEpoch > _ee.millisecondsSinceEpoch) {
        _dayS = startedAt;
        _dayE = endedAt;
        _nightS = _ee;
        _nightE = _ee;
      } else {
        _dayS = startedAt;
        _dayE = _ss;
        _nightS = _ss;
        _nightE = endedAt;
      }
    } else {
      // 終了時間は日跨ぎではない
      // 退勤時間は通常時間帯
      if (endedAt.millisecondsSinceEpoch < _es.millisecondsSinceEpoch &&
          endedAt.millisecondsSinceEpoch > _ee.millisecondsSinceEpoch) {
        _dayS = startedAt;
        _dayE = endedAt;
        _nightS = _ee;
        _nightE = _ee;
      } else {
        _dayS = startedAt;
        _dayE = _ss;
        _nightS = _ss;
        _nightE = endedAt;
      }
    }
  } else {
    // 開始時間は深夜時間帯
    // 終了時間は日跨ぎ
    if (DateTime.parse('$_startedDate') != DateTime.parse('$_endedDate')) {
      // 終了時間は通常時間帯
      if (endedAt.millisecondsSinceEpoch < _es.millisecondsSinceEpoch &&
          endedAt.millisecondsSinceEpoch > _ee.millisecondsSinceEpoch) {
        _nightS = startedAt;
        _nightE = _ee;
        _dayS = _ee;
        _dayE = endedAt;
      } else {
        _nightS = startedAt;
        _nightE = endedAt;
        _dayS = _ee;
        _dayE = _ee;
      }
    } else {
      // 終了時間は日跨ぎではない
      // 終了時間は通常時間帯
      if (endedAt.millisecondsSinceEpoch < _es.millisecondsSinceEpoch &&
          endedAt.millisecondsSinceEpoch > _ee.millisecondsSinceEpoch) {
        _nightS = _ee;
        _nightE = _ee;
        _dayS = _ee;
        _dayE = _ee;
      } else {
        _nightS = startedAt;
        _nightE = endedAt;
        _dayS = _ee;
        _dayE = _ee;
      }
    }
  }
  return [_dayS, _dayE, _nightS, _nightE];
}

String dateText(String format, DateTime? date) {
  String _ret = '';
  if (date != null) {
    _ret = DateFormat(format, 'ja').format(date);
  }
  return _ret;
}

void customSnackBar(BuildContext context, String? message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message ?? '')),
  );
}

Future<DateTime?> customMonthPicker({
  required BuildContext context,
  required DateTime init,
}) async {
  DateTime? _ret;
  DateTime? _selected = await showMonthPicker(
    context: context,
    initialDate: init,
    firstDate: kMonthFirstDate,
    lastDate: kMonthLastDate,
  );
  if (_selected != null) _ret = _selected;
  return _ret;
}

Future<DateTime?> customDatePicker({
  required BuildContext context,
  required DateTime init,
}) async {
  DateTime? _ret;
  DateTime? _selected = await showDatePicker(
    context: context,
    initialDate: init,
    firstDate: kDayFirstDate,
    lastDate: kDayLastDate,
  );
  if (_selected != null) _ret = _selected;
  return _ret;
}

Future<String?> customTimePicker({
  required BuildContext context,
  String? init,
}) async {
  String? _ret;
  List<String> _hm = init!.split(':');
  TimeOfDay? _selected = await showTimePicker(
    context: context,
    initialTime: TimeOfDay(
      hour: int.parse(_hm.first),
      minute: int.parse(_hm.last),
    ),
  );
  if (_selected != null) {
    _ret = '${_selected.format(context)}';
  }
  return _ret;
}

extension IterableModifier<E> on Iterable<E> {
  E? singleWhereOrNull(bool Function(E) test) =>
      cast<E?>().singleWhere((v) => v != null && test(v), orElse: () => null);
}
