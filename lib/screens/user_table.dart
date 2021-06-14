import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_tables/data_tables.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/widgets/custom_text_icon_button.dart';
import 'package:hatarakujikan_web/widgets/loading.dart';
import 'package:intl/intl.dart';

class UserTable extends StatefulWidget {
  final GroupProvider groupProvider;

  UserTable({@required this.groupProvider});

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

    return StreamBuilder<QuerySnapshot>(
      stream: _stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Loading(color: Colors.orange);
        }
        users.clear();
        for (DocumentSnapshot user in snapshot.data.docs) {
          users.add(UserModel.fromSnapshot(user));
        }
        return NativeDataTable.builder(
          header: Column(
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
            ],
          ),
          actions: [
            CustomTextIconButton(
              onPressed: () {},
              backgroundColor: Colors.blue,
              iconData: Icons.add,
              labelText: '新規登録',
            ),
          ],
          columns: [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('名前')),
            DataColumn(label: Text('メールアドレス')),
            DataColumn(label: Text('アプリの利用者')),
            DataColumn(label: Text('登録日時')),
          ],
          rowsPerPage: PaginatedDataTable.defaultRowsPerPage,
          itemCount: users.length,
          itemBuilder: (index) {
            UserModel _user = users[index];
            return DataRow.byIndex(
              index: index,
              cells: [
                DataCell(Text(_user.id)),
                DataCell(Text(_user.name)),
                DataCell(Text(_user.email)),
                DataCell(Text('')),
                DataCell(
                  Text('${DateFormat(formatYMDHM).format(_user.createdAt)}'),
                ),
              ],
              selected: false,
              onSelectChanged: (value) {
                print(_user.name);
              },
            );
          },
        );
      },
    );
  }
}
