import 'dart:convert';

import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/models/work.dart';
import 'package:hatarakujikan_web/models/work_state.dart';
import 'package:hatarakujikan_web/providers/work.dart';
import 'package:hatarakujikan_web/providers/work_state.dart';
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart';

List<String> csvTemplates = ['ひろめカンパニー用レイアウト', '土佐税理士事務所用レイアウト'];

class CsvApi {
  static void groupCheck({GroupModel group}) {
    String _id = group.id;
    switch (_id) {
      case 'UryZHGotsjyR0Zb6g06J':
        csvTemplates.removeWhere((e) => e != 'ひろめカンパニー用レイアウト');
        return;
      case 'h74zqng5i59qHdMG16Cb':
        csvTemplates.removeWhere((e) => e != '土佐税理士事務所用レイアウト');
        return;
      default:
        return;
    }
  }

  static Future<void> download({
    String template,
    WorkProvider workProvider,
    WorkStateProvider workStateProvider,
    GroupModel group,
    DateTime month,
    List<UserModel> users,
  }) async {
    if (template == null) return;
    switch (template) {
      case 'ひろめカンパニー用レイアウト':
        await _works01(
          workProvider: workProvider,
          group: group,
          month: month,
          users: users,
        );
        return;
      case '土佐税理士事務所用レイアウト':
        await _works02(
          workProvider: workProvider,
          workStateProvider: workStateProvider,
          group: group,
          month: month,
          users: users,
        );
        return;
      default:
        return;
    }
  }
}

Future<void> _works01({
  WorkProvider workProvider,
  GroupModel group,
  DateTime month,
  List<UserModel> users,
}) async {
  List<List<String>> rows = [];
  List<String> row = [];
  row.add('社員番号');
  row.add('社員名');
  row.add('平日出勤');
  row.add('出勤時間');
  row.add('支給項目2');
  rows.add(row);
  List<DateTime> days = generateDays(month);
  for (UserModel _user in users) {
    String recordPassword = _user.recordPassword;
    String name = _user.name;
    Map count = {};
    String time1 = '00:00';
    String time2 = '00:00';
    List<WorkModel> _works = await workProvider.selectList(
      groupId: group.id,
      userId: _user.id,
      startAt: days.first,
      endAt: days.last,
    );
    for (WorkModel _work in _works) {
      if (_work.startedAt != _work.endedAt) {
        String _key = '${DateFormat('yyyy-MM-dd').format(_work.startedAt)}';
        count[_key] = '';
        time1 = addTime(time1, _work.calTimes01(group)[0]);
        time2 = addTime(time2, _work.calTimes01(group)[1]);
      }
    }
    int workDays = count.length;
    List<String> _row = [];
    _row.add('$recordPassword');
    _row.add('$name');
    _row.add('$workDays');
    _row.add('$time1');
    _row.add('$time2');
    rows.add(_row);
  }
  _download(rows: rows, fileName: 'works.csv');
}

Future<void> _works02({
  WorkProvider workProvider,
  WorkStateProvider workStateProvider,
  GroupModel group,
  DateTime month,
  List<UserModel> users,
}) async {
  List<List<String>> rows = [];
  List<String> row = [];
  row.add('社員コード');
  row.add('就業日数');
  row.add('出勤日数');
  row.add('欠勤日数');
  row.add('有休日数');
  row.add('特休日数');
  row.add('休出日数');
  row.add('代休日数');
  row.add('遅早回数');
  row.add('出勤時間');
  row.add('遅早時間');
  row.add('平日普通残業時間');
  row.add('平日深夜残業時間');
  row.add('休日普通残業時間');
  row.add('休日深夜残業時間');
  row.add('予備項目');
  row.add('予備項目');
  row.add('予備項目');
  row.add('予備項目');
  row.add('予備項目');
  row.add('予備項目');
  row.add('予備項目');
  row.add('予備項目');
  row.add('予備項目');
  row.add('予備項目');
  row.add('予備項目');
  row.add('予備項目');
  row.add('予備項目');
  row.add('予備項目');
  row.add('予備項目');
  rows.add(row);
  List<DateTime> days = generateDays(month);
  for (UserModel _user in users) {
    String recordPassword = _user.recordPassword;
    Map count = {};
    Map state1Count = {};
    Map state2Count = {};
    Map state3Count = {};
    Map state4Count = {};
    Map holidayCount = {};
    Map overCount = {};
    String workTime = '00:00';
    String overTime = '00:00';
    String overTime1 = '00:00';
    String overTime2 = '00:00';
    String overTime3 = '00:00';
    String overTime4 = '00:00';
    List<WorkModel> _works = await workProvider.selectList(
      groupId: group.id,
      userId: _user.id,
      startAt: days.first,
      endAt: days.last,
    );
    List<WorkStateModel> _workStates = await workStateProvider.selectList(
      groupId: group.id,
      userId: _user.id,
      startAt: days.first,
      endAt: days.last,
    );
    for (WorkModel _work in _works) {
      if (_work.startedAt != _work.endedAt) {
        String _key = '${DateFormat('yyyy-MM-dd').format(_work.startedAt)}';
        count[_key] = '';
        String _week = '${DateFormat('E', 'ja').format(_work.startedAt)}';
        if (group.holidays.contains(_week)) {
          holidayCount[_key] = '';
        }
        DateFormat _keyFormat = DateFormat('yyyyMMddHHmm');
        if (_work.overTimes(group).first != '00:00') {
          String _key1 = '${_keyFormat.format(_work.startedAt)}_1';
          overCount[_key1] = '';
        }
        if (_work.overTimes(group).last != '00:00') {
          String _key2 = '${_keyFormat.format(_work.startedAt)}_2';
          overCount[_key2] = '';
        }
        workTime = addTime(workTime, _work.workTime(group));
        overTime = addTime(overTime, _work.overTimes(group).first);
        overTime = addTime(overTime, _work.overTimes(group).last);
        overTime1 = addTime(overTime1, _work.calTimes02(group)[0]);
        overTime2 = addTime(overTime2, _work.calTimes02(group)[1]);
        overTime3 = addTime(overTime3, _work.calTimes02(group)[2]);
        overTime4 = addTime(overTime4, _work.calTimes02(group)[3]);
      }
    }
    int workDays = count.length;
    int holidayDays = holidayCount.length;
    int overDays = overCount.length;
    for (WorkStateModel _workState in _workStates) {
      String _key = '${DateFormat('yyyy-MM-dd').format(_workState.startedAt)}';
      switch (_workState.state) {
        case '欠勤':
          state1Count[_key] = '';
          break;
        case '特別休暇':
          state2Count[_key] = '';
          break;
        case '有給休暇':
          state3Count[_key] = '';
          break;
        case '代休':
          state4Count[_key] = '';
          break;
      }
    }
    int state1Days = state1Count.length;
    int state2Days = state2Count.length;
    int state3Days = state3Count.length;
    int state4Days = state4Count.length;
    List<String> _row = [];
    _row.add('$recordPassword');
    _row.add('$workDays');
    _row.add('$workDays');
    _row.add('$state1Days');
    _row.add('$state3Days');
    _row.add('$state2Days');
    _row.add('$holidayDays');
    _row.add('$state4Days');
    _row.add('$overDays');
    _row.add('$workTime');
    _row.add('$overTime');
    _row.add('$overTime1');
    _row.add('$overTime2');
    _row.add('$overTime3');
    _row.add('$overTime4');
    _row.add('');
    _row.add('');
    _row.add('');
    _row.add('');
    _row.add('');
    _row.add('');
    _row.add('');
    _row.add('');
    _row.add('');
    _row.add('');
    _row.add('');
    _row.add('');
    _row.add('');
    _row.add('');
    _row.add('');
    rows.add(_row);
  }
  _download(rows: rows, fileName: 'works.csv');
}

void _download({List<List<String>> rows, String fileName}) {
  final bom = '\uFEFF';
  String text = bom + rows.join('\n');
  text = text.replaceAll('[', '');
  text = text.replaceAll(']', '');
  final bytes = utf8.encode(text);
  final blob = Blob([bytes]);
  final url = Url.createObjectUrlFromBlob(blob);
  final anchor = document.createElement('a') as AnchorElement
    ..href = url
    ..style.display = 'none'
    ..download = fileName;
  document.body.children.add(anchor);
  anchor.click();
  document.body.children.remove(anchor);
  Url.revokeObjectUrl(url);
}
