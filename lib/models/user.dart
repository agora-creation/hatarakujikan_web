import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String _id;
  String _number;
  String _name;
  String _email;
  String _password;
  String _recordPassword;
  int _workLv;
  String _lastWorkId;
  String _lastBreakId;
  String _token;
  bool _smartphone;
  DateTime _createdAt;

  String get id => _id;
  String get number => _number;
  String get name => _name;
  String get email => _email;
  String get password => _password;
  String get recordPassword => _recordPassword;
  int get workLv => _workLv;
  String get lastWorkId => _lastWorkId;
  String get lastBreakId => _lastBreakId;
  String get token => _token;
  bool get smartphone => _smartphone;
  DateTime get createdAt => _createdAt;

  UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    _id = snapshot.data()['id'];
    _number = snapshot.data()['number'] ?? '';
    _name = snapshot.data()['name'];
    _email = snapshot.data()['email'] ?? '';
    _password = snapshot.data()['password'] ?? '';
    _recordPassword = snapshot.data()['recordPassword'] ?? '';
    _workLv = snapshot.data()['workLv'];
    _lastWorkId = snapshot.data()['lastWorkId'] ?? '';
    _lastBreakId = snapshot.data()['lastBreakId'] ?? '';
    _token = snapshot.data()['token'] ?? '';
    _smartphone = snapshot.data()['smartphone'];
    _createdAt = snapshot.data()['createdAt'].toDate();
  }
}
