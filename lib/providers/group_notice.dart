import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/models/group_notice.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/services/group_notice.dart';
import 'package:hatarakujikan_web/services/user_notice.dart';

class GroupNoticeProvider with ChangeNotifier {
  GroupNoticeService _groupNoticeService = GroupNoticeService();
  UserNoticeService _userNoticeService = UserNoticeService();

  Future<bool> create({
    required String groupId,
    required String title,
    required String message,
  }) async {
    if (groupId == '') return false;
    if (title == '') return false;
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
    required String id,
    required String groupId,
    required String title,
    required String message,
  }) async {
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

  void delete({required GroupNoticeModel groupNotice}) {
    _groupNoticeService.delete({
      'id': groupNotice.id,
      'groupId': groupNotice.groupId,
    });
  }

  Future<bool> send({
    required String id,
    required String groupId,
    required String title,
    required String message,
    required List<UserModel> users,
  }) async {
    try {
      for (UserModel _user in users) {
        _userNoticeService.create({
          'id': id,
          'groupId': groupId,
          'userId': _user.id,
          'title': title,
          'message': message,
          'read': false,
          'createdAt': DateTime.now(),
        });
        _userNoticeService.send(
          token: _user.token,
          title: title,
          body: message,
        );
      }
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }
}
