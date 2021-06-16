import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  String _id;
  String _name;
  String _adminUserId;
  int _usersNum;
  bool _qrSecurity;
  bool _areaSecurity;
  double _areaLat;
  double _areaLon;
  int _roundStartType;
  int _roundStartNum;
  int _roundEndType;
  int _roundEndNum;
  int _roundBreakStartType;
  int _roundBreakStartNum;
  int _roundBreakEndType;
  int _roundBreakEndNum;
  int _roundWorkType;
  int _roundWorkNum;
  int _legal;
  String _nightStart;
  String _nightEnd;
  DateTime _createdAt;

  String get id => _id;
  String get name => _name;
  String get adminUserId => _adminUserId;
  int get usersNum => _usersNum;
  bool get qrSecurity => _qrSecurity;
  bool get areaSecurity => _areaSecurity;
  double get areaLat => _areaLat;
  double get areaLon => _areaLon;
  int get roundStartType => _roundStartType;
  int get roundStartNum => _roundStartNum;
  int get roundEndType => _roundEndType;
  int get roundEndNum => _roundEndNum;
  int get roundBreakStartType => _roundBreakStartType;
  int get roundBreakStartNum => _roundBreakStartNum;
  int get roundBreakEndType => _roundBreakEndType;
  int get roundBreakEndNum => _roundBreakEndNum;
  int get roundWorkType => _roundWorkType;
  int get roundWorkNum => _roundWorkNum;
  int get legal => _legal;
  String get nightStart => _nightStart;
  String get nightEnd => _nightEnd;
  DateTime get createdAt => _createdAt;

  GroupModel.fromSnapshot(DocumentSnapshot snapshot) {
    _id = snapshot.data()['id'];
    _name = snapshot.data()['name'];
    _adminUserId = snapshot.data()['adminUserId'];
    _usersNum = snapshot.data()['usersNum'];
    _qrSecurity = snapshot.data()['qrSecurity'];
    _areaSecurity = snapshot.data()['areaSecurity'];
    _areaLat = snapshot.data()['areaLat'];
    _areaLon = snapshot.data()['areaLon'];
    _roundStartType = snapshot.data()['roundStartType'];
    _roundStartNum = snapshot.data()['roundStartNum'];
    _roundEndType = snapshot.data()['roundEndType'];
    _roundEndNum = snapshot.data()['roundEndNum'];
    _roundBreakStartType = snapshot.data()['roundBreakStartType'];
    _roundBreakStartNum = snapshot.data()['roundBreakStartNum'];
    _roundBreakEndType = snapshot.data()['roundBreakEndType'];
    _roundBreakEndNum = snapshot.data()['roundBreakEndNum'];
    _roundWorkType = snapshot.data()['roundWorkType'];
    _roundWorkNum = snapshot.data()['roundWorkNum'];
    _legal = snapshot.data()['legal'];
    _nightStart = snapshot.data()['nightStart'];
    _nightEnd = snapshot.data()['nightEnd'];
    _createdAt = snapshot.data()['createdAt'].toDate();
  }
}
