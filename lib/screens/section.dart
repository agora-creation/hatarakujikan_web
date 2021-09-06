import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/section.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/providers/section.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold.dart';
import 'package:hatarakujikan_web/widgets/custom_checkbox_list_tile.dart';
import 'package:hatarakujikan_web/widgets/custom_dropdown_button.dart';
import 'package:hatarakujikan_web/widgets/custom_icon_label.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';
import 'package:hatarakujikan_web/widgets/custom_text_form_field2.dart';
import 'package:hatarakujikan_web/widgets/custom_text_icon_button.dart';
import 'package:hatarakujikan_web/widgets/loading.dart';
import 'package:provider/provider.dart';

class SectionScreen extends StatelessWidget {
  static const String id = 'section';

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final sectionProvider = Provider.of<SectionProvider>(context);

    return CustomAdminScaffold(
      groupProvider: groupProvider,
      selectedRoute: id,
      body: SectionTable(
        groupProvider: groupProvider,
        sectionProvider: sectionProvider,
      ),
    );
  }
}

class SectionTable extends StatefulWidget {
  final GroupProvider groupProvider;
  final SectionProvider sectionProvider;

  SectionTable({
    @required this.groupProvider,
    @required this.sectionProvider,
  });

  @override
  _SectionTableState createState() => _SectionTableState();
}

class _SectionTableState extends State<SectionTable> {
  @override
  Widget build(BuildContext context) {
    GroupModel _group = widget.groupProvider.group;
    Stream<QuerySnapshot> _stream = FirebaseFirestore.instance
        .collection('section')
        .where('groupId', isEqualTo: _group?.id ?? 'error')
        .orderBy('createdAt', descending: true)
        .snapshots();
    List<SectionModel> sections = [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '部署/事業所の管理',
          style: kAdminTitleTextStyle,
        ),
        Text(
          '部署/事業所を一覧表示します。部署/事業所毎にスタッフを登録してください',
          style: kAdminSubTitleTextStyle,
        ),
        SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(),
            CustomTextIconButton(
              onPressed: () {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (_) => AddSectionDialog(
                    sectionProvider: widget.sectionProvider,
                    group: widget.groupProvider.group,
                  ),
                );
              },
              color: Colors.blue,
              iconData: Icons.add,
              label: '新規登録',
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
              sections.clear();
              for (DocumentSnapshot doc in snapshot.data.docs) {
                sections.add(SectionModel.fromSnapshot(doc));
              }
              if (sections.length > 0) {
                return DataTable2(
                  columns: [
                    DataColumn2(label: Text('部署/事業所名')),
                    DataColumn2(label: Text('現在の登録スタッフ'), size: ColumnSize.L),
                    DataColumn2(label: Text('現在の管理者')),
                    DataColumn2(label: Text('修正/削除'), size: ColumnSize.S),
                    DataColumn2(label: Text('スタッフ登録'), size: ColumnSize.S),
                    DataColumn2(label: Text('管理者登録'), size: ColumnSize.S),
                  ],
                  rows: List<DataRow>.generate(
                    sections.length,
                    (index) {
                      List<UserModel> _users = widget.groupProvider.users;
                      String _sectionUsers = '';
                      if (sections[index].userIds != null) {
                        for (String _id in sections[index].userIds) {
                          if (_sectionUsers != '') _sectionUsers += ',';
                          UserModel _user = _users.singleWhere(
                            (e) => e.id == _id,
                          );
                          _sectionUsers += _user.name;
                        }
                      }
                      String _sectionAdminUser = '';
                      if (sections[index].adminUserId != '') {
                        UserModel _user = _users.singleWhere(
                          (e) => e.id == sections[index].adminUserId,
                        );
                        _sectionAdminUser = _user.name;
                      }
                      return DataRow(
                        cells: [
                          DataCell(Text('${sections[index].name}')),
                          DataCell(Text(
                            '$_sectionUsers',
                            overflow: TextOverflow.ellipsis,
                          )),
                          DataCell(Text('$_sectionAdminUser')),
                          DataCell(IconButton(
                            onPressed: () {
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (_) => EditSectionDialog(
                                  sectionProvider: widget.sectionProvider,
                                  section: sections[index],
                                ),
                              );
                            },
                            icon: Icon(Icons.edit, color: Colors.blue),
                          )),
                          DataCell(IconButton(
                            onPressed: () {
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (_) => UserSectionDialog(
                                  groupProvider: widget.groupProvider,
                                  sectionProvider: widget.sectionProvider,
                                  section: sections[index],
                                ),
                              );
                            },
                            icon: Icon(Icons.person, color: Colors.blue),
                          )),
                          DataCell(IconButton(
                            onPressed: () {
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (_) => AdminUserSectionDialog(
                                  groupProvider: widget.groupProvider,
                                  sectionProvider: widget.sectionProvider,
                                  section: sections[index],
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.manage_accounts,
                              color: Colors.blue,
                            ),
                          )),
                        ],
                      );
                    },
                  ),
                );
              } else {
                return Text('現在登録されている部署/事業所はありません');
              }
            },
          ),
        ),
      ],
    );
  }
}

class AddSectionDialog extends StatefulWidget {
  final SectionProvider sectionProvider;
  final GroupModel group;

  AddSectionDialog({
    @required this.sectionProvider,
    @required this.group,
  });

  @override
  _AddSectionDialogState createState() => _AddSectionDialogState();
}

class _AddSectionDialogState extends State<AddSectionDialog> {
  TextEditingController name = TextEditingController();

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
            SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('部署/事業所名', style: TextStyle(fontSize: 14.0)),
                CustomTextFormField2(
                  textInputType: null,
                  maxLines: 1,
                  controller: name,
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
                    if (!await widget.sectionProvider.create(
                      groupId: widget.group.id,
                      name: name.text.trim(),
                    )) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('部署/事業所を登録しました')),
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

class EditSectionDialog extends StatefulWidget {
  final SectionProvider sectionProvider;
  final SectionModel section;

  EditSectionDialog({
    @required this.sectionProvider,
    @required this.section,
  });

  @override
  _EditSectionDialogState createState() => _EditSectionDialogState();
}

class _EditSectionDialogState extends State<EditSectionDialog> {
  TextEditingController name = TextEditingController();

  void _init() async {
    name.text = widget.section?.name;
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
              '部署/事業所の情報を修正できます。',
              style: TextStyle(color: Colors.black54, fontSize: 14.0),
            ),
            SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('部署/事業所名', style: TextStyle(fontSize: 14.0)),
                CustomTextFormField2(
                  textInputType: null,
                  maxLines: 1,
                  controller: name,
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
                    CustomTextButton(
                      onPressed: () {
                        widget.sectionProvider.delete(section: widget.section);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('部署/事業所を削除しました')),
                        );
                        Navigator.pop(context);
                      },
                      color: Colors.red,
                      label: '削除する',
                    ),
                    SizedBox(width: 4.0),
                    CustomTextButton(
                      onPressed: () async {
                        if (!await widget.sectionProvider.update(
                          id: widget.section?.id,
                          name: name.text.trim(),
                        )) {
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('部署/事業所を修正しました')),
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

class UserSectionDialog extends StatefulWidget {
  final GroupProvider groupProvider;
  final SectionProvider sectionProvider;
  final SectionModel section;

  UserSectionDialog({
    @required this.groupProvider,
    @required this.sectionProvider,
    @required this.section,
  });

  @override
  _UserSectionDialogState createState() => _UserSectionDialogState();
}

class _UserSectionDialogState extends State<UserSectionDialog> {
  final ScrollController _scrollController = ScrollController();
  List<UserModel> _selected = [];

  void _init() async {
    for (String _id in widget.section?.userIds) {
      UserModel _user = widget.groupProvider.users.singleWhere(
        (e) => e.id == _id,
      );
      _selected.add(_user);
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
            SizedBox(height: 16.0),
            Text(
              '登録した部署/事業所情報にスタッフ情報を紐付けします。各スタッフを選択して、登録してください。',
              style: TextStyle(color: Colors.black54, fontSize: 14.0),
            ),
            SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '部署/事業所名',
                  style: TextStyle(color: Colors.black54, fontSize: 14.0),
                ),
                Text('${widget.section?.name}'),
              ],
            ),
            Divider(),
            SizedBox(height: 8.0),
            CustomIconLabel(
              iconData: Icons.person,
              label: 'スタッフ',
            ),
            Container(
              width: 250.0,
              child: Scrollbar(
                isAlwaysShown: true,
                controller: _scrollController,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  controller: _scrollController,
                  itemCount: widget.groupProvider.users.length,
                  itemBuilder: (_, index) {
                    UserModel _user = widget.groupProvider.users[index];
                    var contain = _selected.where((e) => e.id == _user.id);
                    return CustomCheckboxListTile(
                      onChanged: (value) {
                        var _contain = _selected.where((e) => e.id == _user.id);
                        setState(() {
                          if (_contain.isEmpty) {
                            _selected.add(_user);
                          } else {
                            _selected.removeWhere((e) => e.id == _user.id);
                          }
                        });
                      },
                      label: '${_user.name}',
                      value: contain.isNotEmpty,
                    );
                  },
                ),
              ),
            ),
            Divider(height: 0.0),
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
                    if (!await widget.sectionProvider.updateUsers(
                      section: widget.section,
                      users: _selected,
                    )) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('部署/事業所情報にスタッフ情報を登録しました')),
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

class AdminUserSectionDialog extends StatefulWidget {
  final GroupProvider groupProvider;
  final SectionProvider sectionProvider;
  final SectionModel section;

  AdminUserSectionDialog({
    @required this.groupProvider,
    @required this.sectionProvider,
    @required this.section,
  });

  @override
  _AdminUserSectionDialogState createState() => _AdminUserSectionDialogState();
}

class _AdminUserSectionDialogState extends State<AdminUserSectionDialog> {
  UserModel _selected;

  void _init() async {
    if (widget.section?.adminUserId != '') {
      _selected = widget.groupProvider.users.singleWhere(
        (e) => e.id == widget.section?.adminUserId,
      );
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
            SizedBox(height: 16.0),
            Text(
              '登録したスタッフ情報の中から管理者を一人決めます。部署/事業所の管理者は専用の管理画面とタブレットアプリを利用できます。',
              style: TextStyle(color: Colors.black54, fontSize: 14.0),
            ),
            SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '部署/事業所名',
                  style: TextStyle(color: Colors.black54, fontSize: 14.0),
                ),
                Text('${widget.section?.name}'),
              ],
            ),
            Divider(),
            SizedBox(height: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '管理者を選ぶ',
                  style: TextStyle(color: Colors.black54, fontSize: 14.0),
                ),
                widget.groupProvider.users.length > 0
                    ? CustomDropdownButton(
                        isExpanded: true,
                        value: _selected,
                        onChanged: (value) {
                          setState(() => _selected = value);
                        },
                        items: widget.groupProvider.users.map((value) {
                          return DropdownMenuItem(
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
                      )
                    : Container(),
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
                    if (!await widget.sectionProvider.updateAdminUser(
                      section: widget.section,
                      user: _selected,
                    )) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('部署/事業所情報に管理者を登録しました。')),
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
