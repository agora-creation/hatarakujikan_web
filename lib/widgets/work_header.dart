import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';

const TextStyle headStyle = TextStyle(
  color: Colors.black54,
  fontSize: 15.0,
);

class WorkHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kBottomBorderDecoration,
      child: ListTile(
        leading: Text('日付', style: headStyle),
        title: ListTile(
          leading: Text('勤務状況', style: headStyle),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('出勤時間', style: headStyle),
              Text('退勤時間', style: headStyle),
              Text('休憩時間', style: headStyle),
              Text('勤務時間', style: headStyle),
              Text('法定内時間', style: headStyle),
              Text('法定外時間', style: headStyle),
              Text('深夜時間', style: headStyle),
              Text('修正/削除', style: headStyle),
              Text('操作ログ', style: headStyle),
              Text('位置情報', style: headStyle),
            ],
          ),
        ),
      ),
    );
  }
}
