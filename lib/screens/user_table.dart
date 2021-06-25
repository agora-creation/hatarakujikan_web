import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/providers/user.dart';
import 'package:hatarakujikan_web/widgets/custom_icon_label.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';
import 'package:hatarakujikan_web/widgets/custom_text_icon_button.dart';
import 'package:hatarakujikan_web/widgets/loading.dart';
import 'package:intl/intl.dart';

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
        .orderBy('name', descending: false)
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
          'スタッフの情報を一覧表示します。アプリから登録するか、この画面で登録できます。',
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
                        groupId: widget.groupProvider.group?.id,
                        positions: widget.groupProvider.group?.positions ?? [],
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
                  DataColumn(label: Text('名前')),
                  DataColumn(label: Text('雇用形態')),
                  DataColumn2(label: Text('タブレット用暗証番号'), size: ColumnSize.L),
                  DataColumn(label: Text('スマホ利用状況')),
                  DataColumn(label: Text('管理者権限')),
                ],
                rows: List<DataRow>.generate(
                  users.length,
                  (index) => DataRow(
                    onSelectChanged: (value) {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (_) => UserDetailsDialog(
                          userProvider: widget.userProvider,
                          user: users[index],
                          positions:
                              widget.groupProvider.group?.positions ?? [],
                        ),
                      );
                    },
                    cells: [
                      DataCell(Text('${users[index].name}')),
                      DataCell(Text('${users[index].position}')),
                      DataCell(Text('${users[index].recordPassword}')),
                      users[index].smartphone
                          ? DataCell(
                              Icon(
                                Icons.smartphone,
                                color: Colors.blue,
                              ),
                            )
                          : DataCell(
                              Icon(
                                Icons.smartphone,
                                color: Colors.transparent,
                              ),
                            ),
                      users[index].id == widget.groupProvider.group?.adminUserId
                          ? DataCell(
                              Icon(
                                Icons.admin_panel_settings,
                                color: Colors.red,
                              ),
                            )
                          : DataCell(
                              Icon(
                                Icons.admin_panel_settings,
                                color: Colors.transparent,
                              ),
                            ),
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
              '「移行元」と「移行先」を選択し、最後に「移行する」ボタンを押してください。',
              style: TextStyle(color: Colors.black54, fontSize: 14.0),
            ),
            Text(
              '移行が完了すると、「移行元」のスタッフデータは削除されます。',
              style: TextStyle(color: Colors.black54, fontSize: 14.0),
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomIconLabel(
                        icon: Icon(Icons.person, color: Colors.black54),
                        label: '移行元',
                      ),
                      DropdownButton<UserModel>(
                        isExpanded: true,
                        hint: Text('選択してください'),
                        value: selectBefUser,
                        onChanged: (value) {
                          setState(() => selectBefUser = value);
                        },
                        items: befUsers.map((value) {
                          return DropdownMenuItem<UserModel>(
                            value: value,
                            child: Text('${value.name}'),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.0),
                Center(
                  child: Icon(
                    Icons.arrow_forward,
                    color: Colors.black54,
                    size: 24.0,
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomIconLabel(
                        icon: Icon(Icons.person, color: Colors.black54),
                        label: '移行先',
                      ),
                      DropdownButton<UserModel>(
                        isExpanded: true,
                        hint: Text('選択してください'),
                        value: selectAftUser,
                        onChanged: (value) {
                          setState(() => selectAftUser = value);
                        },
                        items: aftUsers.map((value) {
                          return DropdownMenuItem<UserModel>(
                            value: value,
                            child: Text('${value.name}'),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
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
  final String groupId;
  final List<String> positions;

  AddUserDialog({
    @required this.userProvider,
    @required this.groupId,
    @required this.positions,
  });

  @override
  _AddUserDialogState createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  TextEditingController name = TextEditingController();
  TextEditingController recordPassword = TextEditingController();
  String position = '';

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
              'また、ここで登録したスタッフデータではスマートフォンアプリをご利用いただけません。スマートフォンアプリ内からご登録をお願いいたします。',
              style: TextStyle(color: Colors.black54, fontSize: 14.0),
            ),
            SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('名前', style: TextStyle(fontSize: 14.0)),
                TextFormField(
                  controller: name,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14.0,
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('タブレット用暗証番号', style: TextStyle(fontSize: 14.0)),
                TextFormField(
                  controller: recordPassword,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14.0,
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('雇用形態', style: TextStyle(fontSize: 14.0)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black38),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: position != '' ? position : null,
                      onChanged: (value) {
                        setState(() => position = value);
                      },
                      items: widget.positions.map((value) {
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
                      groupId: widget.groupId,
                      position: position,
                    )) {
                      return;
                    }
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

class UserDetailsDialog extends StatefulWidget {
  final UserProvider userProvider;
  final UserModel user;
  final List<String> positions;

  UserDetailsDialog({
    @required this.userProvider,
    @required this.user,
    @required this.positions,
  });

  @override
  _UserDetailsDialogState createState() => _UserDetailsDialogState();
}

class _UserDetailsDialogState extends State<UserDetailsDialog> {
  TextEditingController name = TextEditingController();
  TextEditingController recordPassword = TextEditingController();
  String position = '';

  void _init() async {
    setState(() {
      name.text = widget.user?.name;
      recordPassword.text = widget.user?.recordPassword;
      position = widget.user?.position ?? '';
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
              'ただしスマートフォン利用をされている方は、ここで削除はできません。スマートフォンアプリ内で操作をお願いいたします。',
              style: TextStyle(color: Colors.black54, fontSize: 14.0),
            ),
            SizedBox(height: 16.0),
            Container(
              decoration: kBottomBorderDecoration,
              child: ListTile(
                leading: Text('名前'),
                title: TextFormField(
                  controller: name,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14.0,
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            Container(
              decoration: kBottomBorderDecoration,
              child: ListTile(
                leading: Text('タブレット用暗証番号'),
                title: TextFormField(
                  controller: recordPassword,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14.0,
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            Container(
              decoration: kBottomBorderDecoration,
              child: ListTile(
                leading: Text('雇用形態'),
                title: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black38),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: position != '' ? position : null,
                      onChanged: (value) {
                        setState(() => position = value);
                      },
                      items: widget.positions.map((value) {
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
              ),
            ),
            Container(
              decoration: kBottomBorderDecoration,
              child: ListTile(
                leading: Text('作成日時'),
                title: Text(
                  '${DateFormat('yyyy/MM/dd HH:mm').format(widget.user.createdAt)}',
                ),
              ),
            ),
            Container(
              decoration: kBottomBorderDecoration,
              child: ListTile(
                leading: Text('スマホ利用状況'),
                title: widget.user.smartphone ? Text('利用中') : Text(''),
              ),
            ),
            widget.user.smartphone
                ? Container(
                    decoration: kBottomBorderDecoration,
                    child: ListTile(
                      leading: Text('メールアドレス'),
                      title: Text('${widget.user.email}'),
                    ),
                  )
                : Container(),
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
                          position: position,
                        )) {
                          return;
                        }
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
