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
    WorkShiftModel workShift,
    DateTime startedAt,
    DateTime endedAt,
    String state,
  }) async {
    if (workShift == null) return false;
    if (state == null) return false;
    try {
      _workShiftService.update({
        'id': workShift.id,
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

  void delete({WorkShiftModel workShift}) {
    _workShiftService.delete({'id': workShift.id});
  }

  Future<List<WorkShiftModel>> selectList({
    String groupId,
    String userId,
    DateTime startAt,
    DateTime endAt,
  }) async {
    List<WorkShiftModel> _workShifts = [];
    await _workShiftService
        .selectList(
      groupId: groupId,
      userId: userId,
      startAt: startAt,
      endAt: endAt,
    )
        .then((value) {
      _workShifts = value;
    });
    return _workShifts;
  }
}
