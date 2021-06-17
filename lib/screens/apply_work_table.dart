import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/apply_work.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/providers/apply_work.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/providers/user.dart';
import 'package:hatarakujikan_web/widgets/custom_text_icon_button.dart';
import 'package:hatarakujikan_web/widgets/loading.dart';

class ApplyWorkTable extends StatefulWidget {
  final ApplyWorkProvider applyWorkProvider;
  final GroupProvider groupProvider;
  final UserProvider userProvider;

  ApplyWorkTable({
    @required this.applyWorkProvider,
    @required this.groupProvider,
    @required this.userProvider,
  });

  @override
  _ApplyWorkTableState createState() => _ApplyWorkTableState();
}

class _ApplyWorkTableState extends State<ApplyWorkTable> {
  UserModel selectUser;
  List<UserModel> users = [];

  void _init() async {
    await widget.userProvider
        .selectList(groupId: widget.groupProvider.group?.id)
        .then((value) {
      setState(() => users = value);
    });
  }

  void _changeUser(UserModel user) {
    setState(() => selectUser = user);
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> _stream = FirebaseFirestore.instance
        .collection('applyWork')
        .where('groupId', isEqualTo: widget.groupProvider.group?.id)
        .where('userId', isEqualTo: '')
        .orderBy('createdAt', descending: true)
        .snapshots();
    List<ApplyWorkModel> applyWorks = [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '記録修正申請',
          style: kAdminTitleTextStyle,
        ),
        Text(
          'スタッフがスマートフォンから申請した内容を一覧表示します。承認をした場合、自動的に勤務記録が修正されます。',
          style: kAdminSubTitleTextStyle,
        ),
        SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CustomTextIconButton(
                  onPressed: () {},
                  color: Colors.lightBlueAccent,
                  iconData: Icons.person,
                  label: selectUser?.name ?? '選択してください',
                ),
                SizedBox(width: 4.0),
                CustomTextIconButton(
                  onPressed: () {},
                  color: Colors.lightBlueAccent,
                  iconData: Icons.approval,
                  label: '承認待ち',
                ),
              ],
            ),
            Container(),
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
              applyWorks.clear();
              for (DocumentSnapshot applyWork in snapshot.data.docs) {
                applyWorks.add(ApplyWorkModel.fromSnapshot(applyWork));
              }
              return DataTable2(
                columns: [
                  DataColumn(label: Text('申請日時')),
                  DataColumn(label: Text('申請者')),
                  DataColumn(label: Text('申請内容')),
                  DataColumn(label: Text('承認状況')),
                ],
                rows: List<DataRow>.generate(
                  100,
                  (index) => DataRow(
                    cells: [
                      DataCell(Text('$index')),
                      DataCell(Text('$index')),
                      DataCell(Text('$index')),
                      DataCell(Text('$index')),
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
