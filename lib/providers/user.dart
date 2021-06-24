import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/services/user.dart';

class UserProvider with ChangeNotifier {
  UserService _userService = UserService();

  Future<bool> create({
    String name,
    String recordPassword,
    String groupId,
    String position,
  }) async {
    if (name == '') return false;
    if (groupId == '') return false;
    try {
      String _id = _userService.id();
      List<String> _groups = [];
      _groups.add(groupId);
      _userService.create({
        'id': _id,
        'name': name,
        'email': '',
        'password': '',
        'recordPassword': recordPassword,
        'workLv': 0,
        'lastWorkId': '',
        'lastBreakId': '',
        'groups': _groups,
        'position': position,
        'token': '',
        'smartphone': false,
        'createdAt': DateTime.now(),
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> update({
    String id,
    String name,
    String recordPassword,
    String position,
  }) async {
    try {
      _userService.update({
        'id': id,
        'name': name,
        'recordPassword': recordPassword,
        'position': position,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  void delete({UserModel user}) {
    _userService.delete({'id': user?.id});
  }

  Future<List<UserModel>> selectList({String groupId}) async {
    List<UserModel> _users = [];
    await _userService.selectList(groupId: groupId).then((value) {
      _users = value;
    });
    return _users;
  }

  Future<List<UserModel>> selectListSP(
      {String groupId, bool smartphone}) async {
    List<UserModel> _users = [];
    await _userService
        .selectListSP(
      groupId: groupId,
      smartphone: smartphone,
    )
        .then((value) {
      _users = value;
    });
    return _users;
  }
}
