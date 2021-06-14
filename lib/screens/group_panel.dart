import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';

class GroupPanel extends StatefulWidget {
  @override
  _GroupPanelState createState() => _GroupPanelState();
}

class _GroupPanelState extends State<GroupPanel> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '会社/組織の設定',
          style: kAdminTitleTextStyle,
        ),
        Text(
          'スタッフの情報を一覧表示します。アプリでの利用者とそれ以外の利用者がいます。',
          style: kAdminSubTitleTextStyle,
        ),
        SizedBox(height: 16.0),
        Expanded(
          child: Center(
            child: Text('会社/組織の設定'),
          ),
        ),
      ],
    );
  }
}
