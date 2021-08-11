import 'package:flutter/services.dart';
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
      build: (context) => pw.Column(
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
      ),
    ));
    await _download(pdf: pdf, fileName: 'qr.pdf');
    return;
  }

  static Future<void> works01({
    WorkProvider workProvider,
    WorkStateProvider workStateProvider,
    GroupModel group,
    DateTime month,
    UserModel user,
  }) async {
    final font = await rootBundle.load(fontPath);
    final ttf = pw.Font.ttf(font);
    final _headStyle = pw.TextStyle(font: ttf, fontSize: 9.0);
    final _listStyle = pw.TextStyle(font: ttf, fontSize: 7.0);
    final pdf = pw.Document();

    List<DateTime> days = generateDays(month);
    List<DateTime> daysW = [];
    DateTime _startW = days.first.add(Duration(days: 7) * -1);
    DateTime _endW = days.last.add(Duration(days: 7));
    for (int i = 0; i <= _endW.difference(_startW).inDays; i++) {
      daysW.add(_startW.add(Duration(days: i)));
    }
    List<WorkModel> works = [];
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
    List<WorkModel> worksW = [];
    await workProvider
        .selectList(
      groupId: group.id,
      userId: user.id,
      startAt: daysW.first,
      endAt: daysW.last,
    )
        .then((value) {
      worksW = value;
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

    Map workDays = {};
    String workTimes = '00:00';
    String dayTimes = '00:00';
    String nightTimes = '00:00';
    String dayTimeOvers = '00:00';
    String nightTimeOvers = '00:00';
    Map workDaysW = {};

    pw.Widget _cell({String label, PdfColor color}) {
      return pw.Container(
        padding: pw.EdgeInsets.all(4.0),
        color: color ?? null,
        child: pw.Text(label, style: _listStyle),
      );
    }

    List<pw.TableRow> _buildDays() {
      List<pw.TableRow> _result = [];
      // 1列目
      _result.add(pw.TableRow(
        decoration: pw.BoxDecoration(color: PdfColors.grey300),
        children: [
          _cell(label: '日付'),
          _cell(label: '勤務状況'),
          _cell(label: '出勤時間'),
          _cell(label: '退勤時間'),
          _cell(label: '休憩時間'),
          _cell(label: '勤務時間'),
          _cell(label: '通常時間※1'),
          _cell(label: '深夜時間※2'),
          _cell(label: '通常時間外※3'),
          _cell(label: '深夜時間外※4'),
          _cell(label: '週間合計※5'),
        ],
      ));
      // 2列目以降
      // 週間合計
      String _tmp = '00:00';
      for (int i = 0; i < daysW.length; i++) {
        List<WorkModel> _dayWorksW = [];
        for (WorkModel _workW in worksW) {
          String _start =
              '${DateFormat('yyyy-MM-dd').format(_workW.startedAt)}';
          if (daysW[i] == DateTime.parse(_start)) {
            _dayWorksW.add(_workW);
          }
        }
        String _week = '${DateFormat('E', 'ja').format(daysW[i])}';
        if (_week == '日') {
          _tmp = '00:00';
        }
        if (_dayWorksW.length > 0) {
          for (int j = 0; j < _dayWorksW.length; j++) {
            if (_dayWorksW[j].startedAt != _dayWorksW[j].endedAt) {
              _tmp = addTime(_tmp, _dayWorksW[j].workTime(group));
            }
          }
        }
        if (_week == '土') {
          String _key = '${DateFormat('yyyy-MM-dd').format(daysW[i])}';
          workDaysW[_key] = _tmp;
        }
      }
      // 出勤時間など
      for (int i = 0; i < days.length; i++) {
        String _keyW = '${DateFormat('yyyy-MM-dd').format(days[i])}';
        List<WorkModel> _dayWorks = [];
        for (WorkModel _work in works) {
          String _start = '${DateFormat('yyyy-MM-dd').format(_work.startedAt)}';
          if (days[i] == DateTime.parse(_start)) {
            _dayWorks.add(_work);
          }
        }
        WorkStateModel _dayWorkState;
        for (WorkStateModel _workState in workStates) {
          String _start =
              '${DateFormat('yyyy-MM-dd').format(_workState.startedAt)}';
          if (days[i] == DateTime.parse(_start)) {
            _dayWorkState = _workState;
          }
        }
        String _day = '${DateFormat('dd (E)', 'ja').format(days[i])}';
        if (_dayWorks.length > 0) {
          for (int j = 0; j < _dayWorks.length; j++) {
            String _startTime = _dayWorks[j].startTime(group);
            String _state = '---';
            String _endTime = '---:---';
            String _breakTime = '---:---';
            String _workTime = '---:---';
            String _dayTime = '---:---';
            String _nightTime = '---:---';
            String _dayTimeOver = '---:---';
            String _nightTimeOver = '---:---';
            if (_dayWorks[j].startedAt != _dayWorks[j].endedAt) {
              _state = _dayWorks[j].state;
              _endTime = _dayWorks[j].endTime(group);
              _breakTime = _dayWorks[j].breakTime(group)[0];
              _workTime = _dayWorks[j].workTime(group);
              List<String> _calTimes = _dayWorks[j].calTime01(group);
              _dayTime = _calTimes[0];
              _nightTime = _calTimes[1];
              _dayTimeOver = _calTimes[2];
              _nightTimeOver = _calTimes[3];
              String _key =
                  '${DateFormat('yyyy-MM-dd').format(_dayWorks[j].startedAt)}';
              workDays[_key] = '';
              workTimes = addTime(workTimes, _workTime);
              dayTimes = addTime(dayTimes, _dayTime);
              nightTimes = addTime(nightTimes, _nightTime);
              dayTimeOvers = addTime(dayTimeOvers, _dayTimeOver);
              nightTimeOvers = addTime(nightTimeOvers, _nightTimeOver);
            }

            _result.add(pw.TableRow(
              children: [
                _cell(label: '$_day'),
                _cell(label: '$_state'),
                _cell(label: '$_startTime'),
                _cell(label: '$_endTime'),
                _cell(label: '$_breakTime'),
                _cell(label: '$_workTime'),
                _cell(label: '$_dayTime'),
                _cell(label: '$_nightTime'),
                _cell(label: '$_dayTimeOver'),
                _cell(label: '$_nightTimeOver'),
                _cell(label: '${workDaysW[_keyW]}'),
              ],
            ));
          }
        } else {
          PdfColor _stateColor = PdfColors.white;
          switch (_dayWorkState?.state) {
            case '欠勤':
              _stateColor = PdfColors.red100;
              break;
            case '特別休暇':
              _stateColor = PdfColors.green100;
              break;
            case '有給休暇':
              _stateColor = PdfColors.teal100;
              break;
            default:
              _stateColor = PdfColors.white;
              break;
          }
          _result.add(pw.TableRow(
            children: [
              _cell(label: '$_day'),
              _cell(label: '${_dayWorkState?.state ?? ''}', color: _stateColor),
              _cell(label: ''),
              _cell(label: ''),
              _cell(label: ''),
              _cell(label: ''),
              _cell(label: ''),
              _cell(label: ''),
              _cell(label: ''),
              _cell(label: ''),
              _cell(label: '${workDaysW[_keyW]}'),
            ],
          ));
        }
      }
      return _result;
    }

    List<pw.TableRow> _buildDaysTotal() {
      List<pw.TableRow> _result = [];
      _result.add(pw.TableRow(
        decoration: pw.BoxDecoration(color: PdfColors.grey300),
        children: [
          _cell(label: '総勤務日数 [${workDays.length}日]'),
          _cell(label: '総勤務時間 [$workTimes}]'),
          _cell(label: '総通常時間 [$dayTimes]'),
          _cell(label: '総深夜時間 [$nightTimes]'),
          _cell(label: '総通常時間外 [$dayTimeOvers]'),
          _cell(label: '総深夜時間外 [$nightTimeOvers]'),
        ],
      ));
      return _result;
    }

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                '${DateFormat('yyyy年MM月').format(month)}',
                style: _headStyle,
              ),
              pw.Text(
                '${user.name} (${user.recordPassword})',
                style: _headStyle,
              ),
            ],
          ),
          pw.SizedBox(height: 4.0),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey),
            children: _buildDays(),
          ),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey),
            children: _buildDaysTotal(),
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
    ));
    await _download(pdf: pdf, fileName: 'works.pdf');
    return;
  }
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
