import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/date_machine_util.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/models/work.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/providers/user.dart';
import 'package:hatarakujikan_web/providers/work.dart';
import 'package:hatarakujikan_web/widgets/custom_date_button.dart';
import 'package:hatarakujikan_web/widgets/custom_icon_label.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';
import 'package:hatarakujikan_web/widgets/custom_text_icon_button.dart';
import 'package:hatarakujikan_web/widgets/custom_time_button.dart';
import 'package:hatarakujikan_web/widgets/custom_work_head_list_tile.dart';
import 'package:hatarakujikan_web/widgets/custom_work_list_tile.dart';
import 'package:hatarakujikan_web/widgets/loading.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class WorkTable extends StatefulWidget {
  final GroupProvider groupProvider;
  final UserProvider userProvider;
  final WorkProvider workProvider;

  WorkTable({
    @required this.groupProvider,
    @required this.userProvider,
    @required this.workProvider,
  });

  @override
  _WorkTableState createState() => _WorkTableState();
}

class _WorkTableState extends State<WorkTable> {
  DateTime _firstDate = DateTime(DateTime.now().year - 1);
  DateTime _lastDate = DateTime(DateTime.now().year + 1);
  DateTime selectMonth = DateTime.now();
  UserModel selectUser;
  List<UserModel> users = [];
  List<DateTime> days = [];

  void _init() async {
    await widget.userProvider
        .selectList(groupId: widget.groupProvider.group?.id)
        .then((value) {
      setState(() => users = value);
    });
  }

  void _generateDays() async {
    days.clear();
    var _dateMap = DateMachineUtil.getMonthDate(selectMonth, 0);
    DateTime _startAt = DateTime.parse('${_dateMap['start']}');
    DateTime _endAt = DateTime.parse('${_dateMap['end']}');
    for (int i = 0; i <= _endAt.difference(_startAt).inDays; i++) {
      days.add(_startAt.add(Duration(days: i)));
    }
  }

  void _changeUser(UserModel user) {
    setState(() => selectUser = user);
  }

  @override
  void initState() {
    super.initState();
    _generateDays();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    Timestamp _startAt = Timestamp.fromMillisecondsSinceEpoch(DateTime.parse(
            '${DateFormat('yyyy-MM-dd').format(days.first)} 00:00:00.000')
        .millisecondsSinceEpoch);
    Timestamp _endAt = Timestamp.fromMillisecondsSinceEpoch(DateTime.parse(
            '${DateFormat('yyyy-MM-dd').format(days.last)} 23:59:59.999')
        .millisecondsSinceEpoch);
    Stream<QuerySnapshot> _stream = FirebaseFirestore.instance
        .collection('work')
        .where('groupId', isEqualTo: widget.groupProvider.group?.id)
        .where('userId', isEqualTo: selectUser?.id ?? 'error')
        .orderBy('startedAt', descending: false)
        .startAt([_startAt]).endAt([_endAt]).snapshots();
    List<WorkModel> works = [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '勤務の管理',
          style: kAdminTitleTextStyle,
        ),
        Text(
          'スタッフがスマートフォンやタブレット端末で記録した勤務時間を年月形式で一覧表示します。',
          style: kAdminSubTitleTextStyle,
        ),
        SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CustomTextIconButton(
                  onPressed: () async {
                    var selected = await showMonthPicker(
                      context: context,
                      initialDate: selectMonth,
                      firstDate: _firstDate,
                      lastDate: _lastDate,
                    );
                    if (selected == null) return;
                    setState(() {
                      selectMonth = selected;
                      _generateDays();
                    });
                  },
                  color: Colors.lightBlueAccent,
                  iconData: Icons.today,
                  label: '${DateFormat('yyyy年MM月').format(selectMonth)}',
                ),
                SizedBox(width: 4.0),
                CustomTextIconButton(
                  onPressed: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (_) => SelectUserDialog(
                        users: users,
                        selectUser: selectUser,
                        changeUser: _changeUser,
                      ),
                    );
                  },
                  color: Colors.lightBlueAccent,
                  iconData: Icons.person,
                  label: selectUser?.name ?? '指定なし',
                ),
              ],
            ),
            Row(
              children: [
                CustomTextIconButton(
                  onPressed: () {},
                  color: Colors.green,
                  iconData: Icons.file_download,
                  label: 'CSV出力',
                ),
                SizedBox(width: 4.0),
                CustomTextIconButton(
                  onPressed: () {},
                  color: Colors.redAccent,
                  iconData: Icons.file_download,
                  label: 'PDF出力',
                ),
                SizedBox(width: 4.0),
                CustomTextIconButton(
                  onPressed: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (_) => AddWorkDialog(
                        workProvider: widget.workProvider,
                      ),
                    );
                  },
                  color: Colors.blue,
                  iconData: Icons.post_add,
                  label: '新規登録',
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 8.0),
        CustomWorkHeadListTile(),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Loading(color: Colors.orange);
              }
              works.clear();
              for (DocumentSnapshot work in snapshot.data.docs) {
                works.add(WorkModel.fromSnapshot(work));
              }
              return ListView.builder(
                itemCount: days.length,
                itemBuilder: (_, index) {
                  List<WorkModel> _dayWorks = [];
                  for (WorkModel _work in works) {
                    String _startedAt =
                        '${DateFormat('yyyy-MM-dd').format(_work.startedAt)}';
                    if (days[index] == DateTime.parse(_startedAt)) {
                      _dayWorks.add(_work);
                    }
                  }
                  return CustomWorkListTile(
                    workProvider: widget.workProvider,
                    day: days[index],
                    works: _dayWorks,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class SelectUserDialog extends StatelessWidget {
  final List<UserModel> users;
  final UserModel selectUser;
  final Function changeUser;

  SelectUserDialog({
    @required this.users,
    @required this.selectUser,
    @required this.changeUser,
  });

  @override
  Widget build(BuildContext context) {
    final ScrollController _scrollController = ScrollController();

    return AlertDialog(
      content: Container(
        width: 450.0,
        child: ListView(
          shrinkWrap: true,
          children: [
            SizedBox(height: 16.0),
            Divider(height: 0.0),
            Container(
              height: 350.0,
              child: Scrollbar(
                isAlwaysShown: true,
                controller: _scrollController,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  controller: _scrollController,
                  itemCount: users.length,
                  itemBuilder: (_, index) {
                    UserModel _user = users[index];
                    return Container(
                      decoration: kBottomBorderDecoration,
                      child: RadioListTile(
                        title: Text('${_user.name}'),
                        value: _user,
                        groupValue: selectUser,
                        activeColor: Colors.blue,
                        onChanged: (value) {
                          changeUser(value);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            Divider(height: 0.0),
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
                  label: 'OK',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddWorkDialog extends StatefulWidget {
  final WorkProvider workProvider;

  AddWorkDialog({@required this.workProvider});

  @override
  _AddWorkDialogState createState() => _AddWorkDialogState();
}

class _AddWorkDialogState extends State<AddWorkDialog> {
  DateTime _firstDate = DateTime.now().subtract(Duration(days: 365));
  DateTime _lastDate = DateTime.now().add(Duration(days: 365));
  DateTime _startedAt = DateTime.now();
  DateTime _endedAt = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        width: 450.0,
        child: ListView(
          shrinkWrap: true,
          children: [
            SizedBox(height: 16.0),
            Text(
              '記録したい日時を入力し、最後に「登録する」ボタンを押してください。',
              style: TextStyle(color: Colors.black54, fontSize: 14.0),
            ),
            SizedBox(height: 16.0),
            CustomIconLabel(
              icon: Icon(Icons.person, color: Colors.black54),
              label: 'スタッフ',
            ),
            SizedBox(height: 8.0),
            CustomIconLabel(
              icon: Icon(Icons.run_circle, color: Colors.blue),
              label: '出勤時間',
            ),
            SizedBox(height: 4.0),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: CustomDateButton(
                    onPressed: () async {
                      DateTime _selected = await showDatePicker(
                        context: context,
                        initialDate: _startedAt,
                        firstDate: _firstDate,
                        lastDate: _lastDate,
                      );
                      if (_selected != null) {
                        String _date =
                            '${DateFormat('yyyy-MM-dd').format(_selected)}';
                        String _time =
                            '${DateFormat('HH:mm').format(_startedAt)}:00.000';
                        DateTime _dateTime = DateTime.parse('$_date $_time');
                        setState(() => _startedAt = _dateTime);
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
                      String _hour = '${DateFormat('H').format(_startedAt)}';
                      String _minute = '${DateFormat('m').format(_startedAt)}';
                      TimeOfDay _selected = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                          hour: int.parse(_hour),
                          minute: int.parse(_minute),
                        ),
                      );
                      if (_selected != null) {
                        String _date =
                            '${DateFormat('yyyy-MM-dd').format(_startedAt)}';
                        String _time = '${_selected.format(context)}:00.000';
                        DateTime _dateTime = DateTime.parse('$_date $_time');
                        setState(() => _startedAt = _dateTime);
                      }
                    },
                    label: '${DateFormat('HH:mm').format(_startedAt)}',
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            CustomIconLabel(
              icon: Icon(Icons.run_circle, color: Colors.red),
              label: '退勤時間',
            ),
            SizedBox(height: 4.0),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: CustomDateButton(
                    onPressed: () async {
                      DateTime _selected = await showDatePicker(
                        context: context,
                        initialDate: _endedAt,
                        firstDate: _firstDate,
                        lastDate: _lastDate,
                      );
                      if (_selected != null) {
                        String _date =
                            '${DateFormat('yyyy-MM-dd').format(_selected)}';
                        String _time =
                            '${DateFormat('HH:mm').format(_endedAt)}:00.000';
                        DateTime _dateTime = DateTime.parse('$_date $_time');
                        setState(() => _endedAt = _dateTime);
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
                      String _hour = '${DateFormat('H').format(_endedAt)}';
                      String _minute = '${DateFormat('m').format(_endedAt)}';
                      TimeOfDay _selected = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                          hour: int.parse(_hour),
                          minute: int.parse(_minute),
                        ),
                      );
                      if (_selected != null) {
                        String _date =
                            '${DateFormat('yyyy-MM-dd').format(_endedAt)}';
                        String _time = '${_selected.format(context)}:00.000';
                        DateTime _dateTime = DateTime.parse('$_date $_time');
                        setState(() => _endedAt = _dateTime);
                      }
                    },
                    label: '${DateFormat('HH:mm').format(_endedAt)}',
                  ),
                ),
              ],
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
                  onPressed: () => Navigator.pop(context),
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
