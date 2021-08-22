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
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String _dayTime = '00:00';
    String _nightTime = '00:00';
    String _dayTimeOver = '00:00';
    String _nightTimeOver = '00:00';
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
    // 通常時間
    if (_dayS.millisecondsSinceEpoch < _dayE.millisecondsSinceEpoch) {
      Duration _dayDiff = _dayE.difference(_dayS);
      String _dayMinutes = twoDigits(_dayDiff.inMinutes.remainder(60));
      _dayTime = '${twoDigits(_dayDiff.inHours)}:$_dayMinutes';
      _dayTime = subTime(_dayTime, breakTimes(group)[1]);
      List<String> _dayTimes = _dayTime.split(':');
      if (group.legal <= int.parse(_dayTimes.first)) {
        _dayTime = '0${group.legal}:00';
      }
    } else {
      _dayTime = '00:00';
    }
    // 深夜時間
    if (_nightS.millisecondsSinceEpoch < _nightE.millisecondsSinceEpoch) {
      Duration _nightDiff = _nightE.difference(_nightS);
      String _nightMinutes = twoDigits(_nightDiff.inMinutes.remainder(60));
      _nightTime = '${twoDigits(_nightDiff.inHours)}:$_nightMinutes';
      _nightTime = subTime(_nightTime, breakTimes(group)[2]);
      List<String> _nightTimes = _nightTime.split(':');
      if (group.legal <= int.parse(_nightTimes.first)) {
        _nightTime = '0${group.legal}:00';
      }
    } else {
      _nightTime = '00:00';
    }
    // ----------------------------------------
    List<String> _workTimes = workTime(group).split(':');
    if (group.legal <= int.parse(_workTimes.first)) {
      // 法定時間を超えた時点の時間
      DateTime _overTimeS = _startedAt;
      _overTimeS = _overTimeS.add(Duration(hours: group.legal));
      // 休憩時間を足す
      List<String> _breakTimes = breakTimes(group)[0].split(':');
      _overTimeS =
          _overTimeS.add(Duration(hours: int.parse(_breakTimes.first)));
      _overTimeS =
          _overTimeS.add(Duration(minutes: int.parse(_breakTimes.last)));
      DateTime _dayOverS;
      DateTime _dayOverE;
      DateTime _nightOverS;
      DateTime _nightOverE;
      if (_overTimeS.millisecondsSinceEpoch < _baseSS.millisecondsSinceEpoch &&
          _overTimeS.millisecondsSinceEpoch > _baseSE.millisecondsSinceEpoch) {
        if (_endedAt.millisecondsSinceEpoch < _baseES.millisecondsSinceEpoch &&
            _endedAt.millisecondsSinceEpoch > _baseEE.millisecondsSinceEpoch) {
          // 出勤時間[05:00〜22:00]退勤時間[05:00〜22:00]
          _dayOverS = _overTimeS;
          _dayOverE = _endedAt;
          _nightOverS = _baseEE;
          _nightOverE = _baseEE;
        } else {
          // 出勤時間[05:00〜22:00]退勤時間[22:00〜05:00]
          _dayOverS = _overTimeS;
          _dayOverE = _baseES;
          _nightOverS = _baseES;
          _nightOverE = _endedAt;
        }
      } else {
        if (_endedAt.millisecondsSinceEpoch < _baseES.millisecondsSinceEpoch &&
            _endedAt.millisecondsSinceEpoch > _baseEE.millisecondsSinceEpoch) {
          // 出勤時間[22:00〜05:00]退勤時間[05:00〜22:00]
          _nightOverS = _overTimeS;
          _nightOverE = _baseES;
          _dayOverS = _baseES;
          _dayOverE = _endedAt;
        } else {
          // 出勤時間[22:00〜05:00]退勤時間[22:00〜05:00]
          _dayOverS = _baseSS;
          _dayOverE = _baseSS;
          _nightOverS = _overTimeS;
          _nightOverE = _endedAt;
        }
      }
      // 通常時間外
      if (_dayOverS.millisecondsSinceEpoch < _dayOverE.millisecondsSinceEpoch) {
        Duration _dayOverDiff = _dayOverE.difference(_dayOverS);
        String _dayOverMinutes =
            twoDigits(_dayOverDiff.inMinutes.remainder(60));
        _dayTimeOver = '${twoDigits(_dayOverDiff.inHours)}:$_dayOverMinutes';
      } else {
        _dayTimeOver = '00:00';
      }
      // 深夜時間外
      if (_nightOverS.millisecondsSinceEpoch <
          _nightOverE.millisecondsSinceEpoch) {
        Duration _nightOverDiff = _nightOverE.difference(_nightOverS);
        String _nightOverMinutes =
            twoDigits(_nightOverDiff.inMinutes.remainder(60));
        _nightTimeOver =
            '${twoDigits(_nightOverDiff.inHours)}:$_nightOverMinutes';
      } else {
        _nightTimeOver = '00:00';
      }
    }
    // ----------------------------------------
    return [_dayTime, _nightTime, _dayTimeOver, _nightTimeOver];
  }

  // 平日普通残業時間/平日深夜残業時間/休日普通残業時間/休日深夜残業時間
  List<String> calTimes02(GroupModel group) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String _time1 = '00:00';
    String _time2 = '00:00';
    String _time3 = '00:00';
    String _time4 = '00:00';
    String _endedDate = '${DateFormat('yyyy-MM-dd').format(endedAt)}';
    String _endedTime = '${endTime(group)}:00.000';
    DateTime _endedAt = DateTime.parse('$_endedDate $_endedTime');
    // ----------------------------------------
    DateTime _overS;
    DateTime _overE;
    DateTime _baseE = DateTime.parse('$_endedDate ${group.workEnd}:00.000');
    if (_endedAt.millisecondsSinceEpoch > _baseE.millisecondsSinceEpoch) {
      _overS = _baseE;
      _overE = _endedAt;
    } else {
      _overS = _baseE;
      _overE = _baseE;
    }
    // ----------------------------------------
    String week = '${DateFormat('E', 'ja').format(_overS)}';
    if (group.holidays.contains(week)) {
      // 休日普通残業時間
      if (_overS.millisecondsSinceEpoch < _overE.millisecondsSinceEpoch) {
        Duration _overDiff = _overE.difference(_overS);
        String _overMinutes = twoDigits(_overDiff.inMinutes.remainder(60));
        _time3 = '${twoDigits(_overDiff.inHours)}:$_overMinutes';
      } else {
        _time3 = '00:00';
      }
      // 休日深夜残業時間
      if (_overS.millisecondsSinceEpoch < _overE.millisecondsSinceEpoch) {
        Duration _overDiff = _overE.difference(_overS);
        String _overMinutes = twoDigits(_overDiff.inMinutes.remainder(60));
        _time4 = '${twoDigits(_overDiff.inHours)}:$_overMinutes';
      } else {
        _time4 = '00:00';
      }
    } else {
      // 平日普通残業時間
      if (_overS.millisecondsSinceEpoch < _overE.millisecondsSinceEpoch) {
        Duration _overDiff = _overE.difference(_overS);
        String _overMinutes = twoDigits(_overDiff.inMinutes.remainder(60));
        _time1 = '${twoDigits(_overDiff.inHours)}:$_overMinutes';
      } else {
        _time1 = '00:00';
      }
      // 平日深夜残業時間
      if (_overS.millisecondsSinceEpoch < _overE.millisecondsSinceEpoch) {
        Duration _overDiff = _overE.difference(_overS);
        String _overMinutes = twoDigits(_overDiff.inMinutes.remainder(60));
        _time2 = '${twoDigits(_overDiff.inHours)}:$_overMinutes';
      } else {
        _time2 = '00:00';
      }
    }
    // ----------------------------------------
    return [_time1, _time2, _time3, _time4];
  }
}
