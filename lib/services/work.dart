import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hatarakujikan_web/models/work.dart';
import 'package:intl/intl.dart';

class WorkService {
  String _collection = 'work';
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

  Future<WorkModel> select({String id}) async {
    WorkModel _work;
    await _firebaseFirestore
        .collection(_collection)
        .doc(id)
        .get()
        .then((value) {
      _work = WorkModel.fromSnapshot(value);
    });
    return _work;
  }

  Future<List<WorkModel>> selectListStartEnd({
    String groupId,
    String userId,
    DateTime startAt,
    DateTime endAt,
  }) async {
    List<WorkModel> _works = [];
    Timestamp _startAt = Timestamp.fromMillisecondsSinceEpoch(DateTime.parse(
      '${DateFormat('yyyy-MM-dd').format(startAt)} 00:00:00.000',
    ).millisecondsSinceEpoch);
    Timestamp _endAt = Timestamp.fromMillisecondsSinceEpoch(DateTime.parse(
      '${DateFormat('yyyy-MM-dd').format(endAt)} 23:59:59.999',
    ).millisecondsSinceEpoch);
    await _firebaseFirestore
        .collection(_collection)
        .where('groupId', isEqualTo: groupId)
        .where('userId', isEqualTo: userId)
        .orderBy('startedAt', descending: false)
        .startAt([_startAt])
        .endAt([_endAt])
        .get()
        .then((value) {
          for (DocumentSnapshot _work in value.docs) {
            _works.add(WorkModel.fromSnapshot(_work));
          }
        });
    return _works;
  }
}
