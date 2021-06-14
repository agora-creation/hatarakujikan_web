import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/services/user.dart';

class UserProvider with ChangeNotifier {
  UserService _userService = UserService();

  Future<List<UserModel>> selectList({String groupId}) async {
    List<UserModel> _users = [];
    await _userService.selectList(groupId: groupId).then((value) {
      _users = value;
    });
    return _users;
  }
}
