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
    String name,
    String recordPassword,
    GroupModel group,
  }) async {
    if (name == '') return false;
    if (group == null) return false;
    try {
      String _id = _userService.id();
      _userService.create({
        'id': _id,
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
    String id,
    String name,
    String recordPassword,
  }) async {
    try {
      _userService.update({
        'id': id,
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
    UserModel user,
    GroupModel group,
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
    String groupId,
    UserModel before,
    UserModel after,
  }) async {
    if (groupId == '') return false;
    if (before == null) return false;
    if (after == null) return false;
    try {
      _userService.update({
        'id': after?.id,
        'recordPassword': before?.recordPassword,
      });
      await _workService.updateMigration(before?.id, after?.id);
      _userService.delete({'id': before?.id});
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<List<UserModel>> selectList({List<String> userIds}) async {
    List<UserModel> _users = [];
    await _userService.selectList(userIds: userIds).then((value) {
      _users = value;
    });
    return _users;
  }
}
