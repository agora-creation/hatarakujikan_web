import 'package:firebase_auth/firebase_auth.dart';
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
    GroupModel? group,
    String? number,
    String? name,
    String? recordPassword,
  }) async {
    if (group == null) return false;
    if (number == null) return false;
    if (name == null) return false;
    if (recordPassword == null) return false;
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
      List<String> _userIds = group.userIds;
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
    String? id,
    String? number,
    String? name,
    String? recordPassword,
  }) async {
    if (id == null) return false;
    if (number == null) return false;
    if (name == null) return false;
    if (recordPassword == null) return false;
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

  Future<bool> updateSmartphone({
    GroupModel? group,
    UserModel? adminUser,
    UserModel? user,
    bool? smartphone,
    String? email,
    String? password,
  }) async {
    if (group == null) return false;
    if (adminUser == null) return false;
    if (user == null) return false;
    if (smartphone == null) return false;
    if (email == null) return false;
    if (password == null) return false;
    try {
      FirebaseAuth? _auth1 = FirebaseAuth.instance;
      String? newId;
      await _auth1
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      )
          .then((value) {
        newId = value.user?.uid;
      });
      await _auth1.signOut();
      print("a");
      await Future.delayed(Duration(seconds: 5));
      FirebaseAuth? _auth2 = FirebaseAuth.instance;
      await _auth2.signInWithEmailAndPassword(
        email: adminUser.email,
        password: adminUser.password,
      );
      print("b");
      _userService.delete({'id': user.id});
      _userService.create({
        'id': newId,
        'number': user.number,
        'name': user.name,
        'email': email,
        'password': password,
        'recordPassword': user.recordPassword,
        'workLv': user.workLv,
        'lastWorkId': user.lastWorkId,
        'lastBreakId': user.lastBreakId,
        'token': user.token,
        'smartphone': true,
        'createdAt': DateTime.now(),
      });
      List<String> _userIds = group.userIds;
      _userIds.remove(user.id);
      _userIds.add(newId ?? '');
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

  Future<bool> delete({
    GroupModel? group,
    String? id,
  }) async {
    if (group == null) return false;
    if (id == null) return false;
    try {
      _userService.delete({'id': id});
      List<String> _userIds = group.userIds;
      _userIds.remove(id);
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
