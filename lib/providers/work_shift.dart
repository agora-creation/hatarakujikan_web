import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/models/work_shift.dart';
import 'package:hatarakujikan_web/services/work_shift.dart';

class WorkShiftProvider with ChangeNotifier {
  WorkShiftService _workShiftService = WorkShiftService();
  List<String> states = ['欠勤', '特別休暇', '有給休暇', '代休'];

  Future<bool> create({
    GroupModel group,
    UserModel user,
    DateTime startedAt,
    DateTime endedAt,
    String state,
  }) async {
    if (group == null) return false;
    if (user == null) return false;
    if (state == null) return false;
    try {
      String _id = _workShiftService.id();
      _workShiftService.create({
        'id': _id,
        'groupId': group.id,
        'userId': user.id,
        'startedAt': startedAt,
        'endedAt': endedAt,
        'state': state,
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
    UserModel user,
    DateTime startedAt,
    DateTime endedAt,
    String state,
  }) async {
    if (user == null) return false;
    if (state == null) return false;
    try {
      _workShiftService.update({
        'id': id,
        'userId': user.id,
        'startedAt': startedAt,
        'endedAt': endedAt,
        'state': state,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  void delete({String id}) {
    _workShiftService.delete({'id': id});
  }

  Future<List<WorkShiftModel>> selectList({
    GroupModel group,
    UserModel user,
    DateTime startAt,
    DateTime endAt,
  }) async {
    List<WorkShiftModel> _workShifts = [];
    await _workShiftService
        .selectList(
      groupId: group.id,
      userId: user.id,
      startAt: startAt,
      endAt: endAt,
    )
        .then((value) {
      _workShifts = value;
    });
    return _workShifts;
  }
}
