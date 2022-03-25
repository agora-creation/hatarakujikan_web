import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  String _id = '';
  String _name = '';
  String _zip = '';
  String _address = '';
  String _tel = '';
  String _email = '';
  List<String> userIds = [];
  int _usersNum = 0;
  String _adminUserId = '';
  bool _qrSecurity = false;
  bool _areaSecurity = false;
  double _areaLat = 0;
  double _areaLon = 0;
  double _areaRange = 0;
  String _roundStartType = '';
  int _roundStartNum = 0;
  String _roundEndType = '';
  int _roundEndNum = 0;
  String _roundBreakStartType = '';
  int _roundBreakStartNum = 0;
  String _roundBreakEndType = '';
  int _roundBreakEndNum = 0;
  String _roundWorkType = '';
  int _roundWorkNum = 0;
  int _legal = 0;
  String _nightStart = '';
  String _nightEnd = '';
  String _workStart = '';
  String _workEnd = '';
  List<String> holidays = [];
  List<DateTime> holidays2 = [];
  bool _autoBreak = false;
  bool _optionsShift = false;
  DateTime _createdAt = DateTime.now();

  String get id => _id;
  String get name => _name;
  String get zip => _zip;
  String get address => _address;
  String get tel => _tel;
  String get email => _email;
  int get usersNum => _usersNum;
  String get adminUserId => _adminUserId;
  bool get qrSecurity => _qrSecurity;
  bool get areaSecurity => _areaSecurity;
  double get areaLat => _areaLat;
  double get areaLon => _areaLon;
  double get areaRange => _areaRange;
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
  String get workStart => _workStart;
  String get workEnd => _workEnd;
  bool get autoBreak => _autoBreak;
  bool get optionsShift => _optionsShift;
  DateTime get createdAt => _createdAt;

  GroupModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    _id = snapshot.data()!['id'] ?? '';
    _name = snapshot.data()!['name'] ?? '';
    _zip = snapshot.data()!['zip'] ?? '';
    _address = snapshot.data()!['address'] ?? '';
    _tel = snapshot.data()!['tel'] ?? '';
    _email = snapshot.data()!['email'] ?? '';
    userIds = _convertList(snapshot.data()!['userIds']);
    _usersNum = snapshot.data()!['usersNum'] ?? 0;
    _adminUserId = snapshot.data()!['adminUserId'] ?? '';
    _qrSecurity = snapshot.data()!['qrSecurity'] ?? false;
    _areaSecurity = snapshot.data()!['areaSecurity'] ?? false;
    _areaLat = snapshot.data()!['areaLat'].toDouble() ?? 0;
    _areaLon = snapshot.data()!['areaLon'].toDouble() ?? 0;
    _areaRange = snapshot.data()!['areaRange'].toDouble() ?? 0;
    _roundStartType = snapshot.data()!['roundStartType'] ?? '';
    _roundStartNum = snapshot.data()!['roundStartNum'] ?? 0;
    _roundEndType = snapshot.data()!['roundEndType'] ?? '';
    _roundEndNum = snapshot.data()!['roundEndNum'] ?? 0;
    _roundBreakStartType = snapshot.data()!['roundBreakStartType'] ?? '';
    _roundBreakStartNum = snapshot.data()!['roundBreakStartNum'] ?? 0;
    _roundBreakEndType = snapshot.data()!['roundBreakEndType'] ?? '';
    _roundBreakEndNum = snapshot.data()!['roundBreakEndNum'] ?? 0;
    _roundWorkType = snapshot.data()!['roundWorkType'] ?? '';
    _roundWorkNum = snapshot.data()!['roundWorkNum'] ?? 0;
    _legal = snapshot.data()!['legal'] ?? 0;
    _nightStart = snapshot.data()!['nightStart'] ?? '';
    _nightEnd = snapshot.data()!['nightEnd'] ?? '';
    _workStart = snapshot.data()!['workStart'] ?? '';
    _workEnd = snapshot.data()!['workEnd'] ?? '';
    holidays = _convertList(snapshot.data()!['holidays']);
    holidays2 = _convertList2(snapshot.data()!['holidays2']);
    _autoBreak = snapshot.data()!['autoBreak'] ?? false;
    _optionsShift = snapshot.data()!['optionsShift'] ?? false;
    _createdAt = snapshot.data()!['createdAt'].toDate() ?? DateTime.now();
  }

  List<String> _convertList(List list) {
    List<String> converted = [];
    for (String data in list) {
      converted.add(data);
    }
    return converted;
  }

  List<DateTime> _convertList2(List list) {
    List<DateTime> converted = [];
    list.forEach((value) {
      DateTime dateTime = value.toDate();
      converted.add(dateTime);
    });
    return converted;
  }
}
