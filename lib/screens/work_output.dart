import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/widgets/TapListTile.dart';
import 'package:hatarakujikan_web/widgets/admin_header.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold.dart';
import 'package:provider/provider.dart';

class WorkOutputScreen extends StatelessWidget {
  static const String id = 'work_output';

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);

    return CustomAdminScaffold(
      groupProvider: groupProvider,
      selectedRoute: id,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminHeader(
            title: '帳票の出力',
            message: '勤怠記録を様々な形式で帳票出力できます。',
          ),
          SizedBox(height: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TapListTile(
                  title: 'CSVファイル形式で出力',
                  subtitle: 'お使いの給与ソフトに合わせて、CSVファイルをダウンロードできます。',
                  onTap: () {},
                ),
                TapListTile(
                  title: 'PDFファイル形式で出力',
                  subtitle: '勤怠の記録を印刷して確認できるよう、PDFファイルをダウンロードできます。',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
