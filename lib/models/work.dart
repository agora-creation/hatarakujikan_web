import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/models/breaks.dart';
import 'package:intl/intl.dart';

class WorkModel {
  String _id;
  String _groupId;
  String _userId;
  DateTime startedAt;
  double startedLat;
  double startedLon;
  DateTime endedAt;
  double endedLat;
  double endedLon;
  List<BreaksModel> breaks;
  DateTime _createdAt;

  String get id => _id;
  String get groupId => _groupId;
  String get userId => _userId;
  DateTime get createdAt => _createdAt;

  WorkModel.fromSnapshot(DocumentSnapshot snapshot) {
    _id = snapshot.data()['id'];
    _groupId = snapshot.data()['groupId'];
    _userId = snapshot.data()['userId'];
    startedAt = snapshot.data()['startedAt'].toDate();
    startedLat = snapshot.data()['startedLat'].toDouble();
    startedLon = snapshot.data()['startedLon'].toDouble();
    endedAt = snapshot.data()['endedAt'].toDate();
    endedLat = snapshot.data()['endedLat'].toDouble();
    endedLon = snapshot.data()['endedLon'].toDouble();
    breaks = _convertBreaks(snapshot.data()['breaks']) ?? [];
    _createdAt = snapshot.data()['createdAt'].toDate();
  }

  List<BreaksModel> _convertBreaks(List breaks) {
    List<BreaksModel> converted = [];
    for (Map data in breaks) {
      converted.add(BreaksModel.fromMap(data));
    }
    return converted;
  }

  String startTime() {
    String _result = '00:00';
    _result = '${DateFormat('HH:mm').format(startedAt)}';
    return _result;
  }

  String endTime() {
    String _result = '00:00';
    _result = '${DateFormat('HH:mm').format(endedAt)}';
    return _result;
  }

  String breakTime() {
    String _result = '00:00';
    if (breaks.length > 0) {
      for (BreaksModel _break in breaks) {
        _result = addTime(_result, _break.breakTime());
      }
    }
    return _result;
  }

  String workTime() {
    String _result = '00:00';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    // 出勤時間と退勤時間の差を求める
    Duration _diff = endedAt.difference(startedAt);
    String _minutes = twoDigits(_diff.inMinutes.remainder(60));
    String _workTime = '${twoDigits(_diff.inHours)}:$_minutes';
    // 休憩の合計時間を求める
    String _breaksTime = '00:00';
    if (breaks.length > 0) {
      for (BreaksModel _break in breaks) {
        _breaksTime = addTime(_breaksTime, _break.breakTime());
      }
    }
    // 勤務時間と休憩の合計時間の差を求める
    _result = subTime(_workTime, _breaksTime);
    return _result;
  }
}
