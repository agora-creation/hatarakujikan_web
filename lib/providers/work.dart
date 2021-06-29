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
    if (groupId == '') return false;
    if (userId == '') return false;
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
          'startedDev': '管理画面',
          'endedAt': breakEndedAt,
          'endedLat': 0.0,
          'endedLon': 0.0,
          'endedDev': '管理画面',
        });
      }
      _workService.create({
        'id': _id,
        'groupId': groupId,
        'userId': userId,
        'startedAt': startedAt,
        'startedLat': 0.0,
        'startedLon': 0.0,
        'startedDev': '管理画面',
        'endedAt': endedAt,
        'endedLat': 0.0,
        'endedLon': 0.0,
        'endedDev': '管理画面',
        'breaks': _breaks,
        'state': '通常勤務',
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
    _workService.delete({'id': work?.id});
  }

  Future<List<WorkModel>> selectList({
    String groupId,
    String userId,
    DateTime startAt,
    DateTime endAt,
  }) async {
    List<WorkModel> _works = [];
    await _workService
        .selectList(
      groupId: groupId,
      userId: userId,
      startAt: startAt,
      endAt: endAt,
    )
        .then((value) {
      _works = value;
    });
    return _works;
  }
}
