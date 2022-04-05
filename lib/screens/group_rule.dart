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
import 'package:hatarakujikan_web/widgets/icon_title.dart';
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
                      onTap: () {},
                    ),
                    TapListTile(
                      title: '休憩開始時間のまるめ',
                      subtitle:
                          'まるめ方：$_roundBreakStartType、まるめ分数：$_roundBreakStartNum',
                      onTap: () {},
                    ),
                    TapListTile(
                      title: '休憩終了時間のまるめ',
                      subtitle:
                          'まるめ方：$_roundBreakEndType、まるめ分数：$_roundBreakEndNum',
                      onTap: () {},
                    ),
                    TapListTile(
                      title: '勤務時間のまるめ',
                      subtitle: 'まるめ方：$_roundWorkType、まるめ分数：$_roundWorkNum',
                      onTap: () {},
                    ),
                    TapListTile(
                      title: '法定労働時間',
                      subtitle: _legal,
                      onTap: () {},
                    ),
                    TapListTile(
                      title: '深夜時間帯',
                      subtitle: '$_nightStart〜$_nightEnd',
                      onTap: () {},
                    ),
                    TapListTile(
                      title: '所定労働時間帯',
                      subtitle: '$_workStart〜$_workEnd',
                      onTap: () {},
                    ),
                    TapListTile(
                      title: '休日設定(曜日指定)',
                      subtitle: _holidays,
                      onTap: () {},
                    ),
                    TapListTile(
                      title: '休日設定(日付指定)',
                      subtitle: _holidays2,
                      onTap: () {},
                    ),
                    TapListTile(
                      title: '自動休憩(1時間)',
                      subtitle: _autoBreak,
                      onTap: () {},
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
                      onTap: () {},
                    ),
                    TapListTile(
                      title: '打刻時、位置情報が範囲外なら打刻できない',
                      subtitle: _areaSecurity,
                      onTap: () {},
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
