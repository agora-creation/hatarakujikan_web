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
import 'package:hatarakujikan_web/widgets/custom_text_button_mini.dart';
import 'package:hatarakujikan_web/widgets/custom_text_form_field2.dart';
import 'package:hatarakujikan_web/widgets/text_icon_button.dart';
import 'package:hatarakujikan_web/widgets/time_form_field.dart';
import 'package:provider/provider.dart';

class UserScreen extends StatelessWidget {
  static const String id = 'user';

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    GroupModel? group = groupProvider.group;
    List<String> userIds = group?.userIds ?? [];
    List<UserModel> users = [];

    return CustomAdminScaffold(
      groupProvider: groupProvider,
      selectedRoute: id,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminHeader(
            title: 'スタッフの管理',
            message: '会社/組織へ所属するスタッフを登録し、タブレットアプリで打刻できるようにします。',
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
          Text(
            'スマホアプリを利用していなかったスタッフが、スマホアプリの利用を始めた場合、一覧に重複した名前で登録されるはずです。\n「スマホアプリ」のアイコンをタップして、古いスタッフデータと同期してください。',
            style: TextStyle(color: Colors.red),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: userProvider.streamList(),
              builder: (context, snapshot) {
                users.clear();
                if (snapshot.hasData) {
                  for (DocumentSnapshot<Map<String, dynamic>> doc
                      in snapshot.data!.docs) {
                    UserModel _user = UserModel.fromSnapshot(doc);
                    if (userIds.contains(_user.id)) {
                      users.add(_user);
                    }
                  }
                }
                if (users.length == 0) return Text('現在登録しているスタッフはいません。');
                return DataTable2(
                  columns: [
                    DataColumn2(label: Text('スタッフ番号'), size: ColumnSize.M),
                    DataColumn2(label: Text('スタッフ名'), size: ColumnSize.M),
                    DataColumn2(label: Text('タブレット用暗証番号'), size: ColumnSize.M),
                    DataColumn2(label: Text('修正/削除'), size: ColumnSize.S),
                    DataColumn2(label: Text('アプリ利用'), size: ColumnSize.S),
                    DataColumn2(label: Text('退職'), size: ColumnSize.S),
                  ],
                  rows: List<DataRow>.generate(
                    users.length,
                    (index) => DataRow(
                      color: users[index].retired == true
                          ? MaterialStateProperty.all<Color>(Colors.grey)
                          : null,
                      cells: [
                        DataCell(Text('${users[index].number}')),
                        DataCell(Text('${users[index].name}')),
                        DataCell(Text('${users[index].recordPassword}')),
                        users[index].retired == false
                            ? DataCell(IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (_) => EditDialog(
                                      userProvider: userProvider,
                                      user: users[index],
                                      group: group,
                                      adminUser: groupProvider.adminUser,
                                    ),
                                  );
                                },
                              ))
                            : DataCell(Container()),
                        users[index].retired == false &&
                                users[index].smartphone == true
                            ? DataCell(CustomTextButtonMini(
                                label: '旧データと同期',
                                color: Colors.cyan,
                                onPressed: () {
                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (_) => MigrationDialog(
                                      groupProvider: groupProvider,
                                      userProvider: userProvider,
                                      afterUser: users[index],
                                    ),
                                  );
                                },
                              ))
                            : DataCell(Container()),
                        users[index].retired == true
                            ? DataCell(CustomTextButtonMini(
                                label: '退職済み',
                                color: Colors.grey,
                              ))
                            : DataCell(CustomTextButtonMini(
                                label: '退職させる',
                                color: Colors.deepOrange,
                                onPressed: () {
                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (_) => RetiredDialog(
                                      userProvider: userProvider,
                                      user: users[index],
                                      adminUser: groupProvider.adminUser,
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
  final UserModel? adminUser;

  EditDialog({
    required this.userProvider,
    required this.user,
    this.group,
    this.adminUser,
  });

  @override
  State<EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  TextEditingController number = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController recordPassword = TextEditingController();
  bool? autoWorkEnd;
  String? autoWorkEndTime;

  void _init() async {
    number.text = widget.user.number;
    name.text = widget.user.name;
    recordPassword.text = widget.user.recordPassword;
    autoWorkEnd = widget.user.autoWorkEnd;
    autoWorkEndTime = widget.user.autoWorkEndTime;
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
            widget.user.id == widget.adminUser?.id
                ? Text(
                    'このスタッフは会社/組織の管理者として設定されているため、現在削除できません。',
                    style: kDialogTextStyle,
                  )
                : Container(),
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
            SizedBox(height: 8.0),
            CustomDropdownButton(
              label: '自動退勤',
              isExpanded: true,
              value: autoWorkEnd,
              onChanged: (value) {
                setState(() => autoWorkEnd = value);
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
            autoWorkEnd == true ? SizedBox(height: 8.0) : Container(),
            autoWorkEnd == true
                ? TimeFormField(
                    label: '自動退勤時間',
                    time: autoWorkEndTime,
                    onPressed: () async {
                      String? _time = await customTimePicker(
                        context: context,
                        init: autoWorkEndTime,
                      );
                      if (_time == null) return;
                      setState(() => autoWorkEndTime = _time);
                    },
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
                Row(
                  children: [
                    CustomTextButton(
                      label: '削除する',
                      color: widget.user.id == widget.adminUser?.id
                          ? Colors.grey
                          : Colors.red,
                      onPressed: () async {
                        if (widget.user.id == widget.adminUser?.id) return;
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
                          autoWorkEnd: autoWorkEnd,
                          autoWorkEndTime: autoWorkEndTime,
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

class MigrationDialog extends StatefulWidget {
  final GroupProvider groupProvider;
  final UserProvider userProvider;
  final UserModel afterUser;

  MigrationDialog({
    required this.groupProvider,
    required this.userProvider,
    required this.afterUser,
  });

  @override
  _MigrationDialogState createState() => _MigrationDialogState();
}

class _MigrationDialogState extends State<MigrationDialog> {
  List<UserModel> beforeUsers = [];
  UserModel? beforeUser;

  void _init() async {
    List<UserModel> _beforeUsers = await widget.groupProvider.selectUsers(
      smartphone: false,
    );
    if (mounted) {
      setState(() {
        beforeUsers = _beforeUsers;
      });
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
      title: Text('旧スタッフデータとの同期'),
      content: Container(
        width: 450.0,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              '${widget.afterUser.name}はスマホアプリを使い始めました！\n過去のデータは全て旧スタッフデータと紐づいているため、ここで同期するスタッフデータを選択し、『同期する』ボタンをクリックしてください。',
              style: kDialogTextStyle,
            ),
            SizedBox(height: 16.0),
            CustomDropdownButton(
              label: '同期する旧スタッフデータ',
              isExpanded: true,
              value: beforeUser ?? null,
              onChanged: (value) {
                setState(() => beforeUser = value);
              },
              items: beforeUsers.map((user) {
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
            SizedBox(height: 4.0),
            Text(
              '※同期後は、上記で選択した旧スタッフデータは削除されます。',
              style: TextStyle(color: Colors.red),
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
                  label: '同期する',
                  color: Colors.blue,
                  onPressed: () async {
                    if (!await widget.userProvider.migration(
                      group: widget.groupProvider.group,
                      beforeUser: beforeUser,
                      afterUser: widget.afterUser,
                    )) {
                      return;
                    }
                    customSnackBar(context, 'スタッフデータの同期が完了しました');
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

class RetiredDialog extends StatefulWidget {
  final UserProvider userProvider;
  final UserModel user;
  final UserModel? adminUser;

  RetiredDialog({
    required this.userProvider,
    required this.user,
    this.adminUser,
  });

  @override
  State<RetiredDialog> createState() => _RetiredDialogState();
}

class _RetiredDialogState extends State<RetiredDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        width: 450.0,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              '${widget.user.name}を本当に退職させますか？',
              style: kDialogTextStyle,
            ),
            widget.user.id == widget.adminUser?.id
                ? Text(
                    'このスタッフは会社/組織の管理者として設定されているため、現在退職できません。',
                    style: kDialogTextStyle,
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
                  label: 'はい',
                  color: widget.user.id == widget.adminUser?.id
                      ? Colors.grey
                      : Colors.deepOrange,
                  onPressed: () async {
                    if (widget.user.id == widget.adminUser?.id) return;
                    if (!await widget.userProvider.retired(
                      id: widget.user.id,
                    )) {
                      return;
                    }
                    customSnackBar(context, 'スタッフを退職させました');
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
