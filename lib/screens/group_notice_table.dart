import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/group_notice.dart';
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
                  DataColumn2(label: Text('お知らせ内容'), size: ColumnSize.L),
                ],
                rows: List<DataRow>.generate(
                  groupNotices.length,
                  (index) => DataRow(
                    onSelectChanged: (value) {},
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
                Text('お知らせ内容', style: TextStyle(fontSize: 14.0)),
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
