import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:intl/intl.dart';

class BreaksModel {
  String _id;
  DateTime startedAt;
  double startedLat;
  double startedLon;
  String startedDev;
  DateTime endedAt;
  double endedLat;
  double endedLon;
  String endedDev;

  String get id => _id;

  BreaksModel.fromMap(Map data) {
    _id = data['id'];
    startedAt = data['startedAt'].toDate();
    startedLat = data['startedLat'].toDouble();
    startedLon = data['startedLon'].toDouble();
    startedDev = data['startedDev'] ?? '';
    endedAt = data['endedAt'].toDate();
    endedLat = data['endedLat'].toDouble();
    endedLon = data['endedLon'].toDouble();
    endedDev = data['endedDev'] ?? '';
  }

  Map toMap() => {
        'id': id,
        'startedAt': startedAt,
        'startedLat': startedLat,
        'startedLon': startedLon,
        'startedDev': startedDev,
        'endedAt': endedAt,
        'endedLat': endedLat,
        'endedLon': endedLon,
        'endedDev': endedDev,
      };

  String startTime(GroupModel group) {
    String _time = '${DateFormat('HH:mm').format(startedAt)}';
    if (group.roundBreakStartType == '切捨') {
      _time = roundDownTime(_time, group.roundBreakStartNum);
    } else if (group.roundBreakStartType == '切上') {
      _time = roundUpTime(_time, group.roundBreakStartNum);
    }
    return _time;
  }

  String endTime(GroupModel group) {
    String _time = '${DateFormat('HH:mm').format(endedAt)}';
    if (group.roundBreakEndType == '切捨') {
      _time = roundDownTime(_time, group.roundBreakEndNum);
    } else if (group.roundBreakEndType == '切上') {
      _time = roundUpTime(_time, group.roundBreakEndNum);
    }
    return _time;
  }

  List<String> breakTime(GroupModel group) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String _time = '00:00';
    String _dayTime = '00:00';
    String _nightTime = '00:00';
    String _startedDate = '${DateFormat('yyyy-MM-dd').format(startedAt)}';
    String _startedTime = '${startTime(group)}:00.000';
    DateTime _startedAt = DateTime.parse('$_startedDate $_startedTime');
    String _endedDate = '${DateFormat('yyyy-MM-dd').format(endedAt)}';
    String _endedTime = '${endTime(group)}:00.000';
    DateTime _endedAt = DateTime.parse('$_endedDate $_endedTime');
    // 休憩開始時間と休憩終了時間の差を求める
    Duration _diff = _endedAt.difference(_startedAt);
    String _minutes = twoDigits(_diff.inMinutes.remainder(60));
    _time = '${twoDigits(_diff.inHours)}:$_minutes';
    // ----------------------------------------
    DateTime _dayS;
    DateTime _dayE;
    DateTime _nightS;
    DateTime _nightE;
    DateTime _baseSS = DateTime.parse(
      '${DateFormat('yyyy-MM-dd').format(startedAt)} ${group.nightStart}:00.000',
    );
    DateTime _baseES = DateTime.parse(
      '${DateFormat('yyyy-MM-dd').format(startedAt)} ${group.nightEnd}:00.000',
    );
    DateTime _baseSE = DateTime.parse(
      '${DateFormat('yyyy-MM-dd').format(endedAt)} ${group.nightStart}:00.000',
    );
    DateTime _baseEE = DateTime.parse(
      '${DateFormat('yyyy-MM-dd').format(endedAt)} ${group.nightEnd}:00.000',
    );
    if (_startedAt.millisecondsSinceEpoch < _baseSS.millisecondsSinceEpoch &&
        _startedAt.millisecondsSinceEpoch > _baseES.millisecondsSinceEpoch) {
      if (_endedAt.millisecondsSinceEpoch < _baseSE.millisecondsSinceEpoch &&
          _endedAt.millisecondsSinceEpoch > _baseEE.millisecondsSinceEpoch) {
        // 出勤時間[05:00〜22:00]退勤時間[05:00〜22:00]
        _dayS = _startedAt;
        _dayE = _endedAt;
        _nightS = _baseEE;
        _nightE = _baseEE;
      } else {
        // 出勤時間[05:00〜22:00]退勤時間[22:00〜05:00]
        _dayS = _startedAt;
        _dayE = _baseSE;
        _nightS = _baseSE;
        _nightE = _endedAt;
      }
    } else {
      if (_endedAt.millisecondsSinceEpoch < _baseSE.millisecondsSinceEpoch &&
          _endedAt.millisecondsSinceEpoch > _baseEE.millisecondsSinceEpoch) {
        // 出勤時間[22:00〜05:00]退勤時間[05:00〜22:00]
        _nightS = _startedAt;
        _nightE = _baseSE;
        _dayS = _baseSE;
        _dayE = _endedAt;
      } else {
        // 出勤時間[22:00〜05:00]退勤時間[22:00〜05:00]
        _dayS = _baseSS;
        _dayE = _baseSS;
        _nightS = _startedAt;
        _nightE = _endedAt;
      }
    }
    // ----------------------------------------
    if (_dayS.millisecondsSinceEpoch < _dayE.millisecondsSinceEpoch) {
      Duration _dayDiff = _dayE.difference(_dayS);
      String _dayMinutes = twoDigits(_dayDiff.inMinutes.remainder(60));
      _dayTime = '${twoDigits(_dayDiff.inHours)}:$_dayMinutes';
    } else {
      _dayTime = '00:00';
    }
    if (_nightS.millisecondsSinceEpoch < _nightE.millisecondsSinceEpoch) {
      Duration _nightDiff = _nightE.difference(_nightS);
      String _nightMinutes = twoDigits(_nightDiff.inMinutes.remainder(60));
      _nightTime = '${twoDigits(_nightDiff.inHours)}:$_nightMinutes';
    } else {
      _nightTime = '00:00';
    }
    return [_time, _dayTime, _nightTime];
  }
}
