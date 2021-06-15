import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/providers/group.dart';

class UserTable extends StatefulWidget {
  final GroupProvider groupProvider;

  UserTable({@required this.groupProvider});

  @override
  _UserTableState createState() => _UserTableState();
}

class _UserTableState extends State<UserTable> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'スタッフの管理',
          style: kAdminTitleTextStyle,
        ),
        Text(
          'スタッフの情報を一覧表示します。アプリから登録するか、ここで登録できます。',
          style: kAdminSubTitleTextStyle,
        ),
        SizedBox(height: 16.0),
        Expanded(
          child: Center(
            child: Text('スタッフの管理'),
          ),
        ),
      ],
    );
  }
}
