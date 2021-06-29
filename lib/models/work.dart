import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/models/breaks.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:intl/intl.dart';

class WorkModel {
  String _id;
  String _groupId;
  String _userId;
  DateTime startedAt;
  double startedLat;
  double startedLon;
  String startedDev;
  DateTime endedAt;
  double endedLat;
  double endedLon;
  String endedDev;
  List<BreaksModel> breaks;
  String _state;
  DateTime _createdAt;

  String get id => _id;
  String get groupId => _groupId;
  String get userId => _userId;
  String get state => _state;
  DateTime get createdAt => _createdAt;

  WorkModel.fromSnapshot(DocumentSnapshot snapshot) {
    _id = snapshot.data()['id'];
    _groupId = snapshot.data()['groupId'];
    _userId = snapshot.data()['userId'];
    startedAt = snapshot.data()['startedAt'].toDate();
    startedLat = snapshot.data()['startedLat'].toDouble();
    startedLon = snapshot.data()['startedLon'].toDouble();
    startedDev = snapshot.data()['startedDev'] ?? '';
    endedAt = snapshot.data()['endedAt'].toDate();
    endedLat = snapshot.data()['endedLat'].toDouble();
    endedLon = snapshot.data()['endedLon'].toDouble();
    endedDev = snapshot.data()['endedDev'] ?? '';
    breaks = _convertBreaks(snapshot.data()['breaks']) ?? [];
    _state = snapshot.data()['state'] ?? '';
    _createdAt = snapshot.data()['createdAt'].toDate();
  }

  List<BreaksModel> _convertBreaks(List breaks) {
    List<BreaksModel> converted = [];
    for (Map data in breaks) {
      converted.add(BreaksModel.fromMap(data));
    }
    return converted;
  }

  String startTime(GroupModel group) {
    String _time = '${DateFormat('HH:mm').format(startedAt)}';
    if (group.roundStartType == '切捨') {
      _time = roundDownTime(_time, group.roundStartNum);
    } else if (group.roundStartType == '切上') {
      _time = roundUpTime(_time, group.roundStartNum);
    }
    return _time;
  }

  String endTime(GroupModel group) {
    String _time = '${DateFormat('HH:mm').format(endedAt)}';
    if (group.roundEndType == '切捨') {
      _time = roundDownTime(_time, group.roundEndNum);
    } else if (group.roundEndType == '切上') {
      _time = roundUpTime(_time, group.roundEndNum);
    }
    return _time;
  }

  String breakTime(GroupModel group) {
    String _time = '00:00';
    if (breaks.length > 0) {
      for (BreaksModel _break in breaks) {
        _time = addTime(_time, _break.breakTime(group));
      }
    }
    return _time;
  }

  String workTime(GroupModel group) {
    String _startedDate = '${DateFormat('yyyy-MM-dd').format(startedAt)}';
    String _startedTime = '${startTime(group)}:00.000';
    DateTime _startedAt = DateTime.parse('$_startedDate $_startedTime');
    String _endedDate = '${DateFormat('yyyy-MM-dd').format(endedAt)}';
    String _endedTime = '${endTime(group)}:00.000';
    DateTime _endedAt = DateTime.parse('$_endedDate $_endedTime');
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    // 出勤時間と退勤時間の差を求める
    Duration _diff = _endedAt.difference(_startedAt);
    String _minutes = twoDigits(_diff.inMinutes.remainder(60));
    String _workTime = '${twoDigits(_diff.inHours)}:$_minutes';
    // 休憩の合計時間を求める
    String _breaksTime = '00:00';
    if (breaks.length > 0) {
      for (BreaksModel _break in breaks) {
        _breaksTime = addTime(_breaksTime, _break.breakTime(group));
      }
    }
    // 勤務時間と休憩の合計時間の差を求める
    _workTime = subTime(_workTime, _breaksTime);
    return _workTime;
  }
}
