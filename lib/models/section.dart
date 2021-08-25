import 'package:cloud_firestore/cloud_firestore.dart';

class SectionModel {
  String _id;
  String _groupId;
  String _name;
  String _adminUserId;
  List<String> userIds;
  DateTime _createdAt;

  String get id => _id;
  String get groupId => _groupId;
  String get name => _name;
  String get adminUserId => _adminUserId;
  DateTime get createdAt => _createdAt;

  SectionModel.fromSnapshot(DocumentSnapshot snapshot) {
    _id = snapshot.data()['id'];
    _groupId = snapshot.data()['groupId'];
    _name = snapshot.data()['name'];
    _adminUserId = snapshot.data()['adminUserId'];
    userIds = _convertList(snapshot.data()['userIds']) ?? [];
    _createdAt = snapshot.data()['createdAt'].toDate();
  }

  List<String> _convertList(List list) {
    List<String> converted = [];
    for (String data in list) {
      converted.add(data);
    }
    return converted;
  }
}
