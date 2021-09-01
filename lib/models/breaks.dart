import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:intl/intl.dart';

class BreaksModel {
  String _id;
  DateTime startedAt;
  double startedLat;
  double startedLon;
  DateTime endedAt;
  double endedLat;
  double endedLon;

  String get id => _id;

  BreaksModel.fromMap(Map data) {
    _id = data['id'];
    startedAt = data['startedAt'].toDate();
    startedLat = data['startedLat'].toDouble();
    startedLon = data['startedLon'].toDouble();
    endedAt = data['endedAt'].toDate();
    endedLat = data['endedLat'].toDouble();
    endedLon = data['endedLon'].toDouble();
  }

  Map toMap() => {
        'id': id,
        'startedAt': startedAt,
        'startedLat': startedLat,
        'startedLon': startedLon,
        'endedAt': endedAt,
        'endedLat': endedLat,
        'endedLon': endedLon,
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

  List<String> breakTimes(GroupModel group) {
    String _time1 = '00:00';
    String _time2 = '00:00';
    String _time3 = '00:00';
    String _startedDate = '${DateFormat('yyyy-MM-dd').format(startedAt)}';
    String _startedTime = '${startTime(group)}:00.000';
    DateTime _startedAt = DateTime.parse('$_startedDate $_startedTime');
    String _endedDate = '${DateFormat('yyyy-MM-dd').format(endedAt)}';
    String _endedTime = '${endTime(group)}:00.000';
    DateTime _endedAt = DateTime.parse('$_endedDate $_endedTime');
    // 休憩開始時間と休憩終了時間の差を求める
    Duration _diff = _endedAt.difference(_startedAt);
    String _minutes = twoDigits(_diff.inMinutes.remainder(60));
    _time1 = '${twoDigits(_diff.inHours)}:$_minutes';
    // ----------------------------------------
    // 通常時間と深夜時間に分ける
    List<DateTime> _dayNightList = separateDayNight(
      startedAt: _startedAt,
      endedAt: _endedAt,
      nightStart: group.nightStart,
      nightEnd: group.nightEnd,
    );
    DateTime _dayS = _dayNightList[0];
    DateTime _dayE = _dayNightList[1];
    DateTime _nightS = _dayNightList[2];
    DateTime _nightE = _dayNightList[3];
    // ----------------------------------------
    if (_dayS.millisecondsSinceEpoch < _dayE.millisecondsSinceEpoch) {
      Duration _diff = _dayE.difference(_dayS);
      String _minutes = twoDigits(_diff.inMinutes.remainder(60));
      _time2 = '${twoDigits(_diff.inHours)}:$_minutes';
    }
    if (_nightS.millisecondsSinceEpoch < _nightE.millisecondsSinceEpoch) {
      Duration _diff = _nightE.difference(_nightS);
      String _minutes = twoDigits(_diff.inMinutes.remainder(60));
      _time3 = '${twoDigits(_diff.inHours)}:$_minutes';
    }
    // ----------------------------------------
    return [_time1, _time2, _time3];
  }
}
