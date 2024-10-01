import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/csv_file.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/helpers/pdf_file.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/providers/position.dart';
import 'package:hatarakujikan_web/providers/user.dart';
import 'package:hatarakujikan_web/providers/work.dart';
import 'package:hatarakujikan_web/providers/work_shift.dart';
import 'package:hatarakujikan_web/widgets/admin_header.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold.dart';
import 'package:hatarakujikan_web/widgets/custom_checkbox.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';
import 'package:hatarakujikan_web/widgets/loading.dart';
import 'package:hatarakujikan_web/widgets/month_form_field.dart';
import 'package:hatarakujikan_web/widgets/tap_list_tile.dart';
import 'package:provider/provider.dart';

class WorkDownloadScreen extends StatelessWidget {
  static const String id = 'work_download';

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
                  iconData: Icons.file_download,
                  onTap: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (_) => PDFDialog(
                        positionProvider: positionProvider,
                        groupProvider: groupProvider,
                        userProvider: userProvider,
                        workProvider: workProvider,
                        workShiftProvider: workShiftProvider,
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
                          await CSVFile.download(
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
  final PositionProvider positionProvider;
  final UserProvider userProvider;
  final WorkProvider workProvider;
  final WorkShiftProvider workShiftProvider;

  PDFDialog({
    required this.groupProvider,
    required this.positionProvider,
    required this.userProvider,
    required this.workProvider,
    required this.workShiftProvider,
  });

  @override
  State<PDFDialog> createState() => _PDFDialogState();
}

class _PDFDialogState extends State<PDFDialog> {
  bool isLoading = false;
  ScrollController _controller = ScrollController();
  List<UserModel> users = [];
  DateTime month = DateTime.now();
  List<UserModel> checkedUsers = [];
  bool isAll = false;
  bool isRetired = false;

  void _init() async {
    List<UserModel> _users = await widget.groupProvider.selectUsers();
    if (mounted) {
      setState(() => users = _users);
    }
  }

  void _allCheck(bool value) {
    isAll = value;
    if (isAll == true) {
      checkedUsers = users;
    } else {
      checkedUsers = [];
    }
    setState(() {});
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
        child: isLoading == true
            ? Column(
                children: [
                  SizedBox(height: 24.0),
                  Loading(color: Colors.orange),
                  SizedBox(height: 24.0),
                ],
              )
            : Column(
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
                  SizedBox(height: 8.0),
                  Divider(color: Colors.black54, height: 1),
                  Expanded(
                    child: Scrollbar(
                      thumbVisibility: true,
                      controller: _controller,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        controller: _controller,
                        itemCount: users.length,
                        itemBuilder: (_, index) {
                          UserModel _user = users[index];
                          var contain =
                              checkedUsers.where((e) => e.id == _user.id);
                          return CustomCheckbox(
                            label: _user.name,
                            value: contain.isNotEmpty,
                            activeColor: Colors.blue,
                            onChanged: (value) {
                              var _contain =
                                  checkedUsers.where((e) => e.id == _user.id);
                              setState(() {
                                if (_contain.isEmpty) {
                                  checkedUsers.add(_user);
                                } else {
                                  checkedUsers
                                      .removeWhere((e) => e.id == _user.id);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  Divider(color: Colors.black54, height: 1),
                  CustomCheckbox(
                    label: '全選択',
                    value: isAll,
                    activeColor: Colors.blue,
                    onChanged: (value) => _allCheck(value!),
                  ),
                  CustomCheckbox(
                    label: '退職済みのスタッフ分を出力',
                    value: isRetired,
                    activeColor: Colors.blue,
                    onChanged: (value) {
                      setState(() => isRetired = !isRetired);
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
                          if (!isRetired) {
                            if (checkedUsers.isEmpty) {
                              customSnackBar(context, 'スタッフを一名以上選択してください');
                              Navigator.pop(context);
                              return;
                            }
                          }
                          setState(() => isLoading = true);
                          await PDFFile.download(
                            positionProvider: widget.positionProvider,
                            userProvider: widget.userProvider,
                            workProvider: widget.workProvider,
                            workShiftProvider: widget.workShiftProvider,
                            group: widget.groupProvider.group,
                            month: month,
                            users: checkedUsers,
                            isRetired: isRetired,
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
