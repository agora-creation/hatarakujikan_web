import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  String _id;
  String _name;
  String _adminUserId;
  DateTime _createdAt;

  String get id => _id;
  String get name => _name;
  String get adminUserId => _adminUserId;
  DateTime get createdAt => _createdAt;

  GroupModel.fromSnapshot(DocumentSnapshot snapshot) {
    _id = snapshot.data()['id'];
    _name = snapshot.data()['name'];
    _adminUserId = snapshot.data()['adminUserId'];
    _createdAt = snapshot.data()['createdAt'].toDate();
  }
}
