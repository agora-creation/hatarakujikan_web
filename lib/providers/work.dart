import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/models/breaks.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/models/work.dart';
import 'package:hatarakujikan_web/services/work.dart';

class WorkProvider with ChangeNotifier {
  WorkService _workService = WorkService();
  List<String> states = ['通常勤務', '直行/直帰', 'テレワーク'];

  Future<bool> create({
    GroupModel group,
    UserModel user,
    DateTime startedAt,
    DateTime endedAt,
    bool isBreaks,
    DateTime breakStartedAt,
    DateTime breakEndedAt,
  }) async {
    if (group == null) return false;
    if (user == null) return false;
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
        'groupId': group.id,
        'userId': user.id,
        'startedAt': startedAt,
        'startedLat': 0.0,
        'startedLon': 0.0,
        'endedAt': endedAt,
        'endedLat': 0.0,
        'endedLon': 0.0,
        'breaks': _breaks,
        'state': states.first,
        'createdAt': DateTime.now(),
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> update({
    WorkModel work,
    bool isBreaks,
    DateTime breakStartedAt,
    DateTime breakEndedAt,
  }) async {
    try {
      List<Map> _breaks = [];
      for (BreaksModel breaks in work.breaks) {
        _breaks.add(breaks.toMap());
      }
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
      _workService.update({
        'id': work.id,
        'startedAt': work.startedAt,
        'endedAt': work.endedAt,
        'breaks': _breaks,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  void delete({String id}) {
    _workService.delete({'id': id});
  }

  Future<List<WorkModel>> selectList({
    GroupModel group,
    UserModel user,
    DateTime startAt,
    DateTime endAt,
  }) async {
    List<WorkModel> _works = [];
    await _workService
        .selectList(
      groupId: group.id,
      userId: user.id,
      startAt: startAt,
      endAt: endAt,
    )
        .then((value) {
      _works = value;
    });
    return _works;
  }
}
