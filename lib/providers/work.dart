import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/define.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/models/breaks.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/models/work.dart';
import 'package:hatarakujikan_web/services/work.dart';

class WorkProvider with ChangeNotifier {
  WorkService _workService = WorkService();

  Future<bool> create({
    required GroupModel group,
    required UserModel user,
    required DateTime startedAt,
    required DateTime endedAt,
    required bool isBreaks,
    required DateTime breakStartedAt,
    required DateTime breakEndedAt,
  }) async {
    if (group.id == '') return false;
    if (user.id == '') return false;
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
        'state': workStates.first,
        'createdAt': DateTime.now(),
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> update({
    required WorkModel work,
    required bool isBreaks,
    required DateTime breakStartedAt,
    required DateTime breakEndedAt,
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

  void delete({required String id}) {
    _workService.delete({'id': id});
  }

  Future<List<WorkModel>> selectList({
    required GroupModel group,
    required UserModel user,
    required DateTime startAt,
    required DateTime endAt,
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

  DateTime month = DateTime.now();
  UserModel? user;
  List<DateTime> days = generateDays(DateTime.now());

  void changeMonth(DateTime value) {
    month = value;
    days = generateDays(month);
    notifyListeners();
  }

  void changeUser(UserModel value) {
    user = value;
    notifyListeners();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? streamList({String? groupId}) {
    Stream<QuerySnapshot<Map<String, dynamic>>>? _ret;
    Timestamp _startAt = convertTimestamp(days.first, false);
    Timestamp _endAt = convertTimestamp(days.last, true);
    _ret = FirebaseFirestore.instance
        .collection('work')
        .where('groupId', isEqualTo: groupId)
        .where('userId', isEqualTo: user?.id)
        .orderBy('startedAt', descending: true)
        .startAt([_startAt]).endAt([_endAt]).snapshots();
    return _ret;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? streamListShift(
      {String? groupId}) {
    Stream<QuerySnapshot<Map<String, dynamic>>>? _ret;
    Timestamp _startAt = convertTimestamp(days.first, false);
    Timestamp _endAt = convertTimestamp(days.last, true);
    _ret = FirebaseFirestore.instance
        .collection('workShift')
        .where('groupId', isEqualTo: groupId)
        .where('userId', isEqualTo: user?.id)
        .orderBy('startedAt', descending: true)
        .startAt([_startAt]).endAt([_endAt]).snapshots();
    return _ret;
  }
}
