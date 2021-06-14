import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';

class ApplyWorkTable extends StatefulWidget {
  @override
  _ApplyWorkTableState createState() => _ApplyWorkTableState();
}

class _ApplyWorkTableState extends State<ApplyWorkTable> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '記録修正申請',
          style: kAdminTitleTextStyle,
        ),
        Text(
          'スタッフがスマートフォンから申請した記録修正申請を一覧表示します。承認をした場合、自動的に勤務記録が修正されます。',
          style: kAdminSubTitleTextStyle,
        ),
        SizedBox(height: 16.0),
        Expanded(
          child: Center(
            child: Text('記録修正申請'),
          ),
        ),
      ],
    );
  }
}
