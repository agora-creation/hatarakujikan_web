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
    SectionModel section,
    String name,
  }) async {
    try {
      _sectionService.update({
        'id': section.id,
        'name': name,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> updateUsers({
    SectionModel section,
    List<UserModel> users,
  }) async {
    try {
      List<String> _userIds = [];
      for (UserModel _user in users) {
        _userIds.add(_user.id);
      }
      String _adminUserId = '';
      var _contain = _userIds.where((e) => e == section.adminUserId);
      if (_contain.isNotEmpty) {
        _adminUserId = section.adminUserId;
      }
      _sectionService.update({
        'id': section.id,
        'adminUserId': _adminUserId,
        'userIds': _userIds,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> updateAdminUser({
    SectionModel section,
    UserModel user,
  }) async {
    if (user == null) return false;
    try {
      _sectionService.update({
        'id': section.id,
        'adminUserId': user.id,
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
