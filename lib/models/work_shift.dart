import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WorkShiftModel {
  String _id;
  String _groupId;
  String _userId;
  DateTime _startedAt;
  DateTime _endedAt;
  String _state;
  DateTime _createdAt;

  String get id => _id;
  String get groupId => _groupId;
  String get userId => _userId;
  DateTime get startedAt => _startedAt;
  DateTime get endedAt => _endedAt;
  String get state => _state;
  DateTime get createdAt => _createdAt;

  WorkShiftModel.fromSnapshot(DocumentSnapshot snapshot) {
    _id = snapshot.data()['id'];
    _groupId = snapshot.data()['groupId'];
    _userId = snapshot.data()['userId'];
    _startedAt = snapshot.data()['startedAt'].toDate();
    _endedAt = snapshot.data()['endedAt'].toDate();
    _state = snapshot.data()['state'];
    _createdAt = snapshot.data()['createdAt'].toDate();
  }

  Color stateColor() {
    switch (_state) {
      case '欠勤':
        return Colors.red;
      case '特別休暇':
        return Colors.green;
      case '有給休暇':
        return Colors.teal;
      case '代休':
        return Colors.pink;
      default:
        return Colors.red;
    }
  }
}
