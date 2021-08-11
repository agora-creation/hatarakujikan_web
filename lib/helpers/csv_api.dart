import 'package:csv/csv.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/models/work.dart';
import 'package:hatarakujikan_web/providers/work.dart';
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart';

class CsvApi {
  static Future<void> works01({
    WorkProvider workProvider,
    GroupModel group,
    DateTime month,
    List<UserModel> users,
  }) async {
    List<List<dynamic>> rows = [];
    List<dynamic> row = [];
    row.add('社員番号');
    row.add('社員名');
    row.add('平日出勤');
    row.add('出勤時間');
    row.add('支給項目2');
    rows.add(row);

    List<DateTime> days = generateDays(month);
    for (UserModel _user in users) {
      String _recordPassword = _user.recordPassword;
      String _name = _user.name;
      Map _workDays = {};
      String _workTime = '00:00';
      String _legalTime = '00:00';
      String _nightTime = '00:00';
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
      for (WorkModel _work in _works) {
        if (_work.startedAt != _work.endedAt) {
          // 勤務日数
          String _key = '${DateFormat('yyyy-MM-dd').format(_work.startedAt)}';
          _workDays[_key] = '';
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

      List<dynamic> _row = [];
      _row.add('$_recordPassword');
      _row.add('$_name');
      _row.add('${_workDays.length}');
      if (_user.position == '正社員') {
        _row.add('$_workTime');
        _row.add('00:00');
      } else {
        _row.add('$_legalTime');
        _row.add('$_nightTime');
      }
      rows.add(_row);
    }
    _download(rows: rows, fileName: 'work.csv');
    return;
  }
}

void _download({List<List<dynamic>> rows, String fileName}) {
  String csv = const ListToCsvConverter().convert(rows);
  AnchorElement(href: 'data:text/csv;charset=utf-8,$csv')
    ..setAttribute('download', fileName)
    ..click();
}
