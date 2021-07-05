import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/group_notice.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/providers/user.dart';
import 'package:hatarakujikan_web/widgets/custom_text_icon_button.dart';
import 'package:hatarakujikan_web/widgets/loading.dart';

class GroupNoticeTable extends StatefulWidget {
  final GroupProvider groupProvider;
  final UserProvider userProvider;

  GroupNoticeTable({
    @required this.groupProvider,
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
              onPressed: () {},
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
                  DataColumn(label: Text('登録日時')),
                  DataColumn(label: Text('タイトル')),
                  DataColumn2(label: Text('お知らせ内容'), size: ColumnSize.L),
                ],
                rows: List<DataRow>.generate(
                  groupNotices.length,
                  (index) => DataRow(
                    onSelectChanged: (value) {},
                    cells: [
                      DataCell(Text('---')),
                      DataCell(Text('---')),
                      DataCell(Text('---')),
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
