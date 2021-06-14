import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';

class ApplyHolidayTable extends StatefulWidget {
  @override
  _ApplyHolidayTableState createState() => _ApplyHolidayTableState();
}

class _ApplyHolidayTableState extends State<ApplyHolidayTable> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '休暇申請',
          style: kAdminTitleTextStyle,
        ),
        Text(
          'スタッフがスマートフォンから申請した休暇申請を一覧表示します。',
          style: kAdminSubTitleTextStyle,
        ),
        SizedBox(height: 16.0),
        Expanded(
          child: Center(
            child: Text('休暇申請'),
          ),
        ),
      ],
    );
  }
}
