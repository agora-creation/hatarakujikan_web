import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/csv_download.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/providers/position.dart';
import 'package:hatarakujikan_web/providers/user.dart';
import 'package:hatarakujikan_web/providers/work.dart';
import 'package:hatarakujikan_web/providers/work_shift.dart';
import 'package:hatarakujikan_web/widgets/TapListTile.dart';
import 'package:hatarakujikan_web/widgets/admin_header.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold.dart';
import 'package:hatarakujikan_web/widgets/custom_dropdown_button.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';
import 'package:hatarakujikan_web/widgets/loading.dart';
import 'package:hatarakujikan_web/widgets/month_form_field.dart';
import 'package:provider/provider.dart';

class WorkOutputScreen extends StatelessWidget {
  static const String id = 'work_output';

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final positionProvider = Provider.of<PositionProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final workProvider = Provider.of<WorkProvider>(context);
    final workShiftProvider = Provider.of<WorkShiftProvider>(context);
    GroupModel? group = groupProvider.group;

    return CustomAdminScaffold(
      groupProvider: groupProvider,
      selectedRoute: id,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminHeader(
            title: '帳票の出力',
            message: '勤怠記録を様々な形式で帳票出力できます。',
          ),
          SizedBox(height: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TapListTile(
                  title: 'CSVファイル形式で出力',
                  subtitle: 'お使いの給与ソフトに合わせて、CSVファイルをダウンロードできます。',
                  iconData: Icons.file_download,
                  onTap: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (_) => CSVDialog(
                        positionProvider: positionProvider,
                        userProvider: userProvider,
                        workProvider: workProvider,
                        workShiftProvider: workShiftProvider,
                        group: group,
                      ),
                    );
                  },
                ),
                TapListTile(
                  title: 'PDFファイル形式で出力',
                  subtitle: '勤怠の記録を印刷して確認できるよう、PDFファイルをダウンロードできます。',
                  iconData: Icons.print,
                  onTap: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (_) => PDFDialog(
                        groupProvider: groupProvider,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CSVDialog extends StatefulWidget {
  final PositionProvider positionProvider;
  final UserProvider userProvider;
  final WorkProvider workProvider;
  final WorkShiftProvider workShiftProvider;
  final GroupModel? group;

  CSVDialog({
    required this.positionProvider,
    required this.userProvider,
    required this.workProvider,
    required this.workShiftProvider,
    required this.group,
  });

  @override
  State<CSVDialog> createState() => _CSVDialogState();
}

class _CSVDialogState extends State<CSVDialog> {
  bool isLoading = false;
  DateTime month = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        width: 450.0,
        child: isLoading == true
            ? ListView(
                shrinkWrap: true,
                children: [
                  SizedBox(height: 24.0),
                  Loading(color: Colors.orange),
                  SizedBox(height: 24.0),
                ],
              )
            : ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    '出力条件を変更し、「出力する」ボタンをクリックしてください。',
                    style: kDialogTextStyle,
                  ),
                  SizedBox(height: 16.0),
                  MonthFormField(
                    label: '出力年月',
                    month: dateText('yyyy年MM月', month),
                    onPressed: () async {
                      DateTime? selected = await customMonthPicker(
                        context: context,
                        init: month,
                      );
                      if (selected == null) return;
                      setState(() => month = selected);
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
                        label: '出力する',
                        color: Colors.blue,
                        onPressed: () async {
                          setState(() => isLoading = true);
                          await CSVDownload.download(
                            positionProvider: widget.positionProvider,
                            userProvider: widget.userProvider,
                            workProvider: widget.workProvider,
                            workShiftProvider: widget.workShiftProvider,
                            group: widget.group,
                            month: month,
                          );
                          setState(() => isLoading = false);
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

class PDFDialog extends StatefulWidget {
  final GroupProvider groupProvider;

  PDFDialog({
    required this.groupProvider,
  });

  @override
  State<PDFDialog> createState() => _PDFDialogState();
}

class _PDFDialogState extends State<PDFDialog> {
  List<UserModel> users = [];
  DateTime month = DateTime.now();
  UserModel? user;

  void _init() async {
    List<UserModel> _users = await widget.groupProvider.selectUsers();
    if (mounted) {
      setState(() => users = _users);
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
              '出力条件を変更し、「出力する」ボタンをクリックしてください。',
              style: kDialogTextStyle,
            ),
            SizedBox(height: 16.0),
            MonthFormField(
              label: '出力年月',
              month: dateText('yyyy年MM月', DateTime.now()),
              onPressed: () async {
                DateTime? selected = await customMonthPicker(
                  context: context,
                  init: month,
                );
                if (selected == null) return;
                setState(() => month = selected);
              },
            ),
            SizedBox(height: 8.0),
            CustomDropdownButton(
              label: '出力スタッフ',
              isExpanded: true,
              value: user ?? null,
              onChanged: (value) {},
              items: users.map((user) {
                return DropdownMenuItem(
                  value: user,
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
                  label: '出力する',
                  color: Colors.blue,
                  onPressed: () async {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
