import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/work.dart';

const TextStyle footStyle = TextStyle(
  color: Colors.black54,
  fontSize: 15.0,
);

class WorkFooter extends StatelessWidget {
  final List<WorkModel> works;
  final GroupModel? group;

  WorkFooter({
    required this.works,
    this.group,
  });

  @override
  Widget build(BuildContext context) {
    Map _cnt = {};
    int workdays = 0;
    String workTime = '00:00';
    String legalTime = '00:00';
    String nonLegalTime = '00:00';
    String nightTime = '00:00';
    for (WorkModel _work in works) {
      if (_work.startedAt != _work.endedAt) {
        String _key = dateText('yyyy-MM-dd', _work.startedAt);
        _cnt[_key] = '';
        workTime = addTime(workTime, _work.workTime(group));
        List<String> _legalTimes = _work.legalTimes(group);
        legalTime = addTime(legalTime, _legalTimes.first);
        nonLegalTime = addTime(nonLegalTime, _legalTimes.last);
        List<String> _nightTimes = _work.nightTimes(group);
        nightTime = addTime(nightTime, _nightTimes.last);
      }
    }
    workdays = _cnt.length;

    return Container(
      decoration: kTopBorderDecoration,
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('総勤務日数 [$workdays日]', style: footStyle),
            Text('総勤務時間 [$workTime]', style: footStyle),
            Text('総法定内時間 [$legalTime]', style: footStyle),
            Text('総法定外時間 [$nonLegalTime]', style: footStyle),
            Text('総深夜時間 [$nightTime]', style: footStyle),
          ],
        ),
      ),
    );
  }
}
