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
  // 会社/組織QRコードPDF作成
  static Future<void> qrcode({GroupModel group}) async {
    final pdf = pw.Document();
    final font = await rootBundle.load(fontPath);
    final ttf = pw.Font.ttf(font);
    final _titleStyle = pw.TextStyle(font: ttf, fontSize: 18.0);
    final _contentStyle = pw.TextStyle(font: ttf, fontSize: 12.0);

    // タイトル作成
    pw.Widget _buildTitle() {
      return pw.Center(child: pw.Text('${group.name}', style: _titleStyle));
    }

    // QRコード作成
    pw.Widget _buildQrcode() {
      return pw.Container(
        width: 250.0,
        height: 250.0,
        child: pw.BarcodeWidget(
          barcode: pw.Barcode.qrCode(),
          data: '${group.id}',
        ),
      );
    }

    // 説明文作成
    pw.Widget _buildDescription() {
      return pw.Column(
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
          pw.SizedBox(height: 16.0),
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
      );
    }

    // PDFページ作成
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Column(
        children: [
          _buildTitle(),
          pw.SizedBox(height: 16.0),
          _buildQrcode(),
          pw.SizedBox(height: 8.0),
          pw.Divider(),
          pw.SizedBox(height: 8.0),
          _buildDescription(),
        ],
      ),
    ));
    await _download(pdf: pdf, fileName: 'qrcode.pdf');
    return;
  }

  // 勤務状況PDF作成
  static Future<void> works01({
    WorkProvider workProvider,
    WorkStateProvider workStateProvider,
    GroupModel group,
    DateTime month,
    UserModel user,
    bool isAll,
    List<UserModel> users,
  }) async {
    final pdf = pw.Document();
    final font = await rootBundle.load(fontPath);
    final ttf = pw.Font.ttf(font);
    final _headStyle = pw.TextStyle(font: ttf, fontSize: 9.0);
    final _listStyle = pw.TextStyle(font: ttf, fontSize: 7.0);

    // 日付配列作成
    List<DateTime> days = generateDays(month);
    List<DateTime> daysW = [];
    DateTime _startW = days.first.add(Duration(days: 7) * -1);
    DateTime _endW = days.last.add(Duration(days: 7));
    for (int i = 0; i <= _endW.difference(_startW).inDays; i++) {
      daysW.add(_startW.add(Duration(days: i)));
    }

    // セル作成
    pw.Widget _cell({String label, PdfColor color}) {
      return pw.Container(
        padding: pw.EdgeInsets.all(4.0),
        color: color ?? null,
        child: pw.Text(label, style: _listStyle),
      );
    }

    // 説明文作成
    pw.Widget _buildDescription() {
      return pw.Column(
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
      );
    }

    // 全スタッフ一括出力フラグ
    if (isAll) {
      if (users == null) return;
      for (UserModel _user in users) {
        // 各種データ取得
        List<WorkModel> works = await workProvider.selectList(
          groupId: group.id,
          userId: _user.id,
          startAt: days.first,
          endAt: days.last,
        );
        List<WorkModel> worksW = await workProvider.selectList(
          groupId: group.id,
          userId: _user.id,
          startAt: daysW.first,
          endAt: daysW.last,
        );
        List<WorkStateModel> workStates = await workStateProvider.selectList(
          groupId: group.id,
          userId: _user.id,
          startAt: days.first,
          endAt: days.last,
        );
        // ヘッダー作成
        pw.Widget _buildHeader() {
          return pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                '${DateFormat('yyyy年MM月').format(month)}',
                style: _headStyle,
              ),
              pw.Text(
                '${_user.name} (${_user.recordPassword})',
                style: _headStyle,
              ),
            ],
          );
        }

        // 合計値初期化
        Map count = {};
        String workTimes = '00:00';
        String dayTimes = '00:00';
        String nightTimes = '00:00';
        String dayTimeOvers = '00:00';
        String nightTimeOvers = '00:00';
        Map countW = {};
        // 1ヶ月間の表を作成
        pw.Widget _buildDays() {
          List<pw.TableRow> _row = [];
          // 1行目
          _row.add(pw.TableRow(
            decoration: pw.BoxDecoration(color: PdfColors.grey300),
            children: [
              _cell(label: '日付'),
              _cell(label: '勤務状況'),
              _cell(label: '出勤時間'),
              _cell(label: '退勤時間'),
              _cell(label: '休憩時間'),
              _cell(label: '勤務時間'),
              _cell(label: '通常時間※1'),
              _cell(label: '深夜時間(-)※2'),
              _cell(label: '通常時間外※3'),
              _cell(label: '深夜時間外※4'),
              _cell(label: '週間合計※5'),
            ],
          ));
          // 週間合計
          String _tmp = '00:00';
          for (int i = 0; i < daysW.length; i++) {
            List<WorkModel> _dayWorksW = [];
            for (WorkModel _work in worksW) {
              String _start =
                  '${DateFormat('yyyy-MM-dd').format(_work.startedAt)}';
              if (daysW[i] == DateTime.parse(_start)) {
                _dayWorksW.add(_work);
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
              countW[_key] = _tmp;
            }
          }
          // 各種時間
          for (int i = 0; i < days.length; i++) {
            List<WorkModel> _dayWorks = [];
            for (WorkModel _work in works) {
              String _start =
                  '${DateFormat('yyyy-MM-dd').format(_work.startedAt)}';
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
                if (_dayWorks[j].startedAt != _dayWorks[j].endedAt) {
                  String _startTime = _dayWorks[j].startTime(group);
                  String _state = _dayWorks[j].state;
                  String _endTime = _dayWorks[j].endTime(group);
                  String _breakTime = _dayWorks[j].breakTimes(group)[0];
                  String _workTime = _dayWorks[j].workTime(group);
                  List<String> _calTimes = _dayWorks[j].calTimes01(group);
                  String _dayTime = _calTimes[0];
                  String _nightTime = _calTimes[1];
                  String _dayTimeOver = _calTimes[2];
                  String _nightTimeOver = _calTimes[3];
                  String _key =
                      '${DateFormat('yyyy-MM-dd').format(_dayWorks[j].startedAt)}';
                  count[_key] = '';
                  workTimes = addTime(workTimes, _workTime);
                  dayTimes = addTime(dayTimes, _dayTime);
                  nightTimes = addTime(nightTimes, _nightTime);
                  dayTimeOvers = addTime(dayTimeOvers, _dayTimeOver);
                  nightTimeOvers = addTime(nightTimeOvers, _nightTimeOver);
                  _row.add(pw.TableRow(
                    children: [
                      _cell(label: _day),
                      _cell(label: _state),
                      _cell(label: _startTime),
                      _cell(label: _endTime),
                      _cell(label: _breakTime),
                      _cell(label: _workTime),
                      _cell(label: _dayTime),
                      _cell(label: _nightTime),
                      _cell(label: _dayTimeOver),
                      _cell(label: _nightTimeOver),
                      _cell(
                          label: countW[
                                  '${DateFormat('yyyy-MM-dd').format(days[i])}'] ??
                              ''),
                    ],
                  ));
                }
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
                case '代休':
                  _stateColor = PdfColors.pink100;
                  break;
              }
              _row.add(pw.TableRow(
                children: [
                  _cell(label: _day),
                  _cell(label: _dayWorkState?.state ?? '', color: _stateColor),
                  _cell(label: ''),
                  _cell(label: ''),
                  _cell(label: ''),
                  _cell(label: ''),
                  _cell(label: ''),
                  _cell(label: ''),
                  _cell(label: ''),
                  _cell(label: ''),
                  _cell(
                      label: countW[
                              '${DateFormat('yyyy-MM-dd').format(days[i])}'] ??
                          ''),
                ],
              ));
            }
          }
          return pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey),
            children: _row,
          );
        }

        // 1ヶ月間の合計の表を作成
        pw.Widget _buildTotal() {
          List<pw.TableRow> _row = [];
          // 勤務日数
          int workDays = count.length;
          _row.add(pw.TableRow(
            decoration: pw.BoxDecoration(color: PdfColors.grey300),
            children: [
              _cell(label: '総勤務日数 [$workDays日]'),
              _cell(label: '総勤務時間 [$workTimes]'),
              _cell(label: '総通常時間 [$dayTimes]'),
              _cell(label: '総深夜時間(-) [$nightTimes]'),
              _cell(label: '総通常時間外 [$dayTimeOvers]'),
              _cell(label: '総深夜時間外 [$nightTimeOvers]'),
            ],
          ));
          return pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey),
            children: _row,
          );
        }

        // PDFページ作成
        pdf.addPage(pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              pw.SizedBox(height: 4.0),
              _buildDays(),
              _buildTotal(),
              pw.SizedBox(height: 4.0),
              _buildDescription(),
            ],
          ),
        ));
      }
    } else {
      if (user == null) return;
      // 各種データ取得
      List<WorkModel> works = await workProvider.selectList(
        groupId: group.id,
        userId: user.id,
        startAt: days.first,
        endAt: days.last,
      );
      List<WorkModel> worksW = await workProvider.selectList(
        groupId: group.id,
        userId: user.id,
        startAt: daysW.first,
        endAt: daysW.last,
      );
      List<WorkStateModel> workStates = await workStateProvider.selectList(
        groupId: group.id,
        userId: user.id,
        startAt: days.first,
        endAt: days.last,
      );
      // ヘッダー作成
      pw.Widget _buildHeader() {
        return pw.Row(
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
        );
      }

      // 合計値初期化
      Map count = {};
      String workTimes = '00:00';
      String dayTimes = '00:00';
      String nightTimes = '00:00';
      String dayTimeOvers = '00:00';
      String nightTimeOvers = '00:00';
      Map countW = {};
      // 1ヶ月間の表を作成
      pw.Widget _buildDays() {
        List<pw.TableRow> _row = [];
        // 1行目
        _row.add(pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _cell(label: '日付'),
            _cell(label: '勤務状況'),
            _cell(label: '出勤時間'),
            _cell(label: '退勤時間'),
            _cell(label: '休憩時間'),
            _cell(label: '勤務時間'),
            _cell(label: '通常時間※1'),
            _cell(label: '深夜時間(-)※2'),
            _cell(label: '通常時間外※3'),
            _cell(label: '深夜時間外※4'),
            _cell(label: '週間合計※5'),
          ],
        ));
        // 週間合計
        String _tmp = '00:00';
        for (int i = 0; i < daysW.length; i++) {
          List<WorkModel> _dayWorksW = [];
          for (WorkModel _work in worksW) {
            String _start =
                '${DateFormat('yyyy-MM-dd').format(_work.startedAt)}';
            if (daysW[i] == DateTime.parse(_start)) {
              _dayWorksW.add(_work);
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
            countW[_key] = _tmp;
          }
        }
        // 各種時間
        for (int i = 0; i < days.length; i++) {
          List<WorkModel> _dayWorks = [];
          for (WorkModel _work in works) {
            String _start =
                '${DateFormat('yyyy-MM-dd').format(_work.startedAt)}';
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
              if (_dayWorks[j].startedAt != _dayWorks[j].endedAt) {
                String _startTime = _dayWorks[j].startTime(group);
                String _state = _dayWorks[j].state;
                String _endTime = _dayWorks[j].endTime(group);
                String _breakTime = _dayWorks[j].breakTimes(group)[0];
                String _workTime = _dayWorks[j].workTime(group);
                List<String> _calTimes = _dayWorks[j].calTimes01(group);
                String _dayTime = _calTimes[0];
                String _nightTime = _calTimes[1];
                String _dayTimeOver = _calTimes[2];
                String _nightTimeOver = _calTimes[3];
                String _key =
                    '${DateFormat('yyyy-MM-dd').format(_dayWorks[j].startedAt)}';
                count[_key] = '';
                workTimes = addTime(workTimes, _workTime);
                dayTimes = addTime(dayTimes, _dayTime);
                nightTimes = addTime(nightTimes, _nightTime);
                dayTimeOvers = addTime(dayTimeOvers, _dayTimeOver);
                nightTimeOvers = addTime(nightTimeOvers, _nightTimeOver);
                _row.add(pw.TableRow(
                  children: [
                    _cell(label: _day),
                    _cell(label: _state),
                    _cell(label: _startTime),
                    _cell(label: _endTime),
                    _cell(label: _breakTime),
                    _cell(label: _workTime),
                    _cell(label: _dayTime),
                    _cell(label: _nightTime),
                    _cell(label: _dayTimeOver),
                    _cell(label: _nightTimeOver),
                    _cell(
                        label: countW[
                                '${DateFormat('yyyy-MM-dd').format(days[i])}'] ??
                            ''),
                  ],
                ));
              }
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
              case '代休':
                _stateColor = PdfColors.pink100;
                break;
            }
            _row.add(pw.TableRow(
              children: [
                _cell(label: _day),
                _cell(label: _dayWorkState?.state ?? '', color: _stateColor),
                _cell(label: ''),
                _cell(label: ''),
                _cell(label: ''),
                _cell(label: ''),
                _cell(label: ''),
                _cell(label: ''),
                _cell(label: ''),
                _cell(label: ''),
                _cell(
                    label:
                        countW['${DateFormat('yyyy-MM-dd').format(days[i])}'] ??
                            ''),
              ],
            ));
          }
        }
        return pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey),
          children: _row,
        );
      }

      // 1ヶ月間の合計の表を作成
      pw.Widget _buildTotal() {
        List<pw.TableRow> _row = [];
        // 勤務日数
        int workDays = count.length;
        _row.add(pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _cell(label: '総勤務日数 [$workDays日]'),
            _cell(label: '総勤務時間 [$workTimes]'),
            _cell(label: '総通常時間 [$dayTimes]'),
            _cell(label: '総深夜時間(-) [$nightTimes]'),
            _cell(label: '総通常時間外 [$dayTimeOvers]'),
            _cell(label: '総深夜時間外 [$nightTimeOvers]'),
          ],
        ));
        return pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey),
          children: _row,
        );
      }

      // PDFページ作成
      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            pw.SizedBox(height: 4.0),
            _buildDays(),
            _buildTotal(),
            pw.SizedBox(height: 4.0),
            _buildDescription(),
          ],
        ),
      ));
    }
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
