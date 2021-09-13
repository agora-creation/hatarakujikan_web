import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/models/work.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/providers/work_shift.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold.dart';
import 'package:hatarakujikan_web/widgets/custom_date_button.dart';
import 'package:hatarakujikan_web/widgets/custom_dropdown_button.dart';
import 'package:hatarakujikan_web/widgets/custom_label_column.dart';
import 'package:hatarakujikan_web/widgets/custom_sf_calendar.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';
import 'package:hatarakujikan_web/widgets/custom_time_button.dart';
import 'package:hatarakujikan_web/widgets/loading.dart';
import 'package:intl/intl.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class WorkShiftScreen extends StatelessWidget {
  static const String id = 'workShift';

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final workShiftProvider = Provider.of<WorkShiftProvider>(context);

    return CustomAdminScaffold(
      groupProvider: groupProvider,
      selectedRoute: id,
      body: WorkShiftTable(
        groupProvider: groupProvider,
        workShiftProvider: workShiftProvider,
      ),
    );
  }
}

class WorkShiftTable extends StatefulWidget {
  final GroupProvider groupProvider;
  final WorkShiftProvider workShiftProvider;

  WorkShiftTable({
    @required this.groupProvider,
    @required this.workShiftProvider,
  });

  @override
  _WorkShiftTableState createState() => _WorkShiftTableState();
}

class _WorkShiftTableState extends State<WorkShiftTable> {
  List<CalendarResource> _resources = [];
  List<Appointment> _appointments = [];

  void _init() async {
    widget.groupProvider.users.forEach((user) {
      _resources.add(CalendarResource(
        id: '${user.id}',
        displayName: '${user.name}',
        color: Colors.grey.shade100,
      ));
    });
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    GroupModel _group = widget.groupProvider.group;
    Stream<QuerySnapshot> _streamWork = FirebaseFirestore.instance
        .collection('work')
        .where('groupId', isEqualTo: _group?.id ?? 'error')
        .orderBy('startedAt', descending: false)
        .snapshots();
    Stream<QuerySnapshot> _streamWorkShift = FirebaseFirestore.instance
        .collection('workShift')
        .where('groupId', isEqualTo: _group?.id ?? 'error')
        .orderBy('startedAt', descending: false)
        .snapshots();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'シフト表',
          style: kAdminTitleTextStyle,
        ),
        Text(
          'スタッフ毎の予定日時と勤務日時が表示されます。',
          style: kAdminSubTitleTextStyle,
        ),
        SizedBox(height: 16.0),
        Expanded(
          child: StreamBuilder2<QuerySnapshot, QuerySnapshot>(
            streams: Tuple2(_streamWork, _streamWorkShift),
            builder: (context, snapshot) {
              if (!snapshot.item1.hasData) {
                return Loading(color: Colors.orange);
              }
              _appointments.clear();
              for (DocumentSnapshot doc in snapshot.item1.data.docs) {
                WorkModel _work = WorkModel.fromSnapshot(doc);
                if (_work.startedAt != _work.endedAt) {
                  _appointments.add(Appointment(
                    startTime: _work.startedAt,
                    endTime: _work.endedAt,
                    subject: '${_work.state}',
                    color: Colors.grey,
                    resourceIds: [_work.userId],
                  ));
                }
              }
              return CustomSfCalendar(
                dataSource: _ShiftDataSource(_appointments, _resources),
                onTap: (CalendarTapDetails details) {
                  if (details.appointments != null) {
                    dynamic _appointment = details.appointments[0];
                    Appointment _selected;
                    if (_appointment is Appointment) {
                      _selected = _appointment;
                    }
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (_) => EditShiftDialog(
                        day: details.date,
                        resource: details.resource,
                        appointment: _selected,
                      ),
                    );
                  } else {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (_) => AddWorkShiftDialog(
                        workShiftProvider: widget.workShiftProvider,
                        group: widget.groupProvider.group,
                        users: widget.groupProvider.users,
                        date: details.date,
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ShiftDataSource extends CalendarDataSource {
  _ShiftDataSource(
    List<Appointment> source,
    List<CalendarResource> resourceColl,
  ) {
    appointments = source;
    resources = resourceColl;
  }
}

class AddWorkShiftDialog extends StatefulWidget {
  final WorkShiftProvider workShiftProvider;
  final GroupModel group;
  final List<UserModel> users;
  final DateTime date;

  AddWorkShiftDialog({
    @required this.workShiftProvider,
    @required this.group,
    @required this.users,
    @required this.date,
  });

  @override
  _AddWorkShiftDialogState createState() => _AddWorkShiftDialogState();
}

class _AddWorkShiftDialogState extends State<AddWorkShiftDialog> {
  UserModel _user;
  String _state;
  DateTime _startedAt = DateTime.now();
  DateTime _endedAt = DateTime.now();

  void _init() async {
    _startedAt = widget.date;
    _endedAt = widget.date.add(Duration(hours: 8));
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
            SizedBox(height: 8.0),
            Center(
              child: Text(
                '${DateFormat('yyyy/MM/dd(E)', 'ja').format(widget.date)}の予定追加',
                style: kAdminTitleTextStyle,
              ),
            ),
            SizedBox(height: 16.0),
            CustomLabelColumn(
              label: 'スタッフ',
              child: CustomDropdownButton(
                isExpanded: true,
                value: _user,
                onChanged: (value) {
                  setState(() => _user = value);
                },
                items: widget.users.map((value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(
                      '${value.name}',
                      style: kDefaultTextStyle,
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 8.0),
            CustomLabelColumn(
              label: '勤務状況',
              child: CustomDropdownButton(
                isExpanded: true,
                value: _state,
                onChanged: (value) {
                  setState(() => _state = value);
                },
                items: widget.workShiftProvider.states.map((value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(
                      value,
                      style: kDefaultTextStyle,
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 8.0),
            CustomLabelColumn(
              label: '開始日時',
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: CustomDateButton(
                      onPressed: () async {
                        DateTime _selected = await showDatePicker(
                          context: context,
                          initialDate: _startedAt,
                          firstDate: kDayFirstDate,
                          lastDate: kDayLastDate,
                        );
                        if (_selected != null) {
                          _selected = rebuildDate(_selected, _startedAt);
                          setState(() => _startedAt = _selected);
                        }
                      },
                      label: '${DateFormat('yyyy/MM/dd').format(_startedAt)}',
                    ),
                  ),
                  SizedBox(width: 4.0),
                  Expanded(
                    flex: 2,
                    child: CustomTimeButton(
                      onPressed: () async {
                        TimeOfDay _selected = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                            hour: timeToInt(_startedAt)[0],
                            minute: timeToInt(_startedAt)[1],
                          ),
                        );
                        if (_selected != null) {
                          DateTime _dateTime = rebuildTime(
                            context,
                            _startedAt,
                            _selected,
                          );
                          setState(() => _startedAt = _dateTime);
                        }
                      },
                      label: '${DateFormat('HH:mm').format(_startedAt)}',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.0),
            CustomLabelColumn(
              label: '終了日時',
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: CustomDateButton(
                      onPressed: () async {
                        DateTime _selected = await showDatePicker(
                          context: context,
                          initialDate: _endedAt,
                          firstDate: kDayFirstDate,
                          lastDate: kDayLastDate,
                        );
                        if (_selected != null) {
                          _selected = rebuildDate(_selected, _endedAt);
                          setState(() => _endedAt = _selected);
                        }
                      },
                      label: '${DateFormat('yyyy/MM/dd').format(_endedAt)}',
                    ),
                  ),
                  SizedBox(width: 4.0),
                  Expanded(
                    flex: 2,
                    child: CustomTimeButton(
                      onPressed: () async {
                        TimeOfDay _selected = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                            hour: timeToInt(_endedAt)[0],
                            minute: timeToInt(_endedAt)[1],
                          ),
                        );
                        if (_selected != null) {
                          DateTime _dateTime = rebuildTime(
                            context,
                            _endedAt,
                            _selected,
                          );
                          setState(() => _endedAt = _dateTime);
                        }
                      },
                      label: '${DateFormat('HH:mm').format(_endedAt)}',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextButton(
                  onPressed: () => Navigator.pop(context),
                  color: Colors.grey,
                  label: 'キャンセル',
                ),
                CustomTextButton(
                  onPressed: () async {
                    if (!await widget.workShiftProvider.create(
                      group: widget.group,
                      user: _user,
                      startedAt: _startedAt,
                      endedAt: _endedAt,
                      state: _state,
                    )) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('シフト表に予定を追加しました')),
                    );
                    Navigator.pop(context);
                  },
                  color: Colors.blue,
                  label: '登録する',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EditShiftDialog extends StatelessWidget {
  final DateTime day;
  final CalendarResource resource;
  final Appointment appointment;

  EditShiftDialog({
    @required this.day,
    @required this.resource,
    @required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        width: 450.0,
        child: ListView(
          shrinkWrap: true,
          children: [
            SizedBox(height: 8.0),
            Center(
              child: Text(
                '${DateFormat('yyyy/MM/dd (E)', 'ja').format(day)}',
                style: kAdminTitleTextStyle,
              ),
            ),
            SizedBox(height: 16.0),
            CustomLabelColumn(
              label: '勤務状況',
              child: Text('${appointment.subject}'),
            ),
            Divider(),
            CustomLabelColumn(
              label: '出勤日時',
              child:
                  Text('${DateFormat('HH:mm').format(appointment.startTime)}'),
            ),
            Divider(),
            CustomLabelColumn(
              label: '退勤日時',
              child: Text('${DateFormat('HH:mm').format(appointment.endTime)}'),
            ),
            Divider(),
            CustomLabelColumn(
              label: 'スタッフ',
              child: Text('${resource.displayName}'),
            ),
            Divider(),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextButton(
                  onPressed: () => Navigator.pop(context),
                  color: Colors.grey,
                  label: 'キャンセル',
                ),
                CustomTextButton(
                  onPressed: () => Navigator.pop(context),
                  color: Colors.blue,
                  label: 'はい',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
