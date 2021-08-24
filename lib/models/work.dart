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
    String _time = '00:00';
    String _dayTime = '00:00';
    String _nightTime = '00:00';
    if (breaks.length > 0) {
      for (BreaksModel _break in breaks) {
        _time = addTime(_time, _break.breakTimes(group)[0]);
        _dayTime = addTime(_dayTime, _break.breakTimes(group)[1]);
        _nightTime = addTime(_nightTime, _break.breakTimes(group)[2]);
      }
    }
    return [_time, _dayTime, _nightTime];
  }

  String workTime(GroupModel group) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
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
    String _time = '00:00';
    String _nonTime = '00:00';
    List<String> _times = workTime(group).split(':');
    if (group.legal <= int.parse(_times.first)) {
      _time = addTime(_time, '0${group.legal}:00');
      String _tmp = subTime(workTime(group), '0${group.legal}:00');
      _nonTime = addTime(_nonTime, _tmp);
    } else {
      _time = addTime(_time, workTime(group));
      _nonTime = addTime(_nonTime, '00:00');
    }
    return [_time, _nonTime];
  }

  // 深夜時間/深夜時間外
  List<String> nightTimes(GroupModel group) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String _dayTime = '00:00';
    String _nightTime = '00:00';
    String _startedDate = '${DateFormat('yyyy-MM-dd').format(startedAt)}';
    String _startedTime = '${startTime(group)}:00.000';
    DateTime _startedAt = DateTime.parse('$_startedDate $_startedTime');
    String _endedDate = '${DateFormat('yyyy-MM-dd').format(endedAt)}';
    String _endedTime = '${endTime(group)}:00.000';
    DateTime _endedAt = DateTime.parse('$_endedDate $_endedTime');
    // ----------------------------------------
    DateTime _dayS;
    DateTime _dayE;
    DateTime _nightS;
    DateTime _nightE;
    DateTime _baseSS =
        DateTime.parse('$_startedDate ${group.nightStart}:00.000');
    DateTime _baseSE = DateTime.parse('$_startedDate ${group.nightEnd}:00.000');
    DateTime _baseES = DateTime.parse('$_endedDate ${group.nightStart}:00.000');
    DateTime _baseEE = DateTime.parse('$_endedDate ${group.nightEnd}:00.000');
    if (_startedAt.millisecondsSinceEpoch < _baseSS.millisecondsSinceEpoch &&
        _startedAt.millisecondsSinceEpoch > _baseSE.millisecondsSinceEpoch) {
      if (_endedAt.millisecondsSinceEpoch < _baseES.millisecondsSinceEpoch &&
          _endedAt.millisecondsSinceEpoch > _baseEE.millisecondsSinceEpoch) {
        // 出勤時間[05:00〜22:00]退勤時間[05:00〜22:00]
        _dayS = _startedAt;
        _dayE = _endedAt;
        _nightS = _baseEE;
        _nightE = _baseEE;
      } else {
        // 出勤時間[05:00〜22:00]退勤時間[22:00〜05:00]
        _dayS = _startedAt;
        _dayE = _baseES;
        _nightS = _baseES;
        _nightE = _endedAt;
      }
    } else {
      if (_endedAt.millisecondsSinceEpoch < _baseES.millisecondsSinceEpoch &&
          _endedAt.millisecondsSinceEpoch > _baseEE.millisecondsSinceEpoch) {
        // 出勤時間[22:00〜05:00]退勤時間[05:00〜22:00]
        _nightS = _startedAt;
        _nightE = _baseES;
        _dayS = _baseES;
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
    return [_dayTime, _nightTime];
  }

  // 早出時間/残業時間
  List<String> overTimes(GroupModel group) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String _time1 = '00:00';
    String _time2 = '00:00';
    String _startedDate = '${DateFormat('yyyy-MM-dd').format(startedAt)}';
    String _startedTime = '${startTime(group)}:00.000';
    DateTime _startedAt = DateTime.parse('$_startedDate $_startedTime');
    String _endedDate = '${DateFormat('yyyy-MM-dd').format(endedAt)}';
    String _endedTime = '${endTime(group)}:00.000';
    DateTime _endedAt = DateTime.parse('$_endedDate $_endedTime');
    // ----------------------------------------
    DateTime _over1S;
    DateTime _over1E;
    DateTime _over2S;
    DateTime _over2E;
    DateTime _baseS = DateTime.parse('$_startedDate ${group.workStart}:00.000');
    DateTime _baseE = DateTime.parse('$_endedDate ${group.workEnd}:00.000');
    if (_startedAt.millisecondsSinceEpoch < _baseS.millisecondsSinceEpoch) {
      _over1S = _startedAt;
      _over1E = _baseS;
    } else {
      _over1S = _baseS;
      _over1E = _baseS;
    }
    if (_endedAt.millisecondsSinceEpoch > _baseE.millisecondsSinceEpoch) {
      _over2S = _baseE;
      _over2E = _endedAt;
    } else {
      _over2S = _baseE;
      _over2E = _baseE;
    }
    // ----------------------------------------
    if (_over1S.millisecondsSinceEpoch < _over1E.millisecondsSinceEpoch) {
      Duration _over1Diff = _over1E.difference(_over1S);
      String _over1Minutes = twoDigits(_over1Diff.inMinutes.remainder(60));
      _time1 = '${twoDigits(_over1Diff.inHours)}:$_over1Minutes';
    } else {
      _time1 = '00:00';
    }
    if (_over2S.millisecondsSinceEpoch < _over2E.millisecondsSinceEpoch) {
      Duration _over2Diff = _over2E.difference(_over2S);
      String _over2Minutes = twoDigits(_over2Diff.inMinutes.remainder(60));
      _time2 = '${twoDigits(_over2Diff.inHours)}:$_over2Minutes';
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
    String _nightStart = '${group.nightStart}:00.000';
    String _nightEnd = '${group.nightEnd}:00.000';
    String _workEnd = '${group.workEnd}:00.000';
    // ----------------------------------------
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
    String week = '${DateFormat('E', 'ja').format(_overS)}';
    DateTime _dayS;
    DateTime _dayE;
    DateTime _nightS;
    DateTime _nightE;
    String _startedDateOver = '${DateFormat('yyyy-MM-dd').format(_overS)}';
    String _endedDateOver = '${DateFormat('yyyy-MM-dd').format(_overE)}';
    DateTime _ss = DateTime.parse('$_startedDateOver $_nightStart');
    DateTime _se = DateTime.parse('$_startedDateOver $_nightEnd');
    DateTime _es = DateTime.parse('$_endedDateOver $_nightStart');
    DateTime _ee = DateTime.parse('$_endedDateOver $_nightEnd');
    // 出勤時間

    if (_overS.millisecondsSinceEpoch < _baseSS.millisecondsSinceEpoch &&
        _overS.millisecondsSinceEpoch > _baseSE.millisecondsSinceEpoch) {
      if (_overE.millisecondsSinceEpoch < _baseES.millisecondsSinceEpoch &&
          _overE.millisecondsSinceEpoch > _baseEE.millisecondsSinceEpoch) {
        // 開始時間[05:00〜22:00]終了時間[05:00〜22:00]
        _dayS = _overS;
        _dayE = _overE;
        _nightS = _baseEE;
        _nightE = _baseEE;
      } else {
        // 開始時間[05:00〜22:00]終了時間[22:00〜05:00]
        _dayS = _overS;
        _dayE = _baseES;
        _nightS = _baseES;
        _nightE = _overE;
      }
    } else {
      if (_overE.millisecondsSinceEpoch < _baseES.millisecondsSinceEpoch &&
          _overE.millisecondsSinceEpoch > _baseEE.millisecondsSinceEpoch) {
        // 開始時間[22:00〜05:00]終了時間[05:00〜22:00]
        _nightS = _overS;
        _nightE = _baseES;
        _dayS = _baseES;
        _dayE = _overE;
      } else {
        // 開始時間[22:00〜05:00]終了時間[22:00〜05:00]
        _dayS = _baseSS;
        _dayE = _baseSS;
        _nightS = _overS;
        _nightE = _overE;
      }
    }
    if (group.holidays.contains(week)) {
      // 休日普通残業時間
      if (_dayS.millisecondsSinceEpoch < _dayE.millisecondsSinceEpoch) {
        Duration _dayDiff = _dayE.difference(_dayS);
        String _dayMinutes = twoDigits(_dayDiff.inMinutes.remainder(60));
        _time3 = '${twoDigits(_dayDiff.inHours)}:$_dayMinutes';
      } else {
        _time3 = '00:00';
      }
      // 休日深夜残業時間
      if (_nightS.millisecondsSinceEpoch < _nightE.millisecondsSinceEpoch) {
        Duration _nightDiff = _nightE.difference(_nightS);
        String _nightMinutes = twoDigits(_nightDiff.inMinutes.remainder(60));
        _time4 = '${twoDigits(_nightDiff.inHours)}:$_nightMinutes';
      } else {
        _time4 = '00:00';
      }
    } else {
      // 平日普通残業時間
      if (_dayS.millisecondsSinceEpoch < _dayE.millisecondsSinceEpoch) {
        Duration _dayDiff = _dayE.difference(_dayS);
        String _dayMinutes = twoDigits(_dayDiff.inMinutes.remainder(60));
        _time1 = '${twoDigits(_dayDiff.inHours)}:$_dayMinutes';
      } else {
        _time1 = '00:00';
      }
      // 平日深夜残業時間
      if (_nightS.millisecondsSinceEpoch < _nightE.millisecondsSinceEpoch) {
        Duration _nightDiff = _nightE.difference(_nightS);
        String _nightMinutes = twoDigits(_nightDiff.inMinutes.remainder(60));
        _time2 = '${twoDigits(_nightDiff.inHours)}:$_nightMinutes';
      } else {
        _time2 = '00:00';
      }
    }
    // ----------------------------------------
    return [_time1, _time2, _time3, _time4];
  }
}
