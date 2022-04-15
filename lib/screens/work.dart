import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/csv_api.dart';
import 'package:hatarakujikan_web/helpers/define.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/helpers/pdf_api.dart';
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
import 'package:hatarakujikan_web/screens/work_list.dart';
import 'package:hatarakujikan_web/widgets/admin_header.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold.dart';
import 'package:hatarakujikan_web/widgets/custom_checkbox_list_tile.dart';
import 'package:hatarakujikan_web/widgets/custom_date_button.dart';
import 'package:hatarakujikan_web/widgets/custom_dropdown_button.dart';
import 'package:hatarakujikan_web/widgets/custom_label_column.dart';
import 'package:hatarakujikan_web/widgets/custom_radio.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';
import 'package:hatarakujikan_web/widgets/custom_text_icon_button.dart';
import 'package:hatarakujikan_web/widgets/custom_work_footer_list_tile.dart';
import 'package:hatarakujikan_web/widgets/custom_work_list_tile.dart';
import 'package:hatarakujikan_web/widgets/datetime_form_field.dart';
import 'package:hatarakujikan_web/widgets/loading.dart';
import 'package:hatarakujikan_web/widgets/text_icon_button.dart';
import 'package:hatarakujikan_web/widgets/work_footer.dart';
import 'package:hatarakujikan_web/widgets/work_header.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
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
                      group: group,
                    ),
                  );
                },
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
            stream: workProvider.streamList(),
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
  final GroupModel? group;

  AddDialog({
    required this.groupProvider,
    required this.workProvider,
    this.group,
  });

  @override
  _AddDialogState createState() => _AddDialogState();
}

class _AddDialogState extends State<AddDialog> {
  List<UserModel> users = [];
  WorkModel? work;
  BreaksModel? breaks;

  void _init() async {
    List<UserModel> _users = await widget.groupProvider.selectUsers();
    if (mounted) {
      setState(() {
        users = _users;
        work = WorkModel.fromMap({
          'id': '',
          'groupId': widget.group?.id,
          'userId': widget.workProvider.user?.id,
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
        breaks = BreaksModel.fromMap({
          'id': '',
          'startedAt': DateTime.now(),
          'startedLat': 0,
          'startedLon': 0,
          'endedAt': DateTime.now().add(Duration(hours: 1)),
          'endedLat': 0,
          'endedLon': 0,
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
              value: work?.userId,
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
              value: work?.state,
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
            Column(
              children: [
                DateTimeFormField(
                  label: '休憩開始日時',
                  date: dateText('yyyy/MM/dd', breaks?.startedAt),
                  dateOnPressed: () async {
                    DateTime? _date = await customDatePicker(
                      context: context,
                      init: breaks?.startedAt ?? DateTime.now(),
                    );
                    if (_date == null) return;
                    DateTime _dateTime = rebuildDate(_date, breaks?.startedAt);
                    setState(() => breaks?.startedAt = _dateTime);
                  },
                  time: dateText('HH:mm', breaks?.startedAt),
                  timeOnPressed: () async {
                    String? _time = await customTimePicker(
                      context: context,
                      init: dateText('HH:mm', breaks?.startedAt),
                    );
                    if (_time == null) return;
                    DateTime _dateTime = rebuildTime(
                      context,
                      breaks?.startedAt,
                      _time,
                    );
                    setState(() => breaks?.startedAt = _dateTime);
                  },
                ),
                SizedBox(height: 8.0),
                DateTimeFormField(
                  label: '休憩終了日時',
                  date: dateText('yyyy/MM/dd', breaks?.endedAt),
                  dateOnPressed: () async {
                    DateTime? _date = await customDatePicker(
                      context: context,
                      init: breaks?.endedAt ?? DateTime.now(),
                    );
                    if (_date == null) return;
                    DateTime _dateTime = rebuildDate(_date, breaks?.endedAt);
                    setState(() => breaks?.endedAt = _dateTime);
                  },
                  time: dateText('HH:mm', breaks?.endedAt),
                  timeOnPressed: () async {
                    String? _time = await customTimePicker(
                      context: context,
                      init: dateText('HH:mm', breaks?.endedAt),
                    );
                    if (_time == null) return;
                    DateTime _dateTime = rebuildTime(
                      context,
                      breaks?.endedAt,
                      _time,
                    );
                    setState(() => breaks?.endedAt = _dateTime);
                  },
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

class WorkTable extends StatefulWidget {
  final GroupProvider groupProvider;
  final PositionProvider positionProvider;
  final UserProvider userProvider;
  final WorkProvider workProvider;
  final WorkShiftProvider workShiftProvider;

  WorkTable({
    required this.groupProvider,
    required this.positionProvider,
    required this.userProvider,
    required this.workProvider,
    required this.workShiftProvider,
  });

  @override
  _WorkTableState createState() => _WorkTableState();
}

class _WorkTableState extends State<WorkTable> {
  DateTime _month = DateTime.now();
  UserModel? _user;
  List<DateTime> _days = [];

  void _init() async {
    setState(() => _days = generateDays(_month));
  }

  void userChange(UserModel userModel) {
    setState(() => _user = userModel);
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    GroupModel? _group = widget.groupProvider.group;
    Timestamp _startAt = convertTimestamp(_days.first, false);
    Timestamp _endAt = convertTimestamp(_days.last, true);
    Stream<QuerySnapshot<Map<String, dynamic>>> _streamWork = FirebaseFirestore
        .instance
        .collection('work')
        .where('groupId', isEqualTo: _group?.id ?? 'error')
        .where('userId', isEqualTo: _user?.id ?? 'error')
        .orderBy('startedAt', descending: false)
        .startAt([_startAt]).endAt([_endAt]).snapshots();
    Stream<QuerySnapshot<Map<String, dynamic>>> _streamWorkShift =
        FirebaseFirestore.instance
            .collection('workShift')
            .where('groupId', isEqualTo: _group?.id ?? 'error')
            .where('userId', isEqualTo: _user?.id ?? 'error')
            .orderBy('startedAt', descending: false)
            .startAt([_startAt]).endAt([_endAt]).snapshots();
    List<WorkModel> _works = [];
    List<WorkShiftModel> _workShifts = [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminHeader(
          title: '勤怠の記録',
          message: 'スタッフが記録した勤務日時を年月形式で一覧表示します。勤務日時は追加/修正/削除できます。',
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
                      initialDate: _month,
                      firstDate: kMonthFirstDate,
                      lastDate: kMonthLastDate,
                    );
                    if (selected == null) return;
                    setState(() {
                      _month = selected;
                      _days = generateDays(_month);
                    });
                  },
                  color: Colors.lightBlueAccent,
                  iconData: Icons.today,
                  label: dateText('yyyy年MM月', _month),
                ),
                SizedBox(width: 4.0),
                CustomTextIconButton(
                  onPressed: () {},
                  color: Colors.lightBlueAccent,
                  iconData: Icons.person,
                  label: _user?.name ?? '選択してください',
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
                        positionProvider: widget.positionProvider,
                        userProvider: widget.userProvider,
                        workProvider: widget.workProvider,
                        workShiftProvider: widget.workShiftProvider,
                        group: widget.groupProvider.group!,
                        month: _month,
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
                        positionProvider: widget.positionProvider,
                        workProvider: widget.workProvider,
                        workShiftProvider: widget.workShiftProvider,
                        group: widget.groupProvider.group!,
                        month: _month,
                        users: widget.groupProvider.users,
                        user: _user!,
                      ),
                    );
                  },
                  color: Colors.redAccent,
                  iconData: Icons.file_download,
                  label: 'PDF出力',
                ),
                SizedBox(width: 4.0),
                CustomTextIconButton(
                  onPressed: () {},
                  color: Colors.blue,
                  iconData: Icons.add,
                  label: '新規登録',
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
            streams: Tuple2(_streamWork, _streamWorkShift),
            builder: (context, snapshot) {
              _works.clear();
              if (snapshot.item1.hasData) {
                for (DocumentSnapshot<Map<String, dynamic>> doc
                    in snapshot.item1.data!.docs) {
                  _works.add(WorkModel.fromSnapshot(doc));
                }
              }
              _workShifts.clear();
              if (snapshot.item2.hasData) {
                for (DocumentSnapshot<Map<String, dynamic>> doc
                    in snapshot.item2.data!.docs) {
                  _workShifts.add(WorkShiftModel.fromSnapshot(doc));
                }
              }
              return Scrollbar(
                child: ListView.builder(
                  itemCount: _days.length,
                  itemBuilder: (_, index) {
                    DateFormat _format = DateFormat('yyyy-MM-dd');
                    List<WorkModel> _dayWorks = [];
                    for (WorkModel _work in _works) {
                      String _start = '${_format.format(_work.startedAt)}';
                      if (_days[index] == DateTime.parse(_start)) {
                        _dayWorks.add(_work);
                      }
                    }
                    WorkShiftModel? _dayWorkShift;
                    for (WorkShiftModel _workShift in _workShifts) {
                      String _start = '${_format.format(_workShift.startedAt)}';
                      if (_days[index] == DateTime.parse(_start)) {
                        _dayWorkShift = _workShift;
                      }
                    }
                    return CustomWorkListTile(
                      workProvider: widget.workProvider,
                      day: _days[index],
                      dayWorks: _dayWorks,
                      dayWorkShift: _dayWorkShift,
                      group: widget.groupProvider.group,
                    );
                  },
                ),
              );
            },
          ),
        ),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _streamWork,
          builder: (context, snapshot) {
            Map _count = {};
            int _workCount = 0;
            String _workTime = '00:00';
            String _legalTime = '00:00';
            String _nonLegalTime = '00:00';
            String _nightTime = '00:00';
            List<WorkModel> _worksTmp = [];
            if (snapshot.hasData) {
              for (DocumentSnapshot<Map<String, dynamic>> _workTmp
                  in snapshot.data!.docs) {
                _worksTmp.add(WorkModel.fromSnapshot(_workTmp));
              }
            }
            DateFormat _format = DateFormat('yyyy-MM-dd');
            for (WorkModel _work in _worksTmp) {
              if (_work.startedAt != _work.endedAt) {
                String _key = '${_format.format(_work.startedAt)}';
                _count[_key] = '';
                _workTime = addTime(
                  _workTime,
                  _work.workTime(widget.groupProvider.group),
                );
                List<String> _legalTimes = _work.legalTimes(
                  widget.groupProvider.group,
                );
                _legalTime = addTime(_legalTime, _legalTimes.first);
                _nonLegalTime = addTime(_nonLegalTime, _legalTimes.last);
                List<String> _nightTimes = _work.nightTimes(
                  widget.groupProvider.group,
                );
                _nightTime = addTime(_nightTime, _nightTimes.last);
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

class CsvDialog extends StatefulWidget {
  final PositionProvider positionProvider;
  final UserProvider userProvider;
  final WorkProvider workProvider;
  final WorkShiftProvider workShiftProvider;
  final GroupModel group;
  final DateTime month;

  CsvDialog({
    required this.positionProvider,
    required this.userProvider,
    required this.workProvider,
    required this.workShiftProvider,
    required this.group,
    required this.month,
  });

  @override
  _CsvDialogState createState() => _CsvDialogState();
}

class _CsvDialogState extends State<CsvDialog> {
  DateTime _month = DateTime.now();
  bool _isLoading = false;
  String _template = '';

  void _init() async {
    CsvApi.groupCheck(group: widget.group);
    _month = widget.month;
    _template = csvTemplates.first;
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
        child: _isLoading
            ? ListView(
                shrinkWrap: true,
                children: [
                  SizedBox(height: 16.0),
                  Loading(color: Colors.orange),
                  SizedBox(height: 16.0),
                ],
              )
            : ListView(
                shrinkWrap: true,
                children: [
                  SizedBox(height: 16.0),
                  Text(
                    '以下の出力条件を選択し、最後に「出力する」ボタンを押してください。',
                    style: kDefaultTextStyle,
                  ),
                  SizedBox(height: 16.0),
                  CustomLabelColumn(
                    label: 'テンプレート',
                    child: CustomDropdownButton(
                      isExpanded: true,
                      value: _template,
                      onChanged: (value) {
                        setState(() => _template = value);
                      },
                      items: csvTemplates.map((value) {
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
                    label: '年月',
                    child: CustomDateButton(
                      onPressed: () async {
                        var selected = await showMonthPicker(
                          context: context,
                          initialDate: _month,
                          firstDate: kMonthFirstDate,
                          lastDate: kMonthLastDate,
                        );
                        if (selected == null) return;
                        setState(() => _month = selected);
                      },
                      label: dateText('yyyy年MM月', _month),
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
                          setState(() => _isLoading = true);
                          await CsvApi.download(
                            positionProvider: widget.positionProvider,
                            userProvider: widget.userProvider,
                            workProvider: widget.workProvider,
                            workShiftProvider: widget.workShiftProvider,
                            group: widget.group,
                            template: _template,
                            month: _month,
                          );
                          setState(() => _isLoading = false);
                          Navigator.pop(context);
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
  final PositionProvider positionProvider;
  final WorkProvider workProvider;
  final WorkShiftProvider workShiftProvider;
  final GroupModel group;
  final DateTime month;
  final List<UserModel> users;
  final UserModel user;

  PdfDialog({
    required this.positionProvider,
    required this.workProvider,
    required this.workShiftProvider,
    required this.group,
    required this.month,
    required this.users,
    required this.user,
  });

  @override
  _PdfDialogState createState() => _PdfDialogState();
}

class _PdfDialogState extends State<PdfDialog> {
  DateTime _month = DateTime.now();
  UserModel? _user;
  bool _isAll = false;
  bool _isLoading = false;
  String _template = '';

  void _init() async {
    PdfApi.groupCheck(group: widget.group);
    _month = widget.month;
    _user = widget.user;
    _template = pdfTemplates.first;
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
        child: _isLoading
            ? ListView(
                shrinkWrap: true,
                children: [
                  SizedBox(height: 16.0),
                  Loading(color: Colors.orange),
                  SizedBox(height: 16.0),
                ],
              )
            : ListView(
                shrinkWrap: true,
                children: [
                  SizedBox(height: 16.0),
                  Text(
                    '以下の出力条件を選択し、最後に「出力する」ボタンを押してください。',
                    style: kDefaultTextStyle,
                  ),
                  SizedBox(height: 16.0),
                  CustomLabelColumn(
                    label: 'テンプレート',
                    child: CustomDropdownButton(
                      isExpanded: true,
                      value: _template,
                      onChanged: (value) {
                        setState(() => _template = value);
                      },
                      items: pdfTemplates.map((value) {
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
                    label: '年月',
                    child: CustomDateButton(
                      onPressed: () async {
                        var selected = await showMonthPicker(
                          context: context,
                          initialDate: _month,
                          firstDate: kMonthFirstDate,
                          lastDate: kMonthLastDate,
                        );
                        if (selected == null) return;
                        setState(() => _month = selected);
                      },
                      label: dateText('yyyy年MM月', _month),
                    ),
                  ),
                  SizedBox(height: 8.0),
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
                  CustomCheckboxListTile(
                    onChanged: (value) {
                      setState(() => _isAll = value ?? false);
                    },
                    label: '全スタッフ一括出力',
                    value: _isAll,
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
                          setState(() => _isLoading = true);
                          await PdfApi.download(
                            positionProvider: widget.positionProvider,
                            workProvider: widget.workProvider,
                            workShiftProvider: widget.workShiftProvider,
                            group: widget.group,
                            month: _month,
                            user: _user!,
                            isAll: _isAll,
                            users: widget.users,
                            template: _template,
                          );
                          setState(() => _isLoading = false);
                          Navigator.pop(context);
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
