import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/models/breaks.dart';
import 'package:hatarakujikan_web/models/group.dart';

class WorkModel {
  String _id = '';
  String _groupId = '';
  String userId = '';
  DateTime startedAt = DateTime.now();
  double startedLat = 0;
  double startedLon = 0;
  DateTime endedAt = DateTime.now();
  double endedLat = 0;
  double endedLon = 0;
  List<BreaksModel> breaks = [];
  String state = '';
  DateTime _createdAt = DateTime.now();

  String get id => _id;
  String get groupId => _groupId;
  DateTime get createdAt => _createdAt;

  WorkModel.set(Map data) {
    _id = data['id'] ?? '';
    _groupId = data['groupId'] ?? '';
    userId = data['userId'] ?? '';
    startedAt = data['startedAt'] ?? DateTime.now();
    startedLat = data['startedLat'] ?? 0;
    startedLon = data['startedLon'] ?? 0;
    endedAt = data['endedAt'] ?? DateTime.now();
    endedLat = data['endedLat'] ?? 0;
    endedLon = data['endedLon'] ?? 0;
    breaks = data['breaks'] ?? [];
    state = data['state'] ?? '';
    _createdAt = data['createdAt'] ?? DateTime.now();
  }

  WorkModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    _id = snapshot.data()!['id'] ?? '';
    _groupId = snapshot.data()!['groupId'] ?? '';
    userId = snapshot.data()!['userId'] ?? '';
    startedAt = snapshot.data()!['startedAt'].toDate() ?? DateTime.now();
    startedLat = snapshot.data()!['startedLat'].toDouble() ?? 0;
    startedLon = snapshot.data()!['startedLon'].toDouble() ?? 0;
    endedAt = snapshot.data()!['endedAt'].toDate() ?? DateTime.now();
    endedLat = snapshot.data()!['endedLat'].toDouble() ?? 0;
    endedLon = snapshot.data()!['endedLon'].toDouble() ?? 0;
    breaks = _convertBreaks(snapshot.data()!['breaks']);
    state = snapshot.data()!['state'] ?? '';
    _createdAt = snapshot.data()!['createdAt'].toDate() ?? DateTime.now();
  }

  List<BreaksModel> _convertBreaks(List breaks) {
    List<BreaksModel> converted = [];
    for (Map data in breaks) {
      converted.add(BreaksModel.fromMap(data));
    }
    return converted;
  }

  String startTime(GroupModel? group) {
    String _time = dateText('HH:mm', startedAt);
    if (group != null) {
      switch (group.roundStartType) {
        case '切捨':
          _time = roundDownTime(_time, group.roundStartNum);
          break;
        case '切上':
          _time = roundUpTime(_time, group.roundStartNum);
          break;
        default:
          break;
      }
    }
    return _time;
  }

  String endTime(GroupModel? group) {
    String _time = dateText('HH:mm', endedAt);
    if (group != null) {
      switch (group.roundEndType) {
        case '切捨':
          _time = roundDownTime(_time, group.roundEndNum);
          break;
        case '切上':
          _time = roundUpTime(_time, group.roundEndNum);
          break;
        default:
          break;
      }
    }
    return _time;
  }

  List<String> breakTimes(GroupModel? group) {
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

  String workTime(GroupModel? group) {
    String _time = '00:00';
    String _startedDate = dateText('yyyy-MM-dd', startedAt);
    String _startedTime = '${startTime(group)}:00.000';
    DateTime _startedAt = DateTime.parse('$_startedDate $_startedTime');
    String _endedDate = dateText('yyyy-MM-dd', endedAt);
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
  List<String> legalTimes(GroupModel? group) {
    String _time1 = '00:00';
    String _time2 = '00:00';
    if (group != null) {
      List<String> _times = workTime(group).split(':');
      if (group.legal <= int.parse(_times.first)) {
        _time1 = addTime(_time1, '0${group.legal}:00');
        String _tmp = subTime(workTime(group), '0${group.legal}:00');
        _time2 = addTime(_time2, _tmp);
      } else {
        _time1 = addTime(_time1, workTime(group));
        _time2 = addTime(_time2, '00:00');
      }
    }
    return [_time1, _time2];
  }

  // 深夜時間/深夜時間外
  List<String> nightTimes(GroupModel? group) {
    String _time1 = '00:00';
    String _time2 = '00:00';
    String _startedDate = dateText('yyyy-MM-dd', startedAt);
    String _startedTime = '${startTime(group)}:00.000';
    DateTime _startedAt = DateTime.parse('$_startedDate $_startedTime');
    String _endedDate = dateText('yyyy-MM-dd', endedAt);
    String _endedTime = '${endTime(group)}:00.000';
    DateTime _endedAt = DateTime.parse('$_endedDate $_endedTime');
    // ----------------------------------------
    // 通常時間と深夜時間に分ける
    List<DateTime> _dayNightList = separateDayNight(
      startedAt: _startedAt,
      endedAt: _endedAt,
      nightStart: group?.nightStart ?? '22:00',
      nightEnd: group?.nightEnd ?? '05:00',
    );
    DateTime? _dayS = _dayNightList[0];
    DateTime? _dayE = _dayNightList[1];
    DateTime? _nightS = _dayNightList[2];
    DateTime? _nightE = _dayNightList[3];
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
  List<String> overTimes(GroupModel? group) {
    String _time1 = '00:00';
    String _time2 = '00:00';
    String _startedDate = dateText('yyyy-MM-dd', startedAt);
    String _startedTime = '${startTime(group)}:00.000';
    DateTime _startedAt = DateTime.parse('$_startedDate $_startedTime');
    String _endedDate = dateText('yyyy-MM-dd', endedAt);
    String _endedTime = '${endTime(group)}:00.000';
    DateTime _endedAt = DateTime.parse('$_endedDate $_endedTime');
    // ----------------------------------------
    String _workStart = '${group?.workStart}:00.000';
    String _workEnd = '${group?.workEnd}:00.000';
    DateTime? _over1S;
    DateTime? _over1E;
    DateTime? _over2S;
    DateTime? _over2E;
    DateTime? _s = DateTime.parse('$_startedDate $_workStart');
    DateTime? _e = DateTime.parse('$_endedDate $_workEnd');
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

  // 通常時間/深夜時間(-深夜時間外)/通常時間外/深夜時間外
  List<String> calTimes01(GroupModel? group) {
    String _time1 = '00:00';
    String _time2 = '00:00';
    String _time3 = '00:00';
    String _time4 = '00:00';
    String _startedDate = dateText('yyyy-MM-dd', startedAt);
    String _startedTime = '${startTime(group)}:00.000';
    DateTime _startedAt = DateTime.parse('$_startedDate $_startedTime');
    String _endedDate = dateText('yyyy-MM-dd', endedAt);
    String _endedTime = '${endTime(group)}:00.000';
    DateTime _endedAt = DateTime.parse('$_endedDate $_endedTime');
    int _legal = group?.legal ?? 8;
    // ----------------------------------------
    // 出勤時間～退勤時間を、通常時間枠と深夜時間枠に分ける
    List<DateTime> _dayNightList = separateDayNight(
      startedAt: _startedAt,
      endedAt: _endedAt,
      nightStart: group?.nightStart ?? '22:00',
      nightEnd: group?.nightEnd ?? '05:00',
    );
    DateTime? _dayS = _dayNightList[0];
    DateTime? _dayE = _dayNightList[1];
    DateTime? _nightS = _dayNightList[2];
    DateTime? _nightE = _dayNightList[3];
    // ----------------------------------------
    // 通常勤務時間を算出する
    String _dayWorkTime = '00:00';
    if (_dayS.millisecondsSinceEpoch < _dayE.millisecondsSinceEpoch) {
      Duration _diff = _dayE.difference(_dayS);
      String _minutes = twoDigits(_diff.inMinutes.remainder(60));
      _dayWorkTime = '${twoDigits(_diff.inHours)}:$_minutes';
    }
    // 深夜勤務時間を算出する
    String _nightWorkTime = '00:00';
    if (_nightS.millisecondsSinceEpoch < _nightE.millisecondsSinceEpoch) {
      Duration _diff = _nightE.difference(_nightS);
      String _minutes = twoDigits(_diff.inMinutes.remainder(60));
      _nightWorkTime = '${twoDigits(_diff.inHours)}:$_minutes';
    }
    // それぞれ休憩時間を引く
    _dayWorkTime = subTime(_dayWorkTime, breakTimes(group)[1]);
    _nightWorkTime = subTime(_nightWorkTime, breakTimes(group)[2]);
    // 総合勤務時間を算出する
    String _workTime = addTime(_dayWorkTime, _nightWorkTime);
    // 勤務時間外を算出する
    List<String> _workTimeList = _workTime.split(':');
    String _overTime = '00:00';
    if (_legal <= int.parse(_workTimeList.first)) {
      _overTime = subTime(_workTime, '0$_legal:00');
    }
    // ----------------------------------------
    // 通常時間を算出する
    List<String> _dayWorkTimeList = _dayWorkTime.split(':');
    if (_legal <= int.parse(_dayWorkTimeList.first)) {
      _time1 = '0$_legal:00';
    } else {
      _time1 = _dayWorkTime;
    }
    // ----------------------------------------
    // 深夜時間を算出する
    List<String> _nightWorkTimeList = _nightWorkTime.split(':');
    if (_legal <= int.parse(_nightWorkTimeList.first)) {
      _time2 = '0$_legal:00';
    } else {
      _time2 = _nightWorkTime;
    }
    // ----------------------------------------
    // 通常時間外を算出する
    List<String> _time2List = _time2.split(':');
    int _time2Minute =
        (int.parse(_time2List.first) * 60) + int.parse(_time2List.last);
    List<String> _overTimeList = _overTime.split(':');
    int _overTimeMinute =
        (int.parse(_overTimeList.first) * 60) + int.parse(_overTimeList.last);
    if (_time2Minute > _overTimeMinute) {
      _time3 = subTime(_time2, _overTime);
    } else {
      _time3 = subTime(_overTime, _time2);
    }
    // ----------------------------------------
    // 深夜時間外を算出する
    List<String> _time3List = _time3.split(':');
    int _time3Minute =
        (int.parse(_time3List.first) * 60) + int.parse(_time3List.last);
    if (_time3Minute > _overTimeMinute) {
      _time4 = subTime(_time3, _overTime);
    } else {
      _time4 = subTime(_overTime, _time3);
    }
    // ----------------------------------------
    // 深夜時間を再度算出する
    _time2 = subTime(_time2, _time4);
    // ----------------------------------------
    return [_time1, _time2, _time3, _time4];
  }

  // 勤務時間/時間外1/時間外2
  List<String> calTimes02(GroupModel? group, String? type) {
    String _time0 = '00:00';
    String _time1 = '00:00';
    String _time2 = '00:00';
    String _startedDate = dateText('yyyy-MM-dd', startedAt);
    String _startedTime = '${startTime(group)}:00.000';
    DateTime _startedAt = DateTime.parse('$_startedDate $_startedTime');
    String _workStart = '${group?.workStart}:00.000';
    // AグループかBグループ
    if (type == 'A' || type == 'B') {
      DateTime _startedAtTmp = DateTime.parse('$_startedDate $_workStart');
      if (_startedAt.millisecondsSinceEpoch <
          _startedAtTmp.millisecondsSinceEpoch) {
        _startedAt = _startedAtTmp;
      }
    }
    String _endedDate = dateText('yyyy-MM-dd', endedAt);
    String _endedTime = '${endTime(group)}:00.000';
    DateTime _endedAt = DateTime.parse('$_endedDate $_endedTime');
    // ----------------------------------------
    // 出勤時間と退勤時間の差を求める
    Duration _diff = _endedAt.difference(_startedAt);
    String _minutes = twoDigits(_diff.inMinutes.remainder(60));
    _time0 = '${twoDigits(_diff.inHours)}:$_minutes';
    // 休憩の合計時間を求める
    String _breakTime = '00:00';
    if (breaks.length > 0) {
      for (BreaksModel _break in breaks) {
        _breakTime = addTime(_breakTime, _break.breakTimes(group)[0]);
      }
    }
    // 勤務時間と休憩の合計時間の差を求める
    _time0 = subTime(_time0, _breakTime);
    // ----------------------------------------
    // Aグループ
    if (type == 'A') {
      String _workEnd = '${group?.workEnd}:00.000';
      DateTime _time1start = DateTime.parse('$_endedDate $_workEnd');
      DateTime _time1end = _endedAt;
      if (_time1start.millisecondsSinceEpoch <
          _time1end.millisecondsSinceEpoch) {
        Duration _diff = _time1end.difference(_time1start);
        String _minutes = twoDigits(_diff.inMinutes.remainder(60));
        _time1 = '${twoDigits(_diff.inHours)}:$_minutes';
      }
    }
    // ----------------------------------------
    // Bグループ
    if (type == 'B') {
      String _workEnd = '${group?.workEnd}:00.000';
      DateTime _time1start = DateTime.parse('$_endedDate $_workEnd'); //17:00
      DateTime _time1end = _time1start.add(Duration(hours: 1)); //18:00
      if (_endedAt.millisecondsSinceEpoch < _time1end.millisecondsSinceEpoch) {
        if (_time1start.millisecondsSinceEpoch <
            _endedAt.millisecondsSinceEpoch) {
          // Duration _diff = _endedAt.difference(_time1start);
          // String _minutes = twoDigits(_diff.inMinutes.remainder(60));
          // _time1 = '${twoDigits(_diff.inHours)}:$_minutes';
        }
      } else {
        if (_time1start.millisecondsSinceEpoch <
            _time1end.millisecondsSinceEpoch) {
          // Duration _diff = _time1end.difference(_time1start);
          // String _minutes = twoDigits(_diff.inMinutes.remainder(60));
          // _time1 = '${twoDigits(_diff.inHours)}:$_minutes';
        }
        DateTime _time2start = _time1end;
        DateTime _time2end = _endedAt;
        if (_time2start.millisecondsSinceEpoch <
            _time2end.millisecondsSinceEpoch) {
          Duration _diff = _time2end.difference(_time2start);
          String _minutes = twoDigits(_diff.inMinutes.remainder(60));
          _time2 = '${twoDigits(_diff.inHours)}:$_minutes';
        }
      }
    }
    // ----------------------------------------
    // Cグループ
    if (type == 'C') {
      List<String> _time0s = _time0.split(':');
      int _legal = group?.legal ?? 0;
      if (_legal <= int.parse(_time0s.first)) {
        String _tmp = subTime(_time0, '0$_legal:00');
        _time2 = addTime(_time2, _tmp);
      } else {
        _time2 = '00:00';
      }
    }
    // ----------------------------------------
    // Dグループ
    if (type == 'D') {
      List<String> _time0s = _time0.split(':');
      int _legal = group?.legal ?? 0;
      if (_legal <= int.parse(_time0s.first)) {
        String _tmp = subTime(_time0, '0$_legal:00');
        _time2 = addTime(_time2, _tmp);
      } else {
        _time2 = '00:00';
      }
    }
    // ----------------------------------------
    String week = dateText('E', _startedAt);
    if (group!.holidays.contains(week)) {
      _time2 = _time0;
      _time1 = '00:00';
    }
    String key = dateText('yyyy-MM-dd', _startedAt);
    DateTime day = DateTime.parse(key);
    if (group.holidays2.contains(day)) {
      _time2 = _time0;
      _time1 = '00:00';
    }
    // ----------------------------------------
    // 勤務時間から時間外分を引く
    if (_time1 != '00:00') {
      _time0 = subTime(_time0, _time1);
    }
    if (_time2 != '00:00') {
      _time0 = subTime(_time0, _time2);
    }
    // ----------------------------------------
    return [_time0, _time1, _time2];
  }
}
