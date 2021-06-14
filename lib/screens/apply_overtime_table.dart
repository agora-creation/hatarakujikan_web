import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';

class ApplyOvertimeTable extends StatefulWidget {
  @override
  _ApplyOvertimeTableState createState() => _ApplyOvertimeTableState();
}

class _ApplyOvertimeTableState extends State<ApplyOvertimeTable> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '残業申請',
          style: kAdminTitleTextStyle,
        ),
        Text(
          'スタッフがスマートフォンから申請した残業申請を一覧表示します。',
          style: kAdminSubTitleTextStyle,
        ),
        SizedBox(height: 16.0),
        Expanded(
          child: Center(
            child: Text('残業申請'),
          ),
        ),
      ],
    );
  }
}
