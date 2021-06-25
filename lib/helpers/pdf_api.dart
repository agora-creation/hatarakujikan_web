import 'package:flutter/services.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_html/html.dart' as html;

Future<void> workPdf() async {
  final pdf = pw.Document();
  final font = await rootBundle.load('assets/fonts/GenShinGothic-Regular.ttf');
  final ttf = pw.Font.ttf(font);
  pdf.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4,
    build: (context) {
      return pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                '2021年06月',
                style: pw.TextStyle(font: ttf, fontSize: 18.0),
              ),
              pw.Text(
                '山田太郎',
                style: pw.TextStyle(font: ttf, fontSize: 18.0),
              ),
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
