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
      List<String> _groups = [];
      _groups.add(group.id);
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
        'position': '',
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
        'position': before?.position,
      });
      await _workService.updateMigration(before?.id, after?.id);
      _userService.delete({'id': before?.id});
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<List<UserModel>> selectList({String groupId}) async {
    List<UserModel> _users = [];
    await _userService.selectListGroupId(groupId: groupId).then((value) {
      _users = value;
    });
    return _users;
  }

  Future<List<UserModel>> selectListSP({
    String groupId,
    bool smartphone,
  }) async {
    List<UserModel> _users = [];
    await _userService
        .selectListGroupIdSP(
      groupId: groupId,
      smartphone: smartphone,
    )
        .then((value) {
      _users = value;
    });
    return _users;
  }

  Future<List<UserModel>> selectListSmartphone({
    List<String> userIds,
    bool smartphone,
  }) async {
    List<UserModel> _users = [];
    await _userService
        .selectListUserIdsSP(
      userIds: userIds,
      smartphone: smartphone,
    )
        .then((value) {
      _users = value;
    });
    return _users;
  }

  Future<List<UserModel>> selectListNotice({
    String groupId,
    String noticeId,
  }) async {
    List<UserModel> _users = [];
    await _userService
        .selectListGroupIdNotice(
      groupId: groupId,
      noticeId: noticeId,
    )
        .then((value) {
      _users = value;
    });
    return _users;
  }
}
