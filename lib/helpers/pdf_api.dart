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

Future<void> workPdf({
  WorkProvider workProvider,
  WorkStateProvider workStateProvider,
  GroupModel group,
  DateTime month,
  UserModel user,
}) async {
  if (user == null) return;
  List<DateTime> days = [];
  List<WorkModel> works = [];
  days.clear();
  var _dateMap = DateMachineUtil.getMonthDate(month, 0);
  DateTime _startAt = DateTime.parse('${_dateMap['start']}');
  DateTime _endAt = DateTime.parse('${_dateMap['end']}');
  for (int i = 0; i <= _endAt.difference(_startAt).inDays; i++) {
    days.add(_startAt.add(Duration(days: i)));
  }
  await workProvider
      .selectList(
    groupId: group.id,
    userId: user.id,
    startAt: days.first,
    endAt: days.last,
  )
      .then((value) {
    works = value;
  });
  List<WorkStateModel> workStates = [];
  await workStateProvider
      .selectList(
    groupId: group.id,
    userId: user.id,
    startAt: days.first,
    endAt: days.last,
  )
      .then((value) {
    workStates = value;
  });

  final pdf = pw.Document();
  final font = await rootBundle.load('assets/fonts/GenShinGothic-Regular.ttf');
  final ttf = pw.Font.ttf(font);

  final pw.TextStyle _headerStyle = pw.TextStyle(font: ttf, fontSize: 10.0);
  final pw.TextStyle _listStyle = pw.TextStyle(font: ttf, fontSize: 8.0);

  Map _count = {};
  String _totalWorkTime = '00:00';
  String _totalLegalTime = '00:00';
  String _totalNonLegalTime = '00:00';
  String _totalNightTime = '00:00';

  List<pw.TableRow> _buildRows() {
    List<pw.TableRow> _result = [];
    _result.add(
      pw.TableRow(
        decoration: pw.BoxDecoration(color: PdfColors.grey),
        children: [
          pw.Padding(
            padding: pw.EdgeInsets.all(5.0),
            child: pw.Text('日付', style: _listStyle),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.all(5.0),
            child: pw.Text('勤務状況', style: _listStyle),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.all(5.0),
            child: pw.Text('出勤時間', style: _listStyle),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.all(5.0),
            child: pw.Text('退勤時間', style: _listStyle),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.all(5.0),
            child: pw.Text('休憩時間', style: _listStyle),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.all(5.0),
            child: pw.Text('勤務時間', style: _listStyle),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.all(5.0),
            child: pw.Text('法定内時間', style: _listStyle),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.all(5.0),
            child: pw.Text('法定外時間', style: _listStyle),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.all(5.0),
            child: pw.Text('深夜時間', style: _listStyle),
          ),
        ],
      ),
    );
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
          String _legalTime = '---:---';
          String _nonLegalTime = '---:---';
          String _nightTime = '---:---';
          if (dayWorks[j].startedAt != dayWorks[j].endedAt) {
            _endTime = dayWorks[j].endTime(group);
            _breakTime = dayWorks[j].breakTime(group);
            _workTime = dayWorks[j].workTime(group);
            List<String> _legalList = legalList(
              workTime: dayWorks[j].workTime(group),
              legal: group.legal,
            );
            _legalTime = _legalList.first;
            _nonLegalTime = _legalList.last;
            List<String> _nightList = nightList(
              startedAt: dayWorks[j].startedAt,
              endedAt: dayWorks[j].endedAt,
              nightStart: group.nightStart,
              nightEnd: group.nightEnd,
            );
            _nightTime = _nightList.last;
            _count['${DateFormat('yyyy-MM-dd').format(dayWorks[j].startedAt)}'] =
                '';
            _totalWorkTime =
                addTime(_totalWorkTime, dayWorks[j].workTime(group));
            _totalLegalTime = addTime(_totalLegalTime, _legalList.first);
            _totalNonLegalTime = addTime(_totalNonLegalTime, _legalList.last);
            _totalNightTime = addTime(_totalNightTime, _nightList.last);
          }
          _result.add(
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: pw.EdgeInsets.all(5.0),
                  child: pw.Text(
                    _dayText,
                    style: _listStyle,
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(5.0),
                  child: pw.Text('${dayWorks[j].state}', style: _listStyle),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(5.0),
                  child: pw.Text(_startTime, style: _listStyle),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(5.0),
                  child: pw.Text(_endTime, style: _listStyle),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(5.0),
                  child: pw.Text(_breakTime, style: _listStyle),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(5.0),
                  child: pw.Text(_workTime, style: _listStyle),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(5.0),
                  child: pw.Text(_legalTime, style: _listStyle),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(5.0),
                  child: pw.Text(_nonLegalTime, style: _listStyle),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(5.0),
                  child: pw.Text(_nightTime, style: _listStyle),
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
                padding: pw.EdgeInsets.all(5.0),
                child: pw.Text(
                  _dayText,
                  style: _listStyle,
                ),
              ),
              dayWorkState == null
                  ? pw.Padding(
                      padding: pw.EdgeInsets.all(5.0),
                      child: pw.Text('', style: _listStyle),
                    )
                  : pw.Container(
                      padding: pw.EdgeInsets.all(5.0),
                      color: _stateColor,
                      child: pw.Text(dayWorkState?.state, style: _listStyle),
                    ),
              pw.Padding(
                padding: pw.EdgeInsets.all(5.0),
                child: pw.Text('', style: _listStyle),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(5.0),
                child: pw.Text('', style: _listStyle),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(5.0),
                child: pw.Text('', style: _listStyle),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(5.0),
                child: pw.Text('', style: _listStyle),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(5.0),
                child: pw.Text('', style: _listStyle),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(5.0),
                child: pw.Text('', style: _listStyle),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(5.0),
                child: pw.Text('', style: _listStyle),
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
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                '${DateFormat('yyyy年MM月').format(month)}',
                style: _headerStyle,
              ),
              pw.Text('${user.name}', style: _headerStyle),
            ],
          ),
          pw.SizedBox(height: 4.0),
          pw.Table(
            children: _buildRows(),
          ),
          pw.SizedBox(height: 4.0),
          pw.Table(
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey),
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.all(5.0),
                    child:
                        pw.Text('総勤務日数 [${_count.length}日]', style: _listStyle),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(5.0),
                    child:
                        pw.Text('総勤務時間 [$_totalWorkTime]', style: _listStyle),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(5.0),
                    child:
                        pw.Text('総法定内時間 [$_totalLegalTime]', style: _listStyle),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(5.0),
                    child: pw.Text('総法定外時間 [$_totalNonLegalTime]',
                        style: _listStyle),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(5.0),
                    child:
                        pw.Text('総深夜時間 [$_totalNightTime]', style: _listStyle),
                  ),
                ],
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
  html.window.open(url, '_blank');
  html.Url.revokeObjectUrl(url);
  return;
}

Future<void> qrPdf({GroupModel group}) async {
  final pdf = pw.Document();
  final font = await rootBundle.load('assets/fonts/GenShinGothic-Regular.ttf');
  final ttf = pw.Font.ttf(font);
  pdf.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4,
    build: (context) {
      return pw.Column(
        children: [
          pw.Center(
            child: pw.Text(
              '${group.name}',
              style: pw.TextStyle(font: ttf, fontSize: 18.0),
            ),
          ),
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
                'これは${group.name}の会社/組織IDが埋め込まれたQRコードです。別アプリ「はたらくじかん for スマートフォン」でこのQRコードを使用します。',
                style: pw.TextStyle(font: ttf, fontSize: 12.0),
              ),
              pw.Text(
                '別アプリ「はたらくじかん for スマートフォン」でこのQRコードを使用します。',
                style: pw.TextStyle(font: ttf, fontSize: 12.0),
              ),
              pw.SizedBox(height: 8.0),
              pw.Text(
                '【会社/組織に入る時】',
                style: pw.TextStyle(font: ttf, fontSize: 12.0),
              ),
              pw.Text(
                '① 「はたらくじかん for スマートフォン」を起動し、ログインしておく',
                style: pw.TextStyle(font: ttf, fontSize: 12.0),
              ),
              pw.Text(
                '② 下部メニューから「会社/組織」をタップする',
                style: pw.TextStyle(font: ttf, fontSize: 12.0),
              ),
              pw.Text(
                '③ 下部メニューの上の「会社/組織に入る(QRコード)」ボタンをタップする',
                style: pw.TextStyle(font: ttf, fontSize: 12.0),
              ),
              pw.Text(
                '④ カメラが起動するので、枠内にこのQRコードをおさめるように撮る',
                style: pw.TextStyle(font: ttf, fontSize: 12.0),
              ),
              pw.SizedBox(height: 8.0),
              group.qrSecurity
                  ? pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '【出退勤や休憩時間を記録する時】',
                          style: pw.TextStyle(font: ttf, fontSize: 12.0),
                        ),
                        pw.Text(
                          '① 「はたらくじかん for スマートフォン」を起動し、ログインしておく',
                          style: pw.TextStyle(font: ttf, fontSize: 12.0),
                        ),
                        pw.Text(
                          '② 下部メニューが「ホーム」になっているのを確認する',
                          style: pw.TextStyle(font: ttf, fontSize: 12.0),
                        ),
                        pw.Text(
                          '③ 「出勤」「退勤」「休憩開始」「休憩終了」のそれぞれボタンをタップした時にカメラが起動する',
                          style: pw.TextStyle(font: ttf, fontSize: 12.0),
                        ),
                        pw.Text(
                          '④ 枠内にこのQRコードをおさめるように撮る',
                          style: pw.TextStyle(font: ttf, fontSize: 12.0),
                        ),
                      ],
                    )
                  : pw.Container(),
            ],
          ),
        ],
      );
    },
  ));
  final bytes = await pdf.save();
  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.window.open(url, '_blank');
  html.Url.revokeObjectUrl(url);
  return;
}
