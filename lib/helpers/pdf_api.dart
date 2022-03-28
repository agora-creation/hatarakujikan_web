import 'package:flutter/services.dart';
import 'package:hatarakujikan_web/helpers/define.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/position.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/models/work.dart';
import 'package:hatarakujikan_web/models/work_shift.dart';
import 'package:hatarakujikan_web/providers/position.dart';
import 'package:hatarakujikan_web/providers/work.dart';
import 'package:hatarakujikan_web/providers/work_shift.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_html/html.dart' as html;

const String fontPath = 'assets/fonts/GenShinGothic-Regular.ttf';

class PdfApi {
  // 会社/組織QRコードPDF作成
  static Future<void> qrcode({required GroupModel group}) async {
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

  static void groupCheck({required GroupModel group}) {
    String _id = group.id;
    switch (_id) {
      case 'UryZHGotsjyR0Zb6g06J':
        pdfTemplates.removeWhere((e) => e != 'ひろめカンパニー用レイアウト');
        return;
      case 'h74zqng5i59qHdMG16Cb':
        pdfTemplates.removeWhere((e) => e != '土佐税理士事務所用レイアウト');
        return;
      default:
        return;
    }
  }

  static Future<void> download({
    required PositionProvider positionProvider,
    required WorkProvider workProvider,
    required WorkShiftProvider workShiftProvider,
    required GroupModel group,
    required DateTime month,
    required UserModel user,
    required bool isAll,
    required List<UserModel> users,
    required String template,
  }) async {
    if (template == '') return;
    switch (template) {
      case 'ひろめカンパニー用レイアウト':
        await _works01(
          workProvider: workProvider,
          workShiftProvider: workShiftProvider,
          group: group,
          month: month,
          user: user,
          isAll: isAll,
          users: users,
        );
        return;
      case '土佐税理士事務所用レイアウト':
        await _works02(
          positionProvider: positionProvider,
          workProvider: workProvider,
          workShiftProvider: workShiftProvider,
          group: group,
          month: month,
          user: user,
          isAll: isAll,
          users: users,
        );
        return;
      default:
        return;
    }
  }
}

Future<void> _works01({
  required WorkProvider workProvider,
  required WorkShiftProvider workShiftProvider,
  required GroupModel group,
  required DateTime month,
  required UserModel user,
  required bool isAll,
  required List<UserModel> users,
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
  pw.Widget _cell(String label, PdfColor? color) {
    return pw.Container(
      padding: pw.EdgeInsets.all(4.0),
      color: color,
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
    if (users.length == 0) return;
    for (UserModel _user in users) {
      // 各種データ取得
      List<WorkModel> works = await workProvider.selectList(
        group: group,
        user: _user,
        startAt: days.first,
        endAt: days.last,
      );
      List<WorkModel> worksW = await workProvider.selectList(
        group: group,
        user: _user,
        startAt: daysW.first,
        endAt: daysW.last,
      );
      List<WorkShiftModel> workShifts = await workShiftProvider.selectList(
        group: group,
        user: _user,
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
              '${_user.name} (${_user.number})',
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
            _cell('日付', null),
            _cell('勤務状況', null),
            _cell('出勤時間', null),
            _cell('退勤時間', null),
            _cell('休憩時間', null),
            _cell('勤務時間', null),
            _cell('通常時間※1', null),
            _cell('深夜時間(-)※2', null),
            _cell('通常時間外※3', null),
            _cell('深夜時間外※4', null),
            _cell('週間合計※5', null),
          ],
        ));
        DateFormat _format = DateFormat('yyyy-MM-dd');
        // 週間合計
        String _tmp = '00:00';
        for (int i = 0; i < daysW.length; i++) {
          List<WorkModel> _dayWorksW = [];
          for (WorkModel _work in worksW) {
            String _start = '${_format.format(_work.startedAt)}';
            if (daysW[i] == DateTime.parse(_start)) {
              _dayWorksW.add(_work);
            }
          }
          String _week = dateText('E', daysW[i]);
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
            String _key = '${_format.format(daysW[i])}';
            countW[_key] = _tmp;
          }
        }
        // 各種時間
        for (int i = 0; i < days.length; i++) {
          List<WorkModel> _dayWorks = [];
          for (WorkModel _work in works) {
            String _start = '${_format.format(_work.startedAt)}';
            if (days[i] == DateTime.parse(_start)) {
              _dayWorks.add(_work);
            }
          }
          WorkShiftModel? _dayWorkShift;
          for (WorkShiftModel _workShift in workShifts) {
            String _start = '${_format.format(_workShift.startedAt)}';
            if (days[i] == DateTime.parse(_start)) {
              _dayWorkShift = _workShift;
            }
          }
          String _day = dateText('dd (E)', days[i]);
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
                String _key = '${_format.format(_dayWorks[j].startedAt)}';
                count[_key] = '';
                workTimes = addTime(workTimes, _workTime);
                dayTimes = addTime(dayTimes, _dayTime);
                nightTimes = addTime(nightTimes, _nightTime);
                dayTimeOvers = addTime(dayTimeOvers, _dayTimeOver);
                nightTimeOvers = addTime(nightTimeOvers, _nightTimeOver);
                _row.add(pw.TableRow(
                  children: [
                    _cell(_day, null),
                    _cell(_state, null),
                    _cell(_startTime, null),
                    _cell(_endTime, null),
                    _cell(_breakTime, null),
                    _cell(_workTime, null),
                    _cell(_dayTime, null),
                    _cell(_nightTime, null),
                    _cell(_dayTimeOver, null),
                    _cell(_nightTimeOver, null),
                    _cell(countW['${_format.format(days[i])}'] ?? '', null),
                  ],
                ));
              }
            }
          } else {
            _row.add(pw.TableRow(
              children: [
                _cell(_day, null),
                _cell(
                  _dayWorkShift?.state ?? '',
                  _dayWorkShift?.stateColor3(),
                ),
                _cell('', null),
                _cell('', null),
                _cell('', null),
                _cell('', null),
                _cell('', null),
                _cell('', null),
                _cell('', null),
                _cell('', null),
                _cell(countW['${_format.format(days[i])}'] ?? '', null),
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
            _cell('総勤務日数 [$workDays日]', null),
            _cell('総勤務時間 [$workTimes]', null),
            _cell('総通常時間 [$dayTimes]', null),
            _cell('総深夜時間(-) [$nightTimes]', null),
            _cell('総通常時間外 [$dayTimeOvers]', null),
            _cell('総深夜時間外 [$nightTimeOvers]', null),
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
    if (user.id == '') return;
    // 各種データ取得
    List<WorkModel> works = await workProvider.selectList(
      group: group,
      user: user,
      startAt: days.first,
      endAt: days.last,
    );
    List<WorkModel> worksW = await workProvider.selectList(
      group: group,
      user: user,
      startAt: daysW.first,
      endAt: daysW.last,
    );
    List<WorkShiftModel> workShifts = await workShiftProvider.selectList(
      group: group,
      user: user,
      startAt: days.first,
      endAt: days.last,
    );
    // ヘッダー作成
    pw.Widget _buildHeader() {
      return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            dateText('yyyy年MM月', month),
            style: _headStyle,
          ),
          pw.Text(
            '${user.name} (${user.number})',
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
          _cell('日付', null),
          _cell('勤務状況', null),
          _cell('出勤時間', null),
          _cell('退勤時間', null),
          _cell('休憩時間', null),
          _cell('勤務時間', null),
          _cell('通常時間※1', null),
          _cell('深夜時間(-)※2', null),
          _cell('通常時間外※3', null),
          _cell('深夜時間外※4', null),
          _cell('週間合計※5', null),
        ],
      ));
      DateFormat _format = DateFormat('yyyy-MM-dd');
      // 週間合計
      String _tmp = '00:00';
      for (int i = 0; i < daysW.length; i++) {
        List<WorkModel> _dayWorksW = [];
        for (WorkModel _work in worksW) {
          String _start = '${_format.format(_work.startedAt)}';
          if (daysW[i] == DateTime.parse(_start)) {
            _dayWorksW.add(_work);
          }
        }
        String _week = dateText('E', daysW[i]);
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
          String _key = '${_format.format(daysW[i])}';
          countW[_key] = _tmp;
        }
      }
      // 各種時間
      for (int i = 0; i < days.length; i++) {
        List<WorkModel> _dayWorks = [];
        for (WorkModel _work in works) {
          String _start = '${_format.format(_work.startedAt)}';
          if (days[i] == DateTime.parse(_start)) {
            _dayWorks.add(_work);
          }
        }
        WorkShiftModel? _dayWorkShift;
        for (WorkShiftModel _workShift in workShifts) {
          String _start = '${_format.format(_workShift.startedAt)}';
          if (days[i] == DateTime.parse(_start)) {
            _dayWorkShift = _workShift;
          }
        }
        String _day = dateText('dd (E)', days[i]);
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
              String _key = '${_format.format(_dayWorks[j].startedAt)}';
              count[_key] = '';
              workTimes = addTime(workTimes, _workTime);
              dayTimes = addTime(dayTimes, _dayTime);
              nightTimes = addTime(nightTimes, _nightTime);
              dayTimeOvers = addTime(dayTimeOvers, _dayTimeOver);
              nightTimeOvers = addTime(nightTimeOvers, _nightTimeOver);
              _row.add(pw.TableRow(
                children: [
                  _cell(_day, null),
                  _cell(_state, null),
                  _cell(_startTime, null),
                  _cell(_endTime, null),
                  _cell(_breakTime, null),
                  _cell(_workTime, null),
                  _cell(_dayTime, null),
                  _cell(_nightTime, null),
                  _cell(_dayTimeOver, null),
                  _cell(_nightTimeOver, null),
                  _cell(countW['${_format.format(days[i])}'] ?? '', null),
                ],
              ));
            }
          }
        } else {
          _row.add(pw.TableRow(
            children: [
              _cell(_day, null),
              _cell(
                _dayWorkShift?.state ?? '',
                _dayWorkShift?.stateColor3(),
              ),
              _cell('', null),
              _cell('', null),
              _cell('', null),
              _cell('', null),
              _cell('', null),
              _cell('', null),
              _cell('', null),
              _cell('', null),
              _cell(countW['${_format.format(days[i])}'] ?? '', null),
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
          _cell('総勤務日数 [$workDays日]', null),
          _cell('総勤務時間 [$workTimes]', null),
          _cell('総通常時間 [$dayTimes]', null),
          _cell('総深夜時間(-) [$nightTimes]', null),
          _cell('総通常時間外 [$dayTimeOvers]', null),
          _cell('総深夜時間外 [$nightTimeOvers]', null),
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

Future<void> _works02({
  required PositionProvider positionProvider,
  required WorkProvider workProvider,
  WorkShiftProvider workShiftProvider,
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

  // 雇用形態配列作成
  List<PositionModel> positions = await positionProvider.selectList(
    groupId: group.id,
  );

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
          '※Aグループ・・・9時以前は「勤務時間」に該当させない。17時以降は「時間外1」に該当させる。休日出勤の場合は全ての時間を「時間外2」に該当させる。',
          style: _listStyle,
        ),
        pw.Text(
          '※Bグループ・・・9時以前は「勤務時間」に該当させない。17時以降18時以前は「時間外1」に該当させる。18時以降は「時間外2」に該当させる。休日出勤の場合は全ての時間を「時間外2」に該当させる。',
          style: _listStyle,
        ),
        pw.Text(
          '※Cグループ・・・勤務時間が8時間を超えた分の時間を「時間外2」に該当させる。休日出勤の場合は全ての時間を「時間外2」に該当させる。',
          style: _listStyle,
        ),
        pw.Text(
          '※この勤務時間は時間外分を引いています。',
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
      String _positionName = '';
      for (PositionModel _position in positions) {
        List<String> _userIds = _position.userIds;
        if (_userIds.contains(_user.id)) {
          _positionName = _position.name;
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
              '${_user.name} (${_user.number}) 【$_positionName】',
              style: _headStyle,
            ),
          ],
        );
      }

      // 合計値初期化
      Map count = {};
      String workTimes = '00:00';
      String overTime1s = '00:00';
      String overTime2s = '00:00';
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
            _cell(label: '時間外1'),
            _cell(label: '時間外2'),
          ],
        ));
        DateFormat _format = DateFormat('yyyy-MM-dd');
        // 各種時間
        for (int i = 0; i < days.length; i++) {
          List<WorkModel> _dayWorks = [];
          for (WorkModel _work in works) {
            String _start = '${_format.format(_work.startedAt)}';
            if (days[i] == DateTime.parse(_start)) {
              _dayWorks.add(_work);
            }
          }
          WorkShiftModel _dayWorkShift;
          for (WorkShiftModel _workShift in workShifts) {
            String _start = '${_format.format(_workShift.startedAt)}';
            if (days[i] == DateTime.parse(_start)) {
              _dayWorkShift = _workShift;
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
                String _workTime = '00:00';
                String _overTime1 = '00:00';
                String _overTime2 = '00:00';
                if (_positionName == 'Aグループ') {
                  _workTime = _dayWorks[j].calTimes02(group, 'A')[0];
                  _overTime1 = _dayWorks[j].calTimes02(group, 'A')[1];
                  _overTime2 = _dayWorks[j].calTimes02(group, 'A')[2];
                } else if (_positionName == 'Bグループ') {
                  _workTime = _dayWorks[j].calTimes02(group, 'B')[0];
                  _overTime1 = _dayWorks[j].calTimes02(group, 'B')[1];
                  _overTime2 = _dayWorks[j].calTimes02(group, 'B')[2];
                } else if (_positionName == 'Cグループ') {
                  _workTime = _dayWorks[j].calTimes02(group, 'C')[0];
                  _overTime1 = _dayWorks[j].calTimes02(group, 'C')[1];
                  _overTime2 = _dayWorks[j].calTimes02(group, 'C')[2];
                } else {
                  _workTime = _dayWorks[j].calTimes02(group, 'A')[0];
                  _overTime1 = _dayWorks[j].calTimes02(group, 'A')[1];
                  _overTime2 = _dayWorks[j].calTimes02(group, 'A')[2];
                }
                String _key = '${_format.format(_dayWorks[j].startedAt)}';
                count[_key] = '';
                workTimes = addTime(workTimes, _workTime);
                overTime1s = addTime(overTime1s, _overTime1);
                overTime2s = addTime(overTime2s, _overTime2);
                _row.add(pw.TableRow(
                  children: [
                    _cell(label: _day),
                    _cell(label: _state),
                    _cell(label: _startTime),
                    _cell(label: _endTime),
                    _cell(label: _breakTime),
                    _cell(label: _workTime),
                    _cell(label: _overTime1),
                    _cell(label: _overTime2),
                  ],
                ));
              }
            }
          } else {
            _row.add(pw.TableRow(
              children: [
                _cell(label: _day),
                _cell(
                  label: _dayWorkShift?.state ?? '',
                  color: _dayWorkShift?.stateColor3(),
                ),
                _cell(label: ''),
                _cell(label: ''),
                _cell(label: ''),
                _cell(label: ''),
                _cell(label: ''),
                _cell(label: ''),
              ],
            ));
          }
        }
        // 最終行目
        _row.add(pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _cell(label: '合計'),
            _cell(label: ''),
            _cell(label: ''),
            _cell(label: ''),
            _cell(label: ''),
            _cell(label: workTimes),
            _cell(label: overTime1s),
            _cell(label: overTime2s),
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
            pw.SizedBox(height: 4.0),
            _buildDescription(),
          ],
        ),
      ));
    }
  } else {
    if (user == null) return;
    // 各種データ取得
    String _positionName = '';
    for (PositionModel _position in positions) {
      List<String> _userIds = _position.userIds;
      if (_userIds.contains(user.id)) {
        _positionName = _position.name;
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
            '${user.name} (${user.number})【$_positionName】',
            style: _headStyle,
          ),
        ],
      );
    }

    // 合計値初期化
    Map count = {};
    String workTimes = '00:00';
    String overTime1s = '00:00';
    String overTime2s = '00:00';
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
          _cell(label: '時間外1'),
          _cell(label: '時間外2'),
        ],
      ));
      DateFormat _format = DateFormat('yyyy-MM-dd');
      // 各種時間
      for (int i = 0; i < days.length; i++) {
        List<WorkModel> _dayWorks = [];
        for (WorkModel _work in works) {
          String _start = '${_format.format(_work.startedAt)}';
          if (days[i] == DateTime.parse(_start)) {
            _dayWorks.add(_work);
          }
        }
        WorkShiftModel _dayWorkShift;
        for (WorkShiftModel _workShift in workShifts) {
          String _start = '${_format.format(_workShift.startedAt)}';
          if (days[i] == DateTime.parse(_start)) {
            _dayWorkShift = _workShift;
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
              String _workTime = '00:00';
              String _overTime1 = '00:00';
              String _overTime2 = '00:00';
              if (_positionName == 'Aグループ') {
                _workTime = _dayWorks[j].calTimes02(group, 'A')[0];
                _overTime1 = _dayWorks[j].calTimes02(group, 'A')[1];
                _overTime2 = _dayWorks[j].calTimes02(group, 'A')[2];
              } else if (_positionName == 'Bグループ') {
                _workTime = _dayWorks[j].calTimes02(group, 'B')[0];
                _overTime1 = _dayWorks[j].calTimes02(group, 'B')[1];
                _overTime2 = _dayWorks[j].calTimes02(group, 'B')[2];
              } else if (_positionName == 'Cグループ') {
                _workTime = _dayWorks[j].calTimes02(group, 'C')[0];
                _overTime1 = _dayWorks[j].calTimes02(group, 'C')[1];
                _overTime2 = _dayWorks[j].calTimes02(group, 'C')[2];
              } else {
                _workTime = _dayWorks[j].calTimes02(group, 'A')[0];
                _overTime1 = _dayWorks[j].calTimes02(group, 'A')[1];
                _overTime2 = _dayWorks[j].calTimes02(group, 'A')[2];
              }
              String _key = '${_format.format(_dayWorks[j].startedAt)}';
              count[_key] = '';
              workTimes = addTime(workTimes, _workTime);
              overTime1s = addTime(overTime1s, _overTime1);
              overTime2s = addTime(overTime2s, _overTime2);
              _row.add(pw.TableRow(
                children: [
                  _cell(label: _day),
                  _cell(label: _state),
                  _cell(label: _startTime),
                  _cell(label: _endTime),
                  _cell(label: _breakTime),
                  _cell(label: _workTime),
                  _cell(label: _overTime1),
                  _cell(label: _overTime2),
                ],
              ));
            }
          }
        } else {
          _row.add(pw.TableRow(
            children: [
              _cell(label: _day),
              _cell(
                label: _dayWorkShift?.state ?? '',
                color: _dayWorkShift?.stateColor3(),
              ),
              _cell(label: ''),
              _cell(label: ''),
              _cell(label: ''),
              _cell(label: ''),
              _cell(label: ''),
              _cell(label: ''),
            ],
          ));
        }
      }
      // 最終行目
      _row.add(pw.TableRow(
        decoration: pw.BoxDecoration(color: PdfColors.grey300),
        children: [
          _cell(label: '合計'),
          _cell(label: ''),
          _cell(label: ''),
          _cell(label: ''),
          _cell(label: ''),
          _cell(label: workTimes),
          _cell(label: overTime1s),
          _cell(label: overTime2s),
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
          pw.SizedBox(height: 4.0),
          _buildDescription(),
        ],
      ),
    ));
  }
  await _download(pdf: pdf, fileName: 'works.pdf');
  return;
}

Future<void> _download(
    {required pw.Document pdf, required String fileName}) async {
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
