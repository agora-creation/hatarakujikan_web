import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/csv_api.dart';
import 'package:hatarakujikan_web/helpers/define.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/helpers/pdf_api.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/models/work.dart';
import 'package:hatarakujikan_web/models/work_shift.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/providers/position.dart';
import 'package:hatarakujikan_web/providers/user.dart';
import 'package:hatarakujikan_web/providers/work.dart';
import 'package:hatarakujikan_web/providers/work_shift.dart';
import 'package:hatarakujikan_web/widgets/admin_header.dart';
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
    final positionProvider = Provider.of<PositionProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final workProvider = Provider.of<WorkProvider>(context);
    final workShiftProvider = Provider.of<WorkShiftProvider>(context);

    return CustomAdminScaffold(
      groupProvider: groupProvider,
      selectedRoute: id,
      body: WorkTable(
        groupProvider: groupProvider,
        positionProvider: positionProvider,
        userProvider: userProvider,
        workProvider: workProvider,
        workShiftProvider: workShiftProvider,
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
                  onPressed: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (_) => SearchUserDialog(
                        users: widget.groupProvider.users,
                        user: _user!,
                        userChange: userChange,
                      ),
                    );
                  },
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
                  onPressed: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (_) => AddWorkDialog(
                        workProvider: widget.workProvider,
                        group: widget.groupProvider.group!,
                        users: widget.groupProvider.users,
                        user: _user!,
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

class SearchUserDialog extends StatelessWidget {
  final List<UserModel> users;
  final UserModel user;
  final Function userChange;

  SearchUserDialog({
    required this.users,
    required this.user,
    required this.userChange,
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

class AddWorkDialog extends StatefulWidget {
  final WorkProvider workProvider;
  final GroupModel group;
  final List<UserModel> users;
  final UserModel user;

  AddWorkDialog({
    required this.workProvider,
    required this.group,
    required this.users,
    required this.user,
  });

  @override
  _AddWorkDialogState createState() => _AddWorkDialogState();
}

class _AddWorkDialogState extends State<AddWorkDialog> {
  UserModel? _user;
  String _state = '';
  DateTime _startedAt = DateTime.now();
  DateTime _endedAt = DateTime.now();
  bool _isBreaks = false;
  DateTime _breakStartedAt = DateTime.now();
  DateTime _breakEndedAt = DateTime.now();

  void _init() async {
    _user = widget.user;
    _state = workStates.first;
    _endedAt = _startedAt.add(Duration(hours: 8));
    _breakEndedAt = _breakStartedAt.add(Duration(hours: 1));
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
                items: workStates.map((value) {
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
            CustomLabelColumn(
              label: '出勤日時',
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: CustomDateButton(
                      onPressed: () async {
                        DateTime? _selected = await showDatePicker(
                          context: context,
                          initialDate: _startedAt,
                          firstDate: kDayFirstDate,
                          lastDate: kDayLastDate,
                        );
                        if (_selected != null) {
                          _selected = rebuildDate(_selected, _startedAt);
                          setState(() => _startedAt = _selected!);
                        }
                      },
                      label: dateText('yyyy/MM/dd', _startedAt),
                    ),
                  ),
                  SizedBox(width: 4.0),
                  Expanded(
                    flex: 2,
                    child: CustomTimeButton(
                      onPressed: () async {
                        TimeOfDay? _selected = await showTimePicker(
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
                      label: dateText('HH:mm', _startedAt),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.0),
            CustomCheckboxListTile(
              onChanged: (value) {
                setState(() => _isBreaks = value ?? false);
              },
              label: '休憩を追加する',
              value: _isBreaks,
            ),
            SizedBox(height: 8.0),
            _isBreaks == true
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
                                  DateTime? _selected = await showDatePicker(
                                    context: context,
                                    initialDate: _breakStartedAt,
                                    firstDate: kDayFirstDate,
                                    lastDate: kDayLastDate,
                                  );
                                  if (_selected != null) {
                                    _selected =
                                        rebuildDate(_selected, _breakStartedAt);
                                    setState(
                                        () => _breakStartedAt = _selected!);
                                  }
                                },
                                label: dateText('yyyy/MM/dd', _breakStartedAt),
                              ),
                            ),
                            SizedBox(width: 4.0),
                            Expanded(
                              flex: 2,
                              child: CustomTimeButton(
                                onPressed: () async {
                                  TimeOfDay? _selected = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay(
                                      hour: timeToInt(_breakStartedAt)[0],
                                      minute: timeToInt(_breakStartedAt)[1],
                                    ),
                                  );
                                  if (_selected != null) {
                                    DateTime _dateTime = rebuildTime(
                                      context,
                                      _breakStartedAt,
                                      _selected,
                                    );
                                    setState(() => _breakStartedAt = _dateTime);
                                  }
                                },
                                label: dateText('HH:mm', _breakStartedAt),
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
                                  DateTime? _selected = await showDatePicker(
                                    context: context,
                                    initialDate: _breakEndedAt,
                                    firstDate: kDayFirstDate,
                                    lastDate: kDayLastDate,
                                  );
                                  if (_selected != null) {
                                    _selected =
                                        rebuildDate(_selected, _breakEndedAt);
                                    setState(() => _breakEndedAt = _selected!);
                                  }
                                },
                                label: dateText('yyyy/MM/dd', _breakEndedAt),
                              ),
                            ),
                            SizedBox(width: 4.0),
                            Expanded(
                              flex: 2,
                              child: CustomTimeButton(
                                onPressed: () async {
                                  TimeOfDay? _selected = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay(
                                      hour: timeToInt(_breakEndedAt)[0],
                                      minute: timeToInt(_breakEndedAt)[1],
                                    ),
                                  );
                                  if (_selected != null) {
                                    DateTime _dateTime = rebuildTime(
                                      context,
                                      _breakEndedAt,
                                      _selected,
                                    );
                                    setState(() => _breakEndedAt = _dateTime);
                                  }
                                },
                                label: dateText('HH:mm', _breakEndedAt),
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
                        DateTime? _selected = await showDatePicker(
                          context: context,
                          initialDate: _endedAt,
                          firstDate: kDayFirstDate,
                          lastDate: kDayLastDate,
                        );
                        if (_selected != null) {
                          _selected = rebuildDate(_selected, _endedAt);
                          setState(() => _endedAt = _selected!);
                        }
                      },
                      label: dateText('yyyy/MM/dd', _endedAt),
                    ),
                  ),
                  SizedBox(width: 4.0),
                  Expanded(
                    flex: 2,
                    child: CustomTimeButton(
                      onPressed: () async {
                        TimeOfDay? _selected = await showTimePicker(
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
                      label: dateText('HH:mm', _endedAt),
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
                    if (!await widget.workProvider.create(
                      group: widget.group,
                      user: _user!,
                      startedAt: _startedAt,
                      endedAt: _endedAt,
                      isBreaks: _isBreaks,
                      breakStartedAt: _breakStartedAt,
                      breakEndedAt: _breakEndedAt,
                    )) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('勤務データを登録しました')),
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
