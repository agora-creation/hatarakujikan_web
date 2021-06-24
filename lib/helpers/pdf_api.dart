import 'package:flutter/services.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_html/html.dart' as html;

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
          pw.Expanded(
            child: pw.Container(
              width: 200.0,
              height: 200.0,
              child: pw.BarcodeWidget(
                barcode: pw.Barcode.qrCode(),
                data: '${group.id}',
              ),
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'これは${group.name}の会社/組織IDが埋め込まれたQRコードです。別アプリ「はたらくじかん for スマートフォン」でこのQRコードを使用します。',
                style: pw.TextStyle(font: ttf, fontSize: 18.0),
              ),
              pw.Text(
                '【会社/組織に入る時】',
                style: pw.TextStyle(
                    font: ttf, fontSize: 14.0, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                '① 「はたらくじかん for スマートフォン」を起動し、ログインしておく',
                style: pw.TextStyle(font: ttf, fontSize: 14.0),
              ),
              pw.Text(
                '② 下部メニューから「会社/組織」をタップする',
                style: pw.TextStyle(font: ttf, fontSize: 14.0),
              ),
              pw.Text(
                '③ 下部メニューの上の「会社/組織に入る(QRコード)」ボタンをタップする',
                style: pw.TextStyle(font: ttf, fontSize: 14.0),
              ),
              pw.Text(
                '④ カメラが起動するので、枠内にこのQRコードを収めるように撮る',
                style: pw.TextStyle(font: ttf, fontSize: 14.0),
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
}
