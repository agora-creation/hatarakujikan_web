import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:hatarakujikan_web/helpers/date_machine_util.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/models/work.dart';
import 'package:hatarakujikan_web/providers/work.dart';
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart';

Future<void> workCsv({
  WorkProvider workProvider,
  GroupModel group,
  DateTime searchMonth,
  List<UserModel> users,
}) async {
  List<DateTime> days = [];
  days.clear();
  var _dateMap = DateMachineUtil.getMonthDate(searchMonth, 0);
  DateTime _startAt = DateTime.parse('${_dateMap['start']}');
  DateTime _endAt = DateTime.parse('${_dateMap['end']}');
  for (int i = 0; i <= _endAt.difference(_startAt).inDays; i++) {
    days.add(_startAt.add(Duration(days: i)));
  }

  List<List<dynamic>> rows = [];
  List<dynamic> _row = [];
  _row.add('社員番号');
  _row.add('社員名');
  _row.add('平日出勤');
  _row.add('出勤時間');
  _row.add('支給項目2');
  rows.add(_row);
  for (UserModel _user in users) {
    List<dynamic> _row = [];
    _row.add('${_user.recordPassword}');
    _row.add('${_user.name}');
    List<WorkModel> _works = [];
    await workProvider
        .selectList(
      groupId: group.id,
      userId: _user.id,
      startAt: days.first,
      endAt: days.last,
    )
        .then((value) {
      _works = value;
    });
    Map _count = {};
    String _workTime = '00:00';
    String _legalTime = '00:00';
    String _nightTime = '00:00';

    for (WorkModel _work in _works) {
      if (_work.startedAt != _work.endedAt) {
        _count['${DateFormat('yyyy-MM-dd').format(_work.startedAt)}'] = '';
        // 勤務時間
        _workTime = addTime(_workTime, _work.workTime(group));
        // 法定内時間
        List<String> _legalTimes = _work.legalTime(group);
        _legalTime = addTime(_legalTime, _legalTimes.first);
        // 深夜時間
        List<String> _calTimes = _work.calTime01(group);
        _nightTime = addTime(_nightTime, _calTimes[1]);
      }
    }
    _row.add('${_count.length}');
    if (_user.position == '正社員') {
      _row.add('$_workTime');
      _row.add('00:00');
    } else {
      _row.add('$_legalTime');
      _row.add('$_nightTime');
    }
    rows.add(_row);
  }

  String csv = const ListToCsvConverter().convert(rows);
  List<int> bytes = List.from(utf8.encode(csv));
  bytes.insert(0, 0xBF);
  bytes.insert(0, 0xBB);
  bytes.insert(0, 0xEF);
  String csvDecode = utf8.decode(bytes);
  print(csvDecode);
  AnchorElement(href: 'data:text/csv;charset=utf-8bom,$csvDecode')
    ..setAttribute('download', 'work.csv')
    ..click();
  return;
}
