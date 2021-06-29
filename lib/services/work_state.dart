import 'package:cloud_firestore/cloud_firestore.dart';

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
}
