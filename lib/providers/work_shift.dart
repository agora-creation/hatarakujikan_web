import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/models/work_shift.dart';
import 'package:hatarakujikan_web/services/work_shift.dart';

class WorkShiftProvider with ChangeNotifier {
  WorkShiftService _workShiftService = WorkShiftService();

  Future<bool> create({WorkShiftModel? workShift}) async {
    if (workShift == null) return false;
    if (workShift.startedAt == workShift.endedAt) return false;
    if (workShift.startedAt.millisecondsSinceEpoch >
        workShift.endedAt.millisecondsSinceEpoch) return false;
    try {
      String _id = _workShiftService.id();
      _workShiftService.create({
        'id': _id,
        'groupId': workShift.groupId,
        'userId': workShift.userId,
        'startedAt': workShift.startedAt,
        'endedAt': workShift.endedAt,
        'state': workShift.state,
        'createdAt': DateTime.now(),
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> update({WorkShiftModel? workShift}) async {
    if (workShift == null) return false;
    if (workShift.startedAt == workShift.endedAt) return false;
    if (workShift.startedAt.millisecondsSinceEpoch >
        workShift.endedAt.millisecondsSinceEpoch) return false;
    try {
      _workShiftService.update({
        'id': workShift.id,
        'userId': workShift.userId,
        'startedAt': workShift.startedAt,
        'endedAt': workShift.endedAt,
        'state': workShift.state,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> delete({String? id}) async {
    if (id == null) return false;
    try {
      _workShiftService.delete({'id': id});
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? streamList({String? groupId}) {
    Stream<QuerySnapshot<Map<String, dynamic>>>? _ret;
    _ret = FirebaseFirestore.instance
        .collection('work')
        .where('groupId', isEqualTo: groupId ?? 'error')
        .orderBy('startedAt', descending: false)
        .snapshots();
    return _ret;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? streamListShift(
      {String? groupId}) {
    Stream<QuerySnapshot<Map<String, dynamic>>>? _ret;
    _ret = FirebaseFirestore.instance
        .collection('workShift')
        .where('groupId', isEqualTo: groupId ?? 'error')
        .orderBy('startedAt', descending: false)
        .snapshots();
    return _ret;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? streamListTotal({
    String? groupId,
    required DateTime month,
  }) {
    Stream<QuerySnapshot<Map<String, dynamic>>>? _ret;
    Timestamp _startAt = convertTimestamp(
      DateTime(month.year, month.month, 1),
      false,
    );
    Timestamp _endAt = convertTimestamp(
      DateTime(month.year, month.month + 1, 1).add(Duration(days: -1)),
      true,
    );
    _ret = FirebaseFirestore.instance
        .collection('work')
        .where('groupId', isEqualTo: groupId ?? 'error')
        .orderBy('startedAt', descending: false)
        .startAt([_startAt]).endAt([_endAt]).snapshots();
    return _ret;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? streamListShiftTotal({
    String? groupId,
    required DateTime month,
  }) {
    Stream<QuerySnapshot<Map<String, dynamic>>>? _ret;
    Timestamp _startAt = convertTimestamp(
      DateTime(month.year, month.month, 1),
      false,
    );
    Timestamp _endAt = convertTimestamp(
      DateTime(month.year, month.month + 1, 1).add(Duration(days: -1)),
      true,
    );
    _ret = FirebaseFirestore.instance
        .collection('workShift')
        .where('groupId', isEqualTo: groupId ?? 'error')
        .orderBy('startedAt', descending: false)
        .startAt([_startAt]).endAt([_endAt]).snapshots();
    return _ret;
  }

  Future<List<WorkShiftModel>> selectList({
    GroupModel? group,
    UserModel? user,
    DateTime? startAt,
    DateTime? endAt,
  }) async {
    List<WorkShiftModel> _workShifts = [];
    await _workShiftService
        .selectList(
      groupId: group?.id,
      userId: user?.id,
      startAt: startAt,
      endAt: endAt,
    )
        .then((value) {
      _workShifts = value;
    });
    return _workShifts;
  }
}
