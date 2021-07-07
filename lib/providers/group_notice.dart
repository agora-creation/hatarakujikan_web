import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/models/group_notice.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/services/group_notice.dart';
import 'package:hatarakujikan_web/services/user_notice.dart';

class GroupNoticeProvider with ChangeNotifier {
  GroupNoticeService _groupNoticeService = GroupNoticeService();
  UserNoticeService _userNoticeService = UserNoticeService();

  Future<bool> create({
    String groupId,
    String title,
    String message,
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
    String id,
    String groupId,
    String title,
    String message,
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

  void delete({GroupNoticeModel groupNotice}) {
    _groupNoticeService.delete({
      'id': groupNotice.id,
      'groupId': groupNotice.groupId,
    });
  }

  Future<bool> send({
    List<UserModel> users,
    String id,
    String groupId,
    String title,
    String message,
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
