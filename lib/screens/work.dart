import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:hatarakujikan_web/providers/position.dart';
import 'package:hatarakujikan_web/providers/user.dart';
import 'package:hatarakujikan_web/providers/work.dart';
import 'package:hatarakujikan_web/providers/work_shift.dart';
import 'package:hatarakujikan_web/screens/work_download.dart';
import 'package:hatarakujikan_web/widgets/admin_header.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold.dart';
import 'package:hatarakujikan_web/widgets/custom_dropdown_button.dart';
import 'package:hatarakujikan_web/widgets/custom_radio.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button_mini.dart';
import 'package:hatarakujikan_web/widgets/datetime_form_field.dart';
import 'package:hatarakujikan_web/widgets/text_icon_button.dart';
import 'package:hatarakujikan_web/widgets/work_footer.dart';
import 'package:hatarakujikan_web/widgets/work_header.dart';
import 'package:hatarakujikan_web/widgets/work_list.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:provider/provider.dart';

class WorkScreen extends StatelessWidget {
  static const String id = 'work';

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final positionProvider = Provider.of<PositionProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final workProvider = Provider.of<WorkProvider>(context);
    final workShiftProvider = Provider.of<WorkShiftProvider>(context);
    GroupModel? group = groupProvider.group;
    List<WorkModel> works = [];
    List<WorkShiftModel> workShifts = [];

    return CustomAdminScaffold(
      groupProvider: groupProvider,
      selectedRoute: id,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminHeader(
            title: '勤怠の記録',
            message: 'スタッフが打刻した勤怠の履歴を年月毎に表示しています。',
          ),
          SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  TextIconButton(
                    iconData: Icons.today,
                    iconColor: Colors.white,
                    label: dateText('yyyy年MM月', workProvider.month),
                    labelColor: Colors.white,
                    backgroundColor: Colors.lightBlueAccent,
                    onPressed: () async {
                      DateTime? selected = await customMonthPicker(
                        context: context,
                        init: workProvider.month,
                      );
                      if (selected == null) return;
                      workProvider.changeMonth(selected);
                    },
                  ),
                  SizedBox(width: 4.0),
                  TextIconButton(
                    iconData: Icons.person,
                    iconColor: Colors.white,
                    label: workProvider.user == null
                        ? '未選択'
                        : workProvider.user?.name ?? '',
                    labelColor: Colors.white,
                    backgroundColor: Colors.lightBlueAccent,
                    onPressed: () {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (_) => SearchUserDialog(
                          groupProvider: groupProvider,
                          workProvider: workProvider,
                        ),
                      );
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  TextIconButton(
                    iconData: Icons.download,
                    iconColor: Colors.white,
                    label: 'CSV出力',
                    labelColor: Colors.white,
                    backgroundColor: Colors.green,
                    onPressed: () {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (_) => CSVDialog(
                          positionProvider: positionProvider,
                          userProvider: userProvider,
                          workProvider: workProvider,
                          workShiftProvider: workShiftProvider,
                          group: group,
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 4.0),
                  TextIconButton(
                    iconData: Icons.print,
                    iconColor: Colors.white,
                    label: 'PDF印刷',
                    labelColor: Colors.white,
                    backgroundColor: Colors.redAccent,
                    onPressed: () {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (_) => PDFDialog(
                          positionProvider: positionProvider,
                          groupProvider: groupProvider,
                          userProvider: userProvider,
                          workProvider: workProvider,
                          workShiftProvider: workShiftProvider,
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 4.0),
                  TextIconButton(
                    iconData: Icons.add,
                    iconColor: Colors.white,
                    label: '新規登録',
                    labelColor: Colors.white,
                    backgroundColor: Colors.blue,
                    onPressed: () {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (_) => AddDialog(
                          groupProvider: groupProvider,
                          workProvider: workProvider,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8.0),
          WorkHeader(),
          Expanded(
            child: StreamBuilder2<QuerySnapshot<Map<String, dynamic>>,
                QuerySnapshot<Map<String, dynamic>>>(
              streams: Tuple2(
                workProvider.streamList(groupId: group?.id),
                workProvider.streamListShift(groupId: group?.id),
              ),
              builder: (context, snapshot) {
                works.clear();
                workShifts.clear();
                if (snapshot.item1.hasData) {
                  for (DocumentSnapshot<Map<String, dynamic>> doc
                      in snapshot.item1.data!.docs) {
                    works.add(WorkModel.fromSnapshot(doc));
                  }
                }
                if (snapshot.item2.hasData) {
                  for (DocumentSnapshot<Map<String, dynamic>> doc
                      in snapshot.item2.data!.docs) {
                    workShifts.add(WorkShiftModel.fromSnapshot(doc));
                  }
                }
                return Scrollbar(
                  child: ListView.builder(
                    itemCount: workProvider.days.length,
                    itemBuilder: (_, index) {
                      List<WorkModel> _dayInWorks = [];
                      for (WorkModel _work in works) {
                        String _key = dateText('yyyy-MM-dd', _work.startedAt);
                        if (workProvider.days[index] == DateTime.parse(_key)) {
                          _dayInWorks.add(_work);
                        }
                      }
                      WorkShiftModel? _dayInWorkShift;
                      for (WorkShiftModel _workShift in workShifts) {
                        String _key =
                            dateText('yyyy-MM-dd', _workShift.startedAt);
                        if (workProvider.days[index] == DateTime.parse(_key)) {
                          _dayInWorkShift = _workShift;
                        }
                      }
                      return WorkList(
                        groupProvider: groupProvider,
                        workProvider: workProvider,
                        day: workProvider.days[index],
                        dayInWorks: _dayInWorks,
                        dayInWorkShift: _dayInWorkShift,
                        group: group,
                      );
                    },
                  ),
                );
              },
            ),
          ),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: workProvider.streamList(groupId: group?.id),
            builder: (context, snapshot) {
              List<WorkModel> _works = [];
              if (snapshot.hasData) {
                for (DocumentSnapshot<Map<String, dynamic>> _work
                    in snapshot.data!.docs) {
                  _works.add(WorkModel.fromSnapshot(_work));
                }
              }
              return WorkFooter(
                works: _works,
                group: group,
              );
            },
          ),
        ],
      ),
    );
  }
}

class SearchUserDialog extends StatefulWidget {
  final GroupProvider groupProvider;
  final WorkProvider workProvider;

  SearchUserDialog({
    required this.groupProvider,
    required this.workProvider,
  });

  @override
  State<SearchUserDialog> createState() => _SearchUserDialogState();
}

class _SearchUserDialogState extends State<SearchUserDialog> {
  ScrollController _controller = ScrollController();
  List<UserModel> users = [];

  void _init() async {
    List<UserModel> _users = await widget.groupProvider.selectUsers();
    if (mounted) {
      setState(() => users = _users);
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
            Container(
              height: 350.0,
              child: Scrollbar(
                isAlwaysShown: true,
                controller: _controller,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  controller: _controller,
                  itemCount: users.length,
                  itemBuilder: (_, index) {
                    UserModel _user = users[index];
                    return CustomRadio(
                      label: _user.name,
                      value: _user,
                      groupValue: widget.workProvider.user,
                      activeColor: Colors.lightBlueAccent,
                      onChanged: (value) {
                        widget.workProvider.changeUser(value);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
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
                Container(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddDialog extends StatefulWidget {
  final GroupProvider groupProvider;
  final WorkProvider workProvider;

  AddDialog({
    required this.groupProvider,
    required this.workProvider,
  });

  @override
  _AddDialogState createState() => _AddDialogState();
}

class _AddDialogState extends State<AddDialog> {
  List<UserModel> users = [];
  WorkModel? work;
  List<BreaksModel> breaks = [];

  void _addBreaks() {
    BreaksModel _breaks = BreaksModel.set({
      'startedAt': DateTime.now(),
      'endedAt': DateTime.now().add(Duration(hours: 1)),
    });
    setState(() => breaks.add(_breaks));
  }

  void _removeBreaks() {
    setState(() => breaks.removeLast());
  }

  void _init() async {
    List<UserModel> _users = await widget.groupProvider.selectUsers();
    if (mounted) {
      setState(() {
        users = _users;
        work = WorkModel.set({
          'groupId': widget.groupProvider.group?.id,
          'userId': widget.workProvider.user?.id,
          'startedAt': DateTime.now(),
          'endedAt': DateTime.now().add(Duration(hours: 8)),
          'state': workStates.first,
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
    _addBreaks();
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
              value: work?.userId != '' ? work?.userId : null,
              onChanged: (value) {
                setState(() => work?.userId = value);
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
              value: work?.state != '' ? work?.state : null,
              onChanged: (value) {
                setState(() => work?.state = value);
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
              date: dateText('yyyy/MM/dd', work?.startedAt),
              dateOnPressed: () async {
                DateTime? _date = await customDatePicker(
                  context: context,
                  init: work?.startedAt ?? DateTime.now(),
                );
                if (_date == null) return;
                DateTime _dateTime = rebuildDate(_date, work?.startedAt);
                setState(() => work?.startedAt = _dateTime);
              },
              time: dateText('HH:mm', work?.startedAt),
              timeOnPressed: () async {
                String? _time = await customTimePicker(
                  context: context,
                  init: dateText('HH:mm', work?.startedAt),
                );
                if (_time == null) return;
                DateTime _dateTime = rebuildTime(
                  context,
                  work?.startedAt,
                  _time,
                );
                setState(() => work?.startedAt = _dateTime);
              },
            ),
            SizedBox(height: 8.0),
            DateTimeFormField(
              label: '退勤日時',
              date: dateText('yyyy/MM/dd', work?.endedAt),
              dateOnPressed: () async {
                DateTime? _date = await customDatePicker(
                  context: context,
                  init: work?.endedAt ?? DateTime.now(),
                );
                if (_date == null) return;
                DateTime _dateTime = rebuildDate(_date, work?.endedAt);
                setState(() => work?.endedAt = _dateTime);
              },
              time: dateText('HH:mm', work?.endedAt),
              timeOnPressed: () async {
                String? _time = await customTimePicker(
                  context: context,
                  init: dateText('HH:mm', work?.endedAt),
                );
                if (_time == null) return;
                DateTime _dateTime = rebuildTime(context, work?.endedAt, _time);
                setState(() => work?.endedAt = _dateTime);
              },
            ),
            SizedBox(height: 8.0),
            breaks.length > 0
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    itemCount: breaks.length,
                    itemBuilder: (_, index) {
                      BreaksModel _breaks = breaks[index];
                      return Column(
                        children: [
                          DateTimeFormField(
                            label: '休憩開始日時',
                            date: dateText('yyyy/MM/dd', _breaks.startedAt),
                            dateOnPressed: () async {
                              DateTime? _date = await customDatePicker(
                                context: context,
                                init: _breaks.startedAt,
                              );
                              if (_date == null) return;
                              DateTime _dateTime =
                                  rebuildDate(_date, _breaks.startedAt);
                              setState(() => _breaks.startedAt = _dateTime);
                            },
                            time: dateText('HH:mm', _breaks.startedAt),
                            timeOnPressed: () async {
                              String? _time = await customTimePicker(
                                context: context,
                                init: dateText('HH:mm', _breaks.startedAt),
                              );
                              if (_time == null) return;
                              DateTime _dateTime = rebuildTime(
                                context,
                                _breaks.startedAt,
                                _time,
                              );
                              setState(() => _breaks.startedAt = _dateTime);
                            },
                          ),
                          SizedBox(height: 8.0),
                          DateTimeFormField(
                            label: '休憩終了日時',
                            date: dateText('yyyy/MM/dd', _breaks.endedAt),
                            dateOnPressed: () async {
                              DateTime? _date = await customDatePicker(
                                context: context,
                                init: _breaks.endedAt,
                              );
                              if (_date == null) return;
                              DateTime _dateTime =
                                  rebuildDate(_date, _breaks.endedAt);
                              setState(() => _breaks.endedAt = _dateTime);
                            },
                            time: dateText('HH:mm', _breaks.endedAt),
                            timeOnPressed: () async {
                              String? _time = await customTimePicker(
                                context: context,
                                init: dateText('HH:mm', _breaks.endedAt),
                              );
                              if (_time == null) return;
                              DateTime _dateTime = rebuildTime(
                                context,
                                _breaks.endedAt,
                                _time,
                              );
                              setState(() => _breaks.endedAt = _dateTime);
                            },
                          ),
                          SizedBox(height: 8.0),
                        ],
                      );
                    },
                  )
                : Container(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomTextButtonMini(
                  label: '休憩削除',
                  color: Colors.deepOrange,
                  onPressed: () => _removeBreaks(),
                ),
                SizedBox(width: 4.0),
                CustomTextButtonMini(
                  label: '休憩追加',
                  color: Colors.cyan,
                  onPressed: () => _addBreaks(),
                ),
              ],
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
                    if (!await widget.workProvider.create(
                      work: work,
                      breaks: breaks,
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
