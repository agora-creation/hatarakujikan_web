import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/group_notice.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/providers/group_notice.dart';
import 'package:hatarakujikan_web/providers/user.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';
import 'package:hatarakujikan_web/widgets/custom_text_icon_button.dart';
import 'package:hatarakujikan_web/widgets/loading.dart';
import 'package:intl/intl.dart';

class GroupNoticeTable extends StatefulWidget {
  final GroupProvider groupProvider;
  final GroupNoticeProvider groupNoticeProvider;
  final UserProvider userProvider;

  GroupNoticeTable({
    @required this.groupProvider,
    @required this.groupNoticeProvider,
    @required this.userProvider,
  });

  @override
  _GroupNoticeTableState createState() => _GroupNoticeTableState();
}

class _GroupNoticeTableState extends State<GroupNoticeTable> {
  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> _stream = FirebaseFirestore.instance
        .collection('group')
        .doc(widget.groupProvider.group?.id)
        .collection('notice')
        .where('groupId', isEqualTo: widget.groupProvider.group?.id)
        .orderBy('createdAt', descending: true)
        .snapshots();
    List<GroupNoticeModel> groupNotices = [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'お知らせの管理',
          style: kAdminTitleTextStyle,
        ),
        Text(
          'お知らせを一覧表示します。このお知らせはアプリの方専用です。',
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
                  builder: (_) => AddGroupNoticeDialog(
                    groupNoticeProvider: widget.groupNoticeProvider,
                    groupId: widget.groupProvider.group?.id,
                  ),
                );
              },
              color: Colors.blue,
              iconData: Icons.notification_add,
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
              groupNotices.clear();
              for (DocumentSnapshot groupNotice in snapshot.data.docs) {
                groupNotices.add(GroupNoticeModel.fromSnapshot(groupNotice));
              }
              return DataTable2(
                columns: [
                  DataColumn2(label: Text('登録日時'), size: ColumnSize.S),
                  DataColumn(label: Text('タイトル')),
                  DataColumn2(label: Text('メッセージ'), size: ColumnSize.L),
                ],
                rows: List<DataRow>.generate(
                  groupNotices.length,
                  (index) => DataRow(
                    onSelectChanged: (value) {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (_) => GroupNoticeDetailsDialog(
                          groupNoticeProvider: widget.groupNoticeProvider,
                          groupNotice: groupNotices[index],
                          userProvider: widget.userProvider,
                        ),
                      );
                    },
                    cells: [
                      DataCell(
                        Text(
                          '${DateFormat('yyyy/MM/dd HH:mm').format(groupNotices[index].createdAt)}',
                        ),
                      ),
                      DataCell(Text('${groupNotices[index].title}')),
                      DataCell(Text('${groupNotices[index].message}')),
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

class AddGroupNoticeDialog extends StatefulWidget {
  final GroupNoticeProvider groupNoticeProvider;
  final String groupId;

  AddGroupNoticeDialog({
    @required this.groupNoticeProvider,
    @required this.groupId,
  });

  @override
  _AddGroupNoticeDialogState createState() => _AddGroupNoticeDialogState();
}

class _AddGroupNoticeDialogState extends State<AddGroupNoticeDialog> {
  TextEditingController title = TextEditingController();
  TextEditingController message = TextEditingController();

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
                Text('タイトル', style: TextStyle(fontSize: 14.0)),
                TextFormField(
                  controller: title,
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
                Text('メッセージ', style: TextStyle(fontSize: 14.0)),
                TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  controller: message,
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
                CustomTextButton(
                  onPressed: () async {
                    if (!await widget.groupNoticeProvider.create(
                      groupId: widget.groupId,
                      title: title.text.trim(),
                      message: message.text,
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

class GroupNoticeDetailsDialog extends StatefulWidget {
  final GroupNoticeProvider groupNoticeProvider;
  final GroupNoticeModel groupNotice;
  final UserProvider userProvider;

  GroupNoticeDetailsDialog({
    @required this.groupNoticeProvider,
    @required this.groupNotice,
    @required this.userProvider,
  });

  @override
  _GroupNoticeDetailsDialogState createState() =>
      _GroupNoticeDetailsDialogState();
}

class _GroupNoticeDetailsDialogState extends State<GroupNoticeDetailsDialog> {
  final ScrollController _scrollController = ScrollController();
  TextEditingController title = TextEditingController();
  TextEditingController message = TextEditingController();
  List<UserModel> users = [];
  List<UserModel> selected = [];

  void _init() async {
    await widget.userProvider
        .selectListNotice(
      groupId: widget.groupNotice?.groupId,
      noticeId: widget.groupNotice?.id,
    )
        .then((value) {
      setState(() => users = value);
    });
    setState(() {
      title.text = widget.groupNotice?.title;
      message.text = widget.groupNotice?.message;
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
        width: 550.0,
        child: ListView(
          shrinkWrap: true,
          children: [
            SizedBox(height: 16.0),
            Text(
              'お知らせの内容を修正できます。',
              style: TextStyle(color: Colors.black54, fontSize: 14.0),
            ),
            SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('タイトル', style: TextStyle(fontSize: 14.0)),
                TextFormField(
                  controller: title,
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
                Text('メッセージ', style: TextStyle(fontSize: 14.0)),
                TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  controller: message,
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
            Text('送信先スタッフ', style: TextStyle(fontSize: 14.0)),
            SizedBox(height: 4.0),
            Divider(height: 0.0),
            Container(
              height: 300.0,
              child: Scrollbar(
                isAlwaysShown: true,
                controller: _scrollController,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  controller: _scrollController,
                  itemCount: users.length,
                  itemBuilder: (_, index) {
                    UserModel _user = users[index];
                    var contain = selected.where((e) => e.id == _user.id);
                    return Container(
                      decoration: kBottomBorderDecoration,
                      child: CheckboxListTile(
                        title: Text('${_user.name}'),
                        value: contain.isNotEmpty,
                        activeColor: Colors.blue,
                        onChanged: (value) {
                          var contain = selected.where((e) => e.id == _user.id);
                          setState(() {
                            if (contain.isEmpty) {
                              selected.add(_user);
                            } else {
                              selected.removeWhere((e) => e.id == _user.id);
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
                Row(
                  children: [
                    CustomTextButton(
                      onPressed: () {
                        widget.groupNoticeProvider.delete(
                          groupNotice: widget.groupNotice,
                        );
                        Navigator.pop(context);
                      },
                      color: Colors.red,
                      label: '削除する',
                    ),
                    SizedBox(width: 4.0),
                    selected.length > 0
                        ? CustomTextButton(
                            onPressed: () async {
                              if (!await widget.groupNoticeProvider.send(
                                users: selected,
                                id: widget.groupNotice.id,
                                groupId: widget.groupNotice.groupId,
                                title: title.text.trim(),
                                message: message.text,
                              )) {
                                return;
                              }
                              Navigator.pop(context);
                            },
                            color: Colors.cyan,
                            label: '送信する',
                          )
                        : CustomTextButton(
                            onPressed: null,
                            color: Colors.grey,
                            label: '送信する',
                          ),
                    SizedBox(width: 4.0),
                    CustomTextButton(
                      onPressed: () async {
                        if (!await widget.groupNoticeProvider.update(
                          id: widget.groupNotice.id,
                          groupId: widget.groupNotice.groupId,
                          title: title.text.trim(),
                          message: message.text,
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
