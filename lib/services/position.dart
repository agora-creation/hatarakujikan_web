import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hatarakujikan_web/models/position.dart';

class PositionService {
  String _collection = 'position';
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

  void delete(Map<String, dynamic> values) {
    _firebaseFirestore.collection(_collection).doc(values['id']).delete();
  }

  Future<List<PositionModel>> selectList({String? groupId}) async {
    List<PositionModel> _positions = [];
    await _firebaseFirestore
        .collection(_collection)
        .where('groupId', isEqualTo: groupId)
        .orderBy('createdAt', descending: true)
        .get()
        .then((value) {
      for (DocumentSnapshot<Map<String, dynamic>> _position in value.docs) {
        _positions.add(PositionModel.fromSnapshot(_position));
      }
    });
    return _positions;
  }
}
