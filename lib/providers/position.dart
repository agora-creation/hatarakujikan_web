import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/models/position.dart';
import 'package:hatarakujikan_web/services/position.dart';

class PositionProvider with ChangeNotifier {
  PositionService _positionService = PositionService();

  Future<bool> create() async {
    try {
      String _id = _positionService.id();
      _positionService.create({
        'id': _id,
        'groupId': '',
        'name': '',
        'createdAt': DateTime.now(),
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> update() async {
    try {
      _positionService.update({
        'id': '',
        'name': '',
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  void delete({PositionModel position}) {
    _positionService.delete({'id': position.id});
  }
}
