import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String _id = '';
  String _number = '';
  String _name = '';
  String _email = '';
  String _password = '';
  String _recordPassword = '';
  int _workLv = 0;
  String _lastWorkId = '';
  String _lastBreakId = '';
  bool _autoWorkEnd = false;
  String _autoWorkEndTime = '00:00';
  String _token = '';
  bool _smartphone = false;
  bool _retired = false;
  DateTime _createdAt = DateTime.now();

  String get id => _id;
  String get number => _number;
  String get name => _name;
  String get email => _email;
  String get password => _password;
  String get recordPassword => _recordPassword;
  int get workLv => _workLv;
  String get lastWorkId => _lastWorkId;
  String get lastBreakId => _lastBreakId;
  bool get autoWorkEnd => _autoWorkEnd;
  String get autoWorkEndTime => _autoWorkEndTime;
  String get token => _token;
  bool get smartphone => _smartphone;
  bool get retired => _retired;
  DateTime get createdAt => _createdAt;

  UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    _id = snapshot.data()!['id'] ?? '';
    _number = snapshot.data()!['number'] ?? '';
    _name = snapshot.data()!['name'] ?? '';
    _email = snapshot.data()!['email'] ?? '';
    _password = snapshot.data()!['password'] ?? '';
    _recordPassword = snapshot.data()!['recordPassword'] ?? '';
    _workLv = snapshot.data()!['workLv'] ?? 0;
    _lastWorkId = snapshot.data()!['lastWorkId'] ?? '';
    _lastBreakId = snapshot.data()!['lastBreakId'] ?? '';
    _autoWorkEnd = snapshot.data()!['autoWorkEnd'] ?? false;
    _autoWorkEndTime = snapshot.data()!['autoWorkEndTime'] ?? '00:00';
    _token = snapshot.data()!['token'] ?? '';
    _smartphone = snapshot.data()!['smartphone'] ?? false;
    _retired = snapshot.data()!['retired'] ?? false;
    _createdAt = snapshot.data()!['createdAt'].toDate() ?? DateTime.now();
  }
}
