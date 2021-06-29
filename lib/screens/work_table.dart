import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/csv_api.dart';
import 'package:hatarakujikan_web/helpers/date_machine_util.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/helpers/pdf_api.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/models/work.dart';
import 'package:hatarakujikan_web/models/work_state.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/providers/user.dart';
import 'package:hatarakujikan_web/providers/work.dart';
import 'package:hatarakujikan_web/providers/work_state.dart';
import 'package:hatarakujikan_web/widgets/custom_date_button.dart';
import 'package:hatarakujikan_web/widgets/custom_icon_label.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';
import 'package:hatarakujikan_web/widgets/custom_text_icon_button.dart';
import 'package:hatarakujikan_web/widgets/custom_time_button.dart';
import 'package:hatarakujikan_web/widgets/custom_work_footer_list_tile.dart';
import 'package:hatarakujikan_web/widgets/custom_work_header_list_tile.dart';
import 'package:hatarakujikan_web/widgets/custom_work_list_tile.dart';
import 'package:hatarakujikan_web/widgets/loading.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';

class WorkTable extends StatefulWidget {
  final GroupProvider groupProvider;
  final UserProvider userProvider;
  final WorkProvider workProvider;
  final WorkStateProvider workStateProvider;

  WorkTable({
    @required this.groupProvider,
    @required this.userProvider,
    @required this.workProvider,
    @required this.workStateProvider,
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
    Stream<QuerySnapshot> _streamWork = FirebaseFirestore.instance
        .collection('work')
        .where('groupId', isEqualTo: widget.groupProvider.group?.id)
        .where('userId', isEqualTo: selectUser?.id ?? 'error')
        .orderBy('startedAt', descending: false)
        .startAt([_startAt]).endAt([_endAt]).snapshots();
    List<WorkModel> works = [];
    Stream<QuerySnapshot> _streamWorkState = FirebaseFirestore.instance
        .collection('workState')
        .where('groupId', isEqualTo: widget.groupProvider.group?.id)
        .where('userId', isEqualTo: selectUser?.id ?? 'error')
        .orderBy('startedAt', descending: false)
        .startAt([_startAt]).endAt([_endAt]).snapshots();
    List<WorkStateModel> workStates = [];

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
                  label: selectUser?.name ?? '選択してください',
                ),
              ],
            ),
            Row(
              children: [
                CustomTextIconButton(
                  onPressed: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (_) => CsvDialog(
                        workProvider: widget.workProvider,
                        group: widget.groupProvider.group,
                        selectMonth: selectMonth,
                        users: users,
                      ),
                    );
                  },
                  color: Colors.green,
                  iconData: Icons.file_download,
                  label: 'CSV出力',
                ),
                SizedBox(width: 4.0),
                CustomTextIconButton(
                  onPressed: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (_) => PdfDialog(
                        workProvider: widget.workProvider,
                        workStateProvider: widget.workStateProvider,
                        group: widget.groupProvider.group,
                        selectMonth: selectMonth,
                        users: users,
                        selectUser: selectUser,
                      ),
                    );
                  },
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
                        workStateProvider: widget.workStateProvider,
                        groupId: widget.groupProvider.group?.id,
                        users: users,
                        selectUser: selectUser,
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
        CustomWorkHeaderListTile(),
        Expanded(
          child: StreamBuilder2<QuerySnapshot, QuerySnapshot>(
            streams: Tuple2(_streamWork, _streamWorkState),
            builder: (context, snapshot) {
              if (!snapshot.item1.hasData || !snapshot.item2.hasData) {
                return Loading(color: Colors.orange);
              }
              works.clear();
              for (DocumentSnapshot work in snapshot.item1.data.docs) {
                works.add(WorkModel.fromSnapshot(work));
              }
              workStates.clear();
              for (DocumentSnapshot workState in snapshot.item2.data.docs) {
                workStates.add(WorkStateModel.fromSnapshot(workState));
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
                  WorkStateModel _dayWorkState;
                  for (WorkStateModel _workState in workStates) {
                    String _startedAt =
                        '${DateFormat('yyyy-MM-dd').format(_workState.startedAt)}';
                    if (days[index] == DateTime.parse(_startedAt)) {
                      _dayWorkState = _workState;
                    }
                  }
                  return CustomWorkListTile(
                    workProvider: widget.workProvider,
                    day: days[index],
                    works: _dayWorks,
                    workState: _dayWorkState,
                    group: widget.groupProvider.group,
                  );
                },
              );
            },
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: _streamWork,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }
            Map _count = {};
            int _workCount = 0;
            String _workTime = '00:00';
            String _legalTime = '00:00';
            String _nonLegalTime = '00:00';
            String _nightTime = '00:00';
            List<WorkModel> _worksTmp = [];
            for (DocumentSnapshot _workTmp in snapshot.data.docs) {
              _worksTmp.add(WorkModel.fromSnapshot(_workTmp));
            }
            for (WorkModel _work in _worksTmp) {
              if (_work?.startedAt != _work?.endedAt) {
                // 勤務日数
                _count['${DateFormat('yyyy-MM-dd').format(_work?.startedAt)}'] =
                    '';
                // 勤務時間
                _workTime = addTime(
                    _workTime, _work?.workTime(widget.groupProvider.group));
                // 法定内時間/法定外時間
                List<String> _legalList = legalList(
                  workTime: _work?.workTime(widget.groupProvider.group),
                  legal: widget.groupProvider.group?.legal,
                );
                _legalTime = addTime(_legalTime, _legalList.first);
                _nonLegalTime = addTime(_nonLegalTime, _legalList.last);
                // 深夜時間
                List<String> _nightList = nightList(
                  startedAt: _work?.startedAt,
                  endedAt: _work?.endedAt,
                  nightStart: widget.groupProvider.group?.nightStart,
                  nightEnd: widget.groupProvider.group?.nightEnd,
                );
                _nightTime = addTime(_nightTime, _nightList.last);
              }
            }
            _workCount = _count.length;
            return CustomWorkFooterListTile(
              workCount: _workCount,
              workTime: _workTime,
              legalTime: _legalTime,
              nonLegalTime: _nonLegalTime,
              nightTime: _nightTime,
            );
          },
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

class CsvDialog extends StatefulWidget {
  final WorkProvider workProvider;
  final GroupModel group;
  final DateTime selectMonth;
  final List<UserModel> users;

  CsvDialog({
    @required this.workProvider,
    @required this.group,
    @required this.selectMonth,
    @required this.users,
  });

  @override
  _CsvDialogState createState() => _CsvDialogState();
}

class _CsvDialogState extends State<CsvDialog> {
  DateTime _firstDate = DateTime(DateTime.now().year - 1);
  DateTime _lastDate = DateTime(DateTime.now().year + 1);
  List<DateTime> days = [];
  DateTime selectMonth = DateTime.now();

  void _generateDays() async {
    days.clear();
    var _dateMap = DateMachineUtil.getMonthDate(selectMonth, 0);
    DateTime _startAt = DateTime.parse('${_dateMap['start']}');
    DateTime _endAt = DateTime.parse('${_dateMap['end']}');
    for (int i = 0; i <= _endAt.difference(_startAt).inDays; i++) {
      days.add(_startAt.add(Duration(days: i)));
    }
  }

  void _init() async {
    setState(() {
      selectMonth = widget.selectMonth;
    });
  }

  @override
  void initState() {
    super.initState();
    _init();
    _generateDays();
  }

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
              '以下の出力条件を選択し、最後に「出力する」ボタンを押してください。',
              style: TextStyle(color: Colors.black54, fontSize: 14.0),
            ),
            SizedBox(height: 16.0),
            CustomIconLabel(
              icon: Icon(Icons.today, color: Colors.black54),
              label: '年月',
            ),
            SizedBox(height: 4.0),
            CustomDateButton(
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
              label: '${DateFormat('yyyy年MM月').format(selectMonth)}',
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
                    await workCsv(
                      workProvider: widget.workProvider,
                      group: widget.group,
                      month: selectMonth,
                      users: widget.users,
                    );
                  },
                  color: Colors.green,
                  label: '出力する',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PdfDialog extends StatefulWidget {
  final WorkProvider workProvider;
  final WorkStateProvider workStateProvider;
  final GroupModel group;
  final DateTime selectMonth;
  final List<UserModel> users;
  final UserModel selectUser;

  PdfDialog({
    @required this.workProvider,
    @required this.workStateProvider,
    @required this.group,
    @required this.selectMonth,
    @required this.users,
    @required this.selectUser,
  });

  @override
  _PdfDialogState createState() => _PdfDialogState();
}

class _PdfDialogState extends State<PdfDialog> {
  DateTime _firstDate = DateTime(DateTime.now().year - 1);
  DateTime _lastDate = DateTime(DateTime.now().year + 1);
  List<DateTime> days = [];
  DateTime selectMonth = DateTime.now();
  List<UserModel> users = [];
  UserModel selectUser;

  void _generateDays() async {
    days.clear();
    var _dateMap = DateMachineUtil.getMonthDate(selectMonth, 0);
    DateTime _startAt = DateTime.parse('${_dateMap['start']}');
    DateTime _endAt = DateTime.parse('${_dateMap['end']}');
    for (int i = 0; i <= _endAt.difference(_startAt).inDays; i++) {
      days.add(_startAt.add(Duration(days: i)));
    }
  }

  void _init() async {
    setState(() {
      selectMonth = widget.selectMonth;
      users = widget.users;
      selectUser = widget.selectUser;
    });
  }

  @override
  void initState() {
    super.initState();
    _init();
    _generateDays();
  }

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
              '以下の出力条件を選択し、最後に「出力する」ボタンを押してください。',
              style: TextStyle(color: Colors.black54, fontSize: 14.0),
            ),
            SizedBox(height: 16.0),
            CustomIconLabel(
              icon: Icon(Icons.today, color: Colors.black54),
              label: '年月',
            ),
            SizedBox(height: 4.0),
            CustomDateButton(
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
              label: '${DateFormat('yyyy年MM月').format(selectMonth)}',
            ),
            SizedBox(height: 8.0),
            CustomIconLabel(
              icon: Icon(Icons.person, color: Colors.black54),
              label: 'スタッフ',
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black38),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<UserModel>(
                  hint: Text('選択してください'),
                  value: selectUser,
                  onChanged: (value) {
                    setState(() => selectUser = value);
                  },
                  items: users.map((value) {
                    return DropdownMenuItem<UserModel>(
                      value: value,
                      child: Text('${value.name}'),
                    );
                  }).toList(),
                ),
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
                    await workPdf(
                      workProvider: widget.workProvider,
                      workStateProvider: widget.workStateProvider,
                      group: widget.group,
                      month: selectMonth,
                      user: selectUser,
                    );
                  },
                  color: Colors.redAccent,
                  label: '出力する',
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
  final WorkStateProvider workStateProvider;
  final String groupId;
  final List<UserModel> users;
  final UserModel selectUser;

  AddWorkDialog({
    @required this.workProvider,
    @required this.workStateProvider,
    @required this.groupId,
    @required this.users,
    @required this.selectUser,
  });

  @override
  _AddWorkDialogState createState() => _AddWorkDialogState();
}

class _AddWorkDialogState extends State<AddWorkDialog> {
  DateTime _firstDate = DateTime.now().subtract(Duration(days: 365));
  DateTime _lastDate = DateTime.now().add(Duration(days: 365));
  List<UserModel> users = [];
  UserModel selectUser;
  List<String> states;
  String selectState;
  DateTime startedAt = DateTime.now();
  DateTime endedAt = DateTime.now();
  bool isBreaks = false;
  DateTime breakStartedAt = DateTime.now();
  DateTime breakEndedAt = DateTime.now();

  void _init() async {
    setState(() {
      users = widget.users;
      selectUser = widget.selectUser;
      states = widget.workStateProvider.states;
      selectState = widget.workStateProvider.states.first;
    });
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
            SizedBox(height: 16.0),
            Text(
              '勤務状況と記録したい日時を選択し、最後に「登録する」ボタンを押してください。',
              style: TextStyle(color: Colors.black54, fontSize: 14.0),
            ),
            SizedBox(height: 16.0),
            CustomIconLabel(
              icon: Icon(Icons.person, color: Colors.black54),
              label: 'スタッフ',
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black38),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<UserModel>(
                  hint: Text('選択してください'),
                  value: selectUser,
                  onChanged: (value) {
                    setState(() => selectUser = value);
                  },
                  items: users.map((value) {
                    return DropdownMenuItem<UserModel>(
                      value: value,
                      child: Text('${value.name}'),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 8.0),
            CustomIconLabel(
              icon: Icon(Icons.label, color: Colors.black54),
              label: '勤務状況',
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black38),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  hint: Text('選択してください'),
                  value: selectState,
                  onChanged: (value) {
                    setState(() => selectState = value);
                  },
                  items: states.map((value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text('$value'),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 8.0),
            selectState == '通常勤務'
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomIconLabel(
                        icon: Icon(Icons.run_circle, color: Colors.blue),
                        label: '出勤日時',
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
                                  initialDate: startedAt,
                                  firstDate: _firstDate,
                                  lastDate: _lastDate,
                                );
                                if (_selected != null) {
                                  String _date =
                                      '${DateFormat('yyyy-MM-dd').format(_selected)}';
                                  String _time =
                                      '${DateFormat('HH:mm').format(startedAt)}:00.000';
                                  DateTime _dateTime =
                                      DateTime.parse('$_date $_time');
                                  setState(() => startedAt = _dateTime);
                                }
                              },
                              label:
                                  '${DateFormat('yyyy/MM/dd').format(startedAt)}',
                            ),
                          ),
                          SizedBox(width: 4.0),
                          Expanded(
                            flex: 2,
                            child: CustomTimeButton(
                              onPressed: () async {
                                String _hour =
                                    '${DateFormat('H').format(startedAt)}';
                                String _minute =
                                    '${DateFormat('m').format(startedAt)}';
                                TimeOfDay _selected = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay(
                                    hour: int.parse(_hour),
                                    minute: int.parse(_minute),
                                  ),
                                );
                                if (_selected != null) {
                                  String _date =
                                      '${DateFormat('yyyy-MM-dd').format(startedAt)}';
                                  String _time =
                                      '${_selected.format(context)}:00.000';
                                  DateTime _dateTime =
                                      DateTime.parse('$_date $_time');
                                  setState(() => startedAt = _dateTime);
                                }
                              },
                              label: '${DateFormat('HH:mm').format(startedAt)}',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        children: [
                          Checkbox(
                            value: isBreaks,
                            onChanged: (value) {
                              setState(() => isBreaks = value);
                            },
                            activeColor: Colors.orange,
                          ),
                          Text(
                            '休憩日時も入力する',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      isBreaks
                          ? Column(
                              children: [
                                CustomIconLabel(
                                  icon: Icon(Icons.run_circle,
                                      color: Colors.orange),
                                  label: '休憩開始日時',
                                ),
                                SizedBox(height: 4.0),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: CustomDateButton(
                                        onPressed: () async {
                                          DateTime _selected =
                                              await showDatePicker(
                                            context: context,
                                            initialDate: breakStartedAt,
                                            firstDate: _firstDate,
                                            lastDate: _lastDate,
                                          );
                                          if (_selected != null) {
                                            String _date =
                                                '${DateFormat('yyyy-MM-dd').format(_selected)}';
                                            String _time =
                                                '${DateFormat('HH:mm').format(breakStartedAt)}';
                                            DateTime _datetime =
                                                DateTime.parse('$_date $_time');
                                            setState(() =>
                                                breakStartedAt = _datetime);
                                          }
                                        },
                                        label:
                                            '${DateFormat('yyyy/MM/dd').format(breakStartedAt)}',
                                      ),
                                    ),
                                    SizedBox(width: 4.0),
                                    Expanded(
                                      flex: 2,
                                      child: CustomTimeButton(
                                        onPressed: () async {
                                          String _hour =
                                              '${DateFormat('H').format(breakStartedAt)}';
                                          String _minute =
                                              '${DateFormat('m').format(breakStartedAt)}';
                                          TimeOfDay _selected =
                                              await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay(
                                              hour: int.parse(_hour),
                                              minute: int.parse(_minute),
                                            ),
                                          );
                                          if (_selected != null) {
                                            String _date =
                                                '${DateFormat('yyyy-MM-dd').format(breakStartedAt)}';
                                            String _time =
                                                '${_selected.format(context)}:00.000';
                                            DateTime _dateTime =
                                                DateTime.parse('$_date $_time');
                                            setState(() =>
                                                breakStartedAt = _dateTime);
                                          }
                                        },
                                        label:
                                            '${DateFormat('HH:mm').format(breakStartedAt)}',
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.0),
                                CustomIconLabel(
                                  icon: Icon(
                                    Icons.run_circle_outlined,
                                    color: Colors.orange,
                                  ),
                                  label: '休憩終了日時',
                                ),
                                SizedBox(height: 4.0),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: CustomDateButton(
                                        onPressed: () async {
                                          DateTime _selected =
                                              await showDatePicker(
                                            context: context,
                                            initialDate: breakEndedAt,
                                            firstDate: _firstDate,
                                            lastDate: _lastDate,
                                          );
                                          if (_selected != null) {
                                            String _date =
                                                '${DateFormat('yyyy-MM-dd').format(_selected)}';
                                            String _time =
                                                '${DateFormat('HH:mm').format(breakEndedAt)}:00.000';
                                            DateTime _dateTime =
                                                DateTime.parse('$_date $_time');
                                            setState(
                                                () => breakEndedAt = _dateTime);
                                          }
                                        },
                                        label:
                                            '${DateFormat('yyyy/MM/dd').format(breakEndedAt)}',
                                      ),
                                    ),
                                    SizedBox(width: 4.0),
                                    Expanded(
                                      flex: 2,
                                      child: CustomTimeButton(
                                        onPressed: () async {
                                          String _hour =
                                              '${DateFormat('H').format(breakEndedAt)}';
                                          String _minute =
                                              '${DateFormat('m').format(breakEndedAt)}';
                                          TimeOfDay _selected =
                                              await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay(
                                              hour: int.parse(_hour),
                                              minute: int.parse(_minute),
                                            ),
                                          );
                                          if (_selected != null) {
                                            String _date =
                                                '${DateFormat('yyyy-MM-dd').format(breakEndedAt)}';
                                            String _time =
                                                '${_selected.format(context)}:00.000';
                                            DateTime _dateTime =
                                                DateTime.parse('$_date $_time');
                                            setState(
                                                () => breakEndedAt = _dateTime);
                                          }
                                        },
                                        label:
                                            '${DateFormat('HH:mm').format(breakEndedAt)}',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Container(),
                      SizedBox(height: 8.0),
                      CustomIconLabel(
                        icon: Icon(Icons.run_circle, color: Colors.red),
                        label: '退勤日時',
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
                                  initialDate: endedAt,
                                  firstDate: _firstDate,
                                  lastDate: _lastDate,
                                );
                                if (_selected != null) {
                                  String _date =
                                      '${DateFormat('yyyy-MM-dd').format(_selected)}';
                                  String _time =
                                      '${DateFormat('HH:mm').format(endedAt)}:00.000';
                                  DateTime _dateTime =
                                      DateTime.parse('$_date $_time');
                                  setState(() => endedAt = _dateTime);
                                }
                              },
                              label:
                                  '${DateFormat('yyyy/MM/dd').format(endedAt)}',
                            ),
                          ),
                          SizedBox(width: 4.0),
                          Expanded(
                            flex: 2,
                            child: CustomTimeButton(
                              onPressed: () async {
                                String _hour =
                                    '${DateFormat('H').format(endedAt)}';
                                String _minute =
                                    '${DateFormat('m').format(endedAt)}';
                                TimeOfDay _selected = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay(
                                    hour: int.parse(_hour),
                                    minute: int.parse(_minute),
                                  ),
                                );
                                if (_selected != null) {
                                  String _date =
                                      '${DateFormat('yyyy-MM-dd').format(endedAt)}';
                                  String _time =
                                      '${_selected.format(context)}:00.000';
                                  DateTime _dateTime =
                                      DateTime.parse('$_date $_time');
                                  setState(() => endedAt = _dateTime);
                                }
                              },
                              label: '${DateFormat('HH:mm').format(endedAt)}',
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('登録日', style: TextStyle(color: Colors.black54)),
                      SizedBox(height: 4.0),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: CustomDateButton(
                              onPressed: () async {
                                DateTime _selected = await showDatePicker(
                                  context: context,
                                  initialDate: startedAt,
                                  firstDate: _firstDate,
                                  lastDate: _lastDate,
                                );
                                if (_selected != null) {
                                  String _date =
                                      '${DateFormat('yyyy-MM-dd').format(_selected)}';
                                  String _time =
                                      '${DateFormat('HH:mm').format(startedAt)}:00.000';
                                  DateTime _dateTime =
                                      DateTime.parse('$_date $_time');
                                  setState(() => startedAt = _dateTime);
                                }
                              },
                              label:
                                  '${DateFormat('yyyy/MM/dd').format(startedAt)}',
                            ),
                          ),
                          SizedBox(width: 4.0),
                          Expanded(
                            flex: 2,
                            child: Container(),
                          ),
                        ],
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
                  onPressed: () async {
                    if (selectState == '通常勤務') {
                      if (!await widget.workProvider.create(
                        groupId: widget.groupId,
                        userId: selectUser?.id,
                        startedAt: startedAt,
                        endedAt: endedAt,
                        isBreaks: isBreaks,
                        breakStartedAt: breakStartedAt,
                        breakEndedAt: breakEndedAt,
                      )) {
                        return;
                      }
                    } else {
                      if (!await widget.workStateProvider.create(
                        groupId: widget.groupId,
                        userId: selectUser?.id,
                        startedAt: startedAt,
                        state: selectState,
                      )) {
                        return;
                      }
                    }
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
