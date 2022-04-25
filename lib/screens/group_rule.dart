import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hatarakujikan_web/helpers/define.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/widgets/admin_header.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold.dart';
import 'package:hatarakujikan_web/widgets/custom_checkbox.dart';
import 'package:hatarakujikan_web/widgets/custom_dropdown_button.dart';
import 'package:hatarakujikan_web/widgets/custom_google_map.dart';
import 'package:hatarakujikan_web/widgets/custom_slider.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';
import 'package:hatarakujikan_web/widgets/custom_text_form_field2.dart';
import 'package:hatarakujikan_web/widgets/date_range_picker.dart';
import 'package:hatarakujikan_web/widgets/icon_title.dart';
import 'package:hatarakujikan_web/widgets/tap_list_tile.dart';
import 'package:hatarakujikan_web/widgets/time_form_field.dart';
import 'package:provider/provider.dart';

class GroupRuleScreen extends StatelessWidget {
  static const String id = 'group_rule';

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    GroupModel? group = groupProvider.group;
    String _roundStartType = group?.roundStartType ?? '';
    String _roundStartNum = '${group?.roundStartNum ?? 0}分';
    String _roundEndType = group?.roundEndType ?? '';
    String _roundEndNum = '${group?.roundEndNum ?? 0}分';
    String _roundBreakStartType = group?.roundBreakStartType ?? '';
    String _roundBreakStartNum = '${group?.roundBreakStartNum ?? 0}分';
    String _roundBreakEndType = group?.roundBreakEndType ?? '';
    String _roundBreakEndNum = '${group?.roundBreakEndNum ?? 0}分';
    String _roundWorkType = group?.roundWorkType ?? '';
    String _roundWorkNum = '${group?.roundWorkNum ?? 0}分';
    String _legal = '${group?.legal}時間';
    String _nightStart = group?.nightStart ?? '--:--';
    String _nightEnd = group?.nightEnd ?? '--:--';
    String _workStart = group?.workStart ?? '--:--';
    String _workEnd = group?.workEnd ?? '--:--';
    String _holidays = '';
    for (String _week in group?.holidays ?? []) {
      if (_holidays != '') _holidays += ' / ';
      _holidays += _week;
    }
    String _holidays2 = '';
    for (DateTime _day in group?.holidays2 ?? []) {
      if (_holidays2 != '') _holidays2 += ' / ';
      _holidays2 += dateText('yyyy-MM-dd', _day);
    }
    String _autoBreak = '無効';
    if (group?.autoBreak == true) _autoBreak = '有効';
    String _qrSecurity = '無効';
    if (group?.qrSecurity == true) _qrSecurity = '有効';
    String _areaSecurity = '無効';
    if (group?.areaSecurity == true) _areaSecurity = '有効';
    String _areaLat = '${group?.areaLat ?? 0}';
    String _areaLon = '${group?.areaLon ?? 0}';
    String _areaRange = '${group?.areaRange ?? 0}m';

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
                      iconData: Icons.edit,
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
                      iconData: Icons.edit,
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
                      iconData: Icons.edit,
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
                      iconData: Icons.edit,
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
                      iconData: Icons.edit,
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
                      iconData: Icons.edit,
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
                      iconData: Icons.edit,
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
                      iconData: Icons.edit,
                      onTap: () {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (_) => EditWorkDialog(
                            groupProvider: groupProvider,
                          ),
                        );
                      },
                    ),
                    TapListTile(
                      title: '休日設定(曜日指定)',
                      subtitle: _holidays,
                      iconData: Icons.edit,
                      onTap: () {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (_) => EditHolidaysDialog(
                            groupProvider: groupProvider,
                          ),
                        );
                      },
                    ),
                    TapListTile(
                      title: '休日設定(日付指定)',
                      subtitle: _holidays2,
                      iconData: Icons.edit,
                      onTap: () {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (_) => EditHolidays2Dialog(
                            groupProvider: groupProvider,
                          ),
                        );
                      },
                    ),
                    TapListTile(
                      title: '自動休憩時間付与(1時間)',
                      subtitle: _autoBreak,
                      iconData: Icons.edit,
                      onTap: () {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (_) => EditAutoBreakDialog(
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
                      title: 'QRコード認証',
                      subtitle: _qrSecurity,
                      iconData: Icons.edit,
                      onTap: () {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (_) => EditQrSecurityDialog(
                            groupProvider: groupProvider,
                          ),
                        );
                      },
                    ),
                    TapListTile(
                      title: 'GPS位置情報制限',
                      subtitle: _areaSecurity,
                      iconData: Icons.edit,
                      onTap: () {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (_) => EditAreaSecurityDialog(
                            groupProvider: groupProvider,
                          ),
                        );
                      },
                    ),
                    groupProvider.group?.areaSecurity == true
                        ? TapListTile(
                            title: '制限する範囲',
                            subtitle:
                                '緯度：$_areaLat、経度：$_areaLon、半径：$_areaRange',
                            iconData: Icons.edit,
                            onTap: () {
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (_) => EditAreaLatLonDialog(
                                  groupProvider: groupProvider,
                                ),
                              );
                            },
                          )
                        : Container(),
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
              value: roundStartType ?? null,
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
              value: roundStartNum ?? null,
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
              value: roundEndType ?? null,
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
              value: roundEndNum ?? null,
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
              value: roundBreakStartType ?? null,
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
              value: roundBreakStartNum ?? null,
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
              value: roundBreakEndType ?? null,
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
              value: roundBreakEndNum ?? null,
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
              value: roundWorkType ?? null,
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
              value: roundWorkNum ?? null,
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
                Expanded(
                  child: TimeFormField(
                    label: '深夜開始時間',
                    time: nightStart,
                    onPressed: () async {
                      String? _time = await customTimePicker(
                        context: context,
                        init: nightStart,
                      );
                      if (_time == null) return;
                      setState(() => nightStart = _time);
                    },
                  ),
                ),
                SizedBox(width: 8.0),
                Center(
                  child: Text('〜', style: TextStyle(color: Colors.black54)),
                ),
                SizedBox(width: 8.0),
                Expanded(
                  child: TimeFormField(
                    label: '深夜終了時間',
                    time: nightEnd,
                    onPressed: () async {
                      String? _time = await customTimePicker(
                        context: context,
                        init: nightEnd,
                      );
                      if (_time == null) return;
                      setState(() => nightEnd = _time);
                    },
                  ),
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
                  onPressed: () async {
                    if (!await widget.groupProvider.updateNight(
                      id: widget.groupProvider.group?.id,
                      nightStart: nightStart,
                      nightEnd: nightEnd,
                    )) {
                      return;
                    }
                    widget.groupProvider.reloadGroup();
                    customSnackBar(context, '深夜時間帯を保存しました');
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

class EditWorkDialog extends StatefulWidget {
  final GroupProvider groupProvider;

  EditWorkDialog({required this.groupProvider});

  @override
  State<EditWorkDialog> createState() => _EditWorkDialogState();
}

class _EditWorkDialogState extends State<EditWorkDialog> {
  String? workStart;
  String? workEnd;

  void _init() async {
    workStart = widget.groupProvider.group?.workStart;
    workEnd = widget.groupProvider.group?.workEnd;
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
                Expanded(
                  child: TimeFormField(
                    label: '労働開始時間',
                    time: workStart,
                    onPressed: () async {
                      String? _time = await customTimePicker(
                        context: context,
                        init: workStart,
                      );
                      if (_time == null) return;
                      setState(() => workStart = _time);
                    },
                  ),
                ),
                SizedBox(width: 8.0),
                Center(
                  child: Text('〜', style: TextStyle(color: Colors.black54)),
                ),
                SizedBox(width: 8.0),
                Expanded(
                  child: TimeFormField(
                    label: '労働終了時間',
                    time: workEnd,
                    onPressed: () async {
                      String? _time = await customTimePicker(
                        context: context,
                        init: workEnd,
                      );
                      if (_time == null) return;
                      setState(() => workEnd = _time);
                    },
                  ),
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
                  onPressed: () async {
                    if (!await widget.groupProvider.updateWork(
                      id: widget.groupProvider.group?.id,
                      workStart: workStart,
                      workEnd: workEnd,
                    )) {
                      return;
                    }
                    widget.groupProvider.reloadGroup();
                    customSnackBar(context, '所定労働時間帯を保存しました');
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

class EditHolidaysDialog extends StatefulWidget {
  final GroupProvider groupProvider;

  EditHolidaysDialog({required this.groupProvider});

  @override
  State<EditHolidaysDialog> createState() => _EditHolidaysDialogState();
}

class _EditHolidaysDialogState extends State<EditHolidaysDialog> {
  List<String> holidays = [];

  void _init() async {
    holidays = widget.groupProvider.group?.holidays ?? [];
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
            Text(
              '休日としたい曜日にチェックを入れてください。',
              style: kDialogTextStyle,
            ),
            SizedBox(height: 16.0),
            Column(
              children: weekList.map((e) {
                return CustomCheckbox(
                  label: e,
                  value: holidays.contains(e),
                  activeColor: Colors.redAccent,
                  onChanged: (value) {
                    setState(() {
                      if (holidays.contains(e)) {
                        holidays.remove(e);
                      } else {
                        holidays.add(e);
                      }
                    });
                  },
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
                    if (!await widget.groupProvider.updateHolidays(
                      id: widget.groupProvider.group?.id,
                      holidays: holidays,
                    )) {
                      return;
                    }
                    widget.groupProvider.reloadGroup();
                    customSnackBar(context, '休日設定(曜日指定)を保存しました');
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

class EditHolidays2Dialog extends StatefulWidget {
  final GroupProvider groupProvider;

  EditHolidays2Dialog({required this.groupProvider});

  @override
  State<EditHolidays2Dialog> createState() => _EditHolidays2DialogState();
}

class _EditHolidays2DialogState extends State<EditHolidays2Dialog> {
  List<DateTime> holidays2 = [];

  void _init() async {
    holidays2 = widget.groupProvider.group?.holidays2 ?? [];
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
            Text(
              '休日としたい日付を選択してください。',
              style: kDialogTextStyle,
            ),
            SizedBox(height: 16.0),
            DateRangePicker(
              initialSelectedDates: holidays2,
              onSelectionChanged: (value) {
                holidays2.clear();
                for (DateTime _day in value.value) {
                  holidays2.add(_day);
                }
              },
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
                    if (!await widget.groupProvider.updateHolidays2(
                      id: widget.groupProvider.group?.id,
                      holidays2: holidays2,
                    )) {
                      return;
                    }
                    widget.groupProvider.reloadGroup();
                    customSnackBar(context, '休日設定(日付指定)を保存しました');
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

class EditAutoBreakDialog extends StatefulWidget {
  final GroupProvider groupProvider;

  EditAutoBreakDialog({required this.groupProvider});

  @override
  State<EditAutoBreakDialog> createState() => _EditAutoBreakDialogState();
}

class _EditAutoBreakDialogState extends State<EditAutoBreakDialog> {
  bool? autoBreak;

  void _init() async {
    autoBreak = widget.groupProvider.group?.autoBreak;
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
            Text(
              '有効にすると、各スタッフが退勤時に1時間分の休憩時間を自動付与します。',
              style: kDialogTextStyle,
            ),
            SizedBox(height: 16.0),
            CustomDropdownButton(
              label: '自動休憩時間付与(1時間)',
              isExpanded: true,
              value: autoBreak,
              onChanged: (value) {
                setState(() => autoBreak = value);
              },
              items: [
                DropdownMenuItem(
                  value: false,
                  child: Text(
                    '無効',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14.0,
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: true,
                  child: Text(
                    '有効',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14.0,
                    ),
                  ),
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
                  onPressed: () async {
                    if (!await widget.groupProvider.updateAutoBreak(
                      id: widget.groupProvider.group?.id,
                      autoBreak: autoBreak,
                    )) {
                      return;
                    }
                    widget.groupProvider.reloadGroup();
                    customSnackBar(context, '自動休憩時間付与(1時間)の設定を保存しました');
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

class EditQrSecurityDialog extends StatefulWidget {
  final GroupProvider groupProvider;

  EditQrSecurityDialog({required this.groupProvider});

  @override
  State<EditQrSecurityDialog> createState() => _EditQrSecurityDialogState();
}

class _EditQrSecurityDialogState extends State<EditQrSecurityDialog> {
  bool? qrSecurity;

  void _init() async {
    qrSecurity = widget.groupProvider.group?.qrSecurity;
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
            Text(
              '有効にすると、各スタッフがスマホアプリでの打刻時に、会社/組織のQRコードが無いと打刻できなくなります。',
              style: kDialogTextStyle,
            ),
            SizedBox(height: 16.0),
            CustomDropdownButton(
              label: 'QRコード認証',
              isExpanded: true,
              value: qrSecurity,
              onChanged: (value) {
                setState(() => qrSecurity = value);
              },
              items: [
                DropdownMenuItem(
                  value: false,
                  child: Text(
                    '無効',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14.0,
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: true,
                  child: Text(
                    '有効',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14.0,
                    ),
                  ),
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
                  onPressed: () async {
                    if (!await widget.groupProvider.updateQrSecurity(
                      id: widget.groupProvider.group?.id,
                      qrSecurity: qrSecurity,
                    )) {
                      return;
                    }
                    widget.groupProvider.reloadGroup();
                    customSnackBar(context, 'QRコード認証の設定を保存しました');
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

class EditAreaSecurityDialog extends StatefulWidget {
  final GroupProvider groupProvider;

  EditAreaSecurityDialog({required this.groupProvider});

  @override
  State<EditAreaSecurityDialog> createState() => _EditAreaSecurityDialogState();
}

class _EditAreaSecurityDialogState extends State<EditAreaSecurityDialog> {
  bool? areaSecurity;

  void _init() async {
    areaSecurity = widget.groupProvider.group?.areaSecurity;
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
            Text(
              '有効にすると、各スタッフがスマホアプリでの打刻時に、指定した範囲内にスマホが入っていないと打刻できなくなります。',
              style: kDialogTextStyle,
            ),
            SizedBox(height: 16.0),
            CustomDropdownButton(
              label: 'GPS位置情報制限',
              isExpanded: true,
              value: areaSecurity,
              onChanged: (value) {
                setState(() => areaSecurity = value);
              },
              items: [
                DropdownMenuItem(
                  value: false,
                  child: Text(
                    '無効',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14.0,
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: true,
                  child: Text(
                    '有効',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14.0,
                    ),
                  ),
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
                  onPressed: () async {
                    if (!await widget.groupProvider.updateAreaSecurity(
                      id: widget.groupProvider.group?.id,
                      areaSecurity: areaSecurity,
                    )) {
                      return;
                    }
                    widget.groupProvider.reloadGroup();
                    customSnackBar(context, 'GPS位置情報制限の設定を保存しました');
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

class EditAreaLatLonDialog extends StatefulWidget {
  final GroupProvider groupProvider;

  EditAreaLatLonDialog({required this.groupProvider});

  @override
  State<EditAreaLatLonDialog> createState() => _EditAreaLatLonDialogState();
}

class _EditAreaLatLonDialogState extends State<EditAreaLatLonDialog> {
  double? areaLat;
  double? areaLon;
  double? areaRange;
  GoogleMapController? mapController;

  void _init() async {
    areaLat = widget.groupProvider.group?.areaLat;
    areaLon = widget.groupProvider.group?.areaLon;
    areaRange = widget.groupProvider.group?.areaRange;
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
              '情報を変更し、「保存する」ボタンをクリックしてください。',
              style: kDialogTextStyle,
            ),
            Text(
              '赤い範囲が打刻できる範囲になります。',
              style: kDialogTextStyle,
            ),
            SizedBox(height: 16.0),
            CustomGoogleMap(
              height: 350.0,
              onMapCreated: _onMapCreated,
              lat: areaLat,
              lon: areaLon,
              range: areaRange,
              area: true,
              onTap: (latLng) {
                setState(() {
                  areaLat = latLng.latitude;
                  areaLon = latLng.longitude;
                });
              },
            ),
            SizedBox(height: 8.0),
            CustomSlider(
              text: '半径：$areaRange m',
              label: '$areaRange',
              value: areaRange,
              onChanged: (value) {
                setState(() => areaRange = value);
              },
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
                    if (!await widget.groupProvider.updateAreaLatLon(
                      id: widget.groupProvider.group?.id,
                      areaLat: areaLat,
                      areaLon: areaLon,
                      areaRange: areaRange,
                    )) {
                      return;
                    }
                    widget.groupProvider.reloadGroup();
                    customSnackBar(context, '制限する範囲を保存しました');
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
