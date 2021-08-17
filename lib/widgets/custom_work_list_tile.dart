import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/breaks.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/work.dart';
import 'package:hatarakujikan_web/models/work_state.dart';
import 'package:hatarakujikan_web/providers/work.dart';
import 'package:hatarakujikan_web/providers/work_state.dart';
import 'package:hatarakujikan_web/widgets/custom_date_button.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';
import 'package:hatarakujikan_web/widgets/custom_time_button.dart';
import 'package:intl/intl.dart';

class CustomWorkListTile extends StatelessWidget {
  final WorkProvider workProvider;
  final WorkStateProvider workStateProvider;
  final DateTime day;
  final List<WorkModel> works;
  final WorkStateModel workState;
  final GroupModel group;

  CustomWorkListTile({
    this.workProvider,
    this.workStateProvider,
    this.day,
    this.works,
    this.workState,
    this.group,
  });

  @override
  Widget build(BuildContext context) {
    Color _chipColor = Colors.grey.shade300;
    if (workState?.state == '欠勤') {
      _chipColor = Colors.red.shade300;
    } else if (workState?.state == '特別休暇') {
      _chipColor = Colors.green.shade300;
    } else if (workState?.state == '有給休暇') {
      _chipColor = Colors.teal.shade300;
    }

    return Container(
      decoration: kBottomBorderDecoration,
      child: ListTile(
        leading: Text(
          '${DateFormat('dd (E)', 'ja').format(day)}',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 15.0,
          ),
        ),
        title: works.length > 0
            ? ListView.separated(
                shrinkWrap: true,
                physics: ScrollPhysics(),
                separatorBuilder: (_, index) => Divider(height: 0.0),
                itemCount: works.length,
                itemBuilder: (_, index) {
                  WorkModel _work = works[index];
                  String _startTime = _work.startTime(group);
                  String _endTime = '00:00';
                  String _breakTime = '00:00';
                  String _workTime = '00:00';
                  String _legalTime = '00:00';
                  String _nonLegalTime = '00:00';
                  String _nightTime = '00:00';
                  if (_work.startedAt != _work.endedAt) {
                    _endTime = _work.endTime(group);
                    _breakTime = _work.breakTimes(group)[0];
                    _workTime = _work.workTime(group);
                    List<String> _legalTimes = _work.legalTimes(group);
                    _legalTime = _legalTimes.first;
                    _nonLegalTime = _legalTimes.last;
                    List<String> _nightTimes = _work.nightTimes(group);
                    _nightTime = _nightTimes.last;
                  }
                  return ListTile(
                    leading: Chip(
                      backgroundColor: _chipColor,
                      label: Text(
                        '${_work.state}',
                        style: TextStyle(fontSize: 12.0),
                      ),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _startTime,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 15.0,
                          ),
                        ),
                        Text(
                          _endTime,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 15.0,
                          ),
                        ),
                        Text(
                          _breakTime,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 15.0,
                          ),
                        ),
                        Text(
                          _workTime,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 15.0,
                          ),
                        ),
                        Text(
                          _legalTime,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 15.0,
                          ),
                        ),
                        Text(
                          _nonLegalTime,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 15.0,
                          ),
                        ),
                        Text(
                          _nightTime,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 15.0,
                          ),
                        ),
                        _work.startedAt != _work.endedAt
                            ? IconButton(
                                onPressed: () => showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (_) => WorkDetailsDialog(
                                    workProvider: workProvider,
                                    work: _work,
                                    group: group,
                                  ),
                                ),
                                icon: Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                              )
                            : IconButton(
                                onPressed: null,
                                icon: Icon(
                                  Icons.edit,
                                  color: Colors.transparent,
                                ),
                              ),
                        _work.startedAt != _work.endedAt
                            ? IconButton(
                                onPressed: () => showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (_) => WorkLocationDialog(
                                    work: _work,
                                  ),
                                ),
                                icon: Icon(
                                  Icons.location_on,
                                  color: Colors.blue,
                                ),
                              )
                            : IconButton(
                                onPressed: null,
                                icon: Icon(
                                  Icons.location_on,
                                  color: Colors.transparent,
                                ),
                              ),
                      ],
                    ),
                  );
                },
              )
            : workState != null
                ? ListTile(
                    leading: Chip(
                      backgroundColor: _chipColor,
                      label: Text(
                        '${workState.state}',
                        style: TextStyle(fontSize: 12.0),
                      ),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '00:00',
                          style: TextStyle(
                            color: Colors.transparent,
                            fontSize: 15.0,
                          ),
                        ),
                        Text(
                          '00:00',
                          style: TextStyle(
                            color: Colors.transparent,
                            fontSize: 15.0,
                          ),
                        ),
                        Text(
                          '00:00',
                          style: TextStyle(
                            color: Colors.transparent,
                            fontSize: 15.0,
                          ),
                        ),
                        Text(
                          '00:00',
                          style: TextStyle(
                            color: Colors.transparent,
                            fontSize: 15.0,
                          ),
                        ),
                        Text(
                          '00:00',
                          style: TextStyle(
                            color: Colors.transparent,
                            fontSize: 15.0,
                          ),
                        ),
                        Text(
                          '00:00',
                          style: TextStyle(
                            color: Colors.transparent,
                            fontSize: 15.0,
                          ),
                        ),
                        Text(
                          '00:00',
                          style: TextStyle(
                            color: Colors.transparent,
                            fontSize: 15.0,
                          ),
                        ),
                        IconButton(
                          onPressed: () => showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (_) => WorkStateDetailsDialog(
                              workStateProvider: workStateProvider,
                              workState: workState,
                            ),
                          ),
                          icon: Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),
                        ),
                        IconButton(
                          onPressed: null,
                          icon: Icon(
                            Icons.location_on,
                            color: Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),
      ),
    );
  }
}

class WorkDetailsDialog extends StatefulWidget {
  final WorkProvider workProvider;
  final WorkModel work;
  final GroupModel group;

  WorkDetailsDialog({
    @required this.workProvider,
    @required this.work,
    @required this.group,
  });

  @override
  _WorkDetailsDialogState createState() => _WorkDetailsDialogState();
}

class _WorkDetailsDialogState extends State<WorkDetailsDialog> {
  DateTime _firstDate = DateTime.now().subtract(Duration(days: 365));
  DateTime _lastDate = DateTime.now().add(Duration(days: 365));
  WorkModel work;
  bool isBreaks = false;
  DateTime breakStartedAt = DateTime.now();
  DateTime breakEndedAt = DateTime.now();

  void _init() async {
    setState(() {
      work = widget.work;
      breakStartedAt = widget.work.startedAt;
      breakEndedAt = widget.work.startedAt;
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
        width: 550.0,
        child: ListView(
          shrinkWrap: true,
          children: [
            SizedBox(height: 16.0),
            Text(
              '修正したい日時に変更し、最後に「修正する」ボタンを押してください。',
              style: TextStyle(color: Colors.black54, fontSize: 14.0),
            ),
            Text(
              'この記録を削除したい場合は、「削除する」ボタンを押してください。',
              style: TextStyle(color: Colors.black54, fontSize: 14.0),
            ),
            SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '勤務状況',
                  style: TextStyle(color: Colors.black54, fontSize: 14.0),
                ),
                Chip(
                  backgroundColor: Colors.grey.shade300,
                  label: Text('${work.state}'),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '出勤日時',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14.0,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: CustomDateButton(
                        onPressed: () async {
                          DateTime _selected = await showDatePicker(
                            context: context,
                            initialDate: work.startedAt,
                            firstDate: _firstDate,
                            lastDate: _lastDate,
                          );
                          if (_selected != null) {
                            String _date =
                                '${DateFormat('yyyy-MM-dd').format(_selected)}';
                            String _time =
                                '${DateFormat('HH:mm').format(work.startedAt)}:00.000';
                            DateTime _dateTime =
                                DateTime.parse('$_date $_time');
                            setState(() => work.startedAt = _dateTime);
                          }
                        },
                        label:
                            '${DateFormat('yyyy/MM/dd').format(work.startedAt)}',
                      ),
                    ),
                    SizedBox(width: 4.0),
                    Expanded(
                      flex: 2,
                      child: CustomTimeButton(
                        onPressed: () async {
                          String _hour =
                              '${DateFormat('H').format(work.startedAt)}';
                          String _minute =
                              '${DateFormat('m').format(work.startedAt)}';
                          TimeOfDay _selected = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay(
                              hour: int.parse(_hour),
                              minute: int.parse(_minute),
                            ),
                          );
                          if (_selected != null) {
                            String _date =
                                '${DateFormat('yyyy-MM-dd').format(work.startedAt)}';
                            String _time =
                                '${_selected.format(context).padLeft(5, '0')}:00.000';
                            DateTime _dateTime =
                                DateTime.parse('$_date $_time');
                            setState(() => work.startedAt = _dateTime);
                          }
                        },
                        label: '${DateFormat('HH:mm').format(work.startedAt)}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8.0),
            work.breaks.length > 0
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    itemCount: work.breaks.length,
                    itemBuilder: (_, index) {
                      BreaksModel _breaks = work.breaks[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '休憩開始日時',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14.0,
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: CustomDateButton(
                                  onPressed: () async {
                                    DateTime _selected = await showDatePicker(
                                      context: context,
                                      initialDate: _breaks.startedAt,
                                      firstDate: _firstDate,
                                      lastDate: _lastDate,
                                    );
                                    if (_selected != null) {
                                      String _date =
                                          '${DateFormat('yyyy-MM-dd').format(_selected)}';
                                      String _time =
                                          '${DateFormat('HH:mm').format(_breaks.startedAt)}:00.000';
                                      DateTime _dateTime =
                                          DateTime.parse('$_date $_time');
                                      setState(
                                          () => _breaks.startedAt = _dateTime);
                                    }
                                  },
                                  label:
                                      '${DateFormat('yyyy/MM/dd').format(_breaks.startedAt)}',
                                ),
                              ),
                              SizedBox(width: 4.0),
                              Expanded(
                                flex: 2,
                                child: CustomTimeButton(
                                  onPressed: () async {
                                    String _hour =
                                        '${DateFormat('H').format(_breaks.startedAt)}';
                                    String _minute =
                                        '${DateFormat('m').format(_breaks.startedAt)}';
                                    TimeOfDay _selected = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay(
                                        hour: int.parse(_hour),
                                        minute: int.parse(_minute),
                                      ),
                                    );
                                    if (_selected != null) {
                                      String _date =
                                          '${DateFormat('yyyy-MM-dd').format(_breaks.startedAt)}';
                                      String _time =
                                          '${_selected.format(context).padLeft(5, '0')}:00.000';
                                      DateTime _dateTime =
                                          DateTime.parse('$_date $_time');
                                      setState(
                                          () => _breaks.startedAt = _dateTime);
                                    }
                                  },
                                  label:
                                      '${DateFormat('HH:mm').format(_breaks.startedAt)}',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            '休憩終了日時',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14.0,
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: CustomDateButton(
                                  onPressed: () async {
                                    DateTime _selected = await showDatePicker(
                                      context: context,
                                      initialDate: _breaks.endedAt,
                                      firstDate: _firstDate,
                                      lastDate: _lastDate,
                                    );
                                    if (_selected != null) {
                                      String _date =
                                          '${DateFormat('yyyy-MM-dd').format(_selected)}';
                                      String _time =
                                          '${DateFormat('HH:mm').format(_breaks.endedAt)}:00.000';
                                      DateTime _dateTime =
                                          DateTime.parse('$_date $_time');
                                      setState(
                                          () => _breaks.endedAt = _dateTime);
                                    }
                                  },
                                  label:
                                      '${DateFormat('yyyy/MM/dd').format(_breaks.endedAt)}',
                                ),
                              ),
                              SizedBox(width: 4.0),
                              Expanded(
                                flex: 2,
                                child: CustomTimeButton(
                                  onPressed: () async {
                                    String _hour =
                                        '${DateFormat('H').format(_breaks.endedAt)}';
                                    String _minute =
                                        '${DateFormat('m').format(_breaks.endedAt)}';
                                    TimeOfDay _selected = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay(
                                        hour: int.parse(_hour),
                                        minute: int.parse(_minute),
                                      ),
                                    );
                                    if (_selected != null) {
                                      String _date =
                                          '${DateFormat('yyyy-MM-dd').format(_breaks.endedAt)}';
                                      String _time =
                                          '${_selected.format(context).padLeft(5, '0')}:00.000';
                                      DateTime _dateTime =
                                          DateTime.parse('$_date $_time');
                                      setState(
                                          () => _breaks.endedAt = _dateTime);
                                    }
                                  },
                                  label:
                                      '${DateFormat('HH:mm').format(_breaks.endedAt)}',
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: kTopBottomBorderDecoration,
                        child: CheckboxListTile(
                          onChanged: (value) {
                            setState(() => isBreaks = value);
                          },
                          value: isBreaks,
                          title: Text('休憩を追加する'),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      isBreaks == true
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '休憩開始日時',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14.0,
                                  ),
                                ),
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
                                                '${_selected.format(context).padLeft(5, '0')}:00.000';
                                            DateTime _datetime =
                                                DateTime.parse('$_date $_time');
                                            setState(() =>
                                                breakStartedAt = _datetime);
                                          }
                                        },
                                        label:
                                            '${DateFormat('HH:mm').format(breakStartedAt)}',
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  '休憩終了日時',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14.0,
                                  ),
                                ),
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
                                                '${_selected.format(context).padLeft(5, '0')}:00.000';
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
                    ],
                  ),
            SizedBox(height: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '退勤日時',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14.0,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: CustomDateButton(
                        onPressed: () async {
                          DateTime _selected = await showDatePicker(
                            context: context,
                            initialDate: work.endedAt,
                            firstDate: _firstDate,
                            lastDate: _lastDate,
                          );
                          if (_selected != null) {
                            String _date =
                                '${DateFormat('yyyy-MM-dd').format(_selected)}';
                            String _time =
                                '${DateFormat('HH:mm').format(work.endedAt)}:00.000';
                            DateTime _dateTime =
                                DateTime.parse('$_date $_time');
                            setState(() => work.endedAt = _dateTime);
                          }
                        },
                        label:
                            '${DateFormat('yyyy/MM/dd').format(work.endedAt)}',
                      ),
                    ),
                    SizedBox(width: 4.0),
                    Expanded(
                      flex: 2,
                      child: CustomTimeButton(
                        onPressed: () async {
                          String _hour =
                              '${DateFormat('H').format(work.endedAt)}';
                          String _minute =
                              '${DateFormat('m').format(work.endedAt)}';
                          TimeOfDay _selected = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay(
                              hour: int.parse(_hour),
                              minute: int.parse(_minute),
                            ),
                          );
                          if (_selected != null) {
                            String _date =
                                '${DateFormat('yyyy-MM-dd').format(work.endedAt)}';
                            String _time =
                                '${_selected.format(context).padLeft(5, '0')}:00.000';
                            DateTime _dateTime =
                                DateTime.parse('$_date $_time');
                            setState(() => work.endedAt = _dateTime);
                          }
                        },
                        label: '${DateFormat('HH:mm').format(work.endedAt)}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              children: [
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '勤務時間',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14.0,
                            ),
                          ),
                          Text('${work.workTime(widget.group)}'),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '法定内時間',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14.0,
                            ),
                          ),
                          Text('${work.legalTimes(widget.group).first}'),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '法定外時間',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14.0,
                            ),
                          ),
                          Text('${work.legalTimes(widget.group).last}'),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '深夜時間',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14.0,
                            ),
                          ),
                          Text('${work.nightTimes(widget.group).last}'),
                        ],
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '通常時間※1',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14.0,
                            ),
                          ),
                          Text('${work.calTimes01(widget.group)[0]}'),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '深夜時間※2',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14.0,
                            ),
                          ),
                          Text('${work.calTimes01(widget.group)[1]}'),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '通常時間外※3',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14.0,
                            ),
                          ),
                          Text('${work.calTimes01(widget.group)[2]}'),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '深夜時間外※4',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14.0,
                            ),
                          ),
                          Text('${work.calTimes01(widget.group)[3]}'),
                        ],
                      ),
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
                Row(
                  children: [
                    CustomTextButton(
                      onPressed: () {
                        widget.workProvider.delete(work: work);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('勤怠情報を削除しました')),
                        );
                        Navigator.pop(context);
                      },
                      color: Colors.red,
                      label: '削除する',
                    ),
                    SizedBox(width: 4.0),
                    CustomTextButton(
                      onPressed: () async {
                        if (!await widget.workProvider.update(
                          work: work,
                          isBreaks: isBreaks,
                          breakStartedAt: breakStartedAt,
                          breakEndedAt: breakEndedAt,
                        )) {
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('勤怠情報を修正しました')),
                        );
                        Navigator.pop(context);
                      },
                      color: Colors.blue,
                      label: '修正する',
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

class WorkLocationDialog extends StatefulWidget {
  final WorkModel work;

  WorkLocationDialog({@required this.work});

  @override
  _WorkLocationDialogState createState() => _WorkLocationDialogState();
}

class _WorkLocationDialogState extends State<WorkLocationDialog> {
  GoogleMapController mapController;
  Set<Marker> markers = {};

  void _init() async {
    WorkModel _work = widget.work;
    setState(() {
      markers.add(Marker(
        markerId: MarkerId('start_${_work.id}'),
        position: LatLng(
          _work.startedLat,
          _work.startedLon,
        ),
        infoWindow: InfoWindow(
          title: '出勤日時',
          snippet: '${DateFormat('yyyy/MM/dd HH:mm').format(_work.startedAt)}',
        ),
      ));
      _work.breaks.forEach((e) {
        markers.add(Marker(
          markerId: MarkerId('start_${e.id}'),
          position: LatLng(
            e.startedLat,
            e.startedLon,
          ),
          infoWindow: InfoWindow(
            title: '休憩開始日時',
            snippet: '${DateFormat('yyyy/MM/dd HH:mm').format(e.startedAt)}',
          ),
        ));
        markers.add(Marker(
          markerId: MarkerId('end_${e.id}'),
          position: LatLng(
            e.endedLat,
            e.endedLon,
          ),
          infoWindow: InfoWindow(
            title: '休憩終了日時',
            snippet: '${DateFormat('yyyy/MM/dd HH:mm').format(e.endedAt)}',
          ),
        ));
      });
      markers.add(Marker(
        markerId: MarkerId('end_${_work.id}'),
        position: LatLng(
          _work.endedLat,
          _work.endedLon,
        ),
        infoWindow: InfoWindow(
          title: '退勤日時',
          snippet: '${DateFormat('yyyy/MM/dd HH:mm').format(_work.endedAt)}',
        ),
      ));
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() => mapController = controller);
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
              '記録した位置情報',
              style: TextStyle(color: Colors.black54, fontSize: 14.0),
            ),
            Container(
              height: 350.0,
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                markers: markers,
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    widget.work.startedLat,
                    widget.work.startedLon,
                  ),
                  zoom: 17.0,
                ),
                zoomGesturesEnabled: false,
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

class WorkStateDetailsDialog extends StatelessWidget {
  final WorkStateProvider workStateProvider;
  final WorkStateModel workState;

  WorkStateDetailsDialog({
    @required this.workStateProvider,
    @required this.workState,
  });

  @override
  Widget build(BuildContext context) {
    Color _chipColor = Colors.grey.shade300;
    if (workState.state == '欠勤') {
      _chipColor = Colors.red.shade300;
    } else if (workState.state == '特別休暇') {
      _chipColor = Colors.green.shade300;
    } else if (workState.state == '有給休暇') {
      _chipColor = Colors.teal.shade300;
    }

    return AlertDialog(
      content: Container(
        width: 450.0,
        child: ListView(
          shrinkWrap: true,
          children: [
            SizedBox(height: 16.0),
            Text(
              'この記録を削除したい場合は、「削除する」ボタンを押してください。',
              style: TextStyle(color: Colors.black54, fontSize: 14.0),
            ),
            SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '勤務状況',
                  style: TextStyle(color: Colors.black54, fontSize: 14.0),
                ),
                Chip(
                  backgroundColor: _chipColor,
                  label: Text('${workState.state}'),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '登録日',
                  style: TextStyle(color: Colors.black54, fontSize: 14.0),
                ),
                Text('${DateFormat('yyyy/MM/dd').format(workState.startedAt)}'),
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
                  onPressed: () {
                    workStateProvider.delete(workState: workState);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('勤怠情報を削除しました')),
                    );
                    Navigator.pop(context);
                  },
                  color: Colors.red,
                  label: '削除する',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
