import 'package:cloud_firestore/cloud_firestore.dart';

class GroupNoticeService {
  String _collection = 'group';
  String _subCollection = 'notice';
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  String id(String groupId) {
    String _id = _firebaseFirestore
        .collection(_collection)
        .doc(groupId)
        .collection(_subCollection)
        .doc()
        .id;
    return _id;
  }

  void create(Map<String, dynamic> values) {
    _firebaseFirestore
        .collection(_collection)
        .doc(values['groupId'])
        .collection(_subCollection)
        .doc(values['id'])
        .set(values);
  }
}
