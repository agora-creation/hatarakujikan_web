import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hatarakujikan_web/models/user.dart';

class UserService {
  String _collection = 'user';
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

  Future<UserModel?> select({String? id}) async {
    UserModel? _user;
    await _firebaseFirestore
        .collection(_collection)
        .doc(id)
        .get()
        .then((value) {
      _user = UserModel.fromSnapshot(value);
    });
    return _user;
  }

  Future<List<UserModel>> selectList({
    required List<String> userIds,
    bool? smartphone,
  }) async {
    List<UserModel> _users = [];
    if (smartphone == null) {
      await _firebaseFirestore
          .collection(_collection)
          .orderBy('recordPassword', descending: false)
          .get()
          .then((value) {
        for (DocumentSnapshot<Map<String, dynamic>> _user in value.docs) {
          UserModel user = UserModel.fromSnapshot(_user);
          if (userIds.contains(user.id)) _users.add(user);
        }
      });
    } else {
      await _firebaseFirestore
          .collection(_collection)
          .where('smartphone', isEqualTo: smartphone)
          .orderBy('recordPassword', descending: false)
          .get()
          .then((value) {
        for (DocumentSnapshot<Map<String, dynamic>> _user in value.docs) {
          UserModel user = UserModel.fromSnapshot(_user);
          if (userIds.contains(user.id)) _users.add(user);
        }
      });
    }
    return _users;
  }
}
