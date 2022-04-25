import 'package:cloud_firestore/cloud_firestore.dart';

class ApplyPTOService {
  String _collection = 'applyPTO';
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  void update(Map<String, dynamic> values) {
    _firebaseFirestore.collection(_collection).doc(values['id']).update(values);
  }

  void delete(Map<String, dynamic> values) {
    _firebaseFirestore.collection(_collection).doc(values['id']).delete();
  }
}
