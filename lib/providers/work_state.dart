import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/models/work_state.dart';
import 'package:hatarakujikan_web/services/work_state.dart';

class WorkStateProvider with ChangeNotifier {
  WorkStateService _workStateService = WorkStateService();
  List<String> _states = ['通常勤務', '直行/直帰', 'テレワーク', '欠勤', '特別休暇', '有給休暇'];

  List<String> get states => _states;

  Future<bool> create({
    String groupId,
    String userId,
    DateTime startedAt,
    String state,
  }) async {
    if (groupId == '') return false;
    if (userId == '') return false;
    try {
      String _id = _workStateService.id();
      _workStateService.create({
        'id': _id,
        'groupId': groupId,
        'userId': userId,
        'startedAt': startedAt,
        'state': state,
        'createdAt': DateTime.now(),
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  void delete({WorkStateModel workState}) {
    _workStateService.delete({'id': workState?.id});
  }

  Future<List<WorkStateModel>> selectList({
    String groupId,
    String userId,
    DateTime startAt,
    DateTime endAt,
  }) async {
    List<WorkStateModel> _workStates = [];
    await _workStateService
        .selectList(
      groupId: groupId,
      userId: userId,
      startAt: startAt,
      endAt: endAt,
    )
        .then((value) {
      _workStates = value;
    });
    return _workStates;
  }
}
