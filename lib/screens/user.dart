import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/providers/user.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold.dart';
import 'package:hatarakujikan_web/widgets/custom_dropdown_button.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';
import 'package:hatarakujikan_web/widgets/custom_text_form_field2.dart';
import 'package:hatarakujikan_web/widgets/custom_text_icon_button.dart';
import 'package:provider/provider.dart';

class UserScreen extends StatelessWidget {
  static const String id = 'user';

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return CustomAdminScaffold(
      groupProvider: groupProvider,
      selectedRoute: id,
      body: UserTable(
        groupProvider: groupProvider,
        userProvider: userProvider,
      ),
    );
  }
}

class UserTable extends StatefulWidget {
  final GroupProvider groupProvider;
  final UserProvider userProvider;

  UserTable({
    @required this.groupProvider,
    @required this.userProvider,
  });

  @override
  _UserTableState createState() => _UserTableState();
}

class _UserTableState extends State<UserTable> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'スタッフの管理',
          style: kAdminTitleTextStyle,
        ),
        Text(
          'スタッフを一覧表示します。スマートフォンアプリから新規登録して会社/組織へ加入するか、この画面で新規登録できます。',
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
                  onPressed: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (_) => MigrationDialog(
                        groupProvider: widget.groupProvider,
                        userProvider: widget.userProvider,
                      ),
                    );
                  },
                  color: Colors.cyan,
                  iconData: Icons.smartphone,
                  label: 'データ移行',
                ),
                SizedBox(width: 4.0),
                CustomTextIconButton(
                  onPressed: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (_) => AddUserDialog(
                        groupProvider: widget.groupProvider,
                        userProvider: widget.userProvider,
                      ),
                    );
                  },
                  color: Colors.blue,
                  iconData: Icons.add,
                  label: '新規登録',
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 8.0),
        Expanded(
          child: DataTable2(
            columns: [
              DataColumn2(label: Text('スタッフ名')),
              DataColumn2(label: Text('タブレット用暗証番号'), size: ColumnSize.L),
              DataColumn2(label: Text('メールアドレス')),
              DataColumn2(label: Text('修正/削除'), size: ColumnSize.S),
            ],
            rows: List<DataRow>.generate(
              widget.groupProvider.users.length,
              (index) => DataRow(
                cells: [
                  DataCell(Text('${widget.groupProvider.users[index].name}')),
                  DataCell(Text(
                      '${widget.groupProvider.users[index].recordPassword}')),
                  DataCell(Text('${widget.groupProvider.users[index].email}')),
                  DataCell(IconButton(
                    onPressed: () {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (_) => EditUserDialog(
                          groupProvider: widget.groupProvider,
                          userProvider: widget.userProvider,
                          user: widget.groupProvider.users[index],
                        ),
                      );
                    },
                    icon: Icon(Icons.edit, color: Colors.blue),
                  )),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MigrationDialog extends StatefulWidget {
  final GroupProvider groupProvider;
  final UserProvider userProvider;

  MigrationDialog({
    @required this.groupProvider,
    @required this.userProvider,
  });

  @override
  _MigrationDialogState createState() => _MigrationDialogState();
}

class _MigrationDialogState extends State<MigrationDialog> {
  List<UserModel> before = [];
  List<UserModel> after = [];
  UserModel selectBefore;
  UserModel selectAfter;

  void _init() async {
    widget.groupProvider.users.forEach((user) {
      if (user.smartphone == false) {
        before.add(user);
      }
    });
    widget.groupProvider.users.forEach((user) {
      if (user.smartphone == true) {
        after.add(user);
      }
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
              'この機能は、この管理画面から登録したスタッフがスマートフォンアプリの利用を始めた際、スタッフデータが二重に登録されてしまう為、ここでスタッフデータの統一化ができます。',
              style: TextStyle(color: Colors.black54, fontSize: 14.0),
            ),
            SizedBox(height: 8.0),
            Text(
              '「移行元スタッフ」と「移行先スタッフ」をそれぞれ選択し、最後に「移行する」ボタンを押してください。移行が完了すると、「移行元」のスタッフデータは削除されます。',
              style: TextStyle(color: Colors.black54, fontSize: 14.0),
            ),
            SizedBox(height: 16.0),
            Text('移行元スタッフ(未スマホユーザー)', style: TextStyle(fontSize: 14.0)),
            CustomDropdownButton(
              isExpanded: true,
              value: selectBefore,
              onChanged: (value) {
                setState(() => selectBefore = value);
              },
              items: before.map((value) {
                return DropdownMenuItem<UserModel>(
                  value: value,
                  child: Text(
                    '${value.name}',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14.0,
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 8.0),
            Center(
              child: Icon(
                Icons.arrow_downward,
                color: Colors.black54,
                size: 28.0,
              ),
            ),
            SizedBox(height: 8.0),
            Text('移行先スタッフ(スマホユーザー)', style: TextStyle(fontSize: 14.0)),
            CustomDropdownButton(
              isExpanded: false,
              value: selectAfter,
              onChanged: (value) {
                setState(() => selectAfter = value);
              },
              items: after.map((value) {
                return DropdownMenuItem<UserModel>(
                  value: value,
                  child: Text(
                    '${value.name}',
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
                  onPressed: () => Navigator.pop(context),
                  color: Colors.grey,
                  label: 'キャンセル',
                ),
                CustomTextButton(
                  onPressed: () async {
                    if (!await widget.userProvider.migration(
                      groupId: widget.groupProvider.group.id,
                      before: selectBefore,
                      after: selectAfter,
                    )) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('データの移行が完了しました')),
                    );
                    Navigator.pop(context);
                  },
                  color: Colors.cyan,
                  label: '移行する',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddUserDialog extends StatefulWidget {
  final GroupProvider groupProvider;
  final UserProvider userProvider;

  AddUserDialog({
    @required this.groupProvider,
    @required this.userProvider,
  });

  @override
  _AddUserDialogState createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  TextEditingController name = TextEditingController();
  TextEditingController recordPassword = TextEditingController();

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
              '項目を全て入力して、最後に「登録する」ボタンを押してください。',
              style: TextStyle(color: Colors.black54, fontSize: 14.0),
            ),
            Text(
              '※ここで新規登録したスタッフデータではスマートフォンアプリにログインできません。スマートフォンアプリから新規登録して、会社/組織へ加入してください。',
              style: TextStyle(color: Colors.redAccent, fontSize: 14.0),
            ),
            SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('スタッフ名', style: TextStyle(fontSize: 14.0)),
                CustomTextFormField2(
                  textInputType: null,
                  maxLines: 1,
                  controller: name,
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('タブレット用暗証番号', style: TextStyle(fontSize: 14.0)),
                CustomTextFormField2(
                  textInputType: null,
                  maxLines: 1,
                  controller: recordPassword,
                ),
              ],
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
                    if (!await widget.userProvider.create(
                      name: name.text.trim(),
                      recordPassword: recordPassword.text.trim(),
                      group: widget.groupProvider.group,
                    )) {
                      return;
                    }
                    widget.groupProvider.reloadGroupModel();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('スタッフを登録しました')),
                    );
                    Navigator.pop(context);
                  },
                  color: Colors.blue,
                  label: '登録する',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EditUserDialog extends StatefulWidget {
  final GroupProvider groupProvider;
  final UserProvider userProvider;
  final UserModel user;

  EditUserDialog({
    @required this.groupProvider,
    @required this.userProvider,
    @required this.user,
  });

  @override
  _EditUserDialogState createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  TextEditingController name = TextEditingController();
  TextEditingController recordPassword = TextEditingController();

  void _init() async {
    name.text = widget.user?.name;
    recordPassword.text = widget.user?.recordPassword;
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
              'スタッフの情報を修正できます。',
              style: TextStyle(color: Colors.black54, fontSize: 14.0),
            ),
            Text(
              '※スマートフォンアプリから登録している方は、この画面では削除はできません。スマートフォンアプリ内から削除するか、会社/組織から脱退してください。',
              style: TextStyle(color: Colors.redAccent, fontSize: 14.0),
            ),
            SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('スタッフ名', style: TextStyle(fontSize: 14.0)),
                CustomTextFormField2(
                  textInputType: null,
                  maxLines: 1,
                  controller: name,
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('タブレット用暗証番号', style: TextStyle(fontSize: 14.0)),
                CustomTextFormField2(
                  textInputType: null,
                  maxLines: 1,
                  controller: recordPassword,
                ),
              ],
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
                    widget.user.smartphone
                        ? CustomTextButton(
                            onPressed: null,
                            color: Colors.grey,
                            label: '削除する',
                          )
                        : CustomTextButton(
                            onPressed: () {
                              widget.userProvider.delete(
                                user: widget.user,
                                group: widget.groupProvider.group,
                              );
                              widget.groupProvider.reloadGroupModel();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('スタッフを削除しました')),
                              );
                              Navigator.pop(context);
                            },
                            color: Colors.red,
                            label: '削除する',
                          ),
                    SizedBox(width: 4.0),
                    CustomTextButton(
                      onPressed: () async {
                        if (!await widget.userProvider.update(
                          id: widget.user.id,
                          name: name.text.trim(),
                          recordPassword: recordPassword.text.trim(),
                        )) {
                          return;
                        }
                        widget.groupProvider.reloadGroupModel();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('スタッフを修正しました')),
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
