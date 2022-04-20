import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/define.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/models/work.dart';
import 'package:hatarakujikan_web/models/work_shift.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/providers/work_shift.dart';
import 'package:hatarakujikan_web/widgets/admin_header.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold.dart';
import 'package:hatarakujikan_web/widgets/custom_dropdown_button.dart';
import 'package:hatarakujikan_web/widgets/custom_sf_calendar.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';
import 'package:hatarakujikan_web/widgets/datetime_form_field.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class _ShiftDataSource extends CalendarDataSource {
  _ShiftDataSource(
    List<Appointment> source,
    List<CalendarResource> resourceColl,
  ) {
    appointments = source;
    resources = resourceColl;
  }
}

class WorkShiftScreen extends StatelessWidget {
  static const String id = 'workShift';

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final workShiftProvider = Provider.of<WorkShiftProvider>(context);

    return CustomAdminScaffold(
      groupProvider: groupProvider,
      selectedRoute: id,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminHeader(
            title: 'シフト表',
            message: 'スタッフ毎の実務/予定データをシフト表形式で表示しています。予定データを登録できます。',
          ),
          SizedBox(height: 8.0),
          Expanded(
            child: ShiftTable(
              groupProvider: groupProvider,
              workShiftProvider: workShiftProvider,
            ),
          ),
        ],
      ),
    );
  }
}

class ShiftTable extends StatefulWidget {
  final GroupProvider groupProvider;
  final WorkShiftProvider workShiftProvider;

  ShiftTable({
    required this.groupProvider,
    required this.workShiftProvider,
  });

  @override
  State<ShiftTable> createState() => _ShiftTableState();
}

class _ShiftTableState extends State<ShiftTable> {
  List<CalendarResource> resources = [];
  List<Appointment> appointments = [];

  void _init() async {
    List<UserModel> _users = await widget.groupProvider.selectUsers();
    if (mounted) {
      setState(() {
        for (UserModel _user in _users) {
          resources.add(CalendarResource(
            id: _user.id,
            displayName: _user.name,
            color: Colors.grey.shade100,
          ));
        }
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
    GroupModel? group = widget.groupProvider.group;

    return StreamBuilder2<QuerySnapshot<Map<String, dynamic>>,
        QuerySnapshot<Map<String, dynamic>>>(
      streams: Tuple2(
        widget.workShiftProvider.streamList(groupId: group?.id),
        widget.workShiftProvider.streamListShift(groupId: group?.id),
      ),
      builder: (context, snapshot) {
        appointments.clear();
        if (snapshot.item1.hasData) {
          for (DocumentSnapshot<Map<String, dynamic>> doc
              in snapshot.item1.data!.docs) {
            WorkModel work = WorkModel.fromSnapshot(doc);
            if (work.startedAt != work.endedAt) {
              appointments.add(Appointment(
                startTime: work.startedAt,
                endTime: work.endedAt,
                subject: work.state,
                color: Colors.grey,
                resourceIds: [work.userId],
                id: work.id,
                notes: 'work',
              ));
            }
          }
        }
        if (snapshot.item2.hasData) {
          for (DocumentSnapshot<Map<String, dynamic>> doc
              in snapshot.item2.data!.docs) {
            WorkShiftModel workShift = WorkShiftModel.fromSnapshot(doc);
            appointments.add(Appointment(
              startTime: workShift.startedAt,
              endTime: workShift.endedAt,
              subject: workShift.state,
              color: workShift.stateColor(),
              resourceIds: [workShift.userId],
              id: workShift.id,
              notes: 'workShift',
            ));
          }
        }
        return CustomSfCalendar(
          dataSource: _ShiftDataSource(appointments, resources),
          onTap: (CalendarTapDetails details) {
            if (details.appointments != null) {
              dynamic _appointment = details.appointments![0];
              Appointment? _selected;
              if (_appointment is Appointment) _selected = _appointment;
              if (_selected?.notes == 'workShift') {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (_) => EditDialog(
                    groupProvider: widget.groupProvider,
                    workShiftProvider: widget.workShiftProvider,
                    userId: '${details.resource?.id}',
                    appointment: _selected,
                  ),
                );
              }
            } else {
              if (details.resource != null) {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (_) => AddDialog(
                    groupProvider: widget.groupProvider,
                    workShiftProvider: widget.workShiftProvider,
                    userId: '${details.resource?.id}',
                    date: details.date,
                  ),
                );
              }
            }
          },
        );
      },
    );
  }
}

class AddDialog extends StatefulWidget {
  final GroupProvider groupProvider;
  final WorkShiftProvider workShiftProvider;
  final String? userId;
  final DateTime? date;

  AddDialog({
    required this.groupProvider,
    required this.workShiftProvider,
    this.userId,
    this.date,
  });

  @override
  _AddDialogState createState() => _AddDialogState();
}

class _AddDialogState extends State<AddDialog> {
  List<UserModel> users = [];
  WorkShiftModel? workShift;

  void _init() async {
    List<UserModel> _users = await widget.groupProvider.selectUsers();
    if (mounted) {
      setState(() {
        users = _users;
        workShift = WorkShiftModel.set({
          'groupId': widget.groupProvider.group?.id,
          'userId': widget.userId,
          'startedAt': widget.date,
          'endedAt': widget.date?.add(Duration(hours: 8)),
          'state': workShiftStates.first,
        });
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
              '情報を入力し、「登録する」ボタンをクリックしてください。',
              style: kDialogTextStyle,
            ),
            SizedBox(height: 16.0),
            CustomDropdownButton(
              label: '対象スタッフ',
              isExpanded: true,
              value: workShift?.userId != '' ? workShift?.userId : null,
              onChanged: (value) {
                setState(() => workShift?.userId = value);
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
              label: '予定の種類',
              isExpanded: true,
              value: workShift?.state != '' ? workShift?.state : null,
              onChanged: (value) {
                setState(() => workShift?.state = value);
              },
              items: workShiftStates.map((e) {
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
              label: '開始日時',
              date: dateText('yyyy/MM/dd', workShift?.startedAt),
              dateOnPressed: () async {
                DateTime? _date = await customDatePicker(
                  context: context,
                  init: workShift?.startedAt ?? DateTime.now(),
                );
                if (_date == null) return;
                DateTime _dateTime = rebuildDate(_date, workShift?.startedAt);
                setState(() => workShift?.startedAt = _dateTime);
              },
              time: dateText('HH:mm', workShift?.startedAt),
              timeOnPressed: () async {
                String? _time = await customTimePicker(
                  context: context,
                  init: dateText('HH:mm', workShift?.startedAt),
                );
                if (_time == null) return;
                DateTime _dateTime = rebuildTime(
                  context,
                  workShift?.startedAt,
                  _time,
                );
                setState(() => workShift?.startedAt = _dateTime);
              },
            ),
            SizedBox(height: 8.0),
            DateTimeFormField(
              label: '終了日時',
              date: dateText('yyyy/MM/dd', workShift?.endedAt),
              dateOnPressed: () async {
                DateTime? _date = await customDatePicker(
                  context: context,
                  init: workShift?.endedAt ?? DateTime.now(),
                );
                if (_date == null) return;
                DateTime _dateTime = rebuildDate(_date, workShift?.endedAt);
                setState(() => workShift?.endedAt = _dateTime);
              },
              time: dateText('HH:mm', workShift?.endedAt),
              timeOnPressed: () async {
                String? _time = await customTimePicker(
                  context: context,
                  init: dateText('HH:mm', workShift?.endedAt),
                );
                if (_time == null) return;
                DateTime _dateTime =
                    rebuildTime(context, workShift?.endedAt, _time);
                setState(() => workShift?.endedAt = _dateTime);
              },
            ),
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
                    if (!await widget.workShiftProvider.create(
                      workShift: workShift,
                    )) {
                      return;
                    }
                    customSnackBar(context, '予定日時を登録しました');
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

class EditDialog extends StatefulWidget {
  final GroupProvider groupProvider;
  final WorkShiftProvider workShiftProvider;
  final String? userId;
  final Appointment? appointment;

  EditDialog({
    required this.groupProvider,
    required this.workShiftProvider,
    this.userId,
    this.appointment,
  });

  @override
  _EditDialogState createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  List<UserModel> users = [];
  WorkShiftModel? workShift;

  void _init() async {
    List<UserModel> _users = await widget.groupProvider.selectUsers();
    if (mounted) {
      setState(() {
        users = _users;
        workShift = WorkShiftModel.set({
          'id': '${widget.appointment?.id}',
          'groupId': widget.groupProvider.group?.id,
          'userId': widget.userId,
          'startedAt': widget.appointment?.startTime,
          'endedAt': widget.appointment?.endTime,
          'state': widget.appointment?.subject,
        });
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
              value: workShift?.userId != '' ? workShift?.userId : null,
              onChanged: (value) {
                setState(() => workShift?.userId = value);
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
              label: '予定の種類',
              isExpanded: true,
              value: workShift?.state != '' ? workShift?.state : null,
              onChanged: (value) {
                setState(() => workShift?.state = value);
              },
              items: workShiftStates.map((e) {
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
              label: '開始日時',
              date: dateText('yyyy/MM/dd', workShift?.startedAt),
              dateOnPressed: () async {
                DateTime? _date = await customDatePicker(
                  context: context,
                  init: workShift?.startedAt ?? DateTime.now(),
                );
                if (_date == null) return;
                DateTime _dateTime = rebuildDate(_date, workShift?.startedAt);
                setState(() => workShift?.startedAt = _dateTime);
              },
              time: dateText('HH:mm', workShift?.startedAt),
              timeOnPressed: () async {
                String? _time = await customTimePicker(
                  context: context,
                  init: dateText('HH:mm', workShift?.startedAt),
                );
                if (_time == null) return;
                DateTime _dateTime = rebuildTime(
                  context,
                  workShift?.startedAt,
                  _time,
                );
                setState(() => workShift?.startedAt = _dateTime);
              },
            ),
            SizedBox(height: 8.0),
            DateTimeFormField(
              label: '終了日時',
              date: dateText('yyyy/MM/dd', workShift?.endedAt),
              dateOnPressed: () async {
                DateTime? _date = await customDatePicker(
                  context: context,
                  init: workShift?.endedAt ?? DateTime.now(),
                );
                if (_date == null) return;
                DateTime _dateTime = rebuildDate(_date, workShift?.endedAt);
                setState(() => workShift?.endedAt = _dateTime);
              },
              time: dateText('HH:mm', workShift?.endedAt),
              timeOnPressed: () async {
                String? _time = await customTimePicker(
                  context: context,
                  init: dateText('HH:mm', workShift?.endedAt),
                );
                if (_time == null) return;
                DateTime _dateTime =
                    rebuildTime(context, workShift?.endedAt, _time);
                setState(() => workShift?.endedAt = _dateTime);
              },
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextButton(
                  label: 'キャンセル',
                  color: Colors.grey,
                  onPressed: () => Navigator.pop(context),
                ),
                Row(
                  children: [
                    CustomTextButton(
                      label: '削除する',
                      color: Colors.red,
                      onPressed: () async {
                        if (!await widget.workShiftProvider.delete(
                          id: workShift?.id,
                        )) {
                          return;
                        }
                        customSnackBar(context, '予定を削除しました');
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(width: 4.0),
                    CustomTextButton(
                      label: '保存する',
                      color: Colors.blue,
                      onPressed: () async {
                        if (!await widget.workShiftProvider.update(
                          workShift: workShift,
                        )) {
                          return;
                        }
                        customSnackBar(context, '予定日時を保存しました');
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
