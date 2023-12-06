import 'package:flutter/services.dart';
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
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_html/html.dart' as html;

const String fontPath = 'assets/fonts/GenShinGothic-Regular.ttf';

class PDFFile {
  //QRコード作成
  static Future qrcode({GroupModel? group}) async {
    final pdf = pw.Document();
    final font = await rootBundle.load(fontPath);
    final ttf = pw.Font.ttf(font);
    final titleStyle = pw.TextStyle(font: ttf, fontSize: 18.0);
    final contentStyle = pw.TextStyle(font: ttf, fontSize: 12.0);
    //ページ作成
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Column(
        children: [
          //タイトル
          pw.Center(
            child: pw.Text(group?.name ?? '', style: titleStyle),
          ),
          pw.SizedBox(height: 16.0),
          //QRコード
          pw.Container(
            width: 250.0,
            height: 250.0,
            child: pw.BarcodeWidget(
              barcode: pw.Barcode.qrCode(),
              data: group?.id ?? '',
            ),
          ),
          pw.SizedBox(height: 8.0),
          pw.Divider(),
          pw.SizedBox(height: 8.0),
          //その他説明
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'このQRコードには、${group?.name ?? ''}の会社/組織IDが埋め込まれています。スマホアプリ「はたらくじかんforスマートフォン」で使用します。',
                style: contentStyle,
              ),
              pw.SizedBox(height: 8.0),
              pw.Text(
                '【会社/組織に入る時】',
                style: contentStyle,
              ),
              pw.Text(
                '① 「はたらくじかんforスマートフォン」を起動し、ログインする。',
                style: contentStyle,
              ),
              pw.Text(
                '② 下部メニューから「会社/組織」をタップする。',
                style: contentStyle,
              ),
              pw.Text(
                '③ 下部メニューの上の「会社/組織に入る」ボタンをタップする。',
                style: contentStyle,
              ),
              pw.Text(
                '④ アプリ内カメラが起動するので、枠内にQRコードをおさめるように撮る。',
                style: contentStyle,
              ),
              pw.SizedBox(height: 16.0),
              pw.Text(
                '【出退勤や休憩の時間を記録する時】',
                style: contentStyle,
              ),
              pw.Text(
                '① 「はたらくじかんforスマートフォン」を起動し、ログインする。',
                style: contentStyle,
              ),
              pw.Text(
                '② 下部メニューから「ホーム」をタップする。',
                style: contentStyle,
              ),
              pw.Text(
                '③ 「出勤」「退勤」「休憩開始」「休憩終了」ボタンをタップする。',
                style: contentStyle,
              ),
              pw.Text(
                '④ アプリ内カメラが起動するので、枠内にQRコードをおさめるように撮る。',
                style: contentStyle,
              ),
            ],
          ),
        ],
      ),
    ));
    await _dl(pdf: pdf, fileName: 'qrcode.pdf');
    return;
  }

  //共通部
  static Future download({
    required PositionProvider positionProvider,
    required UserProvider userProvider,
    required WorkProvider workProvider,
    required WorkShiftProvider workShiftProvider,
    GroupModel? group,
    DateTime? month,
    UserModel? user,
    bool? isAll,
  }) async {
    String? groupId = group?.id;
    switch (groupId) {
      //ひろめ市場
      case 'UryZHGotsjyR0Zb6g06J':
        await _model01(
          userProvider: userProvider,
          workProvider: workProvider,
          workShiftProvider: workShiftProvider,
          group: group,
          month: month,
          user: user,
          isAll: isAll,
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
          user: user,
          isAll: isAll,
        );
        return;
      default:
        await _model01(
          userProvider: userProvider,
          workProvider: workProvider,
          workShiftProvider: workShiftProvider,
          group: group,
          month: month,
          user: user,
          isAll: isAll,
        );
        return;
    }
  }
}

Future _model01({
  required UserProvider userProvider,
  required WorkProvider workProvider,
  required WorkShiftProvider workShiftProvider,
  GroupModel? group,
  DateTime? month,
  UserModel? user,
  bool? isAll,
}) async {
  if (month == null) return;
  final pdf = pw.Document();
  final font = await rootBundle.load(fontPath);
  final ttf = pw.Font.ttf(font);
  final headStyle = pw.TextStyle(font: ttf, fontSize: 9.0);
  final listStyle = pw.TextStyle(font: ttf, fontSize: 7.0);
  //日付配列作成
  List<DateTime> days = generateDays(month);
  //日付配列(1週間分前後多いver)
  List<DateTime> days2 = [];
  DateTime _start2 = days.first.add(Duration(days: 7) * -1);
  DateTime _end2 = days.last.add(Duration(days: 7));
  for (int i = 0; i <= _end2.difference(_start2).inDays; i++) {
    days2.add(_start2.add(Duration(days: i)));
  }
  if (isAll == true) {
    List<UserModel> users = await userProvider.selectList(
      userIds: group?.userIds ?? [],
    );
    for (UserModel _user in users) {
      List<WorkModel> works = await workProvider.selectList(
        group: group,
        user: _user,
        startAt: days.first,
        endAt: days.last,
      );
      List<WorkModel> works2 = await workProvider.selectList(
        group: group,
        user: _user,
        startAt: days2.first,
        endAt: days2.last,
      );
      List<WorkShiftModel> workShifts = await workShiftProvider.selectList(
        group: group,
        user: _user,
        startAt: days.first,
        endAt: days.last,
      );
      //合計値初期化
      Map cnt = {};
      Map cnt2 = {};
      String workTimes = '00:00';
      String dayTimes = '00:00';
      String nightTimes = '00:00';
      String dayTimeOvers = '00:00';
      String nightTimeOvers = '00:00';
      //一行目
      List<pw.TableRow> _row = [];
      _row.add(pw.TableRow(
        decoration: pw.BoxDecoration(color: PdfColors.grey300),
        children: [
          _cell('日付', listStyle),
          _cell('勤務状況', listStyle),
          _cell('出勤時間', listStyle),
          _cell('退勤時間', listStyle),
          _cell('休憩時間', listStyle),
          _cell('勤務時間', listStyle),
          _cell('通常時間※1', listStyle),
          _cell('深夜時間(-)※2', listStyle),
          _cell('通常時間外※3', listStyle),
          _cell('深夜時間外※4', listStyle),
          _cell('週間合計※5', listStyle),
        ],
      ));
      //週間合計の計算
      String _tmp = '00:00';
      for (DateTime _day2 in days2) {
        List<WorkModel> _dayInWorks2 = [];
        for (WorkModel _work2 in works2) {
          String _key = dateText('yyyy-MM-dd', _work2.startedAt);
          if (_day2 == DateTime.parse(_key)) _dayInWorks2.add(_work2);
        }
        String _week = dateText('E', _day2);
        if (_week == '日') _tmp = '00:00';
        if (_dayInWorks2.length > 0) {
          for (WorkModel _work in _dayInWorks2) {
            if (_work.startedAt != _work.endedAt) {
              _tmp = addTime(_tmp, _work.workTime(group));
            }
          }
        }
        if (_week == '土') {
          String _key = dateText('yyyy-MM-dd', _day2);
          cnt2[_key] = _tmp;
        }
      }
      //二行目以降
      for (DateTime _day in days) {
        List<WorkModel> _dayInWorks = [];
        for (WorkModel _work in works) {
          String _key = dateText('yyyy-MM-dd', _work.startedAt);
          if (_day == DateTime.parse(_key)) _dayInWorks.add(_work);
        }
        WorkShiftModel? _dayInWorkShifts;
        for (WorkShiftModel _workShift in workShifts) {
          String _key = dateText('yyyy-MM-dd', _workShift.startedAt);
          if (_day == DateTime.parse(_key)) _dayInWorkShifts = _workShift;
        }
        String day = dateText('dd (E)', _day);
        if (_dayInWorks.length > 0) {
          for (WorkModel _work in _dayInWorks) {
            if (_work.startedAt != _work.endedAt) {
              String state = _work.state;
              String startTime = _work.startTime(group);
              String endTime = _work.endTime(group);
              String breakTime = _work.breakTimes(group).first;
              String workTime = _work.workTime(group);
              String dayTime = _work.calTimes01(group)[0];
              String nightTime = _work.calTimes01(group)[1];
              String dayTimeOver = _work.calTimes01(group)[2];
              String nightTimeOver = _work.calTimes01(group)[3];
              String _key = dateText('yyyy-MM-dd', _work.startedAt);
              cnt[_key] = '';
              workTimes = addTime(workTimes, workTime);
              dayTimes = addTime(dayTimes, dayTime);
              nightTimes = addTime(nightTimes, nightTime);
              dayTimeOvers = addTime(dayTimeOvers, dayTimeOver);
              nightTimeOvers = addTime(nightTimeOvers, nightTimeOver);
              _row.add(pw.TableRow(
                children: [
                  _cell(day, listStyle),
                  _cell(state, listStyle),
                  _cell(startTime, listStyle),
                  _cell(endTime, listStyle),
                  _cell(breakTime, listStyle),
                  _cell(workTime, listStyle),
                  _cell(dayTime, listStyle),
                  _cell(nightTime, listStyle),
                  _cell(dayTimeOver, listStyle),
                  _cell(nightTimeOver, listStyle),
                  _cell(cnt2[dateText('yyyy-MM-dd', _day)], listStyle),
                ],
              ));
            }
          }
        } else {
          _row.add(pw.TableRow(
            children: [
              _cell(day, listStyle),
              _cell(
                _dayInWorkShifts?.state ?? '',
                listStyle,
                color: _dayInWorkShifts?.stateColor3(),
              ),
              _cell('', listStyle),
              _cell('', listStyle),
              _cell('', listStyle),
              _cell('', listStyle),
              _cell('', listStyle),
              _cell('', listStyle),
              _cell('', listStyle),
              _cell('', listStyle),
              _cell(cnt2[dateText('yyyy-MM-dd', _day)] ?? '', listStyle),
            ],
          ));
        }
      }
      //各時間の合計
      List<pw.TableRow> _totalRow = [];
      int workDays = cnt.length;
      _totalRow.add(pw.TableRow(
        decoration: pw.BoxDecoration(color: PdfColors.grey300),
        children: [
          _cell('総勤務日数 [$workDays日]', listStyle),
          _cell('総勤務時間 [$workTimes]', listStyle),
          _cell('総通常時間 [$dayTimes]', listStyle),
          _cell('総深夜時間(-) [$nightTimes]', listStyle),
          _cell('総通常時間外 [$dayTimeOvers]', listStyle),
          _cell('総深夜時間外 [$nightTimeOvers]', listStyle),
        ],
      ));
      //ページ作成
      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildHeader(
              month: dateText('yyyy年MM月', month),
              user: '${_user.name} (${_user.number})',
              style: headStyle,
            ),
            pw.SizedBox(height: 4.0),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey),
              children: _row,
            ),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey),
              children: _totalRow,
            ),
            pw.SizedBox(height: 4.0),
            _buildRemarks(style: listStyle),
          ],
        ),
      ));
    }
  } else {
    if (user == null) return;
    List<WorkModel> works = await workProvider.selectList(
      group: group,
      user: user,
      startAt: days.first,
      endAt: days.last,
    );
    List<WorkModel> works2 = await workProvider.selectList(
      group: group,
      user: user,
      startAt: days2.first,
      endAt: days2.last,
    );
    List<WorkShiftModel> workShifts = await workShiftProvider.selectList(
      group: group,
      user: user,
      startAt: days.first,
      endAt: days.last,
    );
    //合計値初期化
    Map cnt = {};
    Map cnt2 = {};
    String workTimes = '00:00';
    String dayTimes = '00:00';
    String nightTimes = '00:00';
    String dayTimeOvers = '00:00';
    String nightTimeOvers = '00:00';
    //一行目
    List<pw.TableRow> _row = [];
    _row.add(pw.TableRow(
      decoration: pw.BoxDecoration(color: PdfColors.grey300),
      children: [
        _cell('日付', listStyle),
        _cell('勤務状況', listStyle),
        _cell('出勤時間', listStyle),
        _cell('退勤時間', listStyle),
        _cell('休憩時間', listStyle),
        _cell('勤務時間', listStyle),
        _cell('通常時間※1', listStyle),
        _cell('深夜時間(-)※2', listStyle),
        _cell('通常時間外※3', listStyle),
        _cell('深夜時間外※4', listStyle),
        _cell('週間合計※5', listStyle),
      ],
    ));
    //週間合計の計算
    String _tmp = '00:00';
    for (DateTime _day2 in days2) {
      List<WorkModel> _dayInWorks2 = [];
      for (WorkModel _work2 in works2) {
        String _key = dateText('yyyy-MM-dd', _work2.startedAt);
        if (_day2 == DateTime.parse(_key)) _dayInWorks2.add(_work2);
      }
      String _week = dateText('E', _day2);
      if (_week == '日') _tmp = '00:00';
      if (_dayInWorks2.length > 0) {
        for (WorkModel _work in _dayInWorks2) {
          if (_work.startedAt != _work.endedAt) {
            _tmp = addTime(_tmp, _work.workTime(group));
          }
        }
      }
      if (_week == '土') {
        String _key = dateText('yyyy-MM-dd', _day2);
        cnt2[_key] = _tmp;
      }
    }
    //二行目以降
    for (DateTime _day in days) {
      List<WorkModel> _dayInWorks = [];
      for (WorkModel _work in works) {
        String _key = dateText('yyyy-MM-dd', _work.startedAt);
        if (_day == DateTime.parse(_key)) _dayInWorks.add(_work);
      }
      WorkShiftModel? _dayInWorkShifts;
      for (WorkShiftModel _workShift in workShifts) {
        String _key = dateText('yyyy-MM-dd', _workShift.startedAt);
        if (_day == DateTime.parse(_key)) _dayInWorkShifts = _workShift;
      }
      String day = dateText('dd (E)', _day);
      if (_dayInWorks.length > 0) {
        for (WorkModel _work in _dayInWorks) {
          if (_work.startedAt != _work.endedAt) {
            String state = _work.state;
            String startTime = _work.startTime(group);
            String endTime = _work.endTime(group);
            String breakTime = _work.breakTimes(group).first;
            String workTime = _work.workTime(group);
            String dayTime = _work.calTimes01(group)[0];
            String nightTime = _work.calTimes01(group)[1];
            String dayTimeOver = _work.calTimes01(group)[2];
            String nightTimeOver = _work.calTimes01(group)[3];
            String _key = dateText('yyyy-MM-dd', _work.startedAt);
            cnt[_key] = '';
            workTimes = addTime(workTimes, workTime);
            dayTimes = addTime(dayTimes, dayTime);
            nightTimes = addTime(nightTimes, nightTime);
            dayTimeOvers = addTime(dayTimeOvers, dayTimeOver);
            nightTimeOvers = addTime(nightTimeOvers, nightTimeOver);
            _row.add(pw.TableRow(
              children: [
                _cell(day, listStyle),
                _cell(state, listStyle),
                _cell(startTime, listStyle),
                _cell(endTime, listStyle),
                _cell(breakTime, listStyle),
                _cell(workTime, listStyle),
                _cell(dayTime, listStyle),
                _cell(nightTime, listStyle),
                _cell(dayTimeOver, listStyle),
                _cell(nightTimeOver, listStyle),
                _cell(cnt2[dateText('yyyy-MM-dd', _day)], listStyle),
              ],
            ));
          }
        }
      } else {
        _row.add(pw.TableRow(
          children: [
            _cell(day, listStyle),
            _cell(
              _dayInWorkShifts?.state ?? '',
              listStyle,
              color: _dayInWorkShifts?.stateColor3(),
            ),
            _cell('', listStyle),
            _cell('', listStyle),
            _cell('', listStyle),
            _cell('', listStyle),
            _cell('', listStyle),
            _cell('', listStyle),
            _cell('', listStyle),
            _cell('', listStyle),
            _cell(cnt2[dateText('yyyy-MM-dd', _day)] ?? '', listStyle),
          ],
        ));
      }
    }
    //各時間の合計
    List<pw.TableRow> _totalRow = [];
    int workDays = cnt.length;
    _totalRow.add(pw.TableRow(
      decoration: pw.BoxDecoration(color: PdfColors.grey300),
      children: [
        _cell('総勤務日数 [$workDays日]', listStyle),
        _cell('総勤務時間 [$workTimes]', listStyle),
        _cell('総通常時間 [$dayTimes]', listStyle),
        _cell('総深夜時間(-) [$nightTimes]', listStyle),
        _cell('総通常時間外 [$dayTimeOvers]', listStyle),
        _cell('総深夜時間外 [$nightTimeOvers]', listStyle),
      ],
    ));
    //ページ作成
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildHeader(
            month: dateText('yyyy年MM月', month),
            user: '${user.name} (${user.number})',
            style: headStyle,
          ),
          pw.SizedBox(height: 4.0),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey),
            children: _row,
          ),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey),
            children: _totalRow,
          ),
          pw.SizedBox(height: 4.0),
          _buildRemarks(style: listStyle),
        ],
      ),
    ));
  }
  await _dl(pdf: pdf, fileName: 'works.pdf');
  return;
}

Future _model02({
  required PositionProvider positionProvider,
  required UserProvider userProvider,
  required WorkProvider workProvider,
  required WorkShiftProvider workShiftProvider,
  GroupModel? group,
  DateTime? month,
  UserModel? user,
  bool? isAll,
}) async {
  if (month == null) return;
  final pdf = pw.Document();
  final font = await rootBundle.load(fontPath);
  final ttf = pw.Font.ttf(font);
  final headStyle = pw.TextStyle(font: ttf, fontSize: 9.0);
  final listStyle = pw.TextStyle(font: ttf, fontSize: 7.0);
  //日付配列作成
  List<DateTime> days = generateDays(month);
  //雇用形態配列作成
  List<PositionModel> positions = await positionProvider.selectList(
    groupId: group?.id,
  );
  if (isAll == true) {
    List<UserModel> users = await userProvider.selectList(
      userIds: group?.userIds ?? [],
    );
    for (UserModel _user in users) {
      String positionName = '';
      for (PositionModel _position in positions) {
        List<String> _userIds = _position.userIds;
        if (_userIds.contains(_user.id)) {
          positionName = _position.name;
          break;
        }
      }
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
      //合計値初期化
      Map cnt = {};
      String workTimes = '00:00';
      String overTimes1 = '00:00';
      String overTimes2 = '00:00';
      //一行目
      List<pw.TableRow> _row = [];
      _row.add(pw.TableRow(
        decoration: pw.BoxDecoration(color: PdfColors.grey300),
        children: [
          _cell('日付', listStyle),
          _cell('勤務状況', listStyle),
          _cell('出勤時間', listStyle),
          _cell('退勤時間', listStyle),
          _cell('休憩時間', listStyle),
          _cell('勤務時間', listStyle),
          _cell('時間外1', listStyle),
          _cell('時間外2', listStyle),
        ],
      ));
      //二行目以降
      for (DateTime _day in days) {
        List<WorkModel> _dayInWorks = [];
        for (WorkModel _work in works) {
          String _key = dateText('yyyy-MM-dd', _work.startedAt);
          if (_day == DateTime.parse(_key)) _dayInWorks.add(_work);
        }
        WorkShiftModel? _dayInWorkShifts;
        for (WorkShiftModel _workShift in workShifts) {
          String _key = dateText('yyyy-MM-dd', _workShift.startedAt);
          if (_day == DateTime.parse(_key)) _dayInWorkShifts = _workShift;
        }
        String day = dateText('dd (E)', _day);
        if (_dayInWorks.length > 0) {
          for (WorkModel _work in _dayInWorks) {
            if (_work.startedAt != _work.endedAt) {
              String state = _work.state;
              String startTime = _work.startTime(group);
              String endTime = _work.endTime(group);
              String breakTime = _work.breakTimes(group).first;
              String workTime = '00:00';
              String overTime1 = '00:00';
              String overTime2 = '00:00';
              switch (positionName) {
                case 'Aグループ':
                  workTime = _work.calTimes02(group, 'A')[0];
                  overTime1 = _work.calTimes02(group, 'A')[1];
                  overTime2 = _work.calTimes02(group, 'A')[2];
                  break;
                case 'Bグループ':
                  workTime = _work.calTimes02(group, 'B')[0];
                  overTime1 = _work.calTimes02(group, 'B')[1];
                  overTime2 = _work.calTimes02(group, 'B')[2];
                  break;
                case 'Cグループ':
                  workTime = _work.calTimes02(group, 'C')[0];
                  overTime1 = _work.calTimes02(group, 'C')[1];
                  overTime2 = _work.calTimes02(group, 'C')[2];
                  break;
                case 'Dグループ':
                  workTime = _work.calTimes02(group, 'D')[0];
                  overTime1 = _work.calTimes02(group, 'D')[1];
                  overTime2 = _work.calTimes02(group, 'D')[2];
                  break;
                default:
                  workTime = _work.calTimes02(group, 'A')[0];
                  overTime1 = _work.calTimes02(group, 'A')[1];
                  overTime2 = _work.calTimes02(group, 'A')[2];
                  break;
              }
              String _key = dateText('yyyy-MM-dd', _work.startedAt);
              cnt[_key] = '';
              workTimes = addTime(workTimes, workTime);
              overTimes1 = addTime(overTimes1, overTime1);
              overTimes2 = addTime(overTimes2, overTime2);
              _row.add(pw.TableRow(
                children: [
                  _cell(day, listStyle),
                  _cell(state, listStyle),
                  _cell(startTime, listStyle),
                  _cell(endTime, listStyle),
                  _cell(breakTime, listStyle),
                  _cell(workTime, listStyle),
                  _cell(overTime1, listStyle),
                  _cell(overTime2, listStyle),
                ],
              ));
            }
          }
        } else {
          _row.add(pw.TableRow(
            children: [
              _cell(day, listStyle),
              _cell(
                _dayInWorkShifts?.state ?? '',
                listStyle,
                color: _dayInWorkShifts?.stateColor3(),
              ),
              _cell('', listStyle),
              _cell('', listStyle),
              _cell('', listStyle),
              _cell('', listStyle),
              _cell('', listStyle),
              _cell('', listStyle),
            ],
          ));
        }
      }
      //各時間の合計
      List<pw.TableRow> _totalRow = [];
      _totalRow.add(pw.TableRow(
        decoration: pw.BoxDecoration(color: PdfColors.grey300),
        children: [
          _cell('合計', listStyle),
          _cell('', listStyle),
          _cell('', listStyle),
          _cell('', listStyle),
          _cell('', listStyle),
          _cell(workTimes, listStyle),
          _cell(overTimes1, listStyle),
          _cell(overTimes2, listStyle),
        ],
      ));
      //ページ作成
      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildHeader(
              month: dateText('yyyy年MM月', month),
              user: '${_user.name} (${_user.number})【$positionName】',
              style: headStyle,
            ),
            pw.SizedBox(height: 4.0),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey),
              children: _row,
            ),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey),
              children: _totalRow,
            ),
            pw.SizedBox(height: 4.0),
            _buildRemarks2(style: listStyle),
          ],
        ),
      ));
    }
  } else {
    if (user == null) return;
    String positionName = '';
    for (PositionModel _position in positions) {
      List<String> _userIds = _position.userIds;
      if (_userIds.contains(user.id)) {
        positionName = _position.name;
        break;
      }
    }
    List<WorkModel> works = await workProvider.selectList(
      group: group,
      user: user,
      startAt: days.first,
      endAt: days.last,
    );
    List<WorkShiftModel> workShifts = await workShiftProvider.selectList(
      group: group,
      user: user,
      startAt: days.first,
      endAt: days.last,
    );
    //合計値初期化
    Map cnt = {};
    String workTimes = '00:00';
    String overTimes1 = '00:00';
    String overTimes2 = '00:00';
    //一行目
    List<pw.TableRow> _row = [];
    _row.add(pw.TableRow(
      decoration: pw.BoxDecoration(color: PdfColors.grey300),
      children: [
        _cell('日付', listStyle),
        _cell('勤務状況', listStyle),
        _cell('出勤時間', listStyle),
        _cell('退勤時間', listStyle),
        _cell('休憩時間', listStyle),
        _cell('勤務時間', listStyle),
        _cell('時間外1', listStyle),
        _cell('時間外2', listStyle),
      ],
    ));
    //二行目以降
    for (DateTime _day in days) {
      List<WorkModel> _dayInWorks = [];
      for (WorkModel _work in works) {
        String _key = dateText('yyyy-MM-dd', _work.startedAt);
        if (_day == DateTime.parse(_key)) _dayInWorks.add(_work);
      }
      WorkShiftModel? _dayInWorkShifts;
      for (WorkShiftModel _workShift in workShifts) {
        String _key = dateText('yyyy-MM-dd', _workShift.startedAt);
        if (_day == DateTime.parse(_key)) _dayInWorkShifts = _workShift;
      }
      String day = dateText('dd (E)', _day);
      if (_dayInWorks.length > 0) {
        for (WorkModel _work in _dayInWorks) {
          if (_work.startedAt != _work.endedAt) {
            String state = _work.state;
            String startTime = _work.startTime(group);
            String endTime = _work.endTime(group);
            String breakTime = _work.breakTimes(group).first;
            String workTime = '00:00';
            String overTime1 = '00:00';
            String overTime2 = '00:00';
            switch (positionName) {
              case 'Aグループ':
                workTime = _work.calTimes02(group, 'A')[0];
                overTime1 = _work.calTimes02(group, 'A')[1];
                overTime2 = _work.calTimes02(group, 'A')[2];
                break;
              case 'Bグループ':
                workTime = _work.calTimes02(group, 'B')[0];
                overTime1 = _work.calTimes02(group, 'B')[1];
                overTime2 = _work.calTimes02(group, 'B')[2];
                break;
              case 'Cグループ':
                workTime = _work.calTimes02(group, 'C')[0];
                overTime1 = _work.calTimes02(group, 'C')[1];
                overTime2 = _work.calTimes02(group, 'C')[2];
                break;
              case 'Dグループ':
                workTime = _work.calTimes02(group, 'D')[0];
                overTime1 = _work.calTimes02(group, 'D')[1];
                overTime2 = _work.calTimes02(group, 'D')[2];
                break;
              default:
                workTime = _work.calTimes02(group, 'A')[0];
                overTime1 = _work.calTimes02(group, 'A')[1];
                overTime2 = _work.calTimes02(group, 'A')[2];
                break;
            }
            String _key = dateText('yyyy-MM-dd', _work.startedAt);
            cnt[_key] = '';
            workTimes = addTime(workTimes, workTime);
            overTimes1 = addTime(overTimes1, overTime1);
            overTimes2 = addTime(overTimes2, overTime2);
            _row.add(pw.TableRow(
              children: [
                _cell(day, listStyle),
                _cell(state, listStyle),
                _cell(startTime, listStyle),
                _cell(endTime, listStyle),
                _cell(breakTime, listStyle),
                _cell(workTime, listStyle),
                _cell(overTime1, listStyle),
                _cell(overTime2, listStyle),
              ],
            ));
          }
        }
      } else {
        _row.add(pw.TableRow(
          children: [
            _cell(day, listStyle),
            _cell(
              _dayInWorkShifts?.state ?? '',
              listStyle,
              color: _dayInWorkShifts?.stateColor3(),
            ),
            _cell('', listStyle),
            _cell('', listStyle),
            _cell('', listStyle),
            _cell('', listStyle),
            _cell('', listStyle),
            _cell('', listStyle),
          ],
        ));
      }
    }
    //各時間の合計
    List<pw.TableRow> _totalRow = [];
    _totalRow.add(pw.TableRow(
      decoration: pw.BoxDecoration(color: PdfColors.grey300),
      children: [
        _cell('合計', listStyle),
        _cell('', listStyle),
        _cell('', listStyle),
        _cell('', listStyle),
        _cell('', listStyle),
        _cell(workTimes, listStyle),
        _cell(overTimes1, listStyle),
        _cell(overTimes2, listStyle),
      ],
    ));
    //ページ作成
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildHeader(
            month: dateText('yyyy年MM月', month),
            user: '${user.name} (${user.number})【$positionName】',
            style: headStyle,
          ),
          pw.SizedBox(height: 4.0),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey),
            children: _row,
          ),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey),
            children: _totalRow,
          ),
          pw.SizedBox(height: 4.0),
          _buildRemarks2(style: listStyle),
        ],
      ),
    ));
  }
  await _dl(pdf: pdf, fileName: 'works.pdf');
  return;
}

Future _dl({
  required pw.Document pdf,
  required String fileName,
}) async {
  final bytes = await pdf.save();
  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.document.createElement('a') as html.AnchorElement
    ..href = url
    ..download = fileName;
  html.document.body?.children.add(anchor);
  anchor.click();
  html.document.body?.children.remove(anchor);
  html.Url.revokeObjectUrl(url);
}

pw.Widget _cell(
  String? label,
  pw.TextStyle? style, {
  PdfColor? color,
}) {
  return pw.Container(
    padding: pw.EdgeInsets.all(4.0),
    color: color,
    child: pw.Text(label ?? '', style: style),
  );
}

pw.Widget _buildHeader({
  String? month,
  String? user,
  pw.TextStyle? style,
}) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(month ?? '', style: style),
      pw.Text(user ?? '', style: style),
    ],
  );
}

pw.Widget _buildRemarks({pw.TextStyle? style}) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        '※1・・・深夜時間帯外の勤務時間です。8時間を超えていた場合は、超えた分を切り捨てる。',
        style: style,
      ),
      pw.Text(
        '※2・・・深夜時間帯の勤務時間です。深夜時間外の分も引いた時間です。',
        style: style,
      ),
      pw.Text(
        '※3・・・深夜時間帯外で8時間を超えた時間です。',
        style: style,
      ),
      pw.Text(
        '※4・・・深夜時間帯で8時間を超えた時間です。',
        style: style,
      ),
      pw.Text(
        '※5・・・日〜土曜日までの総勤務時間です。',
        style: style,
      ),
    ],
  );
}

pw.Widget _buildRemarks2({pw.TextStyle? style}) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        '※Aグループ・・・9時以前は「勤務時間」に該当させない。17時以降は「時間外1」に該当させる。休日出勤の場合は全ての時間を「時間外2」に該当させる。',
        style: style,
      ),
      pw.Text(
        '※Bグループ・・・9時以前は「勤務時間」に該当させない。18時以降は「時間外2」に該当させる。休日出勤の場合は全ての時間を「時間外2」に該当させる。',
        style: style,
      ),
      pw.Text(
        '※C/Dグループ・・・勤務時間が8時間を超えた分の時間を「時間外2」に該当させる。休日出勤の場合は全ての時間を「時間外2」に該当させる。',
        style: style,
      ),
      pw.Text(
        '※この勤務時間は時間外分を引いています。',
        style: style,
      ),
    ],
  );
}
