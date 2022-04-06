import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/models/position.dart';
import 'package:hatarakujikan_web/services/position.dart';

class PositionProvider with ChangeNotifier {
  PositionService _positionService = PositionService();

  Future<bool> create({
    String? groupId,
    String? name,
  }) async {
    if (groupId == null) return false;
    if (name == null) return false;
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
    String? id,
    String? name,
  }) async {
    if (id == null) return false;
    if (name == null) return false;
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

  Future<bool> delete({String? id}) async {
    if (id == null) return false;
    try {
      _positionService.delete({'id': id});
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> updateUserIds({
    String? id,
    List<String>? userIds,
  }) async {
    if (id == null) return false;
    if (userIds == null) return false;
    try {
      _positionService.update({
        'id': id,
        'userIds': userIds,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<List<PositionModel>> selectList({required String groupId}) async {
    List<PositionModel> _positions = [];
    await _positionService.selectList(groupId: groupId).then((value) {
      _positions = value;
    });
    return _positions;
  }
}
