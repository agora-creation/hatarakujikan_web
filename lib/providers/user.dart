import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/services/group.dart';
import 'package:hatarakujikan_web/services/user.dart';
import 'package:hatarakujikan_web/services/work.dart';
import 'package:hatarakujikan_web/services/work_shift.dart';

class UserProvider with ChangeNotifier {
  GroupService _groupService = GroupService();
  UserService _userService = UserService();
  WorkService _workService = WorkService();
  WorkShiftService _workShiftService = WorkShiftService();

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

  Future<String?> createAuth({
    required String email,
    required String password,
  }) async {
    String? _ret;
    FirebaseAuth? _auth1 = FirebaseAuth.instance;
    await _auth1
        .createUserWithEmailAndPassword(
      email: email,
      password: password,
    )
        .then((value) {
      _ret = value.user?.uid;
    });
    await _auth1.signOut();
    await Future.delayed(Duration.zero);
    notifyListeners();
    return _ret;
  }

  Future<bool> reCreate({
    GroupModel? group,
    UserModel? user,
    String? newId,
    String? email,
    String? password,
  }) async {
    if (group == null) return false;
    if (user == null) return false;
    if (newId == null) return false;
    if (email == null) return false;
    if (password == null) return false;
    try {
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
      _userIds.add(newId);
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
    GroupModel? group,
    UserModel? beforeUser,
    UserModel? afterUser,
  }) async {
    if (group == null) return false;
    if (beforeUser == null) return false;
    if (afterUser == null) return false;
    try {
      _userService.update({
        'id': afterUser.id,
        'number': beforeUser.number,
        'name': beforeUser.name,
        'recordPassword': beforeUser.recordPassword,
      });
      await _workService.updateMigration(
        beforeUserId: beforeUser.id,
        afterUserId: afterUser.id,
      );
      await _workShiftService.updateMigration(
        beforeUserId: beforeUser.id,
        afterUserId: afterUser.id,
      );
      _userService.delete({'id': beforeUser.id});
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<List<UserModel>> selectList({
    required List<String> userIds,
    bool? smartphone,
  }) async {
    List<UserModel> _users = [];
    await _userService.selectList(userIds: userIds).then((value) {
      _users = value;
    });
    return _users;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? streamList() {
    Stream<QuerySnapshot<Map<String, dynamic>>>? _ret;
    _ret = FirebaseFirestore.instance
        .collection('user')
        .orderBy('recordPassword', descending: false)
        .snapshots();
    return _ret;
  }
}
