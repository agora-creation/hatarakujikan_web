import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hatarakujikan_web/models/group.dart';

class GroupService {
  String _collection = 'group';
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  void update(Map<String, dynamic> values) {
    _firebaseFirestore.collection(_collection).doc(values['id']).update(values);
  }

  Future<GroupModel?> select({String? id}) async {
    GroupModel? _group;
    await _firebaseFirestore
        .collection(_collection)
        .doc(id)
        .get()
        .then((value) {
      _group = GroupModel.fromSnapshot(value);
    });
    return _group;
  }

  Future<List<GroupModel>> selectListAdminUser(String? userId) async {
    List<GroupModel> _groups = [];
    await _firebaseFirestore
        .collection(_collection)
        .where('adminUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get()
        .then((value) {
      for (DocumentSnapshot<Map<String, dynamic>> _data in value.docs) {
        _groups.add(GroupModel.fromSnapshot(_data));
      }
    });
    print(_groups.length);
    return _groups;
  }
}
