import 'package:cloud_firestore/cloud_firestore.dart';

class PositionModel {
  String _id;
  String _groupId;
  String _name;
  DateTime _createdAt;

  String get id => _id;
  String get groupId => _groupId;
  String get name => _name;
  DateTime get createdAt => _createdAt;

  PositionModel.fromSnapshot(DocumentSnapshot snapshot) {
    _id = snapshot.data()['id'];
    _groupId = snapshot.data()['groupId'];
    _name = snapshot.data()['name'];
    _createdAt = snapshot.data()['createdAt'].toDate();
  }
}
