import 'package:cloud_firestore/cloud_firestore.dart';

class ApplyPTOModel {
  String _id = '';
  String _groupId = '';
  String _userId = '';
  String _userName = '';
  DateTime _startedAt = DateTime.now();
  DateTime _endedAt = DateTime.now();
  String _reason = '';
  bool _approval = false;
  DateTime _createdAt = DateTime.now();

  String get id => _id;
  String get groupId => _groupId;
  String get userId => _userId;
  String get userName => _userName;
  DateTime get startedAt => _startedAt;
  DateTime get endedAt => _endedAt;
  String get reason => _reason;
  bool get approval => _approval;
  DateTime get createdAt => _createdAt;

  ApplyPTOModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    _id = snapshot.data()!['id'] ?? '';
    _groupId = snapshot.data()!['groupId'] ?? '';
    _userId = snapshot.data()!['userId'] ?? '';
    _userName = snapshot.data()!['userName'] ?? '';
    _startedAt = snapshot.data()!['startedAt'].toDate() ?? DateTime.now();
    _endedAt = snapshot.data()!['endedAt'].toDate() ?? DateTime.now();
    _reason = snapshot.data()!['reason'] ?? '';
    _approval = snapshot.data()!['approval'] ?? false;
    _createdAt = snapshot.data()!['createdAt'].toDate() ?? DateTime.now();
  }
}
