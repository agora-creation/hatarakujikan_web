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

  Future<UserModel> select({String id}) async {
    UserModel _user;
    await _firebaseFirestore
        .collection(_collection)
        .doc(id)
        .get()
        .then((value) {
      _user = UserModel.fromSnapshot(value);
    });
    return _user;
  }

  Future<List<UserModel>> selectList({List<String> userIds}) async {
    List<UserModel> _users = [];
    for (String _id in userIds) {
      await _firebaseFirestore
          .collection(_collection)
          .where('id', isEqualTo: _id)
          .orderBy('recordPassword', descending: false)
          .get()
          .then((value) {
        for (DocumentSnapshot _user in value.docs) {
          _users.add(UserModel.fromSnapshot(_user));
        }
      });
    }
    return _users;
  }
}
