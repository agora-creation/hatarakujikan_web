import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/models/position.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/services/position.dart';

class PositionProvider with ChangeNotifier {
  PositionService _positionService = PositionService();

  Future<bool> create({
    String groupId,
    String name,
  }) async {
    if (groupId == '') return false;
    if (name == '') return false;
    try {
      String _id = _positionService.id();
      _positionService.create({
        'id': _id,
        'groupId': groupId,
        'name': name,
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
      _positionService.update({
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
    PositionModel position,
    List<UserModel> users,
  }) async {
    try {
      List<String> _userIds = [];
      for (UserModel _user in users) {
        _userIds.add(_user.id);
      }
      _positionService.update({
        'id': position.id,
        'userIds': _userIds,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  void delete({String id}) {
    _positionService.delete({'id': id});
  }

  Future<List<PositionModel>> selectList({String groupId}) async {
    List<PositionModel> _positions = [];
    await _positionService.selectList(groupId: groupId).then((value) {
      _positions = value;
    });
    return _positions;
  }
}