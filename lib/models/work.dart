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

  List<String> breakTimes(GroupModel group) {
    String _time1 = '00:00';
    String _time2 = '00:00';
    String _time3 = '00:00';
    if (breaks.length > 0) {
      for (BreaksModel _break in breaks) {
        _time1 = addTime(_time1, _break.breakTimes(group)[0]);
        _time2 = addTime(_time2, _break.breakTimes(group)[1]);
        _time3 = addTime(_time3, _break.breakTimes(group)[2]);
      }
    }
    return [_time1, _time2, _time3];
  }

  String workTime(GroupModel group) {
    String _time = '00:00';
    String _startedDate = '${DateFormat('yyyy-MM-dd').format(startedAt)}';
    String _startedTime = '${startTime(group)}:00.000';
    DateTime _startedAt = DateTime.parse('$_startedDate $_startedTime');
    String _endedDate = '${DateFormat('yyyy-MM-dd').format(endedAt)}';
    String _endedTime = '${endTime(group)}:00.000';
    DateTime _endedAt = DateTime.parse('$_endedDate $_endedTime');
    // 出勤時間と退勤時間の差を求める
    Duration _diff = _endedAt.difference(_startedAt);
    String _minutes = twoDigits(_diff.inMinutes.remainder(60));
    _time = '${twoDigits(_diff.inHours)}:$_minutes';
    // 休憩の合計時間を求める
    String _breakTime = '00:00';
    if (breaks.length > 0) {
      for (BreaksModel _break in breaks) {
        _breakTime = addTime(_breakTime, _break.breakTimes(group)[0]);
      }
    }
    // 勤務時間と休憩の合計時間の差を求める
    _time = subTime(_time, _breakTime);
    return _time;
  }

  // 法定内時間/法定外時間
  List<String> legalTimes(GroupModel group) {
    String _time1 = '00:00';
    String _time2 = '00:00';
    List<String> _times = workTime(group).split(':');
    if (group.legal <= int.parse(_times.first)) {
      _time1 = addTime(_time1, '0${group.legal}:00');
      String _tmp = subTime(workTime(group), '0${group.legal}:00');
      _time2 = addTime(_time2, _tmp);
    } else {
      _time1 = addTime(_time1, workTime(group));
      _time2 = addTime(_time2, '00:00');
    }
    return [_time1, _time2];
  }

  // 深夜時間/深夜時間外
  List<String> nightTimes(GroupModel group) {
    String _time1 = '00:00';
    String _time2 = '00:00';
    String _startedDate = '${DateFormat('yyyy-MM-dd').format(startedAt)}';
    String _startedTime = '${startTime(group)}:00.000';
    DateTime _startedAt = DateTime.parse('$_startedDate $_startedTime');
    String _endedDate = '${DateFormat('yyyy-MM-dd').format(endedAt)}';
    String _endedTime = '${endTime(group)}:00.000';
    DateTime _endedAt = DateTime.parse('$_endedDate $_endedTime');
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
    // 深夜時間外
    if (_dayS.millisecondsSinceEpoch < _dayE.millisecondsSinceEpoch) {
      Duration _diff = _dayE.difference(_dayS);
      String _minutes = twoDigits(_diff.inMinutes.remainder(60));
      _time1 = '${twoDigits(_diff.inHours)}:$_minutes';
    }
    // 深夜時間
    if (_nightS.millisecondsSinceEpoch < _nightE.millisecondsSinceEpoch) {
      Duration _diff = _nightE.difference(_nightS);
      String _minutes = twoDigits(_diff.inMinutes.remainder(60));
      _time2 = '${twoDigits(_diff.inHours)}:$_minutes';
    }
    // ----------------------------------------
    return [_time1, _time2];
  }

  // 早出時間/残業時間
  List<String> overTimes(GroupModel group) {
    String _time1 = '00:00';
    String _time2 = '00:00';
    String _startedDate = '${DateFormat('yyyy-MM-dd').format(startedAt)}';
    String _startedTime = '${startTime(group)}:00.000';
    DateTime _startedAt = DateTime.parse('$_startedDate $_startedTime');
    String _endedDate = '${DateFormat('yyyy-MM-dd').format(endedAt)}';
    String _endedTime = '${endTime(group)}:00.000';
    DateTime _endedAt = DateTime.parse('$_endedDate $_endedTime');
    // ----------------------------------------
    String _workStart = '${group.workStart}:00.000';
    String _workEnd = '${group.workEnd}:00.000';
    DateTime _over1S;
    DateTime _over1E;
    DateTime _over2S;
    DateTime _over2E;
    DateTime _s = DateTime.parse('$_startedDate $_workStart');
    DateTime _e = DateTime.parse('$_endedDate $_workEnd');
    if (_startedAt.millisecondsSinceEpoch < _s.millisecondsSinceEpoch) {
      _over1S = _startedAt;
      _over1E = _s;
    } else {
      _over1S = _s;
      _over1E = _s;
    }
    if (_endedAt.millisecondsSinceEpoch > _e.millisecondsSinceEpoch) {
      _over2S = _e;
      _over2E = _endedAt;
    } else {
      _over2S = _e;
      _over2E = _e;
    }
    // ----------------------------------------
    if (_over1S.millisecondsSinceEpoch < _over1E.millisecondsSinceEpoch) {
      Duration _diff = _over1E.difference(_over1S);
      String _minutes = twoDigits(_diff.inMinutes.remainder(60));
      _time1 = '${twoDigits(_diff.inHours)}:$_minutes';
    } else {
      _time1 = '00:00';
    }
    if (_over2S.millisecondsSinceEpoch < _over2E.millisecondsSinceEpoch) {
      Duration _diff = _over2E.difference(_over2S);
      String _minutes = twoDigits(_diff.inMinutes.remainder(60));
      _time2 = '${twoDigits(_diff.inHours)}:$_minutes';
    } else {
      _time2 = '00:00';
    }
    return [_time1, _time2];
  }

  // 通常時間/深夜時間/通常時間外/深夜時間外
  List<String> calTimes01(GroupModel group) {
    String _time1 = '00:00';
    String _time2 = '00:00';
    String _time3 = '00:00';
    String _time4 = '00:00';
    String _startedDate = '${DateFormat('yyyy-MM-dd').format(startedAt)}';
    String _startedTime = '${startTime(group)}:00.000';
    DateTime _startedAt = DateTime.parse('$_startedDate $_startedTime');
    String _endedDate = '${DateFormat('yyyy-MM-dd').format(endedAt)}';
    String _endedTime = '${endTime(group)}:00.000';
    DateTime _endedAt = DateTime.parse('$_endedDate $_endedTime');
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
    // 通常時間
    if (_dayS.millisecondsSinceEpoch < _dayE.millisecondsSinceEpoch) {
      Duration _diff = _dayE.difference(_dayS);
      String _minutes = twoDigits(_diff.inMinutes.remainder(60));
      _time1 = '${twoDigits(_diff.inHours)}:$_minutes';
      _time1 = subTime(_time1, breakTimes(group)[1]);
      List<String> _time1List = _time1.split(':');
      if (group.legal <= int.parse(_time1List.first)) {
        _time1 = '0${group.legal}:00';
      }
    }
    // ----------------------------------------
    // 深夜時間
    if (_nightS.millisecondsSinceEpoch < _nightE.millisecondsSinceEpoch) {
      Duration _diff = _nightE.difference(_nightS);
      String _minutes = twoDigits(_diff.inMinutes.remainder(60));
      _time2 = '${twoDigits(_diff.inHours)}:$_minutes';
      _time2 = subTime(_time2, breakTimes(group)[2]);
      List<String> _time2List = _time2.split(':');
      if (group.legal <= int.parse(_time2List.first)) {
        _time2 = '0${group.legal}:00';
      }
    }
    // ----------------------------------------
    List<String> _workTimes = workTime(group).split(':');
    if (group.legal <= int.parse(_workTimes.first)) {
      // 法定時間を超えた時点の時間
      DateTime _overS = _startedAt;
      _overS = _overS.add(Duration(hours: group.legal));
      // 休憩時間を足す
      List<String> _breakTimes = breakTimes(group)[0].split(':');
      _overS = _overS.add(Duration(hours: int.parse(_breakTimes.first)));
      _overS = _overS.add(Duration(minutes: int.parse(_breakTimes.last)));
      // ----------------------------------------
      // 通常時間と深夜時間に分ける
      List<DateTime> _dayNightOverList = separateDayNight(
        startedAt: _overS,
        endedAt: _endedAt,
        nightStart: group.nightStart,
        nightEnd: group.nightEnd,
      );
      DateTime _dayOverS = _dayNightOverList[0];
      DateTime _dayOverE = _dayNightOverList[1];
      DateTime _nightOverS = _dayNightOverList[2];
      DateTime _nightOverE = _dayNightOverList[3];
      // ----------------------------------------
      // 通常時間外
      if (_dayOverS.millisecondsSinceEpoch < _dayOverE.millisecondsSinceEpoch) {
        Duration _diff = _dayOverE.difference(_dayOverS);
        String _minutes = twoDigits(_diff.inMinutes.remainder(60));
        _time3 = '${twoDigits(_diff.inHours)}:$_minutes';
      }
      // ----------------------------------------
      // 深夜時間外
      if (_nightOverS.millisecondsSinceEpoch <
          _nightOverE.millisecondsSinceEpoch) {
        Duration _diff = _nightOverE.difference(_nightOverS);
        String _minutes = twoDigits(_diff.inMinutes.remainder(60));
        _time4 = '${twoDigits(_diff.inHours)}:$_minutes';
      }
      // ----------------------------------------
    }
    // ----------------------------------------
    return [_time1, _time2, _time3, _time4];
  }

  // 平日普通残業時間/平日深夜残業時間/休日普通残業時間/休日深夜残業時間
  List<String> calTimes02(GroupModel group) {
    String _time1 = '00:00';
    String _time2 = '00:00';
    String _time3 = '00:00';
    String _time4 = '00:00';
    String _endedDate = '${DateFormat('yyyy-MM-dd').format(endedAt)}';
    String _endedTime = '${endTime(group)}:00.000';
    DateTime _endedAt = DateTime.parse('$_endedDate $_endedTime');
    // ----------------------------------------
    String _workEnd = '${group.workEnd}:00.000';
    DateTime _overS;
    DateTime _overE;
    DateTime _e = DateTime.parse('$_endedDate $_workEnd');
    // 退勤時間が所定労働時間帯の終了時間を超えている
    if (_endedAt.millisecondsSinceEpoch > _e.millisecondsSinceEpoch) {
      _overS = _e;
      _overE = _endedAt;
    } else {
      _overS = _e;
      _overE = _e;
    }
    // ----------------------------------------
    // 通常時間と深夜時間に分ける
    List<DateTime> _dayNightList = separateDayNight(
      startedAt: _overS,
      endedAt: _overE,
      nightStart: group.nightStart,
      nightEnd: group.nightEnd,
    );
    DateTime _dayS = _dayNightList[0];
    DateTime _dayE = _dayNightList[1];
    DateTime _nightS = _dayNightList[2];
    DateTime _nightE = _dayNightList[3];
    // ----------------------------------------
    String week = '${DateFormat('E', 'ja').format(_overS)}';
    if (group.holidays.contains(week)) {
      // 休日普通残業時間
      if (_dayS.millisecondsSinceEpoch < _dayE.millisecondsSinceEpoch) {
        Duration _diff = _dayE.difference(_dayS);
        String _minutes = twoDigits(_diff.inMinutes.remainder(60));
        _time3 = '${twoDigits(_diff.inHours)}:$_minutes';
      }
      // 休日深夜残業時間
      if (_nightS.millisecondsSinceEpoch < _nightE.millisecondsSinceEpoch) {
        Duration _diff = _nightE.difference(_nightS);
        String _minutes = twoDigits(_diff.inMinutes.remainder(60));
        _time4 = '${twoDigits(_diff.inHours)}:$_minutes';
      }
    } else {
      // 平日普通残業時間
      if (_dayS.millisecondsSinceEpoch < _dayE.millisecondsSinceEpoch) {
        Duration _diff = _dayE.difference(_dayS);
        String _minutes = twoDigits(_diff.inMinutes.remainder(60));
        _time1 = '${twoDigits(_diff.inHours)}:$_minutes';
      }
      // 平日深夜残業時間
      if (_nightS.millisecondsSinceEpoch < _nightE.millisecondsSinceEpoch) {
        Duration _diff = _nightE.difference(_nightS);
        String _minutes = twoDigits(_diff.inMinutes.remainder(60));
        _time2 = '${twoDigits(_diff.inHours)}:$_minutes';
      }
    }
    // ----------------------------------------
    return [_time1, _time2, _time3, _time4];
  }
}
