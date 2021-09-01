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

  Future<List<UserModel>> selectListGroupId({String groupId}) async {
    List<UserModel> _users = [];
    await _firebaseFirestore
        .collection(_collection)
        .where('groups', arrayContains: groupId)
        .orderBy('recordPassword', descending: false)
        .get()
        .then((value) {
      for (DocumentSnapshot _user in value.docs) {
        _users.add(UserModel.fromSnapshot(_user));
      }
    });
    return _users;
  }

  Future<List<UserModel>> selectListGroupIdSP({
    String groupId,
    bool smartphone,
  }) async {
    List<UserModel> _users = [];
    await _firebaseFirestore
        .collection(_collection)
        .where('groups', arrayContains: groupId)
        .where('smartphone', isEqualTo: smartphone)
        .orderBy('recordPassword', descending: false)
        .get()
        .then((value) {
      for (DocumentSnapshot _user in value.docs) {
        _users.add(UserModel.fromSnapshot(_user));
      }
    });
    return _users;
  }

  Future<List<UserModel>> selectListUserIdsSP({
    List<String> userIds,
    bool smartphone,
  }) async {
    List<UserModel> _users = [];
    for (String _id in userIds) {
      await _firebaseFirestore
          .collection(_collection)
          .where('id', isEqualTo: _id)
          .where('smartphone', isEqualTo: smartphone)
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

  Future<List<UserModel>> selectListGroupIdNotice({
    String groupId,
    String noticeId,
  }) async {
    List<UserModel> _users = [];
    await _firebaseFirestore
        .collection(_collection)
        .where('groups', arrayContains: groupId)
        .where('smartphone', isEqualTo: true)
        .orderBy('recordPassword', descending: false)
        .get()
        .then((value) async {
      for (DocumentSnapshot _user in value.docs) {
        UserModel user = UserModel.fromSnapshot(_user);
        DocumentSnapshot noticeSnapshot = await _firebaseFirestore
            .collection(_collection)
            .doc(user.id)
            .collection('notice')
            .doc(noticeId)
            .get();
        if (noticeSnapshot.exists == false) {
          _users.add(UserModel.fromSnapshot(_user));
        }
      }
    });
    return _users;
  }
}
