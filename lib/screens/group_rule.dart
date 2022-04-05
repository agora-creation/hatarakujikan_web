import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/define.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/widgets/TapListTile.dart';
import 'package:hatarakujikan_web/widgets/admin_header.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold.dart';
import 'package:hatarakujikan_web/widgets/custom_dropdown_button.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';
import 'package:hatarakujikan_web/widgets/custom_text_form_field2.dart';
import 'package:hatarakujikan_web/widgets/icon_title.dart';
import 'package:hatarakujikan_web/widgets/time_form_field.dart';
import 'package:provider/provider.dart';

class GroupRuleScreen extends StatelessWidget {
  static const String id = 'group_rule';

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    String _roundStartType = groupProvider.group?.roundStartType ?? '';
    String _roundStartNum = '${groupProvider.group?.roundStartNum}分';
    String _roundEndType = groupProvider.group?.roundEndType ?? '';
    String _roundEndNum = '${groupProvider.group?.roundEndNum}分';
    String _roundBreakStartType =
        groupProvider.group?.roundBreakStartType ?? '';
    String _roundBreakStartNum = '${groupProvider.group?.roundBreakStartNum}分';
    String _roundBreakEndType = groupProvider.group?.roundBreakEndType ?? '';
    String _roundBreakEndNum = '${groupProvider.group?.roundBreakEndNum}分';
    String _roundWorkType = groupProvider.group?.roundWorkType ?? '';
    String _roundWorkNum = '${groupProvider.group?.roundWorkNum}分';
    String _legal = '${groupProvider.group?.legal}時間';
    String _nightStart = groupProvider.group?.nightStart ?? '';
    String _nightEnd = groupProvider.group?.nightEnd ?? '';
    String _workStart = groupProvider.group?.workStart ?? '';
    String _workEnd = groupProvider.group?.workEnd ?? '';
    String _holidays = '';
    for (String _week in groupProvider.group?.holidays ?? []) {
      if (_holidays != '') _holidays += ',';
      _holidays += _week;
    }
    String _holidays2 = '';
    for (DateTime _day in groupProvider.group?.holidays2 ?? []) {
      if (_holidays2 != '') _holidays2 += ',';
      _holidays2 += dateText('yyyy-MM-dd', _day);
    }
    String _autoBreak = '無効';
    if (groupProvider.group?.autoBreak == true) {
      _autoBreak = '有効';
    }
    String _qrSecurity = '無効';
    if (groupProvider.group?.qrSecurity == true) {
      _qrSecurity = '有効';
    }
    String _areaSecurity = '無効';
    if (groupProvider.group?.areaSecurity == true) {
      _areaSecurity = '有効';
    }

    return CustomAdminScaffold(
      groupProvider: groupProvider,
      selectedRoute: id,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminHeader(
            title: '勤怠ルールの設定',
            message: '勤務時間に関する定数を設定したり、アプリ利用時のセキュリティに関する設定をすることができます。',
          ),
          SizedBox(height: 16.0),
          Expanded(
            child: ListView(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconTitle(
                      iconData: Icons.access_time,
                      text: '勤務時間に関する設定',
                    ),
                    SizedBox(height: 8.0),
                    TapListTile(
                      title: '出勤時間のまるめ',
                      subtitle: 'まるめ方：$_roundStartType、まるめ分数：$_roundStartNum',
                      onTap: () {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (_) => EditRoundStartDialog(
                            groupProvider: groupProvider,
                          ),
                        );
                      },
                    ),
                    TapListTile(
                      title: '退勤時間のまるめ',
                      subtitle: 'まるめ方：$_roundEndType、まるめ分数：$_roundEndNum',
                      onTap: () {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (_) => EditRoundEndDialog(
                            groupProvider: groupProvider,
                          ),
                        );
                      },
                    ),
                    TapListTile(
                      title: '休憩開始時間のまるめ',
                      subtitle:
                          'まるめ方：$_roundBreakStartType、まるめ分数：$_roundBreakStartNum',
                      onTap: () {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (_) => EditRoundBreakStartDialog(
                            groupProvider: groupProvider,
                          ),
                        );
                      },
                    ),
                    TapListTile(
                      title: '休憩終了時間のまるめ',
                      subtitle:
                          'まるめ方：$_roundBreakEndType、まるめ分数：$_roundBreakEndNum',
                      onTap: () {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (_) => EditRoundBreakEndDialog(
                            groupProvider: groupProvider,
                          ),
                        );
                      },
                    ),
                    TapListTile(
                      title: '勤務時間のまるめ',
                      subtitle: 'まるめ方：$_roundWorkType、まるめ分数：$_roundWorkNum',
                      onTap: () {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (_) => EditRoundWorkDialog(
                            groupProvider: groupProvider,
                          ),
                        );
                      },
                    ),
                    TapListTile(
                      title: '法定労働時間',
                      subtitle: _legal,
                      onTap: () {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (_) => EditLegalDialog(
                            groupProvider: groupProvider,
                          ),
                        );
                      },
                    ),
                    TapListTile(
                      title: '深夜時間帯',
                      subtitle: '$_nightStart〜$_nightEnd',
                      onTap: () {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (_) => EditNightDialog(
                            groupProvider: groupProvider,
                          ),
                        );
                      },
                    ),
                    TapListTile(
                      title: '所定労働時間帯',
                      subtitle: '$_workStart〜$_workEnd',
                      onTap: () {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (_) => EditRoundStartDialog(
                            groupProvider: groupProvider,
                          ),
                        );
                      },
                    ),
                    TapListTile(
                      title: '休日設定(曜日指定)',
                      subtitle: _holidays,
                      onTap: () {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (_) => EditRoundStartDialog(
                            groupProvider: groupProvider,
                          ),
                        );
                      },
                    ),
                    TapListTile(
                      title: '休日設定(日付指定)',
                      subtitle: _holidays2,
                      onTap: () {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (_) => EditRoundStartDialog(
                            groupProvider: groupProvider,
                          ),
                        );
                      },
                    ),
                    TapListTile(
                      title: '自動休憩(1時間)',
                      subtitle: _autoBreak,
                      onTap: () {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (_) => EditRoundStartDialog(
                            groupProvider: groupProvider,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 24.0),
                    IconTitle(
                      iconData: Icons.security,
                      text: 'セキュリティに関する設定',
                    ),
                    SizedBox(height: 8.0),
                    TapListTile(
                      title: '打刻時、QRコードで認証する',
                      subtitle: _qrSecurity,
                      onTap: () {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (_) => EditRoundStartDialog(
                            groupProvider: groupProvider,
                          ),
                        );
                      },
                    ),
                    TapListTile(
                      title: '打刻時、位置情報が範囲外なら打刻させない',
                      subtitle: _areaSecurity,
                      onTap: () {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (_) => EditRoundStartDialog(
                            groupProvider: groupProvider,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EditRoundStartDialog extends StatefulWidget {
  final GroupProvider groupProvider;

  EditRoundStartDialog({required this.groupProvider});

  @override
  State<EditRoundStartDialog> createState() => _EditRoundStartDialogState();
}

class _EditRoundStartDialogState extends State<EditRoundStartDialog> {
  String? roundStartType;
  int? roundStartNum;

  void _init() async {
    roundStartType = widget.groupProvider.group?.roundStartType;
    roundStartNum = widget.groupProvider.group?.roundStartNum;
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
              label: '出勤時間のまるめ方',
              isExpanded: true,
              value: roundStartType,
              onChanged: (value) {
                setState(() => roundStartType = value);
              },
              items: roundTypeList.map((e) {
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
            CustomDropdownButton(
              label: '出勤時間のまるめ分数',
              isExpanded: true,
              value: roundStartNum,
              onChanged: (value) {
                setState(() => roundStartNum = value);
              },
              items: roundNumList.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(
                    '$e分',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14.0,
                    ),
                  ),
                );
              }).toList(),
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
                CustomTextButton(
                  label: '保存する',
                  color: Colors.blue,
                  onPressed: () async {
                    if (!await widget.groupProvider.updateRoundStart(
                      id: widget.groupProvider.group?.id,
                      roundStartType: roundStartType,
                      roundStartNum: roundStartNum,
                    )) {
                      return;
                    }
                    widget.groupProvider.reloadGroup();
                    customSnackBar(context, '出勤時間のまるめ設定を保存しました');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EditRoundEndDialog extends StatefulWidget {
  final GroupProvider groupProvider;

  EditRoundEndDialog({required this.groupProvider});

  @override
  State<EditRoundEndDialog> createState() => _EditRoundEndDialogState();
}

class _EditRoundEndDialogState extends State<EditRoundEndDialog> {
  String? roundEndType;
  int? roundEndNum;

  void _init() async {
    roundEndType = widget.groupProvider.group?.roundEndType;
    roundEndNum = widget.groupProvider.group?.roundEndNum;
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
              label: '退勤時間のまるめ方',
              isExpanded: true,
              value: roundEndType,
              onChanged: (value) {
                setState(() => roundEndType = value);
              },
              items: roundTypeList.map((e) {
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
            CustomDropdownButton(
              label: '退勤時間のまるめ分数',
              isExpanded: true,
              value: roundEndNum,
              onChanged: (value) {
                setState(() => roundEndNum = value);
              },
              items: roundNumList.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(
                    '$e分',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14.0,
                    ),
                  ),
                );
              }).toList(),
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
                CustomTextButton(
                  label: '保存する',
                  color: Colors.blue,
                  onPressed: () async {
                    if (!await widget.groupProvider.updateRoundEnd(
                      id: widget.groupProvider.group?.id,
                      roundEndType: roundEndType,
                      roundEndNum: roundEndNum,
                    )) {
                      return;
                    }
                    widget.groupProvider.reloadGroup();
                    customSnackBar(context, '退勤時間のまるめ設定を保存しました');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EditRoundBreakStartDialog extends StatefulWidget {
  final GroupProvider groupProvider;

  EditRoundBreakStartDialog({required this.groupProvider});

  @override
  State<EditRoundBreakStartDialog> createState() =>
      _EditRoundBreakStartDialogState();
}

class _EditRoundBreakStartDialogState extends State<EditRoundBreakStartDialog> {
  String? roundBreakStartType;
  int? roundBreakStartNum;

  void _init() async {
    roundBreakStartType = widget.groupProvider.group?.roundBreakStartType;
    roundBreakStartNum = widget.groupProvider.group?.roundBreakStartNum;
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
              label: '休憩開始時間のまるめ方',
              isExpanded: true,
              value: roundBreakStartType,
              onChanged: (value) {
                setState(() => roundBreakStartType = value);
              },
              items: roundTypeList.map((e) {
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
            CustomDropdownButton(
              label: '休憩開始時間のまるめ分数',
              isExpanded: true,
              value: roundBreakStartNum,
              onChanged: (value) {
                setState(() => roundBreakStartNum = value);
              },
              items: roundNumList.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(
                    '$e分',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14.0,
                    ),
                  ),
                );
              }).toList(),
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
                CustomTextButton(
                  label: '保存する',
                  color: Colors.blue,
                  onPressed: () async {
                    if (!await widget.groupProvider.updateRoundBreakStart(
                      id: widget.groupProvider.group?.id,
                      roundBreakStartType: roundBreakStartType,
                      roundBreakStartNum: roundBreakStartNum,
                    )) {
                      return;
                    }
                    widget.groupProvider.reloadGroup();
                    customSnackBar(context, '休憩開始時間のまるめ設定を保存しました');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EditRoundBreakEndDialog extends StatefulWidget {
  final GroupProvider groupProvider;

  EditRoundBreakEndDialog({required this.groupProvider});

  @override
  State<EditRoundBreakEndDialog> createState() =>
      _EditRoundBreakEndDialogState();
}

class _EditRoundBreakEndDialogState extends State<EditRoundBreakEndDialog> {
  String? roundBreakEndType;
  int? roundBreakEndNum;

  void _init() async {
    roundBreakEndType = widget.groupProvider.group?.roundBreakEndType;
    roundBreakEndNum = widget.groupProvider.group?.roundBreakEndNum;
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
              label: '休憩終了時間のまるめ方',
              isExpanded: true,
              value: roundBreakEndType,
              onChanged: (value) {
                setState(() => roundBreakEndType = value);
              },
              items: roundTypeList.map((e) {
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
            CustomDropdownButton(
              label: '休憩終了時間のまるめ分数',
              isExpanded: true,
              value: roundBreakEndNum,
              onChanged: (value) {
                setState(() => roundBreakEndNum = value);
              },
              items: roundNumList.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(
                    '$e分',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14.0,
                    ),
                  ),
                );
              }).toList(),
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
                CustomTextButton(
                  label: '保存する',
                  color: Colors.blue,
                  onPressed: () async {
                    if (!await widget.groupProvider.updateRoundBreakEnd(
                      id: widget.groupProvider.group?.id,
                      roundBreakEndType: roundBreakEndType,
                      roundBreakEndNum: roundBreakEndNum,
                    )) {
                      return;
                    }
                    widget.groupProvider.reloadGroup();
                    customSnackBar(context, '休憩終了時間のまるめ設定を保存しました');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EditRoundWorkDialog extends StatefulWidget {
  final GroupProvider groupProvider;

  EditRoundWorkDialog({required this.groupProvider});

  @override
  State<EditRoundWorkDialog> createState() => _EditRoundWorkDialogState();
}

class _EditRoundWorkDialogState extends State<EditRoundWorkDialog> {
  String? roundWorkType;
  int? roundWorkNum;

  void _init() async {
    roundWorkType = widget.groupProvider.group?.roundWorkType;
    roundWorkNum = widget.groupProvider.group?.roundWorkNum;
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
              label: '勤務時間のまるめ方',
              isExpanded: true,
              value: roundWorkType,
              onChanged: (value) {
                setState(() => roundWorkType = value);
              },
              items: roundTypeList.map((e) {
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
            CustomDropdownButton(
              label: '勤務時間のまるめ分数',
              isExpanded: true,
              value: roundWorkNum,
              onChanged: (value) {
                setState(() => roundWorkNum = value);
              },
              items: roundNumList.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(
                    '$e分',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14.0,
                    ),
                  ),
                );
              }).toList(),
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
                CustomTextButton(
                  label: '保存する',
                  color: Colors.blue,
                  onPressed: () async {
                    if (!await widget.groupProvider.updateRoundWork(
                      id: widget.groupProvider.group?.id,
                      roundWorkType: roundWorkType,
                      roundWorkNum: roundWorkNum,
                    )) {
                      return;
                    }
                    widget.groupProvider.reloadGroup();
                    customSnackBar(context, '勤務時間のまるめ設定を保存しました');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EditLegalDialog extends StatefulWidget {
  final GroupProvider groupProvider;

  EditLegalDialog({required this.groupProvider});

  @override
  State<EditLegalDialog> createState() => _EditLegalDialogState();
}

class _EditLegalDialogState extends State<EditLegalDialog> {
  TextEditingController legal = TextEditingController();

  void _init() async {
    legal.text = widget.groupProvider.group?.legal.toString() ?? '0';
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
            CustomTextFormField2(
              label: '法定労働時間',
              controller: legal,
              textInputType: TextInputType.number,
              maxLines: 1,
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
                CustomTextButton(
                  label: '保存する',
                  color: Colors.blue,
                  onPressed: () async {
                    if (!await widget.groupProvider.updateLegal(
                      id: widget.groupProvider.group?.id,
                      legal: int.parse(legal.text.trim()),
                    )) {
                      return;
                    }
                    widget.groupProvider.reloadGroup();
                    customSnackBar(context, '法定労働時間を保存しました');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EditNightDialog extends StatefulWidget {
  final GroupProvider groupProvider;

  EditNightDialog({required this.groupProvider});

  @override
  State<EditNightDialog> createState() => _EditNightDialogState();
}

class _EditNightDialogState extends State<EditNightDialog> {
  String? nightStart;
  String? nightEnd;

  void _init() async {
    nightStart = widget.groupProvider.group?.nightStart;
    nightEnd = widget.groupProvider.group?.nightEnd;
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TimeFormField(
                  label: '深夜開始時間',
                  time: nightStart,
                  onPressed: () async {
                    List<String> _hm = nightStart!.split(':');
                    TimeOfDay? _selected = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: int.parse(_hm.first),
                        minute: int.parse(_hm.last),
                      ),
                    );
                    if (_selected == null) return;
                    String _time = '${_selected.format(context)}';
                    setState(() => nightStart = _time);
                  },
                ),
                SizedBox(width: 8.0),
                Center(
                  child: Text('〜', style: TextStyle(color: Colors.black54)),
                ),
                SizedBox(width: 8.0),
                TimeFormField(
                  label: '深夜終了時間',
                  time: nightEnd,
                  onPressed: () {},
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
                CustomTextButton(
                  label: '保存する',
                  color: Colors.blue,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
