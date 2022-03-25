import 'package:cloud_firestore/cloud_firestore.dart';

class UserNoticeModel {
  String _id = '';
  String _groupId = '';
  String _userId = '';
  String _title = '';
  String _message = '';
  bool _read = false;
  DateTime _createdAt = DateTime.now();

  String get id => _id;
  String get groupId => _groupId;
  String get userId => _userId;
  String get title => _title;
  String get message => _message;
  bool get read => _read;
  DateTime get createdAt => _createdAt;

  UserNoticeModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    _id = snapshot.data()!['id'] ?? '';
    _groupId = snapshot.data()!['groupId'] ?? '';
    _userId = snapshot.data()!['userId'] ?? '';
    _title = snapshot.data()!['title'] ?? '';
    _message = snapshot.data()!['message'] ?? '';
    _read = snapshot.data()!['read'] ?? false;
    _createdAt = snapshot.data()!['createdAt'].toDate() ?? DateTime.now();
  }
}
