import 'package:flutter/services.dart';
import 'package:hatarakujikan_web/helpers/date_machine_util.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_html/html.dart' as html;

Future<void> workPdf({DateTime month, UserModel user}) async {
  if (user == null) return;
  List<DateTime> days = [];
  days.clear();
  var _dateMap = DateMachineUtil.getMonthDate(month, 0);
  DateTime _startAt = DateTime.parse('${_dateMap['start']}');
  DateTime _endAt = DateTime.parse('${_dateMap['end']}');
  for (int i = 0; i <= _endAt.difference(_startAt).inDays; i++) {
    days.add(_startAt.add(Duration(days: i)));
  }

  final pdf = pw.Document();
  final font = await rootBundle.load('assets/fonts/GenShinGothic-Regular.ttf');
  final ttf = pw.Font.ttf(font);

  final pw.TextStyle _headerStyle = pw.TextStyle(font: ttf, fontSize: 10.0);
  final pw.TextStyle _listStyle = pw.TextStyle(font: ttf, fontSize: 8.0);

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
      _result.add(
        pw.TableRow(
          children: [
            pw.Padding(
              padding: pw.EdgeInsets.all(5.0),
              child: pw.Text(
                '${DateFormat('dd (E)', 'ja').format(days[i])}',
                style: _listStyle,
              ),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.all(5.0),
              child: pw.Text('通常勤務', style: _listStyle),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.all(5.0),
              child: pw.Text('00:00', style: _listStyle),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.all(5.0),
              child: pw.Text('00:00', style: _listStyle),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.all(5.0),
              child: pw.Text('00:00', style: _listStyle),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.all(5.0),
              child: pw.Text('00:00', style: _listStyle),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.all(5.0),
              child: pw.Text('00:00', style: _listStyle),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.all(5.0),
              child: pw.Text('00:00', style: _listStyle),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.all(5.0),
              child: pw.Text('00:00', style: _listStyle),
            ),
          ],
        ),
      );
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
                    child: pw.Text('総勤務日数 [0日]', style: _listStyle),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(5.0),
                    child: pw.Text('総勤務時間 [00:00]', style: _listStyle),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(5.0),
                    child: pw.Text('総法定内時間 [00:00]', style: _listStyle),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(5.0),
                    child: pw.Text('総法定外時間 [00:00]', style: _listStyle),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(5.0),
                    child: pw.Text('総深夜時間 [00:00]', style: _listStyle),
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
