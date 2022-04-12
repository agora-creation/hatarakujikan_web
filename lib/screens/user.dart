import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/providers/user.dart';
import 'package:hatarakujikan_web/widgets/admin_header.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold.dart';
import 'package:hatarakujikan_web/widgets/custom_dropdown_button.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';
import 'package:hatarakujikan_web/widgets/custom_text_form_field2.dart';
import 'package:hatarakujikan_web/widgets/text_icon_button.dart';
import 'package:provider/provider.dart';

class UserScreen extends StatelessWidget {
  static const String id = 'user';

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    GroupModel? group = groupProvider.group;
    List<UserModel> users = [];
    Stream<QuerySnapshot<Map<String, dynamic>>>? stream = FirebaseFirestore
        .instance
        .collection('user')
        .where('id', whereIn: group?.userIds ?? [''])
        .orderBy('recordPassword', descending: false)
        .snapshots();

    return CustomAdminScaffold(
      groupProvider: groupProvider,
      selectedRoute: id,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminHeader(
            title: 'スタッフの管理',
            message:
                '会社/組織へ所属するスタッフを登録し、タブレットアプリで打刻できるようにします。スマホアプリを利用できるようにここで設定も可能です。',
          ),
          SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(),
              TextIconButton(
                iconData: Icons.add,
                iconColor: Colors.white,
                label: '新規登録',
                labelColor: Colors.white,
                backgroundColor: Colors.blue,
                onPressed: () {
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (_) => AddDialog(
                      userProvider: userProvider,
                      group: group,
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: stream,
              builder: (context, snapshot) {
                users.clear();
                if (snapshot.hasData) {
                  for (DocumentSnapshot<Map<String, dynamic>> doc
                      in snapshot.data!.docs) {
                    users.add(UserModel.fromSnapshot(doc));
                  }
                }
                if (users.length == 0) return Text('現在登録しているスタッフはいません。');
                return DataTable2(
                  columns: [
                    DataColumn2(label: Text('スタッフ番号'), size: ColumnSize.M),
                    DataColumn2(label: Text('スタッフ名'), size: ColumnSize.M),
                    DataColumn2(label: Text('タブレット用暗証番号'), size: ColumnSize.M),
                    DataColumn2(label: Text('修正/削除'), size: ColumnSize.S),
                    DataColumn2(label: Text('スマホアプリ利用'), size: ColumnSize.M),
                  ],
                  rows: List<DataRow>.generate(
                    users.length,
                    (index) => DataRow(
                      cells: [
                        DataCell(Text('${users[index].number}')),
                        DataCell(Text('${users[index].name}')),
                        DataCell(Text('${users[index].recordPassword}')),
                        DataCell(IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (_) => EditDialog(
                                userProvider: userProvider,
                                user: users[index],
                                group: group,
                              ),
                            );
                          },
                        )),
                        DataCell(IconButton(
                          icon: users[index].smartphone == true
                              ? Icon(Icons.smartphone, color: Colors.blue)
                              : Icon(Icons.no_cell, color: Colors.blue),
                          onPressed: () {
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (_) => SmartphoneDialog(
                                groupProvider: groupProvider,
                                userProvider: userProvider,
                                user: users[index],
                                group: group,
                              ),
                            );
                          },
                        )),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AddDialog extends StatefulWidget {
  final UserProvider userProvider;
  final GroupModel? group;

  AddDialog({
    required this.userProvider,
    this.group,
  });

  @override
  State<AddDialog> createState() => _AddDialogState();
}

class _AddDialogState extends State<AddDialog> {
  TextEditingController number = TextEditingController();
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
            Text(
              '情報を入力し、「登録する」ボタンをクリックしてください。',
              style: kDialogTextStyle,
            ),
            SizedBox(height: 16.0),
            CustomTextFormField2(
              label: 'スタッフ番号',
              controller: number,
              textInputType: null,
              maxLines: 1,
              onChanged: (value) {
                recordPassword.text = value;
              },
            ),
            SizedBox(height: 8.0),
            CustomTextFormField2(
              label: 'スタッフ名',
              controller: name,
              textInputType: null,
              maxLines: 1,
            ),
            SizedBox(height: 8.0),
            CustomTextFormField2(
              label: 'タブレット用暗証番号',
              controller: recordPassword,
              textInputType: null,
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
                  label: '登録する',
                  color: Colors.blue,
                  onPressed: () async {
                    if (!await widget.userProvider.create(
                      group: widget.group,
                      number: number.text.trim(),
                      name: name.text.trim(),
                      recordPassword: recordPassword.text.trim(),
                    )) {
                      return;
                    }
                    customSnackBar(context, 'スタッフを登録しました');
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

class EditDialog extends StatefulWidget {
  final UserProvider userProvider;
  final UserModel user;
  final GroupModel? group;

  EditDialog({
    required this.userProvider,
    required this.user,
    required this.group,
  });

  @override
  State<EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  TextEditingController number = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController recordPassword = TextEditingController();

  void _init() async {
    number.text = widget.user.number;
    name.text = widget.user.name;
    recordPassword.text = widget.user.recordPassword;
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
              label: 'スタッフ番号',
              controller: number,
              textInputType: null,
              maxLines: 1,
              onChanged: (value) {
                recordPassword.text = value;
              },
            ),
            SizedBox(height: 8.0),
            CustomTextFormField2(
              label: 'スタッフ名',
              controller: name,
              textInputType: null,
              maxLines: 1,
            ),
            SizedBox(height: 8.0),
            CustomTextFormField2(
              label: 'タブレット用暗証番号',
              controller: recordPassword,
              textInputType: null,
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
                Row(
                  children: [
                    CustomTextButton(
                      label: '削除する',
                      color: Colors.red,
                      onPressed: () async {
                        if (!await widget.userProvider.delete(
                          group: widget.group,
                          id: widget.user.id,
                        )) {
                          return;
                        }
                        customSnackBar(context, 'スタッフを削除しました');
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(width: 4.0),
                    CustomTextButton(
                      label: '保存する',
                      color: Colors.blue,
                      onPressed: () async {
                        if (!await widget.userProvider.update(
                          id: widget.user.id,
                          number: number.text.trim(),
                          name: name.text.trim(),
                          recordPassword: recordPassword.text.trim(),
                        )) {
                          return;
                        }
                        customSnackBar(context, 'スタッフを保存しました');
                        Navigator.pop(context);
                      },
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

class SmartphoneDialog extends StatefulWidget {
  final GroupProvider groupProvider;
  final UserProvider userProvider;
  final UserModel user;
  final GroupModel? group;

  SmartphoneDialog({
    required this.groupProvider,
    required this.userProvider,
    required this.user,
    required this.group,
  });

  @override
  State<SmartphoneDialog> createState() => _SmartphoneDialogState();
}

class _SmartphoneDialogState extends State<SmartphoneDialog> {
  bool? smartphone;
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  void _init() async {
    smartphone = widget.user.smartphone;
    email.text = widget.user.email;
    password.text = widget.user.password;
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
              '有効になったスタッフはアプリをインストールし、メールアドレスとパスワードでログインしてください。',
              style: kDialogTextStyle,
            ),
            SizedBox(height: 16.0),
            CustomDropdownButton(
              label: 'スマホアプリ利用',
              isExpanded: true,
              value: smartphone,
              onChanged: (value) {
                setState(() => smartphone = value);
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
            smartphone == true
                ? Column(
                    children: [
                      SizedBox(height: 8.0),
                      CustomTextFormField2(
                        label: 'メールアドレス',
                        controller: email,
                        textInputType: TextInputType.emailAddress,
                        maxLines: 1,
                      ),
                      SizedBox(height: 8.0),
                      CustomTextFormField2(
                        label: 'パスワード',
                        controller: password,
                        textInputType: TextInputType.visiblePassword,
                        maxLines: 1,
                      ),
                    ],
                  )
                : Container(),
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
                    await widget.groupProvider.signOut2();
                    String? newId = await widget.userProvider.createAuth(
                      email: email.text.trim(),
                      password: password.text.trim(),
                    );
                    if (newId == '') {
                      return;
                    }
                    if (!await widget.groupProvider.signIn2()) {
                      return;
                    }
                    if (!await widget.userProvider.reCreate(
                      group: widget.group,
                      user: widget.user,
                      newId: newId,
                      email: email.text.trim(),
                      password: password.text.trim(),
                    )) {
                      return;
                    }

                    widget.groupProvider.reloadGroup();
                    customSnackBar(context, 'スマホアプリ利用の設定を保存しました');
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
