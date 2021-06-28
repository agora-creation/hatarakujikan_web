import 'package:cloud_firestore/cloud_firestore.dart';

class WorkStateModel {
  String _id;
  String _groupId;
  String _userId;
  DateTime _startedAt;
  String _state;
  DateTime _createdAt;

  String get id => _id;
  String get groupId => _groupId;
  String get userId => _userId;
  DateTime get startedAt => _startedAt;
  String get state => _state;
  DateTime get createdAt => _createdAt;

  WorkStateModel.fromSnapshot(DocumentSnapshot snapshot) {
    _id = snapshot.data()['id'];
    _groupId = snapshot.data()['groupId'];
    _userId = snapshot.data()['userId'];
    _startedAt = snapshot.data()['startedAt'].toDate();
    _state = snapshot.data()['state'];
    _createdAt = snapshot.data()['createdAt'].toDate();
  }
}
