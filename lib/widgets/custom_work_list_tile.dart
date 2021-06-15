import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/breaks.dart';
import 'package:hatarakujikan_web/models/work.dart';
import 'package:hatarakujikan_web/providers/work.dart';
import 'package:hatarakujikan_web/widgets/custom_date_button.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';
import 'package:hatarakujikan_web/widgets/custom_time_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CustomWorkListTile extends StatelessWidget {
  final DateTime day;
  final List<WorkModel> works;

  CustomWorkListTile({
    this.day,
    this.works,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kBottomBorderDecoration,
      child: ListTile(
        leading: Text(
          '${DateFormat('dd (E)', 'ja').format(day)}',
          style: TextStyle(color: Colors.black54, fontSize: 16.0),
        ),
        title: works.length > 0
            ? ListView.separated(
                shrinkWrap: true,
                physics: ScrollPhysics(),
                separatorBuilder: (_, index) => Divider(height: 0.0),
                itemCount: works.length,
                itemBuilder: (_, index) {
                  WorkModel _work = works[index];
                  return ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Chip(
                          label: Text(
                            '通常勤務',
                            style: TextStyle(fontSize: 12.0),
                          ),
                        ),
                        Text(
                          '${DateFormat('HH:mm').format(_work.startedAt)}',
                          style:
                              TextStyle(color: Colors.black87, fontSize: 16.0),
                        ),
                        _work.startedAt != _work.endedAt
                            ? Text(
                                '${DateFormat('HH:mm').format(_work.endedAt)}',
                                style: TextStyle(
                                    color: Colors.black87, fontSize: 16.0),
                              )
                            : Text('---:---'),
                        _work.startedAt != _work.endedAt
                            ? Text(
                                '00:00',
                                style: TextStyle(
                                    color: Colors.black87, fontSize: 16.0),
                              )
                            : Text('---:---'),
                        _work.startedAt != _work.endedAt
                            ? Text(
                                '${_work.workTime()}',
                                style: TextStyle(
                                    color: Colors.black87, fontSize: 16.0),
                              )
                            : Text('---:---'),
                        _work.startedAt != _work.endedAt
                            ? Text(
                                '00:00',
                                style: TextStyle(
                                    color: Colors.black87, fontSize: 16.0),
                              )
                            : Text('---:---'),
                        _work.startedAt != _work.endedAt
                            ? Text(
                                '00:00',
                                style: TextStyle(
                                    color: Colors.black87, fontSize: 16.0),
                              )
                            : Text('---:---'),
                        _work.startedAt != _work.endedAt
                            ? Text(
                                '00:00',
                                style: TextStyle(
                                    color: Colors.black87, fontSize: 16.0),
                              )
                            : Text('---:---'),
                      ],
                    ),
                    onTap: _work.startedAt != _work.endedAt
                        ? () {
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (_) => WorkDetailsDialog(work: _work),
                            );
                          }
                        : null,
                  );
                },
              )
            : Container(),
      ),
    );
  }
}

class WorkDetailsDialog extends StatefulWidget {
  final WorkModel work;

  WorkDetailsDialog({@required this.work});

  @override
  _WorkDetailsDialogState createState() => _WorkDetailsDialogState();
}

class _WorkDetailsDialogState extends State<WorkDetailsDialog> {
  WorkModel work;

  void _init() async {
    setState(() => work = widget.work);
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    final workProvider = Provider.of<WorkProvider>(context);

    return AlertDialog(
      content: Container(
        width: 450.0,
        child: ListView(
          shrinkWrap: true,
          children: [
            SizedBox(height: 16.0),
            Text(
              '修正したい日時に変更し、最後に「OK」ボタンを押してください。',
              style: TextStyle(color: Colors.black54, fontSize: 14.0),
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Icon(Icons.run_circle, color: Colors.blue),
                SizedBox(width: 4.0),
                Text('出勤時間', style: TextStyle(color: Colors.black54)),
              ],
            ),
            SizedBox(height: 4.0),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: CustomDateButton(
                    onPressed: () async {
                      final DateTime _selected = await showDatePicker(
                        context: context,
                        initialDate: work.startedAt,
                        firstDate: DateTime.now().subtract(Duration(days: 365)),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (_selected != null) {
                        DateTime _dateTime = DateTime.parse(
                            '${DateFormat(formatY_M_D).format(_selected)} ${DateFormat(formatHM).format(work.startedAt)}:00.000');
                        setState(() => work.startedAt = _dateTime);
                      }
                    },
                    labelText:
                        '${DateFormat(formatYMD).format(work.startedAt)}',
                  ),
                ),
                SizedBox(width: 4.0),
                Expanded(
                  flex: 2,
                  child: CustomTimeButton(
                    onPressed: () async {
                      final int _hour =
                          int.parse(DateFormat('H').format(work.startedAt));
                      final int _minute =
                          int.parse(DateFormat('m').format(work.startedAt));
                      final TimeOfDay _selected = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(hour: _hour, minute: _minute),
                      );
                      if (_selected != null) {
                        DateTime _dateTime = DateTime.parse(
                            '${DateFormat(formatY_M_D).format(work.startedAt)} ${_selected.format(context)}:00.000');
                        setState(() => work.startedAt = _dateTime);
                      }
                    },
                    labelText: '${DateFormat(formatHM).format(work.startedAt)}',
                  ),
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
                        children: [
                          Row(
                            children: [
                              Icon(Icons.run_circle, color: Colors.orange),
                              SizedBox(width: 4.0),
                              Text('休憩開始時間',
                                  style: TextStyle(color: Colors.black54)),
                            ],
                          ),
                          SizedBox(height: 4.0),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: CustomDateButton(
                                  onPressed: () async {
                                    final DateTime _selected =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: _breaks.startedAt,
                                      firstDate: DateTime.now()
                                          .subtract(Duration(days: 365)),
                                      lastDate: DateTime.now()
                                          .add(Duration(days: 365)),
                                    );
                                    if (_selected != null) {
                                      DateTime _dateTime = DateTime.parse(
                                          '${DateFormat(formatY_M_D).format(_selected)} ${DateFormat(formatHM).format(_breaks.startedAt)}:00.000');
                                      setState(
                                          () => _breaks.startedAt = _dateTime);
                                    }
                                  },
                                  labelText:
                                      '${DateFormat(formatYMD).format(_breaks.startedAt)}',
                                ),
                              ),
                              SizedBox(width: 4.0),
                              Expanded(
                                flex: 2,
                                child: CustomTimeButton(
                                  onPressed: () async {
                                    final int _hour = int.parse(DateFormat('H')
                                        .format(_breaks.startedAt));
                                    final int _minute = int.parse(
                                        DateFormat('m')
                                            .format(_breaks.startedAt));
                                    final TimeOfDay _selected =
                                        await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay(
                                          hour: _hour, minute: _minute),
                                    );
                                    if (_selected != null) {
                                      DateTime _dateTime = DateTime.parse(
                                          '${DateFormat(formatY_M_D).format(_breaks.startedAt)} ${_selected.format(context)}:00.000');
                                      setState(
                                          () => _breaks.startedAt = _dateTime);
                                    }
                                  },
                                  labelText:
                                      '${DateFormat(formatHM).format(_breaks.startedAt)}',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.0),
                          Row(
                            children: [
                              Icon(Icons.run_circle_outlined,
                                  color: Colors.orange),
                              SizedBox(width: 4.0),
                              Text('休憩終了時間',
                                  style: TextStyle(color: Colors.black54)),
                            ],
                          ),
                          SizedBox(height: 4.0),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: CustomDateButton(
                                  onPressed: () async {
                                    final DateTime _selected =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: _breaks.endedAt,
                                      firstDate: DateTime.now()
                                          .subtract(Duration(days: 365)),
                                      lastDate: DateTime.now()
                                          .add(Duration(days: 365)),
                                    );
                                    if (_selected != null) {
                                      DateTime _dateTime = DateTime.parse(
                                          '${DateFormat(formatY_M_D).format(_selected)} ${DateFormat(formatHM).format(_breaks.endedAt)}:00.000');
                                      setState(
                                          () => _breaks.endedAt = _dateTime);
                                    }
                                  },
                                  labelText:
                                      '${DateFormat(formatYMD).format(_breaks.endedAt)}',
                                ),
                              ),
                              SizedBox(width: 4.0),
                              Expanded(
                                flex: 2,
                                child: CustomTimeButton(
                                  onPressed: () async {
                                    final int _hour = int.parse(DateFormat('H')
                                        .format(_breaks.endedAt));
                                    final int _minute = int.parse(
                                        DateFormat('m')
                                            .format(_breaks.endedAt));
                                    final TimeOfDay _selected =
                                        await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay(
                                          hour: _hour, minute: _minute),
                                    );
                                    if (_selected != null) {
                                      DateTime _dateTime = DateTime.parse(
                                          '${DateFormat(formatY_M_D).format(_breaks.endedAt)} ${_selected.format(context)}:00.000');
                                      setState(
                                          () => _breaks.endedAt = _dateTime);
                                    }
                                  },
                                  labelText:
                                      '${DateFormat(formatHM).format(_breaks.endedAt)}',
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  )
                : Container(),
            SizedBox(height: 8.0),
            Row(
              children: [
                Icon(Icons.run_circle, color: Colors.red),
                SizedBox(width: 4.0),
                Text('退勤時間', style: TextStyle(color: Colors.black54)),
              ],
            ),
            SizedBox(height: 4.0),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: CustomDateButton(
                    onPressed: () async {
                      final DateTime _selected = await showDatePicker(
                        context: context,
                        initialDate: work.endedAt,
                        firstDate: DateTime.now().subtract(Duration(days: 365)),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (_selected != null) {
                        DateTime _dateTime = DateTime.parse(
                            '${DateFormat(formatY_M_D).format(_selected)} ${DateFormat(formatHM).format(work.endedAt)}:00.000');
                        setState(() => work.endedAt = _dateTime);
                      }
                    },
                    labelText: '${DateFormat(formatYMD).format(work.endedAt)}',
                  ),
                ),
                SizedBox(width: 4.0),
                Expanded(
                  flex: 2,
                  child: CustomTimeButton(
                    onPressed: () async {
                      final int _hour =
                          int.parse(DateFormat('H').format(work.endedAt));
                      final int _minute =
                          int.parse(DateFormat('m').format(work.endedAt));
                      final TimeOfDay _selected = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(hour: _hour, minute: _minute),
                      );
                      if (_selected != null) {
                        DateTime _dateTime = DateTime.parse(
                            '${DateFormat(formatY_M_D).format(work.endedAt)} ${_selected.format(context)}:00.000');
                        setState(() => work.endedAt = _dateTime);
                      }
                    },
                    labelText: '${DateFormat(formatHM).format(work.endedAt)}',
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
                  backgroundColor: Colors.grey,
                  labelText: 'キャンセル',
                ),
                CustomTextButton(
                  onPressed: () async {
                    if (!await workProvider.update(work: work)) {
                      return;
                    }
                    Navigator.pop(context);
                  },
                  backgroundColor: Colors.blue,
                  labelText: 'OK',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
