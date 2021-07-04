import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/breaks.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/work.dart';
import 'package:hatarakujikan_web/models/work_state.dart';
import 'package:hatarakujikan_web/providers/work.dart';
import 'package:hatarakujikan_web/providers/work_state.dart';
import 'package:hatarakujikan_web/widgets/custom_date_button.dart';
import 'package:hatarakujikan_web/widgets/custom_icon_label.dart';
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
                    _breakTime = _work.breakTime(group);
                    _workTime = _work.workTime(group);
                    List<String> _legalList = legalList(
                      workTime: _work.workTime(group),
                      legal: group.legal,
                    );
                    _legalTime = _legalList.first;
                    _nonLegalTime = _legalList.last;
                    List<String> _nightList = nightList(
                      startedAt: _work.startedAt,
                      endedAt: _work.endedAt,
                      nightStart: group.nightStart,
                      nightEnd: group.nightEnd,
                    );
                    _nightTime = _nightList.last;
                  }
                  return ListTile(
                    leading: Chip(
                      backgroundColor: _chipColor,
                      label: Text('${_work.state}',
                          style: TextStyle(fontSize: 12.0)),
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
                        IconButton(
                          onPressed: _work.startedAt != _work.endedAt
                              ? () => showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (_) => WorkDetailsDialog(
                                      workProvider: workProvider,
                                      work: _work,
                                    ),
                                  )
                              : null,
                          icon: Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),
                        ),
                        IconButton(
                          onPressed: () => showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (_) => WorkLocationDialog(work: _work),
                          ),
                          icon: Icon(
                            Icons.location_on,
                            color: Colors.blue,
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

  WorkDetailsDialog({
    @required this.workProvider,
    @required this.work,
  });

  @override
  _WorkDetailsDialogState createState() => _WorkDetailsDialogState();
}

class _WorkDetailsDialogState extends State<WorkDetailsDialog> {
  DateTime _firstDate = DateTime.now().subtract(Duration(days: 365));
  DateTime _lastDate = DateTime.now().add(Duration(days: 365));
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
    return AlertDialog(
      content: Container(
        width: 450.0,
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
            CustomIconLabel(
              icon: Icon(Icons.label, color: Colors.black54),
              label: '勤務状況',
            ),
            SizedBox(height: 4.0),
            Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                backgroundColor: Colors.grey.shade300,
                label: Text('${work.state}'),
              ),
            ),
            SizedBox(height: 8.0),
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
                        initialDate: work.startedAt,
                        firstDate: _firstDate,
                        lastDate: _lastDate,
                      );
                      if (_selected != null) {
                        String _date =
                            '${DateFormat('yyyy-MM-dd').format(_selected)}';
                        String _time =
                            '${DateFormat('HH:mm').format(work.startedAt)}:00.000';
                        DateTime _dateTime = DateTime.parse('$_date $_time');
                        setState(() => work.startedAt = _dateTime);
                      }
                    },
                    label: '${DateFormat('yyyy/MM/dd').format(work.startedAt)}',
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
                        DateTime _dateTime = DateTime.parse('$_date $_time');
                        setState(() => work.startedAt = _dateTime);
                      }
                    },
                    label: '${DateFormat('HH:mm').format(work.startedAt)}',
                  ),
                ),
              ],
            ),
            Text(
              '記録端末: ${work.startedDev}',
              style: TextStyle(color: Colors.black54, fontSize: 14.0),
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
                          CustomIconLabel(
                            icon: Icon(Icons.run_circle, color: Colors.orange),
                            label: '休憩開始日時',
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
                          Text(
                            '記録端末: ${_breaks.startedDev}',
                            style: TextStyle(
                                color: Colors.black54, fontSize: 14.0),
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
                          Text(
                            '記録端末: ${_breaks.endedDev}',
                            style: TextStyle(
                                color: Colors.black54, fontSize: 14.0),
                          ),
                        ],
                      );
                    },
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
                        initialDate: work.endedAt,
                        firstDate: _firstDate,
                        lastDate: _lastDate,
                      );
                      if (_selected != null) {
                        String _date =
                            '${DateFormat('yyyy-MM-dd').format(_selected)}';
                        String _time =
                            '${DateFormat('HH:mm').format(work.endedAt)}:00.000';
                        DateTime _dateTime = DateTime.parse('$_date $_time');
                        setState(() => work.endedAt = _dateTime);
                      }
                    },
                    label: '${DateFormat('yyyy/MM/dd').format(work.endedAt)}',
                  ),
                ),
                SizedBox(width: 4.0),
                Expanded(
                  flex: 2,
                  child: CustomTimeButton(
                    onPressed: () async {
                      String _hour = '${DateFormat('H').format(work.endedAt)}';
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
                        DateTime _dateTime = DateTime.parse('$_date $_time');
                        setState(() => work.endedAt = _dateTime);
                      }
                    },
                    label: '${DateFormat('HH:mm').format(work.endedAt)}',
                  ),
                ),
              ],
            ),
            Text(
              '記録端末: ${work.endedDev}',
              style: TextStyle(color: Colors.black54, fontSize: 14.0),
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
                        Navigator.pop(context);
                      },
                      color: Colors.red,
                      label: '削除する',
                    ),
                    SizedBox(width: 4.0),
                    CustomTextButton(
                      onPressed: () async {
                        if (!await widget.workProvider.update(work: work)) {
                          return;
                        }
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

  void _onMapCreated(GoogleMapController controller) {
    setState(() => mapController = controller);
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
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    widget.work.startedLat,
                    widget.work.startedLon,
                  ),
                  zoom: 17.0,
                ),
                compassEnabled: false,
                rotateGesturesEnabled: false,
                tiltGesturesEnabled: false,
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
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
            CustomIconLabel(
              icon: Icon(Icons.label, color: Colors.black54),
              label: '勤務状況',
            ),
            SizedBox(height: 4.0),
            Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                backgroundColor: _chipColor,
                label: Text('${workState.state}'),
              ),
            ),
            SizedBox(height: 8.0),
            Text('登録日', style: TextStyle(color: Colors.black54)),
            SizedBox(height: 4.0),
            Text('${DateFormat('yyyy/MM/dd').format(workState.startedAt)}'),
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
