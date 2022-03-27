import 'package:cloud_firestore/cloud_firestore.dart';

class GroupNoticeService {
  String _collection = 'group';
  String _subCollection = 'notice';
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  String id(String? groupId) {
    return _firebaseFirestore
        .collection(_collection)
        .doc(groupId)
        .collection(_subCollection)
        .doc()
        .id;
  }

  void create(Map<String, dynamic> values) {
    _firebaseFirestore
        .collection(_collection)
        .doc(values['groupId'])
        .collection(_subCollection)
        .doc(values['id'])
        .set(values);
  }

  void update(Map<String, dynamic> values) {
    _firebaseFirestore
        .collection(_collection)
        .doc(values['groupId'])
        .collection(_subCollection)
        .doc(values['id'])
        .update(values);
  }

  void delete(Map<String, dynamic> values) {
    _firebaseFirestore
        .collection(_collection)
        .doc(values['groupId'])
        .collection(_subCollection)
        .doc(values['id'])
        .delete();
  }
}
