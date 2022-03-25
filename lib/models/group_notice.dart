import 'package:cloud_firestore/cloud_firestore.dart';

class GroupNoticeModel {
  String _id = '';
  String _groupId = '';
  String _title = '';
  String _message = '';
  DateTime _createdAt = DateTime.now();

  String get id => _id;
  String get groupId => _groupId;
  String get title => _title;
  String get message => _message;
  DateTime get createdAt => _createdAt;

  GroupNoticeModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    _id = snapshot.data()!['id'] ?? '';
    _groupId = snapshot.data()!['groupId'] ?? '';
    _title = snapshot.data()!['title'] ?? '';
    _message = snapshot.data()!['message'] ?? '';
    _createdAt = snapshot.data()!['createdAt'].toDate() ?? DateTime.now();
  }
}
