import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  String _id;
  String _name;
  String _adminUserId;
  int _usersNum;
  List<String> positions;
  bool _qrSecurity;
  bool _areaSecurity;
  double _areaLat;
  double _areaLon;
  String _roundStartType;
  int _roundStartNum;
  String _roundEndType;
  int _roundEndNum;
  String _roundBreakStartType;
  int _roundBreakStartNum;
  String _roundBreakEndType;
  int _roundBreakEndNum;
  String _roundWorkType;
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
  String get roundStartType => _roundStartType;
  int get roundStartNum => _roundStartNum;
  String get roundEndType => _roundEndType;
  int get roundEndNum => _roundEndNum;
  String get roundBreakStartType => _roundBreakStartType;
  int get roundBreakStartNum => _roundBreakStartNum;
  String get roundBreakEndType => _roundBreakEndType;
  int get roundBreakEndNum => _roundBreakEndNum;
  String get roundWorkType => _roundWorkType;
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
    positions = _convertPositions(snapshot.data()['positions']) ?? [];
    _qrSecurity = snapshot.data()['qrSecurity'];
    _areaSecurity = snapshot.data()['areaSecurity'];
    _areaLat = snapshot.data()['areaLat'].toDouble();
    _areaLon = snapshot.data()['areaLon'].toDouble();
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

  List<String> _convertPositions(List positions) {
    List<String> converted = [];
    for (String data in positions) {
      converted.add(data);
    }
    return converted;
  }
}
