import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/pdf_api.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/widgets/custom_dropdown_button.dart';
import 'package:hatarakujikan_web/widgets/custom_icon_label.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';
import 'package:hatarakujikan_web/widgets/custom_text_icon_button.dart';
import 'package:hatarakujikan_web/widgets/custom_text_icon_button2.dart';

class GroupWorkPanel extends StatefulWidget {
  final GroupProvider groupProvider;

  GroupWorkPanel({@required this.groupProvider});

  @override
  _GroupWorkPanelState createState() => _GroupWorkPanelState();
}

class _GroupWorkPanelState extends State<GroupWorkPanel> {
  List<String> roundTypeList = ['切捨', '切上'];
  List<int> roundNumList = [1, 5, 10, 15, 30];
  String roundStartType;
  int roundStartNum;
  String roundEndType;
  int roundEndNum;
  String roundBreakStartType;
  int roundBreakStartNum;
  String roundBreakEndType;
  int roundBreakEndNum;
  String roundWorkType;
  int roundWorkNum;
  List<int> legalList = [8];
  int legal;
  String nightStart;
  String nightEnd;

  void _init() async {
    setState(() {
      roundStartType = widget.groupProvider.group?.roundStartType;
      roundStartNum = widget.groupProvider.group?.roundStartNum;
      roundEndType = widget.groupProvider.group?.roundEndType;
      roundEndNum = widget.groupProvider.group?.roundEndNum;
      roundBreakStartType = widget.groupProvider.group?.roundBreakStartType;
      roundBreakStartNum = widget.groupProvider.group?.roundBreakStartNum;
      roundBreakEndType = widget.groupProvider.group?.roundBreakEndType;
      roundBreakEndNum = widget.groupProvider.group?.roundBreakEndNum;
      roundWorkType = widget.groupProvider.group?.roundWorkType;
      roundWorkNum = widget.groupProvider.group?.roundWorkNum;
      legal = widget.groupProvider.group?.legal;
      nightStart = widget.groupProvider.group?.nightStart;
      nightEnd = widget.groupProvider.group?.nightEnd;
    });
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
                    await qrPdf(group: widget.groupProvider.group);
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomIconLabel(
                iconData: Icons.access_time,
                label: '時間のまるめ',
              ),
              SizedBox(height: 8.0),
              Row(
                children: [
                  Text('出勤時間　　'),
                  SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('まるめ方', style: TextStyle(fontSize: 14.0)),
                      CustomDropdownButton(
                        value: roundStartType,
                        onChanged: (value) {
                          setState(() => roundStartType = value);
                        },
                        items: roundTypeList.map((value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14.0,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('まるめ分数', style: TextStyle(fontSize: 14.0)),
                      CustomDropdownButton(
                        value: roundStartNum,
                        onChanged: (value) {
                          setState(() => roundStartNum = value);
                        },
                        items: roundNumList.map((value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(
                              '$value分',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14.0,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Row(
                children: [
                  Text('退勤時間　　'),
                  SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('まるめ方', style: TextStyle(fontSize: 14.0)),
                      CustomDropdownButton(
                        value: roundEndType,
                        onChanged: (value) {
                          setState(() => roundEndType = value);
                        },
                        items: roundTypeList.map((value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14.0,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('まるめ分数', style: TextStyle(fontSize: 14.0)),
                      CustomDropdownButton(
                        value: roundEndNum,
                        onChanged: (value) {
                          setState(() => roundEndNum = value);
                        },
                        items: roundNumList.map((value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(
                              '$value分',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14.0,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Row(
                children: [
                  Text('休憩開始時間'),
                  SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('まるめ方', style: TextStyle(fontSize: 14.0)),
                      CustomDropdownButton(
                        value: roundBreakStartType,
                        onChanged: (value) {
                          setState(() => roundBreakStartType = value);
                        },
                        items: roundTypeList.map((value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14.0,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('まるめ分数', style: TextStyle(fontSize: 14.0)),
                      CustomDropdownButton(
                        value: roundBreakStartNum,
                        onChanged: (value) {
                          setState(() => roundBreakStartNum = value);
                        },
                        items: roundNumList.map((value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(
                              '$value分',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14.0,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Row(
                children: [
                  Text('休憩終了時間'),
                  SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('まるめ方', style: TextStyle(fontSize: 14.0)),
                      CustomDropdownButton(
                        value: roundBreakEndType,
                        onChanged: (value) {
                          setState(() => roundBreakEndType = value);
                        },
                        items: roundTypeList.map((value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14.0,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('まるめ分数', style: TextStyle(fontSize: 14.0)),
                      CustomDropdownButton(
                        value: roundBreakEndNum,
                        onChanged: (value) {
                          setState(() => roundBreakEndNum = value);
                        },
                        items: roundNumList.map((value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(
                              '$value分',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14.0,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Row(
                children: [
                  Text('勤務時間　　'),
                  SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('まるめ方', style: TextStyle(fontSize: 14.0)),
                      CustomDropdownButton(
                        value: roundWorkType,
                        onChanged: (value) {
                          setState(() => roundWorkType = value);
                        },
                        items: roundTypeList.map((value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14.0,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('まるめ分数', style: TextStyle(fontSize: 14.0)),
                      CustomDropdownButton(
                        value: roundWorkNum,
                        onChanged: (value) {
                          setState(() => roundWorkNum = value);
                        },
                        items: roundNumList.map((value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(
                              '$value分',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14.0,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              CustomIconLabel(
                iconData: Icons.access_time,
                label: '法定時間',
              ),
              SizedBox(height: 8.0),
              CustomDropdownButton(
                value: legal,
                onChanged: (value) {
                  setState(() => legal = value);
                },
                items: legalList.map((value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(
                      '$value時間',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14.0,
                      ),
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
                  CustomTextIconButton2(
                    onPressed: () async {
                      List<String> _hm = nightStart.split(':');
                      TimeOfDay _selected = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                          hour: int.parse(_hm.first),
                          minute: int.parse(_hm.last),
                        ),
                      );
                      if (_selected != null) {
                        String _time = '${_selected.format(context)}';
                        setState(() => nightStart = _time);
                      }
                    },
                    iconData: Icons.access_time,
                    label: nightStart,
                  ),
                  SizedBox(width: 8.0),
                  Text('〜'),
                  SizedBox(width: 8.0),
                  CustomTextIconButton2(
                    onPressed: () async {
                      List<String> _hm = nightEnd.split(':');
                      TimeOfDay _selected = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                          hour: int.parse(_hm.first),
                          minute: int.parse(_hm.last),
                        ),
                      );
                      if (_selected != null) {
                        String _time = '${_selected.format(context)}';
                        setState(() => nightEnd = _time);
                      }
                    },
                    iconData: Icons.access_time,
                    label: nightEnd,
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
