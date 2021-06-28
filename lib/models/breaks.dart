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

  String breakTime(GroupModel group) {
    String _startedDate = '${DateFormat('yyyy-MM-dd').format(startedAt)}';
    String _startedTime = '${startTime(group)}:00.000';
    DateTime _startedAt = DateTime.parse('$_startedDate $_startedTime');
    String _endedDate = '${DateFormat('yyyy-MM-dd').format(endedAt)}';
    String _endedTime = '${endTime(group)}:00.000';
    DateTime _endedAt = DateTime.parse('$_endedDate $_endedTime');
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    // 休憩開始時間と休憩終了時間の差を求める
    Duration _diff = _endedAt.difference(_startedAt);
    String _minutes = twoDigits(_diff.inMinutes.remainder(60));
    return '${twoDigits(_diff.inHours)}:$_minutes';
  }
}
