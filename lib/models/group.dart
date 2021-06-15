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
  DateTime _createdAt;

  String get id => _id;
  String get name => _name;
  String get adminUserId => _adminUserId;
  int get usersNum => _usersNum;
  bool get qrSecurity => _qrSecurity;
  bool get areaSecurity => _areaSecurity;
  double get areaLat => _areaLat;
  double get areaLon => _areaLon;
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
    _createdAt = snapshot.data()['createdAt'].toDate();
  }
}
