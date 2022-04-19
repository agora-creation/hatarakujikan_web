import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/models/work.dart';

class WorkService {
  String _collection = 'work';
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  String id() {
    return _firebaseFirestore.collection(_collection).doc().id;
  }

  void create(Map<String, dynamic> values) {
    _firebaseFirestore.collection(_collection).doc(values['id']).set(values);
  }

  void update(Map<String, dynamic> values) {
    _firebaseFirestore.collection(_collection).doc(values['id']).update(values);
  }

  Future updateMigration({
    String? beforeUserId,
    String? afterUserId,
  }) async {
    await _firebaseFirestore
        .collection(_collection)
        .where('userId', isEqualTo: beforeUserId)
        .get()
        .then((value) {
      for (DocumentSnapshot _doc in value.docs) {
        _firebaseFirestore.collection(_collection).doc(_doc.id).update({
          'userId': afterUserId,
        });
      }
    });
  }

  void delete(Map<String, dynamic> values) {
    _firebaseFirestore.collection(_collection).doc(values['id']).delete();
  }

  Future<WorkModel?> select({String? id}) async {
    WorkModel? _work;
    await _firebaseFirestore
        .collection(_collection)
        .doc(id)
        .get()
        .then((value) {
      _work = WorkModel.fromSnapshot(value);
    });
    return _work;
  }

  Future<List<WorkModel>> selectList({
    String? groupId,
    String? userId,
    DateTime? startAt,
    DateTime? endAt,
  }) async {
    List<WorkModel> _works = [];
    Timestamp _startAt = convertTimestamp(startAt!, false);
    Timestamp _endAt = convertTimestamp(endAt!, true);
    await _firebaseFirestore
        .collection(_collection)
        .where('groupId', isEqualTo: groupId)
        .where('userId', isEqualTo: userId)
        .orderBy('startedAt', descending: false)
        .startAt([_startAt])
        .endAt([_endAt])
        .get()
        .then((value) {
          for (DocumentSnapshot<Map<String, dynamic>> _work in value.docs) {
            _works.add(WorkModel.fromSnapshot(_work));
          }
        });
    return _works;
  }
}
