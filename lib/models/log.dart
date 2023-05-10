import 'package:cloud_firestore/cloud_firestore.dart';

class LogModel {
  String _id = '';
  String _groupId = '';
  String _userId = '';
  String _userName = '';
  String _workId = '';
  String _title = '';
  String _details = '';
  DateTime _createdAt = DateTime.now();

  String get id => _id;
  String get groupId => _groupId;
  String get userId => _userId;
  String get userName => _userName;
  String get workId => _workId;
  String get title => _title;
  String get details => _details;
  DateTime get createdAt => _createdAt;

  LogModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    _id = snapshot.data()!['id'] ?? '';
    _groupId = snapshot.data()!['groupId'] ?? '';
    _userId = snapshot.data()!['userId'] ?? '';
    _userName = snapshot.data()!['userName'] ?? '';
    _workId = snapshot.data()!['workId'] ?? '';
    _title = snapshot.data()!['title'] ?? '';
    _details = snapshot.data()!['details'] ?? '';
    _createdAt = snapshot.data()!['createdAt'].toDate() ?? DateTime.now();
  }
}
