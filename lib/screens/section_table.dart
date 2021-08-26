import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/section.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/providers/section.dart';
import 'package:hatarakujikan_web/providers/user.dart';
import 'package:hatarakujikan_web/widgets/custom_icon_label.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';
import 'package:hatarakujikan_web/widgets/custom_text_form_field2.dart';
import 'package:hatarakujikan_web/widgets/custom_text_icon_button.dart';
import 'package:hatarakujikan_web/widgets/loading.dart';

class SectionTable extends StatefulWidget {
  final GroupProvider groupProvider;
  final SectionProvider sectionProvider;
  final UserProvider userProvider;

  SectionTable({
    @required this.groupProvider,
    @required this.sectionProvider,
    @required this.userProvider,
  });

  @override
  _SectionTableState createState() => _SectionTableState();
}

class _SectionTableState extends State<SectionTable> {
  List<UserModel> users = [];

  void _init() async {
    String _groupId = widget.groupProvider.group?.id;
    await widget.userProvider.selectList(groupId: _groupId).then((value) {
      setState(() => users = value);
    });
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> _stream = FirebaseFirestore.instance
        .collection('section')
        .where('groupId', isEqualTo: widget.groupProvider.group?.id)
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
              for (DocumentSnapshot section in snapshot.data.docs) {
                sections.add(SectionModel.fromSnapshot(section));
              }
              if (sections.length > 0) {
                return DataTable2(
                  columns: [
                    DataColumn(label: Text('部署/事業所名')),
                    DataColumn2(label: Text('現在の登録スタッフ'), size: ColumnSize.L),
                    DataColumn2(label: Text('修正/削除'), size: ColumnSize.S),
                    DataColumn2(label: Text('スタッフ登録'), size: ColumnSize.S),
                  ],
                  rows: List<DataRow>.generate(
                    sections.length,
                    (index) => DataRow(
                      cells: [
                        DataCell(Text('${sections[index].name}')),
                        DataCell(Text(
                          '${sections[index].userIds}',
                          overflow: TextOverflow.ellipsis,
                        )),
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
                                sectionProvider: widget.sectionProvider,
                                userProvider: widget.userProvider,
                                section: sections[index],
                              ),
                            );
                          },
                          icon: Icon(Icons.person, color: Colors.blue),
                        )),
                      ],
                    ),
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
    setState(() {
      name.text = widget.section?.name;
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
                          id: widget.section.id,
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
  final SectionProvider sectionProvider;
  final UserProvider userProvider;
  final SectionModel section;

  UserSectionDialog({
    @required this.sectionProvider,
    @required this.userProvider,
    @required this.section,
  });

  @override
  _UserSectionDialogState createState() => _UserSectionDialogState();
}

class _UserSectionDialogState extends State<UserSectionDialog> {
  final ScrollController _scrollController = ScrollController();
  List<UserModel> _users = [];
  List<UserModel> _selected = [];

  void _init() async {
    await widget.userProvider
        .selectList(
      groupId: widget.section?.groupId,
    )
        .then((value) {
      setState(() => _users = value);
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
              width: 350.0,
              child: Scrollbar(
                isAlwaysShown: true,
                controller: _scrollController,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  controller: _scrollController,
                  itemCount: _users.length,
                  itemBuilder: (_, index) {
                    UserModel _user = _users[index];
                    var contain = _selected.where((e) => e.id == _user.id);

                    return Container(
                      decoration: kBottomBorderDecoration,
                      child: CheckboxListTile(
                        title: Text('${_user.name}'),
                        value: contain.isNotEmpty,
                        activeColor: Colors.blue,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (value) {
                          var _contain =
                              _selected.where((e) => e.id == _user.id);
                          setState(() {
                            if (_contain.isEmpty) {
                              _selected.add(_user);
                            } else {
                              _selected.removeWhere((e) => e.id == _user.id);
                            }
                          });
                        },
                      ),
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
                      users: _selected,
                      id: widget.section.id,
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
