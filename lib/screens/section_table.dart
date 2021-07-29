import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/section.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/providers/section.dart';
import 'package:hatarakujikan_web/providers/user.dart';
import 'package:hatarakujikan_web/widgets/custom_dropdown_button.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';
import 'package:hatarakujikan_web/widgets/custom_text_form_field2.dart';
import 'package:hatarakujikan_web/widgets/custom_text_icon_button.dart';
import 'package:hatarakujikan_web/widgets/loading.dart';

class SectionTable extends StatefulWidget {
  final GroupProvider groupProvider;
  final UserProvider userProvider;
  final SectionProvider sectionProvider;

  SectionTable({
    @required this.groupProvider,
    @required this.userProvider,
    @required this.sectionProvider,
  });

  @override
  _SectionTableState createState() => _SectionTableState();
}

class _SectionTableState extends State<SectionTable> {
  List<UserModel> users = [];

  void _init() async {
    await widget.userProvider
        .selectListSP(
      groupId: widget.groupProvider.group?.id,
      smartphone: true,
    )
        .then((value) {
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
          '部署の管理',
          style: kAdminTitleTextStyle,
        ),
        Text(
          '部署を一覧表示します。登録した部署は、「スタッフの管理」からそれぞれ割り当ててください。部署の管理者は別の管理画面にてログインして、部署毎のスタッフを管理できます。',
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
                    groupId: widget.groupProvider.group?.id,
                    users: users,
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
                    DataColumn(label: Text('部署名')),
                    DataColumn(label: Text('管理者スタッフ')),
                  ],
                  rows: List<DataRow>.generate(
                    sections.length,
                    (index) => DataRow(
                      onSelectChanged: (value) {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (_) => SectionDetailsDialog(
                            sectionProvider: widget.sectionProvider,
                            section: sections[index],
                            groupId: widget.groupProvider.group?.id,
                          ),
                        );
                      },
                      cells: [
                        DataCell(Text('${sections[index].name}')),
                        DataCell(Text('${sections[index].adminUserId}')),
                      ],
                    ),
                  ),
                );
              } else {
                return Text('現在登録されている部署はありません');
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
  final String groupId;
  final List<UserModel> users;

  AddSectionDialog({
    @required this.sectionProvider,
    @required this.groupId,
    @required this.users,
  });

  @override
  _AddSectionDialogState createState() => _AddSectionDialogState();
}

class _AddSectionDialogState extends State<AddSectionDialog> {
  TextEditingController name = TextEditingController();
  UserModel adminUser;

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
                Text('部署名', style: TextStyle(fontSize: 14.0)),
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
                Text('管理者スタッフ', style: TextStyle(fontSize: 14.0)),
                CustomDropdownButton(
                  value: adminUser,
                  onChanged: (value) {
                    setState(() => adminUser = value);
                  },
                  items: widget.users.map((value) {
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
                ),
                Text(
                  '※部署の管理者は、別管理画面の使用が可能です。',
                  style: TextStyle(color: Colors.redAccent, fontSize: 14.0),
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
                      groupId: widget.groupId,
                      name: name.text.trim(),
                      adminUserId: adminUser?.id,
                    )) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('部署を登録しました')),
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

class SectionDetailsDialog extends StatefulWidget {
  final SectionProvider sectionProvider;
  final SectionModel section;
  final String groupId;

  SectionDetailsDialog({
    @required this.sectionProvider,
    @required this.section,
    @required this.groupId,
  });

  @override
  _SectionDetailsDialogState createState() => _SectionDetailsDialogState();
}

class _SectionDetailsDialogState extends State<SectionDetailsDialog> {
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
              '部署の情報を修正できます。',
              style: TextStyle(color: Colors.black54, fontSize: 14.0),
            ),
            SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('部署名', style: TextStyle(fontSize: 14.0)),
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
                          groupId: widget.groupId,
                          name: name.text.trim(),
                          adminUserId: '',
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
