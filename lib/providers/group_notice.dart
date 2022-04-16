import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/models/group_notice.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/services/group_notice.dart';
import 'package:hatarakujikan_web/services/user_notice.dart';

class GroupNoticeProvider with ChangeNotifier {
  GroupNoticeService _groupNoticeService = GroupNoticeService();
  UserNoticeService _userNoticeService = UserNoticeService();

  Future<bool> create({
    String? groupId,
    String? title,
    String? message,
  }) async {
    if (groupId == null) return false;
    if (title == null) return false;
    if (message == null) return false;
    try {
      String _id = _groupNoticeService.id(groupId);
      _groupNoticeService.create({
        'id': _id,
        'groupId': groupId,
        'title': title,
        'message': message,
        'createdAt': DateTime.now(),
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> update({
    String? id,
    String? groupId,
    String? title,
    String? message,
  }) async {
    if (id == null) return false;
    if (groupId == null) return false;
    if (title == null) return false;
    if (message == null) return false;
    try {
      _groupNoticeService.update({
        'id': id,
        'groupId': groupId,
        'title': title,
        'message': message,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> delete({
    String? id,
    String? groupId,
  }) async {
    if (id == null) return false;
    if (groupId == null) return false;
    try {
      _groupNoticeService.delete({
        'id': id,
        'groupId': groupId,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> send({
    GroupNoticeModel? notice,
    List<UserModel>? users,
  }) async {
    if (notice == null) return false;
    if (users == null) return false;
    if (users.length == 0) return false;
    try {
      for (UserModel _user in users) {
        _userNoticeService.create({
          'id': notice.id,
          'groupId': notice.groupId,
          'userId': _user.id,
          'title': notice.title,
          'message': notice.message,
          'read': false,
          'createdAt': DateTime.now(),
        });
        _userNoticeService.send(
          token: _user.token,
          title: notice.title,
          body: notice.message,
        );
      }
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? streamList({String? groupId}) {
    Stream<QuerySnapshot<Map<String, dynamic>>>? _ret;
    _ret = FirebaseFirestore.instance
        .collection('group')
        .doc(groupId)
        .collection('notice')
        .where('groupId', isEqualTo: groupId ?? 'error')
        .orderBy('createdAt', descending: true)
        .snapshots();
    return _ret;
  }
}
