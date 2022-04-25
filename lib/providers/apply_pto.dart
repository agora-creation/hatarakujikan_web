import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/define.dart';
import 'package:hatarakujikan_web/models/apply_pto.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/services/apply_pto.dart';
import 'package:hatarakujikan_web/services/work_shift.dart';

class ApplyPTOProvider with ChangeNotifier {
  ApplyPTOService _applyPTOService = ApplyPTOService();
  WorkShiftService _workShiftService = WorkShiftService();

  Future<bool> update({ApplyPTOModel? applyPTO}) async {
    if (applyPTO == null) return false;
    try {
      _applyPTOService.update({
        'id': applyPTO.id,
        'approval': true,
      });
      String _id = _workShiftService.id();
      _workShiftService.create({
        'id': _id,
        'groupId': applyPTO.groupId,
        'userId': applyPTO.userId,
        'startedAt': applyPTO.startedAt,
        'endedAt': applyPTO.endedAt,
        'state': workShiftStates[3],
        'createdAt': DateTime.now(),
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
      _applyPTOService.delete({'id': id});
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  UserModel? user;
  bool approval = false;

  void changeUser(UserModel value) {
    user = value;
    notifyListeners();
  }

  void changeApproval(bool value) {
    approval = value;
    notifyListeners();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? streamList({String? groupId}) {
    Stream<QuerySnapshot<Map<String, dynamic>>>? _ret;
    if (user == null) {
      _ret = FirebaseFirestore.instance
          .collection('applyPTO')
          .where('groupId', isEqualTo: groupId ?? 'error')
          .where('approval', isEqualTo: approval)
          .orderBy('createdAt', descending: true)
          .snapshots();
    } else {
      _ret = FirebaseFirestore.instance
          .collection('applyPTO')
          .where('groupId', isEqualTo: groupId ?? 'error')
          .where('userId', isEqualTo: user?.id ?? 'error')
          .where('approval', isEqualTo: approval)
          .orderBy('createdAt', descending: true)
          .snapshots();
    }
    return _ret;
  }
}
