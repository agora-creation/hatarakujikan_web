import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/define.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/breaks.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/models/work.dart';
import 'package:hatarakujikan_web/models/work_shift.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/providers/work.dart';
import 'package:hatarakujikan_web/widgets/custom_dropdown_button.dart';

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

class EditDialog extends StatefulWidget {
  final GroupProvider groupProvider;
  final WorkProvider workProvider;
  final WorkModel? work;
  final GroupModel? group;

  EditDialog({
    required this.groupProvider,
    required this.workProvider,
    this.work,
    this.group,
  });

  @override
  _EditDialogState createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  List<UserModel> users = [];
  WorkModel? work;
  List<BreaksModel> breaks = [];

  void _init() async {
    List<UserModel> _users = await widget.groupProvider.selectUsers();
    if (mounted) {
      setState(() {
        users = _users;
        work = WorkModel.fromMap({
          'id': widget.work?.id,
          'groupId': widget.work?.groupId,
          'userId': widget.work?.userId,
          'startedAt': DateTime.now(),
          'startedLat': 0,
          'startedLon': 0,
          'endedAt': DateTime.now().add(Duration(hours: 8)),
          'endedLat': 0,
          'endedLon': 0,
          'breaks': [],
          'state': workStates.first,
          'createdAt': DateTime.now(),
        });

        id = widget.work?.id;
        userId = widget.work?.userId;
        startedAt = widget.work?.startedAt;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        width: 450.0,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              '情報を変更し、「保存する」ボタンをクリックしてください。',
              style: kDialogTextStyle,
            ),
            SizedBox(height: 16.0),
            CustomDropdownButton(
              label: '対象スタッフ',
              isExpanded: true,
              value: userId,
              onChanged: (value) {
                setState(() => userId = value);
              },
              items: users.map((user) {
                return DropdownMenuItem(
                  value: user.id,
                  child: Text(
                    user.name,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14.0,
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 8.0),
            CustomDropdownButton(
              label: '勤務状況',
              isExpanded: true,
              value: state,
              onChanged: (value) {
                setState(() => state = value);
              },
              items: workStates.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14.0,
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 8.0),
            DateTimeFormField(
              label: '出勤日時',
              date: dateText('yyyy/MM/dd', startedAt),
              dateOnPressed: () async {
                DateTime? _date = await customDatePicker(
                  context: context,
                  init: startedAt,
                );
                if (_date == null) return;
                DateTime _dateTime = rebuildDate(_date, startedAt);
                setState(() => startedAt = _dateTime);
              },
              time: dateText('HH:mm', startedAt),
              timeOnPressed: () async {
                String? _time = await customTimePicker(
                  context: context,
                  init: dateText('HH:mm', startedAt),
                );
                if (_time == null) return;
                DateTime _dateTime = rebuildTime(context, startedAt, _time);
                setState(() => startedAt = _dateTime);
              },
            ),
            SizedBox(height: 8.0),
            DateTimeFormField(
              label: '退勤日時',
              date: dateText('yyyy/MM/dd', endedAt),
              dateOnPressed: () async {
                DateTime? _date = await customDatePicker(
                  context: context,
                  init: endedAt,
                );
                if (_date == null) return;
                DateTime _dateTime = rebuildDate(_date, endedAt);
                setState(() => endedAt = _dateTime);
              },
              time: dateText('HH:mm', endedAt),
              timeOnPressed: () async {
                String? _time = await customTimePicker(
                  context: context,
                  init: dateText('HH:mm', endedAt),
                );
                if (_time == null) return;
                DateTime _dateTime = rebuildTime(context, endedAt, _time);
                setState(() => endedAt = _dateTime);
              },
            ),
            SizedBox(height: 8.0),
            CustomCheckbox(
              label: '休憩時間を入力する',
              value: isBreaks,
              activeColor: Colors.blue,
              onChanged: (value) {
                setState(() => isBreaks = value!);
              },
            ),
            SizedBox(height: 8.0),
            isBreaks == true
                ? Column(
                    children: [
                      DateTimeFormField(
                        label: '休憩開始日時',
                        date: dateText('yyyy/MM/dd', breakStartedAt),
                        dateOnPressed: () async {
                          DateTime? _date = await customDatePicker(
                            context: context,
                            init: breakStartedAt,
                          );
                          if (_date == null) return;
                          DateTime _dateTime =
                              rebuildDate(_date, breakStartedAt);
                          setState(() => breakStartedAt = _dateTime);
                        },
                        time: dateText('HH:mm', breakStartedAt),
                        timeOnPressed: () async {
                          String? _time = await customTimePicker(
                            context: context,
                            init: dateText('HH:mm', breakStartedAt),
                          );
                          if (_time == null) return;
                          DateTime _dateTime = rebuildTime(
                            context,
                            breakStartedAt,
                            _time,
                          );
                          setState(() => breakStartedAt = _dateTime);
                        },
                      ),
                      SizedBox(height: 8.0),
                      DateTimeFormField(
                        label: '休憩終了日時',
                        date: dateText('yyyy/MM/dd', breakEndedAt),
                        dateOnPressed: () async {
                          DateTime? _date = await customDatePicker(
                            context: context,
                            init: breakEndedAt,
                          );
                          if (_date == null) return;
                          DateTime _dateTime = rebuildDate(_date, breakEndedAt);
                          setState(() => breakEndedAt = _dateTime);
                        },
                        time: dateText('HH:mm', breakEndedAt),
                        timeOnPressed: () async {
                          String? _time = await customTimePicker(
                            context: context,
                            init: dateText('HH:mm', breakEndedAt),
                          );
                          if (_time == null) return;
                          DateTime _dateTime = rebuildTime(
                            context,
                            breakEndedAt,
                            _time,
                          );
                          setState(() => breakEndedAt = _dateTime);
                        },
                      ),
                    ],
                  )
                : Container(),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextButton(
                  label: 'キャンセル',
                  color: Colors.grey,
                  onPressed: () => Navigator.pop(context),
                ),
                CustomTextButton(
                  label: '登録する',
                  color: Colors.blue,
                  onPressed: () async {
                    if (!await widget.workProvider.create(
                      group: widget.group,
                      userId: userId,
                      startedAt: startedAt,
                      endedAt: endedAt,
                      isBreaks: isBreaks,
                      breakStartedAt: breakStartedAt,
                      breakEndedAt: breakEndedAt,
                      state: state,
                    )) {
                      return;
                    }
                    customSnackBar(context, '勤務日時を登録しました');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
