import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/widgets/custom_icon_label.dart';
import 'package:hatarakujikan_web/widgets/custom_text_icon_button.dart';

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
          '各勤務時間の計算に必要な項目をここで設定できます。',
          style: kAdminSubTitleTextStyle,
        ),
        SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(),
            CustomTextIconButton(
              onPressed: () async {
                if (!await widget.groupProvider.updateWork(
                  id: widget.groupProvider.group?.id,
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
                  SnackBar(content: Text('設定の保存が完了しました')),
                );
                widget.groupProvider.reloadGroupModel();
              },
              color: Colors.blue,
              iconData: Icons.save,
              label: '設定を保存',
            ),
          ],
        ),
        SizedBox(height: 8.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: kBottomBorderDecoration,
                child: CustomIconLabel(
                  icon: Icon(Icons.access_time, color: Colors.black54),
                  label: '時間のまるめ',
                ),
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
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black38),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
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
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('まるめ分数', style: TextStyle(fontSize: 14.0)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black38),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
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
                        ),
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
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black38),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
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
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('まるめ分数', style: TextStyle(fontSize: 14.0)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black38),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
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
                        ),
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
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black38),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
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
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('まるめ分数', style: TextStyle(fontSize: 14.0)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black38),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
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
                        ),
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
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black38),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
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
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('まるめ分数', style: TextStyle(fontSize: 14.0)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black38),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
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
                        ),
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
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black38),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
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
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('まるめ分数', style: TextStyle(fontSize: 14.0)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black38),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
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
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Container(
                decoration: kBottomBorderDecoration,
                child: CustomIconLabel(
                  icon: Icon(Icons.access_time, color: Colors.black54),
                  label: '法定時間',
                ),
              ),
              SizedBox(height: 8.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black38),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
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
                ),
              ),
              SizedBox(height: 16.0),
              Container(
                decoration: kBottomBorderDecoration,
                child: CustomIconLabel(
                  icon: Icon(Icons.access_time, color: Colors.black54),
                  label: '深夜時間帯',
                ),
              ),
              SizedBox(height: 8.0),
              Row(
                children: [
                  TextButton.icon(
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
                    icon: Icon(
                      Icons.access_time,
                      color: Colors.black54,
                      size: 16.0,
                    ),
                    label: Text(
                      nightStart,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16.0,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      side: BorderSide(color: Colors.black38, width: 1),
                      padding: EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 24.0,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Text('〜'),
                  SizedBox(width: 8.0),
                  TextButton.icon(
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
                    icon: Icon(
                      Icons.access_time,
                      color: Colors.black54,
                      size: 16.0,
                    ),
                    label: Text(
                      nightEnd,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16.0,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      side: BorderSide(color: Colors.black38, width: 1),
                      padding: EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 24.0,
                      ),
                    ),
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
