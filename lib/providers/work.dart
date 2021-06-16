import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/models/breaks.dart';
import 'package:hatarakujikan_web/models/work.dart';
import 'package:hatarakujikan_web/services/work.dart';

class WorkProvider with ChangeNotifier {
  WorkService _workService = WorkService();

  Future<bool> create({
    String groupId,
    String userId,
    DateTime startedAt,
    DateTime endedAt,
    bool isBreaks,
    DateTime breakStartedAt,
    DateTime breakEndedAt,
  }) async {
    try {
      String _id = _workService.id();
      List<Map> _breaks = [];
      if (isBreaks) {
        String _breaksId = randomString(20);
        _breaks.add({
          'id': _breaksId,
          'startedAt': breakStartedAt,
          'startedLat': 0.0,
          'startedLon': 0.0,
          'endedAt': breakEndedAt,
          'endedLat': 0.0,
          'endedLon': 0.0,
        });
      }
      _workService.create({
        'id': _id,
        'groupId': groupId,
        'userId': userId,
        'startedAt': startedAt,
        'startedLat': 0.0,
        'startedLon': 0.0,
        'endedAt': endedAt,
        'endedLat': 0.0,
        'endedLon': 0.0,
        'breaks': _breaks,
        'createdAt': DateTime.now(),
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> update({WorkModel work}) async {
    try {
      List<Map> _breaks = [];
      for (BreaksModel breaks in work?.breaks) {
        _breaks.add(breaks.toMap());
      }
      _workService.update({
        'id': work?.id,
        'startedAt': work?.startedAt,
        'endedAt': work?.endedAt,
        'breaks': _breaks,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  void delete({WorkModel work}) {
    _workService.delete({'id': work.id});
  }
}
