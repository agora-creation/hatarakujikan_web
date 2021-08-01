import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/apply_work.dart';
import 'package:hatarakujikan_web/models/breaks.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/providers/apply_work.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/providers/user.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';
import 'package:hatarakujikan_web/widgets/custom_text_icon_button.dart';
import 'package:hatarakujikan_web/widgets/loading.dart';
import 'package:intl/intl.dart';

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
  List<UserModel> users = [];
  UserModel searchUser;
  bool searchApproval = false;

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

  void searchUserChange(UserModel user) {
    setState(() => searchUser = user);
  }

  void searchApprovalChange(bool approval) {
    setState(() => searchApproval = approval);
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> _stream;
    if (searchUser != null) {
      _stream = FirebaseFirestore.instance
          .collection('applyWork')
          .where('groupId', isEqualTo: widget.groupProvider.group?.id)
          .where('userId', isEqualTo: searchUser?.id)
          .where('approval', isEqualTo: searchApproval)
          .orderBy('createdAt', descending: true)
          .snapshots();
    } else {
      _stream = FirebaseFirestore.instance
          .collection('applyWork')
          .where('groupId', isEqualTo: widget.groupProvider.group?.id)
          .where('approval', isEqualTo: searchApproval)
          .orderBy('createdAt', descending: true)
          .snapshots();
    }
    List<ApplyWorkModel> applyWorks = [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '記録修正申請',
          style: kAdminTitleTextStyle,
        ),
        Text(
          'スタッフがスマートフォンアプリから申請した内容を一覧表示します。承認をした場合は自動的に勤怠データが修正されます。',
          style: kAdminSubTitleTextStyle,
        ),
        SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CustomTextIconButton(
                  onPressed: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (_) => SearchUserDialog(
                        users: users,
                        searchUser: searchUser,
                        searchUserChange: searchUserChange,
                      ),
                    );
                  },
                  color: Colors.lightBlueAccent,
                  iconData: Icons.person,
                  label: searchUser?.name ?? '選択してください',
                ),
                SizedBox(width: 4.0),
                CustomTextIconButton(
                  onPressed: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (_) => SearchApprovalDialog(
                        searchApproval: searchApproval,
                        searchApprovalChange: searchApprovalChange,
                      ),
                    );
                  },
                  color: Colors.lightBlueAccent,
                  iconData: Icons.approval,
                  label: searchApproval ? '承認済み' : '承認待ち',
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
                  DataColumn(label: Text('申請者名')),
                  DataColumn2(label: Text('事由'), size: ColumnSize.L),
                  DataColumn(label: Text('承認状況')),
                ],
                rows: List<DataRow>.generate(
                  applyWorks.length,
                  (index) => DataRow(
                    onSelectChanged: (value) {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (_) => ApplyWorkDetailsDialog(
                          applyWorkProvider: widget.applyWorkProvider,
                          applyWork: applyWorks[index],
                        ),
                      );
                    },
                    cells: [
                      DataCell(
                        Text(
                          '${DateFormat('yyyy/MM/dd HH:mm').format(applyWorks[index].createdAt)}',
                        ),
                      ),
                      DataCell(Text('${applyWorks[index].userName}')),
                      DataCell(Text('${applyWorks[index].reason}')),
                      applyWorks[index].approval
                          ? DataCell(Text('承認済み'))
                          : DataCell(Text('承認待ち')),
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

class SearchUserDialog extends StatelessWidget {
  final List<UserModel> users;
  final UserModel searchUser;
  final Function searchUserChange;

  SearchUserDialog({
    @required this.users,
    @required this.searchUser,
    @required this.searchUserChange,
  });

  @override
  Widget build(BuildContext context) {
    final ScrollController _scrollController = ScrollController();

    return AlertDialog(
      content: Container(
        width: 450.0,
        child: ListView(
          shrinkWrap: true,
          children: [
            SizedBox(height: 16.0),
            Divider(),
            Container(
              height: 350.0,
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
                    return Container(
                      decoration: kBottomBorderDecoration,
                      child: RadioListTile(
                        title: Text('${_user.name}'),
                        value: _user,
                        groupValue: searchUser,
                        activeColor: Colors.blue,
                        onChanged: (value) {
                          searchUserChange(value);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            Divider(),
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
                  onPressed: () => Navigator.pop(context),
                  color: Colors.blue,
                  label: 'OK',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SearchApprovalDialog extends StatelessWidget {
  final bool searchApproval;
  final Function searchApprovalChange;

  SearchApprovalDialog({
    @required this.searchApproval,
    @required this.searchApprovalChange,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        width: 450.0,
        child: ListView(
          shrinkWrap: true,
          children: [
            SizedBox(height: 16.0),
            Divider(),
            Container(
              decoration: kBottomBorderDecoration,
              child: RadioListTile(
                title: Text('承認待ち'),
                value: false,
                groupValue: searchApproval,
                activeColor: Colors.blue,
                onChanged: (value) {
                  searchApprovalChange(value);
                  Navigator.pop(context);
                },
              ),
            ),
            Container(
              decoration: kBottomBorderDecoration,
              child: RadioListTile(
                title: Text('承認済み'),
                value: true,
                groupValue: searchApproval,
                activeColor: Colors.blue,
                onChanged: (value) {
                  searchApprovalChange(value);
                  Navigator.pop(context);
                },
              ),
            ),
            Divider(),
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
                  onPressed: () => Navigator.pop(context),
                  color: Colors.blue,
                  label: 'OK',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ApplyWorkDetailsDialog extends StatelessWidget {
  final ApplyWorkProvider applyWorkProvider;
  final ApplyWorkModel applyWork;

  ApplyWorkDetailsDialog({
    @required this.applyWorkProvider,
    @required this.applyWork,
  });

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
              '申請内容を確認し、「却下する」もしくは「承認する」ボタンを押してください。',
              style: TextStyle(color: Colors.black54, fontSize: 14.0),
            ),
            SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '申請日時',
                  style: TextStyle(color: Colors.black54, fontSize: 14.0),
                ),
                Text(
                  '${DateFormat('yyyy/MM/dd HH:mm').format(applyWork.createdAt)}',
                ),
              ],
            ),
            Divider(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '申請者名',
                  style: TextStyle(color: Colors.black54, fontSize: 14.0),
                ),
                Text('${applyWork.userName}'),
              ],
            ),
            Divider(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '申請内容',
                  style: TextStyle(color: Colors.black54, fontSize: 14.0),
                ),
                Container(
                  decoration: kBottomBorderDecoration,
                  child: ListTile(
                    leading: Text('出勤時間'),
                    title: Text(
                      '${DateFormat('yyyy/MM/dd HH:mm').format(applyWork.startedAt)}',
                    ),
                  ),
                ),
                applyWork.breaks.length > 0
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        itemCount: applyWork.breaks.length,
                        itemBuilder: (_, index) {
                          BreaksModel _breaks = applyWork.breaks[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: kBottomBorderDecoration,
                                child: ListTile(
                                  leading: Text('休憩開始時間'),
                                  title: Text(
                                    '${DateFormat('yyyy/MM/dd HH:mm').format(_breaks.startedAt)}',
                                  ),
                                ),
                              ),
                              Container(
                                decoration: kBottomBorderDecoration,
                                child: ListTile(
                                  leading: Text('休憩終了時間'),
                                  title: Text(
                                    '${DateFormat('yyyy/MM/dd HH:mm').format(_breaks.endedAt)}',
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      )
                    : Container(),
                Container(
                  decoration: kBottomBorderDecoration,
                  child: ListTile(
                    leading: Text('退勤時間'),
                    title: Text(
                      '${DateFormat('yyyy/MM/dd HH:mm').format(applyWork.endedAt)}',
                    ),
                  ),
                ),
              ],
            ),
            Divider(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '事由',
                  style: TextStyle(color: Colors.black54, fontSize: 14.0),
                ),
                Text('${applyWork.reason}'),
              ],
            ),
            Divider(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '承認状況',
                  style: TextStyle(color: Colors.black54, fontSize: 14.0),
                ),
                applyWork.approval ? Text('承認済み') : Text('承認待ち')
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
                    applyWork.approval
                        ? CustomTextButton(
                            onPressed: () {
                              applyWorkProvider.delete(applyWork: applyWork);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('申請を削除しました')),
                              );
                              Navigator.pop(context);
                            },
                            color: Colors.red,
                            label: '削除する',
                          )
                        : CustomTextButton(
                            onPressed: () {
                              applyWorkProvider.delete(applyWork: applyWork);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('申請を却下しました')),
                              );
                              Navigator.pop(context);
                            },
                            color: Colors.red,
                            label: '却下する',
                          ),
                    SizedBox(width: 4.0),
                    applyWork.approval
                        ? CustomTextButton(
                            onPressed: null,
                            color: Colors.grey,
                            label: '承認する',
                          )
                        : CustomTextButton(
                            onPressed: () async {
                              if (!await applyWorkProvider.update(
                                applyWork: applyWork,
                              )) {
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('申請を承認しました')),
                              );
                              Navigator.pop(context);
                            },
                            color: Colors.blue,
                            label: '承認する',
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
