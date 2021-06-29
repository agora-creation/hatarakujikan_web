import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hatarakujikan_web/models/work_state.dart';
import 'package:intl/intl.dart';

class WorkStateService {
  String _collection = 'workState';
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

  Future<void> updateMigration(String befUserId, String aftUserId) async {
    await _firebaseFirestore
        .collection(_collection)
        .where('userId', isEqualTo: befUserId)
        .get()
        .then((value) {
      for (DocumentSnapshot _work in value.docs) {
        _firebaseFirestore.collection(_collection).doc(_work.id).update({
          'userId': aftUserId,
        });
      }
    });
  }

  void delete(Map<String, dynamic> values) {
    _firebaseFirestore.collection(_collection).doc(values['id']).delete();
  }

  Future<List<WorkStateModel>> selectList({
    String groupId,
    String userId,
    DateTime startAt,
    DateTime endAt,
  }) async {
    List<WorkStateModel> _workStates = [];
    Timestamp _startAt = Timestamp.fromMillisecondsSinceEpoch(DateTime.parse(
            '${DateFormat('yyyy-MM-dd').format(startAt)} 00:00:00.000')
        .millisecondsSinceEpoch);
    Timestamp _endAt = Timestamp.fromMillisecondsSinceEpoch(
        DateTime.parse('${DateFormat('yyyy-MM-dd').format(endAt)} 23:59:59.999')
            .millisecondsSinceEpoch);
    await _firebaseFirestore
        .collection(_collection)
        .where('groupId', isEqualTo: groupId)
        .where('userId', isEqualTo: userId)
        .orderBy('startedAt', descending: false)
        .startAt([_startAt])
        .endAt([_endAt])
        .get()
        .then((value) {
          for (DocumentSnapshot _workState in value.docs) {
            _workStates.add(WorkStateModel.fromSnapshot(_workState));
          }
        });
    return _workStates;
  }
}
