import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/services/group.dart';
import 'package:hatarakujikan_web/services/user.dart';
import 'package:hatarakujikan_web/services/work.dart';

class UserProvider with ChangeNotifier {
  GroupService _groupService = GroupService();
  UserService _userService = UserService();
  WorkService _workService = WorkService();

  Future<bool> create({
    required String number,
    required String name,
    required String recordPassword,
    required GroupModel group,
  }) async {
    if (number == '') return false;
    if (name == '') return false;
    try {
      String _id = _userService.id();
      _userService.create({
        'id': _id,
        'number': number,
        'name': name,
        'email': '',
        'password': '',
        'recordPassword': recordPassword,
        'workLv': 0,
        'lastWorkId': '',
        'lastBreakId': '',
        'token': '',
        'smartphone': false,
        'createdAt': DateTime.now(),
      });
      List<String> _userIds = [];
      _userIds = group.userIds;
      _userIds.add(_id);
      _groupService.update({
        'id': group.id,
        'userIds': _userIds,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> update({
    required String id,
    required String number,
    required String name,
    required String recordPassword,
  }) async {
    try {
      _userService.update({
        'id': id,
        'number': number,
        'name': name,
        'recordPassword': recordPassword,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  void delete({
    required UserModel user,
    required GroupModel group,
  }) {
    _userService.delete({'id': user.id});
    List<String> _userIds = [];
    _userIds = group.userIds;
    _userIds.remove(user.id);
    _groupService.update({
      'id': group.id,
      'userIds': _userIds,
    });
  }

  Future<bool> migration({
    required String groupId,
    required UserModel before,
    required UserModel after,
  }) async {
    if (groupId == '') return false;
    if (before.id == '') return false;
    if (after.id == '') return false;
    try {
      _userService.update({
        'id': after.id,
        'number': before.number,
        'recordPassword': before.recordPassword,
      });
      await _workService.updateMigration(
        beforeUserId: before.id,
        afterUserId: after.id,
      );
      _userService.delete({'id': before.id});
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<List<UserModel>> selectList({required List<String> userIds}) async {
    List<UserModel> _users = [];
    await _userService.selectList(userIds: userIds).then((value) {
      _users = value;
    });
    return _users;
  }
}
