import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';

class CustomWorkFooterListTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kTopBorderDecoration,
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '勤務日数 [0日]',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 16.0,
              ),
            ),
            Text(
              '総勤務時間 [00:00]',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 15.0,
              ),
            ),
            Text(
              '総法定内時間 [00:00]',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 15.0,
              ),
            ),
            Text(
              '総法定外時間 [00:00]',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 15.0,
              ),
            ),
            Text(
              '総深夜時間 [00:00]',
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
