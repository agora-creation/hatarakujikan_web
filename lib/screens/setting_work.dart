import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/pdf_api.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold.dart';
import 'package:hatarakujikan_web/widgets/custom_checkbox_list_tile.dart';
import 'package:hatarakujikan_web/widgets/custom_dropdown_button.dart';
import 'package:hatarakujikan_web/widgets/custom_icon_label.dart';
import 'package:hatarakujikan_web/widgets/custom_label_column.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';
import 'package:hatarakujikan_web/widgets/custom_text_icon_button.dart';
import 'package:hatarakujikan_web/widgets/custom_text_icon_button2.dart';
import 'package:hatarakujikan_web/widgets/custom_week_checkbox.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class SettingWorkScreen extends StatelessWidget {
  static const String id = 'group_work';

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);

    return CustomAdminScaffold(
      groupProvider: groupProvider,
      selectedRoute: id,
      body: SettingWorkPanel(groupProvider: groupProvider),
    );
  }
}

class SettingWorkPanel extends StatefulWidget {
  final GroupProvider groupProvider;

  SettingWorkPanel({@required this.groupProvider});

  @override
  _SettingWorkPanelState createState() => _SettingWorkPanelState();
}

class _SettingWorkPanelState extends State<SettingWorkPanel> {
  String _roundStartType;
  int _roundStartNum;
  String _roundEndType;
  int _roundEndNum;
  String _roundBreakStartType;
  int _roundBreakStartNum;
  String _roundBreakEndType;
  int _roundBreakEndNum;
  String _roundWorkType;
  int _roundWorkNum;
  int _legal;
  String _nightStart;
  String _nightEnd;
  String _workStart;
  String _workEnd;
  List<String> _holidays;
  List<DateTime> _holidays2;
  bool _autoBreak;

  void _init() async {
    _roundStartType = widget.groupProvider.group?.roundStartType;
    _roundStartNum = widget.groupProvider.group?.roundStartNum;
    _roundEndType = widget.groupProvider.group?.roundEndType;
    _roundEndNum = widget.groupProvider.group?.roundEndNum;
    _roundBreakStartType = widget.groupProvider.group?.roundBreakStartType;
    _roundBreakStartNum = widget.groupProvider.group?.roundBreakStartNum;
    _roundBreakEndType = widget.groupProvider.group?.roundBreakEndType;
    _roundBreakEndNum = widget.groupProvider.group?.roundBreakEndNum;
    _roundWorkType = widget.groupProvider.group?.roundWorkType;
    _roundWorkNum = widget.groupProvider.group?.roundWorkNum;
    _legal = widget.groupProvider.group?.legal;
    _nightStart = widget.groupProvider.group?.nightStart;
    _nightEnd = widget.groupProvider.group?.nightEnd;
    _workStart = widget.groupProvider.group?.workStart;
    _workEnd = widget.groupProvider.group?.workEnd;
    _holidays = widget.groupProvider.group?.holidays;
    _holidays2 = widget.groupProvider.group?.holidays2;
    _autoBreak = widget.groupProvider.group?.autoBreak;
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '勤怠ルール設定',
          style: kAdminTitleTextStyle,
        ),
        Text(
          '各勤務時間の計算をする際に必要な項目を設定できます。',
          style: kAdminSubTitleTextStyle,
        ),
        SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(),
            Row(
              children: [
                CustomTextIconButton(
                  onPressed: () async {
                    await PdfApi.qrcode(group: widget.groupProvider.group);
                  },
                  color: Colors.redAccent,
                  iconData: Icons.qr_code,
                  label: 'QRコード出力',
                ),
                SizedBox(width: 4.0),
                CustomTextIconButton(
                  onPressed: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (_) => ConfirmDialog(
                        groupProvider: widget.groupProvider,
                        roundStartType: _roundStartType,
                        roundStartNum: _roundStartNum,
                        roundEndType: _roundEndType,
                        roundEndNum: _roundEndNum,
                        roundBreakStartType: _roundBreakStartType,
                        roundBreakStartNum: _roundBreakStartNum,
                        roundBreakEndType: _roundBreakEndType,
                        roundBreakEndNum: _roundBreakEndNum,
                        roundWorkType: _roundWorkType,
                        roundWorkNum: _roundWorkNum,
                        legal: _legal,
                        nightStart: _nightStart,
                        nightEnd: _nightEnd,
                        workStart: _workStart,
                        workEnd: _workEnd,
                        holidays: _holidays,
                        holidays2: _holidays2,
                        autoBreak: _autoBreak,
                      ),
                    );
                  },
                  color: Colors.blue,
                  iconData: Icons.save,
                  label: '設定を保存',
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 8.0),
        Expanded(
          child: ListView(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomIconLabel(
                    iconData: Icons.access_time,
                    label: '時間のまるめ',
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(''),
                          Text('出勤時間　　'),
                        ],
                      ),
                      SizedBox(width: 8.0),
                      CustomLabelColumn(
                        label: 'まるめ方',
                        child: CustomDropdownButton(
                          isExpanded: false,
                          value: _roundStartType,
                          onChanged: (value) {
                            setState(() => _roundStartType = value);
                          },
                          items: roundTypeList.map((value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: kDefaultTextStyle,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(width: 8.0),
                      CustomLabelColumn(
                        label: 'まるめ分数',
                        child: CustomDropdownButton(
                          isExpanded: false,
                          value: _roundStartNum,
                          onChanged: (value) {
                            setState(() => _roundStartNum = value);
                          },
                          items: roundNumList.map((value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(
                                '$value分',
                                style: kDefaultTextStyle,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(''),
                          Text('退勤時間　　'),
                        ],
                      ),
                      SizedBox(width: 8.0),
                      CustomLabelColumn(
                        label: 'まるめ方',
                        child: CustomDropdownButton(
                          isExpanded: false,
                          value: _roundEndType,
                          onChanged: (value) {
                            setState(() => _roundEndType = value);
                          },
                          items: roundTypeList.map((value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: kDefaultTextStyle,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(width: 8.0),
                      CustomLabelColumn(
                        label: 'まるめ分数',
                        child: CustomDropdownButton(
                          isExpanded: false,
                          value: _roundEndNum,
                          onChanged: (value) {
                            setState(() => _roundEndNum = value);
                          },
                          items: roundNumList.map((value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(
                                '$value分',
                                style: kDefaultTextStyle,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(''),
                          Text('休憩開始時間'),
                        ],
                      ),
                      SizedBox(width: 8.0),
                      CustomLabelColumn(
                        label: 'まるめ方',
                        child: CustomDropdownButton(
                          isExpanded: false,
                          value: _roundBreakStartType,
                          onChanged: (value) {
                            setState(() => _roundBreakStartType = value);
                          },
                          items: roundTypeList.map((value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: kDefaultTextStyle,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(width: 8.0),
                      CustomLabelColumn(
                        label: 'まるめ分数',
                        child: CustomDropdownButton(
                          isExpanded: false,
                          value: _roundBreakStartNum,
                          onChanged: (value) {
                            setState(() => _roundBreakStartNum = value);
                          },
                          items: roundNumList.map((value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(
                                '$value分',
                                style: kDefaultTextStyle,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(''),
                          Text('休憩終了時間'),
                        ],
                      ),
                      SizedBox(width: 8.0),
                      CustomLabelColumn(
                        label: 'まるめ方',
                        child: CustomDropdownButton(
                          isExpanded: false,
                          value: _roundBreakEndType,
                          onChanged: (value) {
                            setState(() => _roundBreakEndType = value);
                          },
                          items: roundTypeList.map((value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: kDefaultTextStyle,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(width: 8.0),
                      CustomLabelColumn(
                        label: 'まるめ分数',
                        child: CustomDropdownButton(
                          isExpanded: false,
                          value: _roundBreakEndNum,
                          onChanged: (value) {
                            setState(() => _roundBreakEndNum = value);
                          },
                          items: roundNumList.map((value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(
                                '$value分',
                                style: kDefaultTextStyle,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(''),
                          Text('勤務時間　　'),
                        ],
                      ),
                      SizedBox(width: 8.0),
                      CustomLabelColumn(
                        label: 'まるめ方',
                        child: CustomDropdownButton(
                          isExpanded: false,
                          value: _roundWorkType,
                          onChanged: (value) {
                            setState(() => _roundWorkType = value);
                          },
                          items: roundTypeList.map((value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: kDefaultTextStyle,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(width: 8.0),
                      CustomLabelColumn(
                        label: 'まるめ分数',
                        child: CustomDropdownButton(
                          isExpanded: false,
                          value: _roundWorkNum,
                          onChanged: (value) {
                            setState(() => _roundWorkNum = value);
                          },
                          items: roundNumList.map((value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(
                                '$value分',
                                style: kDefaultTextStyle,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  CustomIconLabel(
                    iconData: Icons.access_time,
                    label: '法定労働時間',
                  ),
                  SizedBox(height: 8.0),
                  CustomDropdownButton(
                    isExpanded: false,
                    value: _legal,
                    onChanged: (value) {
                      setState(() => _legal = value);
                    },
                    items: legalList.map((value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(
                          '$value時間',
                          style: kDefaultTextStyle,
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16.0),
                  CustomIconLabel(
                    iconData: Icons.access_time,
                    label: '深夜時間帯',
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('開始', style: TextStyle(fontSize: 14.0)),
                          CustomTextIconButton2(
                            onPressed: () async {
                              List<String> _hm = _nightStart.split(':');
                              TimeOfDay _selected = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(
                                  hour: int.parse(_hm.first),
                                  minute: int.parse(_hm.last),
                                ),
                              );
                              if (_selected != null) {
                                String _time = '${_selected.format(context)}';
                                setState(() => _nightStart = _time);
                              }
                            },
                            iconData: Icons.access_time,
                            label: _nightStart,
                          ),
                        ],
                      ),
                      SizedBox(width: 8.0),
                      Column(
                        children: [
                          Text(''),
                          Text('〜'),
                        ],
                      ),
                      SizedBox(width: 8.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('終了', style: TextStyle(fontSize: 14.0)),
                          CustomTextIconButton2(
                            onPressed: () async {
                              List<String> _hm = _nightEnd.split(':');
                              TimeOfDay _selected = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(
                                  hour: int.parse(_hm.first),
                                  minute: int.parse(_hm.last),
                                ),
                              );
                              if (_selected != null) {
                                String _time = '${_selected.format(context)}';
                                setState(() => _nightEnd = _time);
                              }
                            },
                            iconData: Icons.access_time,
                            label: _nightEnd,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  CustomIconLabel(
                    iconData: Icons.access_time,
                    label: '所定労働時間帯',
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('開始', style: TextStyle(fontSize: 14.0)),
                          CustomTextIconButton2(
                            onPressed: () async {
                              List<String> _hm = _workStart.split(':');
                              TimeOfDay _selected = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(
                                  hour: int.parse(_hm.first),
                                  minute: int.parse(_hm.last),
                                ),
                              );
                              if (_selected != null) {
                                String _time = '${_selected.format(context)}';
                                setState(() => _workStart = _time);
                              }
                            },
                            iconData: Icons.access_time,
                            label: _workStart,
                          ),
                        ],
                      ),
                      SizedBox(width: 8.0),
                      Column(
                        children: [
                          Text(''),
                          Text('〜'),
                        ],
                      ),
                      SizedBox(width: 8.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('終了', style: TextStyle(fontSize: 14.0)),
                          CustomTextIconButton2(
                            onPressed: () async {
                              List<String> _hm = _workEnd.split(':');
                              TimeOfDay _selected = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(
                                  hour: int.parse(_hm.first),
                                  minute: int.parse(_hm.last),
                                ),
                              );
                              if (_selected != null) {
                                String _time = '${_selected.format(context)}';
                                setState(() => _workEnd = _time);
                              }
                            },
                            iconData: Icons.access_time,
                            label: _workEnd,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  CustomIconLabel(
                    iconData: Icons.calendar_view_week,
                    label: '休日設定(曜日指定/日付指定)',
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '※休日とする曜日にチェックを入れてください。',
                    style: TextStyle(fontSize: 14.0),
                  ),
                  Row(
                    children: weekList.map((e) {
                      return Expanded(
                        child: CustomWeekCheckbox(
                          onChanged: (value) {
                            setState(() {
                              if (_holidays.contains(e)) {
                                _holidays.remove(e);
                              } else {
                                _holidays.add(e);
                              }
                            });
                          },
                          value: _holidays.contains(e),
                          label: e,
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '※休日とする日付に選んでください。',
                    style: TextStyle(fontSize: 14.0),
                  ),
                  Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black38),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: SfDateRangePicker(
                        view: DateRangePickerView.month,
                        selectionMode: DateRangePickerSelectionMode.multiple,
                        initialSelectedDates: _holidays2,
                        selectionColor: Colors.redAccent,
                        onSelectionChanged: (value) {
                          _holidays2.clear();
                          for (DateTime date in value.value) {
                            _holidays2.add(date);
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  CustomIconLabel(
                    iconData: Icons.access_time,
                    label: '自動休憩時間',
                  ),
                  SizedBox(height: 8.0),
                  CustomCheckboxListTile(
                    onChanged: (value) {
                      setState(() => _autoBreak = value);
                    },
                    label: 'ここにチェックを入れると、退勤時に「01:00」分の休憩時間を登録します',
                    value: _autoBreak,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ConfirmDialog extends StatelessWidget {
  final GroupProvider groupProvider;
  final String roundStartType;
  final int roundStartNum;
  final String roundEndType;
  final int roundEndNum;
  final String roundBreakStartType;
  final int roundBreakStartNum;
  final String roundBreakEndType;
  final int roundBreakEndNum;
  final String roundWorkType;
  final int roundWorkNum;
  final int legal;
  final String nightStart;
  final String nightEnd;
  final String workStart;
  final String workEnd;
  final List<String> holidays;
  final List<DateTime> holidays2;
  final bool autoBreak;

  ConfirmDialog({
    @required this.groupProvider,
    @required this.roundStartType,
    @required this.roundStartNum,
    @required this.roundEndType,
    @required this.roundEndNum,
    @required this.roundBreakStartType,
    @required this.roundBreakStartNum,
    @required this.roundBreakEndType,
    @required this.roundBreakEndNum,
    @required this.roundWorkType,
    @required this.roundWorkNum,
    @required this.legal,
    @required this.nightStart,
    @required this.nightEnd,
    @required this.workStart,
    @required this.workEnd,
    @required this.holidays,
    @required this.holidays2,
    @required this.autoBreak,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.0),
          Text(
            '設定内容を保存します。よろしいですか？',
            style: TextStyle(fontSize: 16.0),
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
                  if (!await groupProvider.updateWork(
                    id: groupProvider.group?.id,
                    roundStartType: roundStartType,
                    roundStartNum: roundStartNum,
                    roundEndType: roundEndType,
                    roundEndNum: roundEndNum,
                    roundBreakStartType: roundBreakStartType,
                    roundBreakStartNum: roundBreakStartNum,
                    roundBreakEndType: roundBreakEndType,
                    roundBreakEndNum: roundBreakEndNum,
                    roundWorkType: roundWorkType,
                    roundWorkNum: roundWorkNum,
                    legal: legal,
                    nightStart: nightStart,
                    nightEnd: nightEnd,
                    workStart: workStart,
                    workEnd: workEnd,
                    holidays: holidays,
                    holidays2: holidays2,
                    autoBreak: autoBreak,
                  )) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('勤怠ルール設定を保存しました')),
                  );
                  groupProvider.reloadGroupModel();
                  Navigator.pop(context);
                },
                color: Colors.blue,
                label: 'はい',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
