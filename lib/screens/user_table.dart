import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/providers/user.dart';
import 'package:hatarakujikan_web/widgets/custom_dropdown_button.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';
import 'package:hatarakujikan_web/widgets/custom_text_form_field2.dart';
import 'package:hatarakujikan_web/widgets/custom_text_icon_button.dart';
import 'package:hatarakujikan_web/widgets/loading.dart';

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
    Stream<QuerySnapshot> _stream = FirebaseFirestore.instance
        .collection('user')
        .where('groups', arrayContains: widget.groupProvider.group?.id)
        .orderBy('recordPassword', descending: false)
        .snapshots();
    List<UserModel> users = [];

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
                  onPressed: () async {
                    List<UserModel> befUsers = [];
                    List<UserModel> aftUsers = [];
                    await widget.userProvider
                        .selectListSP(
                      groupId: widget.groupProvider.group?.id,
                      smartphone: false,
                    )
                        .then((value) {
                      befUsers = value;
                    });
                    await widget.userProvider
                        .selectListSP(
                      groupId: widget.groupProvider.group?.id,
                      smartphone: true,
                    )
                        .then((value) {
                      aftUsers = value;
                    });
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (_) => MigrationDialog(
                        befUsers: befUsers,
                        aftUsers: aftUsers,
                        userProvider: widget.userProvider,
                        groupId: widget.groupProvider.group?.id,
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
                        userProvider: widget.userProvider,
                        group: widget.groupProvider.group,
                        usersLen: users.length,
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
          child: StreamBuilder<QuerySnapshot>(
            stream: _stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Loading(color: Colors.orange);
              }
              users.clear();
              for (DocumentSnapshot user in snapshot.data.docs) {
                users.add(UserModel.fromSnapshot(user));
              }
              return DataTable2(
                columns: [
                  DataColumn(label: Text('スタッフ名')),
                  DataColumn2(label: Text('タブレット用暗証番号'), size: ColumnSize.L),
                  DataColumn(label: Text('メールアドレス')),
                  DataColumn2(label: Text('修正/削除'), size: ColumnSize.S),
                ],
                rows: List<DataRow>.generate(
                  users.length,
                  (index) => DataRow(
                    cells: [
                      DataCell(Text('${users[index].name}')),
                      DataCell(Text('${users[index].recordPassword}')),
                      DataCell(Text('${users[index].email}')),
                      DataCell(IconButton(
                        onPressed: () {
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (_) => EditUserDialog(
                              userProvider: widget.userProvider,
                              user: users[index],
                            ),
                          );
                        },
                        icon: Icon(Icons.edit, color: Colors.blue),
                      )),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class MigrationDialog extends StatefulWidget {
  final List<UserModel> befUsers;
  final List<UserModel> aftUsers;
  final UserProvider userProvider;
  final String groupId;

  MigrationDialog({
    @required this.befUsers,
    @required this.aftUsers,
    @required this.userProvider,
    @required this.groupId,
  });

  @override
  _MigrationDialogState createState() => _MigrationDialogState();
}

class _MigrationDialogState extends State<MigrationDialog> {
  List<UserModel> befUsers = [];
  List<UserModel> aftUsers = [];
  UserModel selectBefUser;
  UserModel selectAftUser;

  void _init() async {
    setState(() {
      befUsers = widget.befUsers;
      aftUsers = widget.aftUsers;
      selectBefUser = null;
      selectAftUser = null;
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
              value: selectBefUser,
              onChanged: (value) {
                setState(() => selectBefUser = value);
              },
              items: befUsers.map((value) {
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
              value: selectAftUser,
              onChanged: (value) {
                setState(() => selectAftUser = value);
              },
              items: aftUsers.map((value) {
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
                      groupId: widget.groupId,
                      befUser: selectBefUser,
                      aftUser: selectAftUser,
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
  final UserProvider userProvider;
  final GroupModel group;
  final int usersLen;

  AddUserDialog({
    @required this.userProvider,
    @required this.group,
    @required this.usersLen,
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
                      group: widget.group,
                      usersLen: widget.usersLen,
                      name: name.text.trim(),
                      recordPassword: recordPassword.text.trim(),
                    )) {
                      return;
                    }
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
  final UserProvider userProvider;
  final UserModel user;

  EditUserDialog({
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
    setState(() {
      name.text = widget.user?.name;
      recordPassword.text = widget.user?.recordPassword;
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
                              widget.userProvider.delete(user: widget.user);
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
