import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/models/apply_work.dart';
import 'package:hatarakujikan_web/models/breaks.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/services/apply_work.dart';
import 'package:hatarakujikan_web/services/work.dart';

class ApplyWorkProvider with ChangeNotifier {
  ApplyWorkService _applyWorkService = ApplyWorkService();
  WorkService _workService = WorkService();

  Future<bool> update({ApplyWorkModel? applyWork}) async {
    if (applyWork == null) return false;
    try {
      _applyWorkService.update({
        'id': applyWork.id,
        'approval': true,
      });
      List<Map> _breaks = [];
      for (BreaksModel breaks in applyWork.breaks) {
        _breaks.add(breaks.toMap());
      }
      _workService.update({
        'id': applyWork.workId,
        'startedAt': applyWork.startedAt,
        'endedAt': applyWork.endedAt,
        'breaks': _breaks,
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
      _applyWorkService.delete({'id': id});
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
          .collection('applyWork')
          .where('groupId', isEqualTo: groupId ?? 'error')
          .where('approval', isEqualTo: approval)
          .orderBy('createdAt', descending: true)
          .snapshots();
    } else {
      _ret = FirebaseFirestore.instance
          .collection('applyWork')
          .where('groupId', isEqualTo: groupId ?? 'error')
          .where('userId', isEqualTo: user?.id ?? 'error')
          .where('approval', isEqualTo: approval)
          .orderBy('createdAt', descending: true)
          .snapshots();
    }
    return _ret;
  }
}
