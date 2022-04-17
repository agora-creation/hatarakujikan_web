import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hatarakujikan_web/helpers/define.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/breaks.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/models/work.dart';
import 'package:hatarakujikan_web/models/work_shift.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/providers/work.dart';
import 'package:hatarakujikan_web/widgets/custom_dropdown_button.dart';
import 'package:hatarakujikan_web/widgets/custom_google_map.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button_mini.dart';
import 'package:hatarakujikan_web/widgets/datetime_form_field.dart';

const TextStyle timeStyle = TextStyle(
  color: Colors.black87,
  fontSize: 15.0,
);

const TextStyle timeStyle2 = TextStyle(
  color: Colors.transparent,
  fontSize: 15.0,
);

class WorkList extends StatelessWidget {
  final GroupProvider groupProvider;
  final WorkProvider workProvider;
  final DateTime day;
  final List<WorkModel> dayInWorks;
  final WorkShiftModel? dayInWorkShift;
  final GroupModel? group;

  WorkList({
    required this.groupProvider,
    required this.workProvider,
    required this.day,
    required this.dayInWorks,
    this.dayInWorkShift,
    this.group,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kBottomBorderDecoration,
      child: ListTile(
        leading: Text(
          dateText('dd (E)', day),
          style: TextStyle(
            color: Colors.black54,
            fontSize: 15.0,
          ),
        ),
        title: dayInWorks.length > 0
            ? ListView.separated(
                shrinkWrap: true,
                physics: ScrollPhysics(),
                separatorBuilder: (_, index) => Divider(height: 0.0),
                itemCount: dayInWorks.length,
                itemBuilder: (_, index) {
                  WorkModel _work = dayInWorks[index];
                  if (_work.startedAt == _work.endedAt) return Container();
                  String _startTime = _work.startTime(group);
                  String _endTime = _work.endTime(group);
                  String _breakTime = _work.breakTimes(group)[0];
                  String _workTime = _work.workTime(group);
                  List<String> _legalTimes = _work.legalTimes(group);
                  String _legalTime = _legalTimes.first;
                  String _nonLegalTime = _legalTimes.last;
                  List<String> _nightTimes = _work.nightTimes(group);
                  String _nightTime = _nightTimes.last;
                  return ListTile(
                    leading: Chip(
                      backgroundColor: Colors.grey.shade300,
                      label: Text(
                        _work.state,
                        style: TextStyle(
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_startTime, style: timeStyle),
                        Text(_endTime, style: timeStyle),
                        Text(_breakTime, style: timeStyle),
                        Text(_workTime, style: timeStyle),
                        Text(_legalTime, style: timeStyle),
                        Text(_nonLegalTime, style: timeStyle),
                        Text(_nightTime, style: timeStyle),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (_) => EditDialog(
                                groupProvider: groupProvider,
                                workProvider: workProvider,
                                work: _work,
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.location_on, color: Colors.blue),
                          onPressed: () {
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (_) => LocationDialog(work: _work),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              )
            : dayInWorkShift != null
                ? ListTile(
                    leading: Chip(
                      backgroundColor: dayInWorkShift?.stateColor2(),
                      label: Text(
                        dayInWorkShift?.state ?? '',
                        style: TextStyle(fontSize: 12.0),
                      ),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('00:00', style: timeStyle2),
                        Text('00:00', style: timeStyle2),
                        Text('00:00', style: timeStyle2),
                        Text('00:00', style: timeStyle2),
                        Text('00:00', style: timeStyle2),
                        Text('00:00', style: timeStyle2),
                        Text('00:00', style: timeStyle2),
                        Icon(Icons.edit, color: Colors.transparent),
                        Icon(Icons.map, color: Colors.transparent),
                      ],
                    ),
                  )
                : Container(),
      ),
    );
  }
}

class EditDialog extends StatefulWidget {
  final GroupProvider groupProvider;
  final WorkProvider workProvider;
  final WorkModel work;

  EditDialog({
    required this.groupProvider,
    required this.workProvider,
    required this.work,
  });

  @override
  _EditDialogState createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
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
        work = widget.work;
        breaks = widget.work.breaks;
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
                DateTime _dateTime = rebuildTime(
                  context,
                  work?.endedAt,
                  _time,
                );
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
                Row(
                  children: [
                    CustomTextButton(
                      label: '削除する',
                      color: Colors.red,
                      onPressed: () async {
                        if (!await widget.workProvider.delete(id: work?.id)) {
                          return;
                        }
                        customSnackBar(context, '勤務データを削除しました');
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(width: 4.0),
                    CustomTextButton(
                      label: '保存する',
                      color: Colors.blue,
                      onPressed: () async {
                        if (!await widget.workProvider.update(
                          work: work,
                          breaks: breaks,
                        )) {
                          return;
                        }
                        customSnackBar(context, '勤務日時を保存しました');
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

class LocationDialog extends StatefulWidget {
  final WorkModel work;

  LocationDialog({required this.work});

  @override
  State<LocationDialog> createState() => _LocationDialogState();
}

class _LocationDialogState extends State<LocationDialog> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};

  void _init() async {
    if (mounted) {
      setState(() {
        markers.add(Marker(
          markerId: MarkerId('start_${widget.work.id}'),
          position: LatLng(
            widget.work.startedLat,
            widget.work.startedLon,
          ),
          infoWindow: InfoWindow(
            title: '出勤日時',
            snippet: dateText('yyyy/MM/dd HH:mm', widget.work.startedAt),
          ),
        ));
        markers.add(Marker(
          markerId: MarkerId('end_${widget.work.id}'),
          position: LatLng(
            widget.work.endedLat,
            widget.work.endedLon,
          ),
          infoWindow: InfoWindow(
            title: '退勤日時',
            snippet: dateText('yyyy/MM/dd HH:mm', widget.work.endedAt),
          ),
        ));
        widget.work.breaks.forEach((e) {
          markers.add(Marker(
            markerId: MarkerId('start_${e.id}'),
            position: LatLng(
              e.startedLat,
              e.startedLon,
            ),
            infoWindow: InfoWindow(
              title: '休憩開始日時',
              snippet: dateText('yyyy/MM/dd HH:mm', e.startedAt),
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
              snippet: dateText('yyyy/MM/dd HH:mm', e.endedAt),
            ),
          ));
        });
      });
    }
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
        width: 650.0,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              '打刻した場所を表示しています。',
              style: kDialogTextStyle,
            ),
            SizedBox(height: 16.0),
            CustomGoogleMap(
              height: 350.0,
              markers: markers,
              onMapCreated: _onMapCreated,
              lat: widget.work.startedLat,
              lon: widget.work.startedLon,
              area: false,
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
