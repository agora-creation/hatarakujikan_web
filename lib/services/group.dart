import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hatarakujikan_web/models/group.dart';

class GroupService {
  String _collection = 'group';
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  void update(Map<String, dynamic> values) {
    _firebaseFirestore.collection(_collection).doc(values['id']).update(values);
  }

  Future<GroupModel> select({String groupId}) async {
    GroupModel _group;
    await _firebaseFirestore
        .collection(_collection)
        .doc(groupId)
        .get()
        .then((value) {
      _group = GroupModel.fromSnapshot(value);
    });
    return _group;
  }

  Future<List<GroupModel>> selectList({String adminUserId}) async {
    List<GroupModel> _groups = [];
    await _firebaseFirestore
        .collection(_collection)
        .where('adminUserId', isEqualTo: adminUserId)
        .orderBy('createdAt', descending: true)
        .get()
        .then((value) {
      for (DocumentSnapshot _group in value.docs) {
        _groups.add(GroupModel.fromSnapshot(_group));
      }
    });
    return _groups;
  }
}
