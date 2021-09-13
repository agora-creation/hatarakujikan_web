import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/models/work_shift.dart';

class WorkShiftService {
  String _collection = 'workShift';
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  String id() {
    String _id = _firebaseFirestore.collection(_collection).doc().id;
    return _id;
  }

  void create(Map<String, dynamic> values) {
    _firebaseFirestore.collection(_collection).doc(values['id']).set(values);
  }

  void update(Map<String, dynamic> values) {
    _firebaseFirestore.collection(_collection).doc(values['id']).update(values);
  }

  Future<void> updateMigration(String before, String after) async {
    await _firebaseFirestore
        .collection(_collection)
        .where('userId', isEqualTo: before)
        .get()
        .then((value) {
      for (DocumentSnapshot _doc in value.docs) {
        _firebaseFirestore.collection(_collection).doc(_doc.id).update({
          'userId': after,
        });
      }
    });
  }

  void delete(Map<String, dynamic> values) {
    _firebaseFirestore.collection(_collection).doc(values['id']).delete();
  }

  Future<List<WorkShiftModel>> selectList({
    String groupId,
    String userId,
    DateTime startAt,
    DateTime endAt,
  }) async {
    List<WorkShiftModel> _workShifts = [];
    Timestamp _startAt = convertTimestamp(startAt, false);
    Timestamp _endAt = convertTimestamp(endAt, true);
    await _firebaseFirestore
        .collection(_collection)
        .where('groupId', isEqualTo: groupId)
        .where('userId', isEqualTo: userId)
        .orderBy('startedAt', descending: false)
        .startAt([_startAt])
        .endAt([_endAt])
        .get()
        .then((value) {
          for (DocumentSnapshot _workShift in value.docs) {
            _workShifts.add(WorkShiftModel.fromSnapshot(_workShift));
          }
        });
    return _workShifts;
  }
}
