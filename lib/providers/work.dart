import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/models/breaks.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/models/work.dart';
import 'package:hatarakujikan_web/services/log.dart';
import 'package:hatarakujikan_web/services/user.dart';
import 'package:hatarakujikan_web/services/work.dart';

class WorkProvider with ChangeNotifier {
  LogService _logService = LogService();
  UserService _userService = UserService();
  WorkService _workService = WorkService();

  Future<bool> create({
    WorkModel? work,
    List<BreaksModel>? breaks,
  }) async {
    if (work == null) return false;
    if (breaks == null) return false;
    UserModel? _user = await _userService.select(id: work.userId);
    if (_user == null) return false;
    if (work.startedAt == work.endedAt) return false;
    if (work.startedAt.millisecondsSinceEpoch >
        work.endedAt.millisecondsSinceEpoch) return false;
    try {
      List<Map> _breaks = [];
      for (BreaksModel _breaksModel in breaks) {
        String _breaksId = randomString(20);
        _breaks.add({
          'id': _breaksId,
          'startedAt': _breaksModel.startedAt,
          'startedLat': _breaksModel.startedLat,
          'startedLon': _breaksModel.startedLon,
          'endedAt': _breaksModel.endedAt,
          'endedLat': _breaksModel.endedLat,
          'endedLon': _breaksModel.endedLon,
        });
      }
      String _id = _workService.id();
      _workService.create({
        'id': _id,
        'groupId': work.groupId,
        'userId': work.userId,
        'startedAt': work.startedAt,
        'startedLat': work.startedLat,
        'startedLon': work.startedLon,
        'endedAt': work.endedAt,
        'endedLat': work.endedLat,
        'endedLon': work.endedLon,
        'breaks': _breaks,
        'state': work.state,
        'createdAt': DateTime.now(),
      });
      String _logId = _logService.id();
      String d = '';
      d += '[出勤] ${dateText('yyyy/MM/dd HH:mm', work.startedAt)}\n';
      d += '[退勤] ${dateText('yyyy/MM/dd HH:mm', work.endedAt)}\n';
      for (BreaksModel _breaksModel in breaks) {
        d += '[休憩開始] ${dateText('yyyy/MM/dd HH:mm', _breaksModel.startedAt)}\n';
        d += '[休憩終了] ${dateText('yyyy/MM/dd HH:mm', _breaksModel.endedAt)}\n';
      }
      _logService.create({
        'id': _logId,
        'groupId': work.groupId,
        'userId': work.userId,
        'userName': _user.name,
        'workId': _id,
        'title': '勤怠データを記録しました',
        'details': d.trim(),
        'createdAt': DateTime.now(),
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> update({
    WorkModel? work,
    List<BreaksModel>? breaks,
  }) async {
    if (work == null) return false;
    if (breaks == null) return false;
    UserModel? _user = await _userService.select(id: work.userId);
    if (_user == null) return false;
    if (work.startedAt == work.endedAt) return false;
    if (work.startedAt.millisecondsSinceEpoch >
        work.endedAt.millisecondsSinceEpoch) return false;
    try {
      List<Map> _breaks = [];
      for (BreaksModel _breaksModel in breaks) {
        String _breaksId = randomString(20);
        _breaks.add({
          'id': _breaksId,
          'startedAt': _breaksModel.startedAt,
          'startedLat': _breaksModel.startedLat,
          'startedLon': _breaksModel.startedLon,
          'endedAt': _breaksModel.endedAt,
          'endedLat': _breaksModel.endedLat,
          'endedLon': _breaksModel.endedLon,
        });
      }
      _workService.update({
        'id': work.id,
        'userId': work.userId,
        'startedAt': work.startedAt,
        'endedAt': work.endedAt,
        'breaks': _breaks,
        'state': work.state,
      });
      String _logId = _logService.id();
      String d = '';
      d += '[出勤] ${dateText('yyyy/MM/dd HH:mm', work.startedAt)}\n';
      d += '[退勤] ${dateText('yyyy/MM/dd HH:mm', work.endedAt)}\n';
      for (BreaksModel _breaksModel in breaks) {
        d += '[休憩開始] ${dateText('yyyy/MM/dd HH:mm', _breaksModel.startedAt)}\n';
        d += '[休憩終了] ${dateText('yyyy/MM/dd HH:mm', _breaksModel.endedAt)}\n';
      }
      _logService.create({
        'id': _logId,
        'groupId': work.groupId,
        'userId': work.userId,
        'userName': _user.name,
        'workId': work.id,
        'title': '勤怠データを修正しました',
        'details': d.trim(),
        'createdAt': DateTime.now(),
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> delete({WorkModel? work}) async {
    if (work == null) return false;
    UserModel? _user = await _userService.select(id: work.userId);
    if (_user == null) return false;
    try {
      _workService.delete({'id': work.id});
      String _logId = _logService.id();
      String d = '';
      d += '[出勤] ${dateText('yyyy/MM/dd HH:mm', work.startedAt)}\n';
      d += '[退勤] ${dateText('yyyy/MM/dd HH:mm', work.endedAt)}\n';
      for (BreaksModel _breaksModel in work.breaks) {
        d += '[休憩開始] ${dateText('yyyy/MM/dd HH:mm', _breaksModel.startedAt)}\n';
        d += '[休憩終了] ${dateText('yyyy/MM/dd HH:mm', _breaksModel.endedAt)}\n';
      }
      _logService.create({
        'id': _logId,
        'groupId': work.groupId,
        'userId': work.userId,
        'userName': _user.name,
        'workId': work.id,
        'title': '勤怠データを削除しました',
        'details': d.trim(),
        'createdAt': DateTime.now(),
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
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
        .where('groupId', isEqualTo: groupId ?? 'error')
        .where('userId', isEqualTo: user?.id ?? 'error')
        .orderBy('startedAt', descending: false)
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
        .where('groupId', isEqualTo: groupId ?? 'error')
        .where('userId', isEqualTo: user?.id ?? 'error')
        .orderBy('startedAt', descending: false)
        .startAt([_startAt]).endAt([_endAt]).snapshots();
    return _ret;
  }

  Future<List<WorkModel>> selectList({
    GroupModel? group,
    UserModel? user,
    DateTime? startAt,
    DateTime? endAt,
  }) async {
    List<WorkModel> _works = [];
    await _workService
        .selectList(
      groupId: group?.id,
      userId: user?.id,
      startAt: startAt,
      endAt: endAt,
    )
        .then((value) {
      _works = value;
    });
    return _works;
  }
}
