import 'package:csv/csv.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/models/work.dart';
import 'package:hatarakujikan_web/providers/work.dart';
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart';

List<String> csvTemplates = ['ひろめカンパニー専用形式', '土佐税理士事務所専用形式'];

class CsvApi {
  // static void groupCheck({GroupModel group}) {
  //   String _id = group.id;
  //   switch(_id) {
  //     case '':
  //
  //   }
  // }

  static Future<void> works01({
    WorkProvider workProvider,
    GroupModel group,
    DateTime month,
    List<UserModel> users,
  }) async {
    List<List<String>> rows = [];
    List<String> row = [];
    // 1行目(項目名)
    row.add('社員番号');
    row.add('社員名');
    row.add('平日出勤');
    row.add('出勤時間');
    row.add('支給項目2');
    rows.add(row);
    // 2行目以降(データ)
    List<DateTime> days = generateDays(month);
    for (UserModel _user in users) {
      String recordPassword = _user.recordPassword;
      String name = _user.name;
      Map count = {};
      String workTime = '00:00';
      String legalTime = '00:00';
      String nightTime = '00:00';
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
          count[_key] = '';
          // 勤務時間
          workTime = addTime(workTime, _work.workTime(group));
          // 法定内時間
          List<String> _legalTimes = _work.legalTimes(group);
          legalTime = addTime(legalTime, _legalTimes.first);
          // 深夜時間
          List<String> _calTimes = _work.calTimes01(group);
          nightTime = addTime(nightTime, _calTimes[1]);
        }
      }
      // 勤務日数
      int workDays = count.length;
      List<String> _row = [];
      _row.add('$recordPassword');
      _row.add('$name');
      _row.add('$workDays');
      if (_user.position == '正社員') {
        _row.add('$workTime');
        _row.add('00:00');
      } else {
        _row.add('$legalTime');
        _row.add('$nightTime');
      }
      rows.add(_row);
    }
    _download(rows: rows, fileName: 'works.csv');
    return;
  }

  static Future<void> works02() async {
    List<List<String>> rows = [];
    _download(rows: rows, fileName: 'works.csv');
    return;
  }
}

void _download({List<List<String>> rows, String fileName}) {
  String csv = const ListToCsvConverter().convert(rows);
  print(csv);
  AnchorElement(href: 'data:text/csv;charset=utf-8,$csv')
    ..setAttribute('download', fileName)
    ..click();
}
