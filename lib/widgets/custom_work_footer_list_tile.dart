import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';

class CustomWorkFooterListTile extends StatelessWidget {
  final int? workCount;
  final String? workTime;
  final String? legalTime;
  final String? nonLegalTime;
  final String? nightTime;

  CustomWorkFooterListTile({
    this.workCount,
    this.workTime,
    this.legalTime,
    this.nonLegalTime,
    this.nightTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kTopBorderDecoration,
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '総勤務日数 [$workCount日]',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 16.0,
              ),
            ),
            Text(
              '総勤務時間 [$workTime]',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 15.0,
              ),
            ),
            Text(
              '総法定内時間 [$legalTime]',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 15.0,
              ),
            ),
            Text(
              '総法定外時間 [$nonLegalTime]',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 15.0,
              ),
            ),
            Text(
              '総深夜時間 [$nightTime]',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 15.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
