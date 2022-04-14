import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/work.dart';
import 'package:hatarakujikan_web/models/work_shift.dart';
import 'package:hatarakujikan_web/providers/work.dart';

const TextStyle timeStyle = TextStyle(
  color: Colors.black87,
  fontSize: 15.0,
);

const TextStyle timeStyle2 = TextStyle(
  color: Colors.transparent,
  fontSize: 15.0,
);

class WorkList extends StatelessWidget {
  final WorkProvider workProvider;
  final DateTime day;
  final List<WorkModel> dayInWorks;
  final WorkShiftModel? dayInWorkShift;
  final GroupModel? group;

  WorkList({
    required this.workProvider,
    required this.day,
    required this.dayInWorks,
    this.dayInWorkShift,
    this.group,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kBottomBorderDecoration,
      child: ListTile(
        leading: Text(
          dateText('dd (E)', day),
          style: TextStyle(
            color: Colors.black54,
            fontSize: 15.0,
          ),
        ),
        title: dayInWorks.length > 0
            ? ListView.separated(
                shrinkWrap: true,
                physics: ScrollPhysics(),
                separatorBuilder: (_, index) => Divider(height: 0.0),
                itemCount: dayInWorks.length,
                itemBuilder: (_, index) {
                  WorkModel _work = dayInWorks[index];
                  if (_work.startedAt == _work.endedAt) return Container();
                  String _startTime = _work.startTime(group);
                  String _endTime = _work.endTime(group);
                  String _breakTime = _work.breakTimes(group)[0];
                  String _workTime = _work.workTime(group);
                  List<String> _legalTimes = _work.legalTimes(group);
                  String _legalTime = _legalTimes.first;
                  String _nonLegalTime = _legalTimes.last;
                  List<String> _nightTimes = _work.nightTimes(group);
                  String _nightTime = _nightTimes.last;
                  return ListTile(
                    leading: Chip(
                      backgroundColor: Colors.grey.shade300,
                      label: Text(
                        _work.state,
                        style: TextStyle(
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_startTime, style: timeStyle),
                        Text(_endTime, style: timeStyle),
                        Text(_breakTime, style: timeStyle),
                        Text(_workTime, style: timeStyle),
                        Text(_legalTime, style: timeStyle),
                        Text(_nonLegalTime, style: timeStyle),
                        Text(_nightTime, style: timeStyle),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.map, color: Colors.blue),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  );
                },
              )
            : dayInWorkShift != null
                ? ListTile(
                    leading: Chip(
                      backgroundColor: dayInWorkShift?.stateColor2(),
                      label: Text(
                        dayInWorkShift?.state ?? '',
                        style: TextStyle(fontSize: 12.0),
                      ),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('00:00', style: timeStyle2),
                        Text('00:00', style: timeStyle2),
                        Text('00:00', style: timeStyle2),
                        Text('00:00', style: timeStyle2),
                        Text('00:00', style: timeStyle2),
                        Text('00:00', style: timeStyle2),
                        Text('00:00', style: timeStyle2),
                        Icon(Icons.edit, color: Colors.transparent),
                        Icon(Icons.map, color: Colors.transparent),
                      ],
                    ),
                  )
                : Container(),
      ),
    );
  }
}
