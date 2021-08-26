import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/models/section.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/services/section.dart';

class SectionProvider with ChangeNotifier {
  SectionService _sectionService = SectionService();

  Future<bool> create({
    String groupId,
    String name,
  }) async {
    if (groupId == '') return false;
    if (name == '') return false;
    try {
      String _id = _sectionService.id();
      _sectionService.create({
        'id': _id,
        'groupId': groupId,
        'name': name,
        'adminUserId': '',
        'userIds': [],
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
  }) async {
    try {
      _sectionService.update({
        'id': id,
        'name': name,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> updateUsers({
    List<UserModel> users,
    String id,
  }) async {
    try {
      List<String> _userIds = [];
      for (UserModel _user in users) {
        _userIds.add(_user.id);
      }
      _sectionService.update({
        'id': id,
        'userIds': _userIds,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  void delete({SectionModel section}) {
    _sectionService.delete({'id': section.id});
  }
}
