import 'package:flutter/services.dart';
import 'package:hatarakujikan_web/models/group.dart';
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
    GroupModel? group,
  }) async {
    String? groupId = group?.id;
    switch (groupId) {
      //ひろめ市場
      case 'UryZHGotsjyR0Zb6g06J':
        await _model01();
        return;
      //土佐税理士
      case 'h74zqng5i59qHdMG16Cb':
        await _model02();
        return;
      default:
        return;
    }
  }
}

Future _model01() async {
  final pdf = pw.Document();
  final font = await rootBundle.load(fontPath);
  final ttf = pw.Font.ttf(font);
  final headStyle = pw.TextStyle(font: ttf, fontSize: 9.0);
  final listStyle = pw.TextStyle(font: ttf, fontSize: 7.0);
  await _dl(pdf: pdf, fileName: 'works.pdf');
  return;
}

Future _model02() async {
  final pdf = pw.Document();
  final font = await rootBundle.load(fontPath);
  final ttf = pw.Font.ttf(font);
  final headStyle = pw.TextStyle(font: ttf, fontSize: 9.0);
  final listStyle = pw.TextStyle(font: ttf, fontSize: 7.0);
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
