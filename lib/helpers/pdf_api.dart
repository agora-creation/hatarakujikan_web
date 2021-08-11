import 'package:flutter/services.dart';
import 'package:hatarakujikan_web/helpers/date_machine_util.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/models/work.dart';
import 'package:hatarakujikan_web/models/work_state.dart';
import 'package:hatarakujikan_web/providers/work.dart';
import 'package:hatarakujikan_web/providers/work_state.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_html/html.dart' as html;

const String fontPath = 'assets/fonts/GenShinGothic-Regular.ttf';

class PdfApi {
  static Future<void> qrcode({GroupModel group}) async {
    final font = await rootBundle.load(fontPath);
    final ttf = pw.Font.ttf(font);
    final _titleStyle = pw.TextStyle(font: ttf, fontSize: 18.0);
    final _contentStyle = pw.TextStyle(font: ttf, fontSize: 12.0);
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Column(
          children: [
            pw.Center(child: pw.Text('${group.name}', style: _titleStyle)),
            pw.SizedBox(height: 16.0),
            pw.Container(
              width: 250.0,
              height: 250.0,
              child: pw.BarcodeWidget(
                barcode: pw.Barcode.qrCode(),
                data: '${group.id}',
              ),
            ),
            pw.SizedBox(height: 16.0),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'このQRコードには、${group.name}の会社/組織IDが埋め込まれています。スマートフォンアプリ「はたらくじかん for スマートフォン」で使用します。',
                  style: _contentStyle,
                ),
                pw.SizedBox(height: 8.0),
                pw.Text(
                  '【会社/組織に入る時】',
                  style: _contentStyle,
                ),
                pw.Text(
                  '① 「はたらくじかん for スマートフォン」を起動し、ログインする。',
                  style: _contentStyle,
                ),
                pw.Text(
                  '② 下部メニューから「会社/組織」をタップする。',
                  style: _contentStyle,
                ),
                pw.Text(
                  '③ 下部メニューの上の「会社/組織に入る」ボタンをタップする。',
                  style: _contentStyle,
                ),
                pw.Text(
                  '④ アプリ内カメラが起動するので、枠内にQRコードをおさめるように撮る。',
                  style: _contentStyle,
                ),
                pw.SizedBox(height: 8.0),
                pw.Text(
                  '【出退勤や休憩の時間を記録する時】',
                  style: _contentStyle,
                ),
                pw.Text(
                  '① 「はたらくじかん for スマートフォン」を起動し、ログインする。',
                  style: _contentStyle,
                ),
                pw.Text(
                  '② 下部メニューから「ホーム」をタップする。',
                  style: _contentStyle,
                ),
                pw.Text(
                  '③ 「出勤」「退勤」「休憩開始」「休憩終了」ボタンをタップする。',
                  style: _contentStyle,
                ),
                pw.Text(
                  '④ アプリ内カメラが起動するので、枠内にQRコードをおさめるように撮る。',
                  style: _contentStyle,
                ),
              ],
            ),
          ],
        );
      },
    ));
    await _download(pdf: pdf, fileName: 'work.pdf');
    return;
  }
}

Future<void> pdfWorks({
  WorkProvider workProvider,
  WorkStateProvider workStateProvider,
  GroupModel group,
  DateTime searchMonth,
  UserModel searchUser,
  bool isAll,
}) async {
  // フォント
  final font = await rootBundle.load('assets/fonts/GenShinGothic-Regular.ttf');
  final ttf = pw.Font.ttf(font);
  if (searchUser == null) return;
  // 各種配列初期化
  List<DateTime> days = [];
  List<DateTime> daysWeek = [];
  List<WorkModel> works = [];
  List<WorkModel> worksWeek = [];
  List<WorkStateModel> workStates = [];
  days.clear();
  var _dateMap = DateMachineUtil.getMonthDate(searchMonth, 0);
  DateTime _startAt = DateTime.parse('${_dateMap['start']}');
  DateTime _endAt = DateTime.parse('${_dateMap['end']}');
  for (int i = 0; i <= _endAt.difference(_startAt).inDays; i++) {
    days.add(_startAt.add(Duration(days: i)));
  }
  daysWeek.clear();
  DateTime _startAtWeek = _startAt.add(Duration(days: 7) * -1);
  DateTime _endAtWeek = _endAt.add(Duration(days: 7));
  for (int i = 0; i <= _endAtWeek.difference(_startAtWeek).inDays; i++) {
    daysWeek.add(_startAtWeek.add(Duration(days: i)));
  }
  await workProvider
      .selectList(
    groupId: group.id,
    userId: searchUser.id,
    startAt: days.first,
    endAt: days.last,
  )
      .then((value) {
    works = value;
  });
  await workProvider
      .selectList(
    groupId: group.id,
    userId: searchUser.id,
    startAt: daysWeek.first,
    endAt: daysWeek.last,
  )
      .then((value) {
    worksWeek = value;
  });
  await workStateProvider
      .selectList(
    groupId: group.id,
    userId: searchUser.id,
    startAt: days.first,
    endAt: days.last,
  )
      .then((value) {
    workStates = value;
  });

  final pw.TextStyle _headerStyle = pw.TextStyle(font: ttf, fontSize: 9.0);
  final pw.TextStyle _listStyle = pw.TextStyle(font: ttf, fontSize: 7.0);
  // 書き出し
  final pdf = pw.Document();

  Map _count = {};
  String _totalWorkTime = '00:00';
  String _totalDayTime = '00:00';
  String _totalNightTime = '00:00';
  String _totalDayTimeOver = '00:00';
  String _totalNightTimeOver = '00:00';
  Map _weeks = {};

  List<pw.TableRow> _buildRows() {
    List<pw.TableRow> _result = [];
    _result.add(
      pw.TableRow(
        decoration: pw.BoxDecoration(color: PdfColors.grey300),
        children: [
          pw.Padding(
            padding: pw.EdgeInsets.all(4.0),
            child: pw.Text('日付', style: _listStyle),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.all(4.0),
            child: pw.Text('勤務状況', style: _listStyle),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.all(4.0),
            child: pw.Text('出勤時間', style: _listStyle),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.all(4.0),
            child: pw.Text('退勤時間', style: _listStyle),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.all(4.0),
            child: pw.Text('休憩時間', style: _listStyle),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.all(4.0),
            child: pw.Text('勤務時間', style: _listStyle),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.all(4.0),
            child: pw.Text('通常時間※1', style: _listStyle),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.all(4.0),
            child: pw.Text('深夜時間※2', style: _listStyle),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.all(4.0),
            child: pw.Text('通常時間外※3', style: _listStyle),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.all(4.0),
            child: pw.Text('深夜時間外※4', style: _listStyle),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.all(4.0),
            child: pw.Text('週間合計※5', style: _listStyle),
          ),
        ],
      ),
    );

    String _workTimeTmp = '00:00';
    for (int i = 0; i < daysWeek.length; i++) {
      List<WorkModel> dayWeekWorks = [];
      for (WorkModel _workWeek in worksWeek) {
        String _startedAt =
            '${DateFormat('yyyy-MM-dd').format(_workWeek.startedAt)}';
        if (daysWeek[i] == DateTime.parse(_startedAt)) {
          dayWeekWorks.add(_workWeek);
        }
      }
      String _weekText = '${DateFormat('E', 'ja').format(daysWeek[i])}';
      if (_weekText == '日') {
        _workTimeTmp = '00:00';
      }
      if (dayWeekWorks.length > 0) {
        for (int j = 0; j < dayWeekWorks.length; j++) {
          if (dayWeekWorks[j].startedAt != dayWeekWorks[j].endedAt) {
            _workTimeTmp = addTime(
              _workTimeTmp,
              dayWeekWorks[j].workTime(group),
            );
          }
        }
      }
      if (_weekText == '土') {
        _weeks['${DateFormat('yyyy-MM-dd').format(daysWeek[i])}'] =
            _workTimeTmp;
      }
    }
    for (int i = 0; i < days.length; i++) {
      List<WorkModel> dayWorks = [];
      for (WorkModel _work in works) {
        String _startedAt =
            '${DateFormat('yyyy-MM-dd').format(_work.startedAt)}';
        if (days[i] == DateTime.parse(_startedAt)) {
          dayWorks.add(_work);
        }
      }
      WorkStateModel dayWorkState;
      for (WorkStateModel _workState in workStates) {
        String _startedAt =
            '${DateFormat('yyyy-MM-dd').format(_workState.startedAt)}';
        if (days[i] == DateTime.parse(_startedAt)) {
          dayWorkState = _workState;
        }
      }
      String _dayText = '${DateFormat('dd (E)', 'ja').format(days[i])}';
      if (dayWorks.length > 0) {
        for (int j = 0; j < dayWorks.length; j++) {
          String _startTime = dayWorks[j].startTime(group);
          String _endTime = '---:---';
          String _breakTime = '---:---';
          String _workTime = '---:---';
          String _dayTime = '---:---';
          String _nightTime = '---:---';
          String _dayTimeOver = '---:---';
          String _nightTimeOver = '---:---';
          if (dayWorks[j].startedAt != dayWorks[j].endedAt) {
            _endTime = dayWorks[j].endTime(group);
            _breakTime = dayWorks[j].breakTime(group)[0];
            _workTime = dayWorks[j].workTime(group);
            List<String> _calTimes = dayWorks[j].calTime01(group);
            _dayTime = _calTimes[0];
            _nightTime = _calTimes[1];
            _dayTimeOver = _calTimes[2];
            _nightTimeOver = _calTimes[3];
            _count['${DateFormat('yyyy-MM-dd').format(dayWorks[j].startedAt)}'] =
                '';
            _totalWorkTime = addTime(
              _totalWorkTime,
              dayWorks[j].workTime(group),
            );
            _totalDayTime = addTime(_totalDayTime, _dayTime);
            _totalNightTime = addTime(_totalNightTime, _nightTime);
            _totalDayTimeOver = addTime(_totalDayTimeOver, _dayTimeOver);
            _totalNightTimeOver = addTime(_totalNightTimeOver, _nightTimeOver);
          }
          _result.add(
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: pw.EdgeInsets.all(4.0),
                  child: pw.Text(
                    _dayText,
                    style: _listStyle,
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(4.0),
                  child: pw.Text('${dayWorks[j].state}', style: _listStyle),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(4.0),
                  child: pw.Text(_startTime, style: _listStyle),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(4.0),
                  child: pw.Text(_endTime, style: _listStyle),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(4.0),
                  child: pw.Text(_breakTime, style: _listStyle),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(4.0),
                  child: pw.Text(_workTime, style: _listStyle),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(4.0),
                  child: pw.Text(_dayTime, style: _listStyle),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(4.0),
                  child: pw.Text(_nightTime, style: _listStyle),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(4.0),
                  child: pw.Text(_dayTimeOver, style: _listStyle),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(4.0),
                  child: pw.Text(_nightTimeOver, style: _listStyle),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(4.0),
                  child: pw.Text(
                    _weeks['${DateFormat('yyyy-MM-dd').format(days[i])}'],
                    style: _listStyle,
                  ),
                ),
              ],
            ),
          );
        }
      } else {
        PdfColor _stateColor = PdfColors.white;
        if (dayWorkState?.state == '欠勤') {
          _stateColor = PdfColors.red100;
        } else if (dayWorkState?.state == '特別休暇') {
          _stateColor = PdfColors.green100;
        } else if (dayWorkState?.state == '有給休暇') {
          _stateColor = PdfColors.teal100;
        }
        _result.add(
          pw.TableRow(
            children: [
              pw.Padding(
                padding: pw.EdgeInsets.all(4.0),
                child: pw.Text(
                  _dayText,
                  style: _listStyle,
                ),
              ),
              dayWorkState == null
                  ? pw.Padding(
                      padding: pw.EdgeInsets.all(4.0),
                      child: pw.Text('', style: _listStyle),
                    )
                  : pw.Container(
                      padding: pw.EdgeInsets.all(4.0),
                      color: _stateColor,
                      child: pw.Text(dayWorkState?.state, style: _listStyle),
                    ),
              pw.Padding(
                padding: pw.EdgeInsets.all(4.0),
                child: pw.Text('', style: _listStyle),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(4.0),
                child: pw.Text('', style: _listStyle),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(4.0),
                child: pw.Text('', style: _listStyle),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(4.0),
                child: pw.Text('', style: _listStyle),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(4.0),
                child: pw.Text('', style: _listStyle),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(4.0),
                child: pw.Text('', style: _listStyle),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(4.0),
                child: pw.Text('', style: _listStyle),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(4.0),
                child: pw.Text('', style: _listStyle),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(4.0),
                child: pw.Text(
                  _weeks['${DateFormat('yyyy-MM-dd').format(days[i])}'],
                  style: _listStyle,
                ),
              ),
            ],
          ),
        );
      }
    }
    return _result;
  }

  pdf.addPage(
    pw.Page(
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                '${DateFormat('yyyy年MM月').format(searchMonth)}',
                style: _headerStyle,
              ),
              pw.Text(
                '${searchUser.name} (${searchUser.recordPassword})',
                style: _headerStyle,
              ),
            ],
          ),
          pw.SizedBox(height: 4.0),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey),
            children: _buildRows(),
          ),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.all(4.0),
                    child: pw.Text(
                      '総勤務日数 [${_count.length}日]',
                      style: _listStyle,
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(4.0),
                    child: pw.Text(
                      '総勤務時間 [$_totalWorkTime]',
                      style: _listStyle,
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(4.0),
                    child: pw.Text(
                      '総通常時間 [$_totalDayTime]',
                      style: _listStyle,
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(4.0),
                    child: pw.Text(
                      '総深夜時間 [$_totalNightTime]',
                      style: _listStyle,
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(4.0),
                    child: pw.Text(
                      '総通常時間外 [$_totalDayTimeOver]',
                      style: _listStyle,
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(4.0),
                    child: pw.Text(
                      '総深夜時間外 [$_totalNightTimeOver]',
                      style: _listStyle,
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 4.0),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '※1・・・深夜時間帯外の勤務時間です。',
                style: _listStyle,
              ),
              pw.Text(
                '※2・・・深夜時間帯の勤務時間です。深夜時間外の分も引いた時間です。',
                style: _listStyle,
              ),
              pw.Text(
                '※3・・・深夜時間帯外で法定時間を超えた時間です。',
                style: _listStyle,
              ),
              pw.Text(
                '※4・・・深夜時間帯で法定時間を超えた時間です。',
                style: _listStyle,
              ),
              pw.Text(
                '※5・・・日〜土曜日までの総勤務時間です。',
                style: _listStyle,
              ),
            ],
          ),
        ],
      ),
    ),
  );

  pdf.addPage(
    pw.Page(
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                '${DateFormat('yyyy年MM月').format(searchMonth)}',
                style: _headerStyle,
              ),
              pw.Text(
                '${DateFormat('yyyy年MM月').format(searchMonth)}',
                style: _headerStyle,
              ),
            ],
          ),
        ],
      ),
    ),
  );

  final bytes = await pdf.save();
  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.document.createElement('a') as html.AnchorElement
    ..href = url
    ..download = 'work.pdf';
  html.document.body.children.add(anchor);
  anchor.click();
  html.document.body.children.remove(anchor);
  html.Url.revokeObjectUrl(url);
  return;
}

Future<void> _download({pw.Document pdf, String fileName}) async {
  final bytes = await pdf.save();
  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.document.createElement('a') as html.AnchorElement
    ..href = url
    ..download = fileName;
  html.document.body.children.add(anchor);
  anchor.click();
  html.document.body.children.remove(anchor);
  html.Url.revokeObjectUrl(url);
}
