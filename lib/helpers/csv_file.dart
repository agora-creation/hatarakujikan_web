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
import 'package:universal_html/html.dart';

class CSVFile {
  //共通部
  static Future download({
    required PositionProvider positionProvider,
    required UserProvider userProvider,
    required WorkProvider workProvider,
    required WorkShiftProvider workShiftProvider,
    GroupModel? group,
    DateTime? month,
  }) async {
    String? groupId = group?.id;
    switch (groupId) {
      //ひろめ市場
      case 'UryZHGotsjyR0Zb6g06J':
        await _model01(
          positionProvider: positionProvider,
          userProvider: userProvider,
          workProvider: workProvider,
          group: group,
          month: month,
        );
        return;
      //土佐税理士
      case 'h74zqng5i59qHdMG16Cb':
        await _model02(
          positionProvider: positionProvider,
          userProvider: userProvider,
          workProvider: workProvider,
          workShiftProvider: workShiftProvider,
          group: group,
          month: month,
        );
        return;
      default:
        await _model01(
          positionProvider: positionProvider,
          userProvider: userProvider,
          workProvider: workProvider,
          group: group,
          month: month,
        );
        return;
    }
  }
}

Future _model01({
  required PositionProvider positionProvider,
  required UserProvider userProvider,
  required WorkProvider workProvider,
  GroupModel? group,
  DateTime? month,
}) async {
  if (group == null) return;
  if (month == null) return;
  List<DateTime> days = generateDays(month);
  List<List<String>> rows = [];
  List<String> row = [];
  row.add('社員番号');
  row.add('社員名');
  row.add('平日出勤');
  row.add('出勤時間');
  row.add('支給項目2');
  rows.add(row);
  List<PositionModel> positions = await positionProvider.selectList(
    groupId: group.id,
  );
  for (PositionModel _position in positions) {
    List<UserModel> users = await userProvider.selectList(
      userIds: _position.userIds,
    );
    for (UserModel _user in users) {
      String number = _user.number;
      String name = _user.name;
      Map cnt = {};
      String time = '00:00';
      String time1 = '00:00';
      String time2 = '00:00';
      List<WorkModel> works = await workProvider.selectList(
        group: group,
        user: _user,
        startAt: days.first,
        endAt: days.last,
      );
      for (WorkModel _work in works) {
        if (_work.startedAt != _work.endedAt) {
          String _key = dateText('yyyy-MM-dd', _work.startedAt);
          cnt[_key] = '';
          time = addTime(time, _work.workTime(group));
          time1 = addTime(time1, _work.calTimes01(group).first);
          time2 = addTime(time2, _work.calTimes01(group).last);
        }
      }
      int workDays = cnt.length;
      List<String> _row = [];
      _row.add(number);
      _row.add(name);
      _row.add('$workDays');
      if (_position.name == '正社員') {
        _row.add(time);
        _row.add('00:00');
      } else {
        _row.add(time1);
        _row.add(time2);
      }
      rows.add(_row);
    }
  }
  _dl(rows: rows, fileName: 'works.csv');
  return;
}

Future _model02({
  required PositionProvider positionProvider,
  required UserProvider userProvider,
  required WorkProvider workProvider,
  required WorkShiftProvider workShiftProvider,
  GroupModel? group,
  DateTime? month,
}) async {
  if (group == null) return;
  if (month == null) return;
  List<DateTime> days = generateDays(month);
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
  List<PositionModel> positions = await positionProvider.selectList(
    groupId: group.id,
  );
  for (PositionModel _position in positions) {
    List<UserModel> users = await userProvider.selectList(
      userIds: _position.userIds,
    );
    for (UserModel _user in users) {
      String number = _user.number;
      Map cnt = {};
      Map stateCnt1 = {};
      Map stateCnt2 = {};
      Map stateCnt3 = {};
      Map stateCnt4 = {};
      Map holidayCnt = {};
      String workTime = '00:00';
      String overTime1 = '00:00';
      String overTime2 = '00:00';
      List<WorkModel> works = await workProvider.selectList(
        group: group,
        user: _user,
        startAt: days.first,
        endAt: days.last,
      );
      List<WorkShiftModel> workShifts = await workShiftProvider.selectList(
        group: group,
        user: _user,
        startAt: days.first,
        endAt: days.last,
      );
      for (WorkModel _work in works) {
        if (_work.startedAt != _work.endedAt) {
          String _key = dateText('yyyy-MM-dd', _work.startedAt);
          cnt[_key] = '';
          String _week = dateText('E', _work.startedAt);
          if (group.holidays.contains(_week)) holidayCnt[_key] = '';
          DateTime _day = DateTime.parse(_key);
          if (group.holidays2.contains(_day)) holidayCnt[_key] = '';
          switch (_position.name) {
            case 'Aグループ':
              workTime = addTime(workTime, _work.calTimes02(group, 'A')[0]);
              overTime1 = addTime(overTime1, _work.calTimes02(group, 'A')[1]);
              overTime2 = addTime(overTime2, _work.calTimes02(group, 'A')[2]);
              break;
            case 'Bグループ':
              workTime = addTime(workTime, _work.calTimes02(group, 'B')[0]);
              overTime1 = addTime(overTime1, _work.calTimes02(group, 'B')[1]);
              overTime2 = addTime(overTime2, _work.calTimes02(group, 'B')[2]);
              break;
            case 'Cグループ':
              workTime = addTime(workTime, _work.calTimes02(group, 'C')[0]);
              overTime1 = addTime(overTime1, _work.calTimes02(group, 'C')[1]);
              overTime2 = addTime(overTime2, _work.calTimes02(group, 'C')[2]);
              break;
            default:
              workTime = addTime(workTime, _work.calTimes02(group, 'A')[0]);
              overTime1 = addTime(overTime1, _work.calTimes02(group, 'A')[1]);
              overTime2 = addTime(overTime2, _work.calTimes02(group, 'A')[2]);
              break;
          }
        }
      }
      //時間外を30分四捨五入
      List<String> overTime1s = overTime1.split(':');
      if (30 <= int.parse(overTime1s.last)) {
        overTime1 = '${twoDigits(int.parse(overTime1s.first))}:00';
        overTime2 = addTime(overTime1, '01:00');
      } else {
        overTime1 = '${twoDigits(int.parse(overTime1s.first))}:00';
      }
      List<String> overTime2s = overTime2.split(':');
      if (30 <= int.parse(overTime2s.last)) {
        overTime2 = '${twoDigits(int.parse(overTime2s.first))}:00';
        overTime2 = addTime(overTime2, '01:00');
      } else {
        overTime2 = '${twoDigits(int.parse(overTime2s.first))}:00';
      }
      int workDays = cnt.length;
      int holidayDays = holidayCnt.length;
      for (WorkShiftModel _workShift in workShifts) {
        String _key = dateText('yyyy-MM-dd', _workShift.startedAt);
        switch (_workShift.state) {
          case '欠勤':
            stateCnt1[_key] = '';
            break;
          case '特別休暇':
            stateCnt2[_key] = '';
            break;
          case '有給休暇':
            stateCnt3[_key] = '';
            break;
          case '代休':
            stateCnt4[_key] = '';
            break;
        }
      }
      int stateDays1 = stateCnt1.length;
      int stateDays2 = stateCnt2.length;
      int stateDays3 = stateCnt3.length;
      int stateDays4 = stateCnt4.length;
      List<String> _row = [];
      _row.add(number);
      _row.add('$workDays');
      _row.add('$workDays');
      _row.add('$stateDays1');
      _row.add('$stateDays3');
      _row.add('$stateDays2');
      _row.add('$holidayDays');
      _row.add('$stateDays4');
      _row.add('0');
      _row.add(workTime);
      _row.add('0');
      _row.add(overTime1);
      _row.add(overTime2);
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
  _dl(rows: rows, fileName: 'works.csv');
  return;
}

void _dl({
  required List<List<String>> rows,
  required String fileName,
}) {
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
  document.body?.children.add(anchor);
  anchor.click();
  document.body?.children.remove(anchor);
  Url.revokeObjectUrl(url);
}
