import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/csv_api.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/helpers/pdf_api.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/models/work.dart';
import 'package:hatarakujikan_web/models/work_state.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/providers/work.dart';
import 'package:hatarakujikan_web/providers/work_state.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold.dart';
import 'package:hatarakujikan_web/widgets/custom_checkbox_list_tile.dart';
import 'package:hatarakujikan_web/widgets/custom_date_button.dart';
import 'package:hatarakujikan_web/widgets/custom_dropdown_button.dart';
import 'package:hatarakujikan_web/widgets/custom_label_column.dart';
import 'package:hatarakujikan_web/widgets/custom_radio_list_tile.dart';
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
import 'package:provider/provider.dart';

class WorkScreen extends StatelessWidget {
  static const String id = 'work';

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final workProvider = Provider.of<WorkProvider>(context);
    final workStateProvider = Provider.of<WorkStateProvider>(context);

    return CustomAdminScaffold(
      groupProvider: groupProvider,
      selectedRoute: id,
      body: WorkTable(
        groupProvider: groupProvider,
        workProvider: workProvider,
        workStateProvider: workStateProvider,
      ),
    );
  }
}

class WorkTable extends StatefulWidget {
  final GroupProvider groupProvider;
  final WorkProvider workProvider;
  final WorkStateProvider workStateProvider;

  WorkTable({
    @required this.groupProvider,
    @required this.workProvider,
    @required this.workStateProvider,
  });

  @override
  _WorkTableState createState() => _WorkTableState();
}

class _WorkTableState extends State<WorkTable> {
  DateTime month = DateTime.now();
  UserModel user;
  List<DateTime> days = [];

  void _init() async {
    setState(() => days = generateDays(month));
  }

  void userChange(UserModel userModel) {
    setState(() => user = userModel);
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    GroupModel _group = widget.groupProvider.group;
    Timestamp _startAt = convertTimestamp(days.first, false);
    Timestamp _endAt = convertTimestamp(days.last, true);
    Stream<QuerySnapshot> _streamWork = FirebaseFirestore.instance
        .collection('work')
        .where('groupId', isEqualTo: _group?.id ?? 'error')
        .where('userId', isEqualTo: user?.id ?? 'error')
        .orderBy('startedAt', descending: false)
        .startAt([_startAt]).endAt([_endAt]).snapshots();
    Stream<QuerySnapshot> _streamWorkState = FirebaseFirestore.instance
        .collection('workState')
        .where('groupId', isEqualTo: _group?.id ?? 'error')
        .where('userId', isEqualTo: user?.id ?? 'error')
        .orderBy('startedAt', descending: false)
        .startAt([_startAt]).endAt([_endAt]).snapshots();
    List<WorkModel> works = [];
    List<WorkStateModel> workStates = [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '勤怠の記録',
          style: kAdminTitleTextStyle,
        ),
        Text(
          'スタッフがスマートフォンアプリやタブレットアプリで記録した勤怠時間を年月形式で一覧表示します。この画面から追加や修正ができます。',
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
                      initialDate: month,
                      firstDate: kMonthFirstDate,
                      lastDate: kMonthLastDate,
                    );
                    if (selected == null) return;
                    setState(() {
                      month = selected;
                      days = generateDays(month);
                    });
                  },
                  color: Colors.lightBlueAccent,
                  iconData: Icons.today,
                  label: '${DateFormat('yyyy年MM月').format(month)}',
                ),
                SizedBox(width: 4.0),
                CustomTextIconButton(
                  onPressed: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (_) => SearchUserDialog(
                        users: widget.groupProvider.users,
                        user: user,
                        userChange: userChange,
                      ),
                    );
                  },
                  color: Colors.lightBlueAccent,
                  iconData: Icons.person,
                  label: user?.name ?? '選択してください',
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
                        workStateProvider: widget.workStateProvider,
                        group: widget.groupProvider.group,
                        month: month,
                        users: widget.groupProvider.users,
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
                        month: month,
                        users: widget.groupProvider.users,
                        user: user,
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
                        users: widget.groupProvider.users,
                        user: user,
                      ),
                    );
                  },
                  color: Colors.blue,
                  iconData: Icons.add,
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
              for (DocumentSnapshot doc in snapshot.item1.data.docs) {
                works.add(WorkModel.fromSnapshot(doc));
              }
              workStates.clear();
              for (DocumentSnapshot doc in snapshot.item2.data.docs) {
                workStates.add(WorkStateModel.fromSnapshot(doc));
              }
              return ListView.builder(
                itemCount: days.length,
                itemBuilder: (_, index) {
                  List<WorkModel> dayWorks = [];
                  for (WorkModel _work in works) {
                    String _start =
                        '${DateFormat('yyyy-MM-dd').format(_work.startedAt)}';
                    if (days[index] == DateTime.parse(_start)) {
                      dayWorks.add(_work);
                    }
                  }
                  WorkStateModel dayWorkState;
                  for (WorkStateModel _workState in workStates) {
                    String _start =
                        '${DateFormat('yyyy-MM-dd').format(_workState.startedAt)}';
                    if (days[index] == DateTime.parse(_start)) {
                      dayWorkState = _workState;
                    }
                  }
                  return CustomWorkListTile(
                    workProvider: widget.workProvider,
                    workStateProvider: widget.workStateProvider,
                    day: days[index],
                    dayWorks: dayWorks,
                    dayWorkState: dayWorkState,
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
                String _key =
                    '${DateFormat('yyyy-MM-dd').format(_work?.startedAt)}';
                _count[_key] = '';
                _workTime = addTime(
                  _workTime,
                  _work?.workTime(widget.groupProvider.group),
                );
                List<String> _legalTimes =
                    _work?.legalTimes(widget.groupProvider.group);
                _legalTime = addTime(_legalTime, _legalTimes.first);
                _nonLegalTime = addTime(_nonLegalTime, _legalTimes.last);
                List<String> _nightTimes =
                    _work?.nightTimes(widget.groupProvider.group);
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

class SearchUserDialog extends StatelessWidget {
  final List<UserModel> users;
  final UserModel user;
  final Function userChange;

  SearchUserDialog({
    @required this.users,
    @required this.user,
    @required this.userChange,
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
            Divider(),
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
                    return CustomRadioListTile(
                      onChanged: (value) {
                        userChange(value);
                        Navigator.pop(context);
                      },
                      label: '${_user.name}',
                      value: _user,
                      groupValue: user,
                    );
                  },
                ),
              ),
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
  final WorkStateProvider workStateProvider;
  final GroupModel group;
  final DateTime month;
  final List<UserModel> users;

  CsvDialog({
    @required this.workProvider,
    @required this.workStateProvider,
    @required this.group,
    @required this.month,
    @required this.users,
  });

  @override
  _CsvDialogState createState() => _CsvDialogState();
}

class _CsvDialogState extends State<CsvDialog> {
  DateTime month = DateTime.now();
  List<DateTime> days = [];
  bool _isLoading = false;
  String template;

  void _init() async {
    CsvApi.groupCheck(group: widget.group);
    setState(() {
      month = widget.month;
      template = csvTemplates.first;
      days = generateDays(month);
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
                      value: template,
                      onChanged: (value) {
                        setState(() => template = value);
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
                          initialDate: month,
                          firstDate: kMonthFirstDate,
                          lastDate: kMonthLastDate,
                        );
                        if (selected == null) return;
                        setState(() {
                          month = selected;
                          days = generateDays(month);
                        });
                      },
                      label: '${DateFormat('yyyy年MM月').format(month)}',
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
                            template: template,
                            workProvider: widget.workProvider,
                            workStateProvider: widget.workStateProvider,
                            group: widget.group,
                            month: month,
                            users: widget.users,
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
  final WorkProvider workProvider;
  final WorkStateProvider workStateProvider;
  final GroupModel group;
  final DateTime month;
  final List<UserModel> users;
  final UserModel user;

  PdfDialog({
    @required this.workProvider,
    @required this.workStateProvider,
    @required this.group,
    @required this.month,
    @required this.users,
    @required this.user,
  });

  @override
  _PdfDialogState createState() => _PdfDialogState();
}

class _PdfDialogState extends State<PdfDialog> {
  List<DateTime> days = [];
  DateTime month = DateTime.now();
  UserModel user;
  bool isAll = false;
  bool _isLoading = false;

  void _init() async {
    setState(() {
      month = widget.month;
      user = widget.user;
      days = generateDays(month);
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
                    label: '年月',
                    child: CustomDateButton(
                      onPressed: () async {
                        var selected = await showMonthPicker(
                          context: context,
                          initialDate: month,
                          firstDate: kMonthFirstDate,
                          lastDate: kMonthLastDate,
                        );
                        if (selected == null) return;
                        setState(() {
                          month = selected;
                          days = generateDays(month);
                        });
                      },
                      label: '${DateFormat('yyyy年MM月').format(month)}',
                    ),
                  ),
                  SizedBox(height: 8.0),
                  CustomLabelColumn(
                    label: 'スタッフ',
                    child: CustomDropdownButton(
                      isExpanded: true,
                      value: user,
                      onChanged: (value) {
                        setState(() => user = value);
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
                      setState(() => isAll = value);
                    },
                    label: '全スタッフ一括出力',
                    value: isAll,
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
                          await PdfApi.works01(
                            workProvider: widget.workProvider,
                            workStateProvider: widget.workStateProvider,
                            group: widget.group,
                            month: month,
                            user: user,
                            isAll: isAll,
                            users: widget.users,
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

class AddWorkDialog extends StatefulWidget {
  final WorkProvider workProvider;
  final WorkStateProvider workStateProvider;
  final String groupId;
  final List<UserModel> users;
  final UserModel user;

  AddWorkDialog({
    @required this.workProvider,
    @required this.workStateProvider,
    @required this.groupId,
    @required this.users,
    @required this.user,
  });

  @override
  _AddWorkDialogState createState() => _AddWorkDialogState();
}

class _AddWorkDialogState extends State<AddWorkDialog> {
  UserModel user;
  String state;
  DateTime startedAt = DateTime.now();
  DateTime endedAt = DateTime.now();
  bool isBreaks = false;
  DateTime breakStartedAt = DateTime.now();
  DateTime breakEndedAt = DateTime.now();

  void _init() async {
    setState(() {
      user = widget.user;
      state = widget.workStateProvider.states.first;
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
              style: kDefaultTextStyle,
            ),
            SizedBox(height: 16.0),
            CustomLabelColumn(
              label: 'スタッフ',
              child: CustomDropdownButton(
                isExpanded: true,
                value: user,
                onChanged: (value) {
                  setState(() => user = value);
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
                value: state,
                onChanged: (value) {
                  setState(() => state = value);
                },
                items: widget.workStateProvider.states.map((value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(
                      '$value',
                      style: kDefaultTextStyle,
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 8.0),
            state == '通常勤務' || state == '直行/直帰' || state == 'テレワーク'
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomLabelColumn(
                        label: '出勤日時',
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: CustomDateButton(
                                onPressed: () async {
                                  DateTime _selected = await showDatePicker(
                                    context: context,
                                    initialDate: startedAt,
                                    firstDate: kDayFirstDate,
                                    lastDate: kDayLastDate,
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
                                        '${_selected.format(context).padLeft(5, '0')}:00.000';
                                    DateTime _dateTime =
                                        DateTime.parse('$_date $_time');
                                    setState(() => startedAt = _dateTime);
                                  }
                                },
                                label:
                                    '${DateFormat('HH:mm').format(startedAt)}',
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.0),
                      CustomCheckboxListTile(
                        onChanged: (value) {
                          setState(() => isBreaks = value);
                        },
                        label: '休憩を追加する',
                        value: isBreaks,
                      ),
                      SizedBox(height: 8.0),
                      isBreaks == true
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomLabelColumn(
                                  label: '休憩開始日時',
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: CustomDateButton(
                                          onPressed: () async {
                                            DateTime _selected =
                                                await showDatePicker(
                                              context: context,
                                              initialDate: breakStartedAt,
                                              firstDate: kDayFirstDate,
                                              lastDate: kDayLastDate,
                                            );
                                            if (_selected != null) {
                                              String _date =
                                                  '${DateFormat('yyyy-MM-dd').format(_selected)}';
                                              String _time =
                                                  '${DateFormat('HH:mm').format(breakStartedAt)}';
                                              DateTime _dateTime =
                                                  DateTime.parse(
                                                      '$_date $_time');
                                              setState(() =>
                                                  breakStartedAt = _dateTime);
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
                                                  '${_selected.format(context).padLeft(5, '0')}:00.000';
                                              DateTime _dateTime =
                                                  DateTime.parse(
                                                      '$_date $_time');
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
                                ),
                                SizedBox(height: 8.0),
                                CustomLabelColumn(
                                  label: '休憩終了日時',
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: CustomDateButton(
                                          onPressed: () async {
                                            DateTime _selected =
                                                await showDatePicker(
                                              context: context,
                                              initialDate: breakEndedAt,
                                              firstDate: kDayFirstDate,
                                              lastDate: kDayLastDate,
                                            );
                                            if (_selected != null) {
                                              String _date =
                                                  '${DateFormat('yyyy-MM-dd').format(_selected)}';
                                              String _time =
                                                  '${DateFormat('HH:mm').format(breakEndedAt)}:00.000';
                                              DateTime _dateTime =
                                                  DateTime.parse(
                                                      '$_date $_time');
                                              setState(() =>
                                                  breakEndedAt = _dateTime);
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
                                                  '${_selected.format(context).padLeft(5, '0')}:00.000';
                                              DateTime _dateTime =
                                                  DateTime.parse(
                                                      '$_date $_time');
                                              setState(() =>
                                                  breakEndedAt = _dateTime);
                                            }
                                          },
                                          label:
                                              '${DateFormat('HH:mm').format(breakEndedAt)}',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                      SizedBox(height: 8.0),
                      CustomLabelColumn(
                        label: '退勤日時',
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: CustomDateButton(
                                onPressed: () async {
                                  DateTime _selected = await showDatePicker(
                                    context: context,
                                    initialDate: endedAt,
                                    firstDate: kDayFirstDate,
                                    lastDate: kDayLastDate,
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
                                        '${_selected.format(context).padLeft(5, '0')}:00.000';
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
                      ),
                    ],
                  )
                : CustomLabelColumn(
                    label: '登録日',
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: CustomDateButton(
                            onPressed: () async {
                              DateTime _selected = await showDatePicker(
                                context: context,
                                initialDate: startedAt,
                                firstDate: kDayFirstDate,
                                lastDate: kDayLastDate,
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
                    if (state == '通常勤務' ||
                        state == '直行/直帰' ||
                        state == 'テレワーク') {
                      if (startedAt == endedAt) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('出勤日時と退勤日時に同じ日時が入力されています')),
                        );
                        Navigator.pop(context);
                        return;
                      }
                      if (!await widget.workProvider.create(
                        groupId: widget.groupId,
                        userId: user?.id,
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
                        userId: user?.id,
                        startedAt: startedAt,
                        state: state,
                      )) {
                        return;
                      }
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('勤怠情報を登録しました')),
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
