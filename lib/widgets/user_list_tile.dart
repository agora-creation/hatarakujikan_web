import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/user.dart';

class UserListTile extends StatelessWidget {
  final UserModel user;

  UserListTile({required this.user});

  @override
  Widget build(BuildContext context) {
    Widget _workLv = Text('');
    switch (user.workLv) {
      case 0:
        _workLv = Text('');
        break;
      case 1:
        _workLv = Chip(
          backgroundColor: Colors.blue,
          label: Text('出勤中', style: TextStyle(color: Colors.white)),
        );
        break;
      case 2:
        _workLv = Chip(
          backgroundColor: Colors.orange,
          label: Text('休憩中', style: TextStyle(color: Colors.white)),
        );
        break;
    }
    return Container(
      decoration: kBottomBorderDecoration,
      child: ListTile(
        title: Text(user.name),
        trailing: _workLv,
      ),
    );
  }
}
