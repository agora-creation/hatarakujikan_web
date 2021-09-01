import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hatarakujikan_web/models/section.dart';

class SectionService {
  String _collection = 'section';
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

  Future<SectionModel> select({String id}) async {
    SectionModel _section;
    await _firebaseFirestore
        .collection(_collection)
        .doc(id)
        .get()
        .then((value) {
      _section = SectionModel.fromSnapshot(value);
    });
    return _section;
  }

  Future<List<SectionModel>> selectListAdminUser({String adminUserId}) async {
    List<SectionModel> _sections = [];
    await _firebaseFirestore
        .collection(_collection)
        .where('adminUserId', isEqualTo: adminUserId)
        .orderBy('createdAt', descending: true)
        .get()
        .then((value) {
      for (DocumentSnapshot _section in value.docs) {
        _sections.add(SectionModel.fromSnapshot(_section));
      }
    });
    return _sections;
  }
}
