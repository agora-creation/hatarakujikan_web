import 'dart:convert';

import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/position.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/models/work.dart';
import 'package:hatarakujikan_web/models/work_shift.dart';
import 'package:hatarakujikan_web/providers/position.dart';
import 'package:hatarakujikan_web/providers/user.dart';
import 'package:hatarakujikan_web/providers/work.dart';
import 'package:hatarakujikan_web/providers/work_shift.dart';
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart';

List<String> csvTemplates = ['ひろめカンパニー用レイアウト', '土佐税理士事務所用レイアウト'];

class CsvApi {
  // 会社/組織をチェックし、配列から消す
  static void groupCheck({required GroupModel group}) {
    String _id = group.id;
    switch (_id) {
      case 'UryZHGotsjyR0Zb6g06J':
        csvTemplates.removeWhere((e) => e != 'ひろめカンパニー用レイアウト');
        return;
      case 'h74zqng5i59qHdMG16Cb':
        csvTemplates.removeWhere((e) => e != '土佐税理士事務所用レイアウト');
        return;
      default:
        csvTemplates.clear();
        return;
    }
  }

  // ダウンロード
  static Future<void> download({
    required PositionProvider positionProvider,
    required UserProvider userProvider,
    required WorkProvider workProvider,
    required WorkShiftProvider workShiftProvider,
    GroupModel? group,
    DateTime? month,
    String? template,
  }) async {
    if (template == '') return;
    switch (template) {
      case 'ひろめカンパニー用レイアウト':
        await _works01(
          positionProvider: positionProvider,
          userProvider: userProvider,
          workProvider: workProvider,
          group: group,
          month: month,
        );
        return;
      case '土佐税理士事務所用レイアウト':
        await _works02(
          positionProvider: positionProvider,
          userProvider: userProvider,
          workProvider: workProvider,
          workShiftProvider: workShiftProvider,
          group: group,
          month: month,
        );
        return;
      default:
        return;
    }
  }
}

Future<void> _works01({
  required PositionProvider positionProvider,
  required UserProvider userProvider,
  required WorkProvider workProvider,
  GroupModel? group,
  DateTime? month,
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
  List<PositionModel> _positions = await positionProvider.selectList(
    groupId: group.id,
  );
  for (PositionModel _position in _positions) {
    List<UserModel> _users = await userProvider.selectList(
      userIds: _position.userIds,
    );
    for (UserModel _user in _users) {
      String number = _user.number;
      String name = _user.name;
      Map count = {};
      String time = '00:00';
      String time1 = '00:00';
      String time2 = '00:00';
      List<WorkModel> _works = await workProvider.selectList(
        group: group,
        user: _user,
        startAt: days.first,
        endAt: days.last,
      );
      for (WorkModel _work in _works) {
        if (_work.startedAt != _work.endedAt) {
          String _key = '${DateFormat('yyyy-MM-dd').format(_work.startedAt)}';
          count[_key] = '';
          time = addTime(time, _work.workTime(group));
          time1 = addTime(time1, _work.calTimes01(group)[0]);
          time2 = addTime(time2, _work.calTimes01(group)[1]);
        }
      }
      int workDays = count.length;
      List<String> _row = [];
      _row.add('$number');
      _row.add('$name');
      _row.add('$workDays');
      if (_position.name == '正社員') {
        _row.add('$time');
        _row.add('00:00');
      } else {
        _row.add('$time1');
        _row.add('$time2');
      }
      rows.add(_row);
    }
  }
  _download(rows: rows, fileName: 'works.csv');
}

Future<void> _works02({
  PositionProvider positionProvider,
  UserProvider userProvider,
  WorkProvider workProvider,
  WorkShiftProvider workShiftProvider,
  GroupModel group,
  DateTime month,
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
  row.add('勤務時間');
  row.add('遅早時間');
  row.add('時間外1');
  row.add('時間外2');
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
  List<PositionModel> _positions = await positionProvider.selectList(
    groupId: group.id,
  );
  for (PositionModel _position in _positions) {
    List<UserModel> _users = await userProvider.selectList(
      userIds: _position.userIds,
    );
    for (UserModel _user in _users) {
      String number = _user.number;
      Map count = {};
      Map state1Count = {};
      Map state2Count = {};
      Map state3Count = {};
      Map state4Count = {};
      Map holidayCount = {};
      String workTime = '00:00';
      String overTime1 = '00:00';
      String overTime2 = '00:00';
      List<WorkModel> _works = await workProvider.selectList(
        group: group,
        user: _user,
        startAt: days.first,
        endAt: days.last,
      );
      List<WorkShiftModel> _workShifts = await workShiftProvider.selectList(
        group: group,
        user: _user,
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
          DateTime _day = DateTime.parse(_key);
          if (group.holidays2.contains(_day)) {
            holidayCount[_key] = '';
          }
          if (_position.name == 'Aグループ') {
            workTime = addTime(workTime, _work.calTimes02(group, 'A')[0]);
            overTime1 = addTime(overTime1, _work.calTimes02(group, 'A')[1]);
            overTime2 = addTime(overTime2, _work.calTimes02(group, 'A')[2]);
          } else if (_position.name == 'Bグループ') {
            workTime = addTime(workTime, _work.calTimes02(group, 'B')[0]);
            overTime1 = addTime(overTime1, _work.calTimes02(group, 'B')[1]);
            overTime2 = addTime(overTime2, _work.calTimes02(group, 'B')[2]);
          } else if (_position.name == 'Cグループ') {
            workTime = addTime(workTime, _work.calTimes02(group, 'C')[0]);
            overTime1 = addTime(overTime1, _work.calTimes02(group, 'C')[1]);
            overTime2 = addTime(overTime2, _work.calTimes02(group, 'C')[2]);
          } else {
            workTime = addTime(workTime, _work.calTimes02(group, 'A')[0]);
            overTime1 = addTime(overTime1, _work.calTimes02(group, 'A')[1]);
            overTime2 = addTime(overTime2, _work.calTimes02(group, 'A')[2]);
          }
        }
      }
      // 時間外を30分四捨五入
      List<String> _overTime1s = overTime1.split(':');
      if (30 <= int.parse(_overTime1s.last)) {
        overTime1 = '${twoDigits(int.parse(_overTime1s.first))}:00';
        overTime1 = addTime(overTime1, '01:00');
      } else {
        overTime1 = '${twoDigits(int.parse(_overTime1s.first))}:00';
      }
      List<String> _overTime2s = overTime2.split(':');
      if (30 <= int.parse(_overTime2s.last)) {
        overTime2 = '${twoDigits(int.parse(_overTime2s.first))}:00';
        overTime2 = addTime(overTime2, '01:00');
      } else {
        overTime2 = '${twoDigits(int.parse(_overTime2s.first))}:00';
      }
      int workDays = count.length;
      int holidayDays = holidayCount.length;
      for (WorkShiftModel _workShift in _workShifts) {
        String _key =
            '${DateFormat('yyyy-MM-dd').format(_workShift.startedAt)}';
        switch (_workShift.state) {
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
      _row.add('$number');
      _row.add('$workDays');
      _row.add('$workDays');
      _row.add('$state1Days');
      _row.add('$state3Days');
      _row.add('$state2Days');
      _row.add('$holidayDays');
      _row.add('$state4Days');
      _row.add('0');
      _row.add('$workTime');
      _row.add('0');
      _row.add('$overTime1');
      _row.add('$overTime2');
      _row.add('00:00');
      _row.add('00:00');
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
