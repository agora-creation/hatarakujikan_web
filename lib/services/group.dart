import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hatarakujikan_web/models/group.dart';

class GroupService {
  String _collection = 'group';
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  void update(Map<String, dynamic> values) {
    _firebaseFirestore.collection(_collection).doc(values['id']).update(values);
  }

  Future<GroupModel> select({String groupId}) async {
    DocumentSnapshot snapshot =
        await _firebaseFirestore.collection(_collection).doc(groupId).get();
    return GroupModel.fromSnapshot(snapshot);
  }

  Future<List<GroupModel>> selectList({String adminUserId}) async {
    List<GroupModel> _groups = [];
    QuerySnapshot snapshot = await _firebaseFirestore
        .collection(_collection)
        .where('adminUserId', isEqualTo: adminUserId)
        .orderBy('createdAt', descending: true)
        .get();
    for (DocumentSnapshot _group in snapshot.docs) {
      _groups.add(GroupModel.fromSnapshot(_group));
    }
    return _groups;
  }
}
