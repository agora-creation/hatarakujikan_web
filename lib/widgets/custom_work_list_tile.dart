import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hatarakujikan_web/helpers/define.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/breaks.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/work.dart';
import 'package:hatarakujikan_web/models/work_shift.dart';
import 'package:hatarakujikan_web/providers/work.dart';
import 'package:hatarakujikan_web/widgets/custom_checkbox_list_tile.dart';
import 'package:hatarakujikan_web/widgets/custom_date_button.dart';
import 'package:hatarakujikan_web/widgets/custom_label_column.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';
import 'package:hatarakujikan_web/widgets/custom_time_button.dart';
import 'package:hatarakujikan_web/widgets/custom_work_table.dart';

class CustomWorkListTile extends StatelessWidget {
  final WorkProvider workProvider;
  final DateTime? day;
  final List<WorkModel>? dayWorks;
  final WorkShiftModel? dayWorkShift;
  final GroupModel? group;

  CustomWorkListTile({
    required this.workProvider,
    this.day,
    this.dayWorks,
    this.dayWorkShift,
    this.group,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kBottomBorderDecoration,
      child: ListTile(
        leading: Text(
          dateText('dd (E)', day),
          style: kListDayTextStyle,
        ),
        title: dayWorks!.length > 0
            ? ListView.separated(
                shrinkWrap: true,
                physics: ScrollPhysics(),
                separatorBuilder: (_, index) => Divider(height: 0.0),
                itemCount: dayWorks!.length,
                itemBuilder: (_, index) {
                  WorkModel _work = dayWorks![index];
                  if (_work.startedAt != _work.endedAt) {
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
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_startTime, style: kListTimeTextStyle),
                          Text(_endTime, style: kListTimeTextStyle),
                          Text(_breakTime, style: kListTimeTextStyle),
                          Text(_workTime, style: kListTimeTextStyle),
                          Text(_legalTime, style: kListTimeTextStyle),
                          Text(_nonLegalTime, style: kListTimeTextStyle),
                          Text(_nightTime, style: kListTimeTextStyle),
                          IconButton(
                            onPressed: () => showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (_) => EditWorkDialog(
                                workProvider: workProvider,
                                work: _work,
                                group: group!,
                              ),
                            ),
                            icon: Icon(Icons.edit, color: Colors.blue),
                          ),
                          IconButton(
                            onPressed: () => showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (_) => LocationWorkDialog(work: _work),
                            ),
                            icon: Icon(Icons.location_on, color: Colors.blue),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              )
            : dayWorkShift != null
                ? ListTile(
                    leading: Chip(
                      backgroundColor: dayWorkShift?.stateColor2(),
                      label: Text(
                        dayWorkShift!.state,
                        style: TextStyle(fontSize: 12.0),
                      ),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('00:00', style: kListTime2TextStyle),
                        Text('00:00', style: kListTime2TextStyle),
                        Text('00:00', style: kListTime2TextStyle),
                        Text('00:00', style: kListTime2TextStyle),
                        Text('00:00', style: kListTime2TextStyle),
                        Text('00:00', style: kListTime2TextStyle),
                        Text('00:00', style: kListTime2TextStyle),
                        IconButton(
                          onPressed: null,
                          icon: Icon(
                            Icons.edit,
                            color: Colors.transparent,
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

class EditWorkDialog extends StatefulWidget {
  final WorkProvider workProvider;
  final WorkModel work;
  final GroupModel group;

  EditWorkDialog({
    required this.workProvider,
    required this.work,
    required this.group,
  });

  @override
  _EditWorkDialogState createState() => _EditWorkDialogState();
}

class _EditWorkDialogState extends State<EditWorkDialog> {
  WorkModel? _work;
  bool _isBreaks = false;
  DateTime _breakStartedAt = DateTime.now();
  DateTime _breakEndedAt = DateTime.now();

  void _init() async {
    setState(() {
      _work = widget.work;
      _breakStartedAt = widget.work.startedAt;
      _breakEndedAt = widget.work.startedAt;
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
              '修正したい日時に変更し、最後に「修正する」ボタンを押してください。',
              style: kDefaultTextStyle,
            ),
            Text(
              'この記録を削除したい場合は、「削除する」ボタンを押してください。',
              style: kDefaultTextStyle,
            ),
            SizedBox(height: 16.0),
            CustomLabelColumn(
              label: '勤務状況',
              child: Chip(
                backgroundColor: Colors.grey.shade300,
                label: Text(_work?.state ?? ''),
              ),
            ),
            Divider(),
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
                          initialDate: _work?.startedAt ?? DateTime.now(),
                          firstDate: kDayFirstDate,
                          lastDate: kDayLastDate,
                        );
                        if (_selected != null) {
                          _selected = rebuildDate(_selected, _work?.startedAt);
                          setState(() => _work?.startedAt = _selected!);
                        }
                      },
                      label: dateText('yyyy/MM/dd', _work?.startedAt),
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
                            hour: timeToInt(_work?.startedAt)[0],
                            minute: timeToInt(_work?.startedAt)[1],
                          ),
                        );
                        if (_selected != null) {
                          // DateTime? _dateTime = rebuildTime(
                          //   context,
                          //   _work?.startedAt,
                          //   _selected,
                          // );
                          // setState(() => _work?.startedAt = _dateTime);
                        }
                      },
                      label: dateText('HH:mm', _work?.startedAt),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.0),
            _work!.breaks.length > 0
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    itemCount: _work!.breaks.length,
                    itemBuilder: (_, index) {
                      BreaksModel _breaks = _work!.breaks[index];
                      return Column(
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
                                      DateTime? _selected =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: _breaks.startedAt,
                                        firstDate: kDayFirstDate,
                                        lastDate: kDayLastDate,
                                      );
                                      if (_selected != null) {
                                        _selected = rebuildDate(
                                            _selected, _breaks.startedAt);
                                        setState(() =>
                                            _breaks.startedAt = _selected!);
                                      }
                                    },
                                    label: dateText(
                                        'yyyy/MM/dd', _breaks.startedAt),
                                  ),
                                ),
                                SizedBox(width: 4.0),
                                Expanded(
                                  flex: 2,
                                  child: CustomTimeButton(
                                    onPressed: () async {
                                      TimeOfDay? _selected =
                                          await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay(
                                          hour: timeToInt(_breaks.startedAt)[0],
                                          minute:
                                              timeToInt(_breaks.startedAt)[1],
                                        ),
                                      );
                                      if (_selected != null) {
                                        // DateTime _dateTime = rebuildTime(
                                        //   context,
                                        //   _breaks.startedAt,
                                        //   _selected,
                                        // );
                                        // setState(() =>
                                        //     _breaks.startedAt = _dateTime);
                                      }
                                    },
                                    label: dateText('HH:mm', _breaks.startedAt),
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
                                      DateTime? _selected =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: _breaks.endedAt,
                                        firstDate: kDayFirstDate,
                                        lastDate: kDayLastDate,
                                      );
                                      if (_selected != null) {
                                        _selected = rebuildDate(
                                            _selected, _breaks.endedAt);
                                        setState(
                                            () => _breaks.endedAt = _selected!);
                                      }
                                    },
                                    label:
                                        dateText('yyyy/MM/dd', _breaks.endedAt),
                                  ),
                                ),
                                SizedBox(width: 4.0),
                                Expanded(
                                  flex: 2,
                                  child: CustomTimeButton(
                                    onPressed: () async {
                                      TimeOfDay? _selected =
                                          await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay(
                                          hour: timeToInt(_breaks.endedAt)[0],
                                          minute: timeToInt(_breaks.endedAt)[1],
                                        ),
                                      );
                                      if (_selected != null) {
                                        // DateTime? _dateTime = rebuildTime(
                                        //   context,
                                        //   _breaks.endedAt,
                                        //   _selected,
                                        // );
                                        // setState(
                                        //     () => _breaks.endedAt = _dateTime);
                                      }
                                    },
                                    label: dateText('HH:mm', _breaks.endedAt),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomCheckboxListTile(
                        onChanged: (value) {
                          setState(() => _isBreaks = value!);
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
                                            DateTime? _selected =
                                                await showDatePicker(
                                              context: context,
                                              initialDate: _breakStartedAt,
                                              firstDate: kDayFirstDate,
                                              lastDate: kDayLastDate,
                                            );
                                            if (_selected != null) {
                                              _selected = rebuildDate(
                                                  _selected, _breakStartedAt);
                                              setState(() =>
                                                  _breakStartedAt = _selected!);
                                            }
                                          },
                                          label: dateText(
                                              'yyyy/MM/dd', _breakStartedAt),
                                        ),
                                      ),
                                      SizedBox(width: 4.0),
                                      Expanded(
                                        flex: 2,
                                        child: CustomTimeButton(
                                          onPressed: () async {
                                            TimeOfDay? _selected =
                                                await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay(
                                                hour: timeToInt(
                                                    _breakStartedAt)[0],
                                                minute: timeToInt(
                                                    _breakStartedAt)[1],
                                              ),
                                            );
                                            if (_selected != null) {
                                              // DateTime _dateTime = rebuildTime(
                                              //   context,
                                              //   _breakStartedAt,
                                              //   _selected,
                                              // );
                                              // setState(() =>
                                              //     _breakStartedAt = _dateTime);
                                            }
                                          },
                                          label: dateText(
                                              'HH:mm', _breakStartedAt),
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
                                            DateTime? _selected =
                                                await showDatePicker(
                                              context: context,
                                              initialDate: _breakEndedAt,
                                              firstDate: kDayFirstDate,
                                              lastDate: kDayLastDate,
                                            );
                                            if (_selected != null) {
                                              _selected = rebuildDate(
                                                  _selected, _breakEndedAt);
                                              setState(() =>
                                                  _breakEndedAt = _selected!);
                                            }
                                          },
                                          label: dateText(
                                              'yyyy/MM/dd', _breakEndedAt),
                                        ),
                                      ),
                                      SizedBox(width: 4.0),
                                      Expanded(
                                        flex: 2,
                                        child: CustomTimeButton(
                                          onPressed: () async {
                                            TimeOfDay? _selected =
                                                await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay(
                                                hour:
                                                    timeToInt(_breakEndedAt)[0],
                                                minute:
                                                    timeToInt(_breakEndedAt)[1],
                                              ),
                                            );
                                            if (_selected != null) {
                                              // DateTime _dateTime = rebuildTime(
                                              //   context,
                                              //   _breakEndedAt,
                                              //   _selected,
                                              // );
                                              // setState(() =>
                                              //     _breakEndedAt = _dateTime);
                                            }
                                          },
                                          label:
                                              dateText('HH:mm', _breakEndedAt),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                    ],
                  ),
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
                          initialDate: _work?.endedAt ?? DateTime.now(),
                          firstDate: kDayFirstDate,
                          lastDate: kDayLastDate,
                        );
                        if (_selected != null) {
                          _selected = rebuildDate(_selected, _work?.endedAt);
                          setState(() => _work?.endedAt = _selected!);
                        }
                      },
                      label: dateText('yyyy/MM/dd', _work?.endedAt),
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
                            hour: timeToInt(_work?.endedAt)[0],
                            minute: timeToInt(_work?.endedAt)[1],
                          ),
                        );
                        if (_selected != null) {
                          // DateTime _dateTime = rebuildTime(
                          //   context,
                          //   _work?.endedAt,
                          //   _selected,
                          // );
                          // setState(() => _work?.endedAt = _dateTime);
                        }
                      },
                      label: dateText('HH:mm', _work?.endedAt),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.0),
            CustomWorkTable(
              group: widget.group,
              work: _work!,
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
                        widget.workProvider.delete(id: _work?.id ?? '');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('勤務データを削除しました')),
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
                          work: _work!,
                          isBreaks: _isBreaks,
                          breakStartedAt: _breakStartedAt,
                          breakEndedAt: _breakEndedAt,
                        )) {
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('勤務データを修正しました')),
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

class LocationWorkDialog extends StatefulWidget {
  final WorkModel work;

  LocationWorkDialog({required this.work});

  @override
  _LocationWorkDialogState createState() => _LocationWorkDialogState();
}

class _LocationWorkDialogState extends State<LocationWorkDialog> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};

  void _init() async {
    WorkModel? _work = widget.work;
    setState(() {
      markers.add(Marker(
        markerId: MarkerId('start_${_work.id}'),
        position: LatLng(
          _work.startedLat,
          _work.startedLon,
        ),
        infoWindow: InfoWindow(
          title: '出勤日時',
          snippet: dateText('yyyy/MM/dd HH:mm', _work.startedAt),
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
      markers.add(Marker(
        markerId: MarkerId('end_${_work.id}'),
        position: LatLng(
          _work.endedLat,
          _work.endedLon,
        ),
        infoWindow: InfoWindow(
          title: '退勤日時',
          snippet: dateText('yyyy/MM/dd HH:mm', _work.endedAt),
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
            CustomLabelColumn(
              label: '記録した位置情報',
              child: Container(
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
