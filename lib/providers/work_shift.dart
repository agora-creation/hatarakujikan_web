import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/models/work_shift.dart';
import 'package:hatarakujikan_web/services/work_shift.dart';

class WorkShiftProvider with ChangeNotifier {
  WorkShiftService _workShiftService = WorkShiftService();

  Future<bool> create({
    required GroupModel group,
    required UserModel user,
    required DateTime startedAt,
    required DateTime endedAt,
    required String state,
  }) async {
    if (group.id == '') return false;
    if (user.id == '') return false;
    if (state == '') return false;
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
    required String id,
    required UserModel user,
    required DateTime startedAt,
    required DateTime endedAt,
    required String state,
  }) async {
    if (user.id == '') return false;
    if (state == '') return false;
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

  void delete({required String id}) {
    _workShiftService.delete({'id': id});
  }

  Future<List<WorkShiftModel>> selectList({
    required GroupModel group,
    required UserModel user,
    required DateTime startAt,
    required DateTime endAt,
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
