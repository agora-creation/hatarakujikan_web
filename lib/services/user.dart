import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hatarakujikan_web/models/user.dart';

class UserService {
  String _collection = 'user';
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

  void delete(Map<String, dynamic> values) {
    _firebaseFirestore.collection(_collection).doc(values['id']).delete();
  }

  Future<UserModel> select({String userId}) async {
    DocumentSnapshot snapshot =
        await _firebaseFirestore.collection(_collection).doc(userId).get();
    return UserModel.fromSnapshot(snapshot);
  }
}
