import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/providers/user.dart';
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
          'スタッフの情報を一覧表示します。アプリから登録するか、ここで登録できます。',
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
              users.clear();
              for (DocumentSnapshot user in snapshot.data.docs) {
                users.add(UserModel.fromSnapshot(user));
              }
              return DataTable2(
                columns: [
                  DataColumn(label: Text('名前')),
                  DataColumn(label: Text('メールアドレス')),
                  DataColumn(label: Text('アプリ利用')),
                  DataColumn(label: Text('作成日時')),
                ],
                rows: List<DataRow>.generate(
                  users.length,
                  (index) => DataRow(
                    onSelectChanged: (value) {},
                    cells: [
                      DataCell(Text('${users[index].name}')),
                      DataCell(Text('${users[index].email}')),
                      users[index].smartphone
                          ? DataCell(Text('○'))
                          : DataCell(Text('')),
                      DataCell(
                        Text(
                          '${DateFormat('yyyy/MM/dd HH:mm').format(users[index].createdAt)}',
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
