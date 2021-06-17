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
import 'package:hatarakujikan_web/widgets/custom_icon_label.dart';
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
  UserModel selectUser;
  List<UserModel> users = [];
  bool selectApproval = false;

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

  void _changeApproval(bool approval) {
    setState(() => selectApproval = approval);
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> _stream;
    if (selectUser != null) {
      _stream = FirebaseFirestore.instance
          .collection('applyWork')
          .where('groupId', isEqualTo: widget.groupProvider.group?.id)
          .where('userId', isEqualTo: selectUser?.id)
          .where('approval', isEqualTo: selectApproval)
          .orderBy('createdAt', descending: true)
          .snapshots();
    } else {
      _stream = FirebaseFirestore.instance
          .collection('applyWork')
          .where('groupId', isEqualTo: widget.groupProvider.group?.id)
          .where('approval', isEqualTo: selectApproval)
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
                  onPressed: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (_) => SelectUserDialog(
                        users: users,
                        selectUser: selectUser,
                        changeUser: _changeUser,
                      ),
                    );
                  },
                  color: Colors.lightBlueAccent,
                  iconData: Icons.person,
                  label: selectUser?.name ?? '選択してください',
                ),
                SizedBox(width: 4.0),
                CustomTextIconButton(
                  onPressed: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (_) => SelectApprovalDialog(
                        selectApproval: selectApproval,
                        changeApproval: _changeApproval,
                      ),
                    );
                  },
                  color: Colors.lightBlueAccent,
                  iconData: Icons.approval,
                  label: selectApproval ? '承認済み' : '承認待ち',
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

class SelectUserDialog extends StatelessWidget {
  final List<UserModel> users;
  final UserModel selectUser;
  final Function changeUser;

  SelectUserDialog({
    @required this.users,
    @required this.selectUser,
    @required this.changeUser,
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
            Divider(height: 0.0),
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
                        groupValue: selectUser,
                        activeColor: Colors.blue,
                        onChanged: (value) {
                          changeUser(value);
                          Navigator.pop(context);
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

class SelectApprovalDialog extends StatelessWidget {
  final bool selectApproval;
  final Function changeApproval;

  SelectApprovalDialog({
    @required this.selectApproval,
    @required this.changeApproval,
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
            Divider(height: 0.0),
            Container(
              decoration: kBottomBorderDecoration,
              child: RadioListTile(
                title: Text('承認待ち'),
                value: false,
                groupValue: selectApproval,
                activeColor: Colors.blue,
                onChanged: (value) {
                  changeApproval(value);
                  Navigator.pop(context);
                },
              ),
            ),
            Container(
              decoration: kBottomBorderDecoration,
              child: RadioListTile(
                title: Text('承認済み'),
                value: true,
                groupValue: selectApproval,
                activeColor: Colors.blue,
                onChanged: (value) {
                  changeApproval(value);
                  Navigator.pop(context);
                },
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
            Container(
              decoration: kBottomBorderDecoration,
              child: ListTile(
                leading: Text('申請日時'),
                title: Text(
                  '${DateFormat('yyyy/MM/dd HH:mm').format(applyWork.createdAt)}',
                ),
              ),
            ),
            Container(
              decoration: kBottomBorderDecoration,
              child: ListTile(
                leading: Text('申請者'),
                title: Text('${applyWork.userName}'),
              ),
            ),
            Container(
              decoration: kBottomBorderDecoration,
              child: ListTile(
                leading: Text('申請内容'),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomIconLabel(
                      icon: Icon(Icons.run_circle, color: Colors.blue),
                      label: '出勤時間',
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      '${DateFormat('yyyy/MM/dd HH:mm').format(applyWork.startedAt)}',
                    ),
                    SizedBox(height: 8.0),
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
                                  CustomIconLabel(
                                    icon: Icon(
                                      Icons.run_circle,
                                      color: Colors.orange,
                                    ),
                                    label: '休憩開始時間',
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(
                                    '${DateFormat('yyyy/MM/dd HH:mm').format(_breaks.startedAt)}',
                                  ),
                                  SizedBox(height: 8.0),
                                  CustomIconLabel(
                                    icon: Icon(
                                      Icons.run_circle_outlined,
                                      color: Colors.orange,
                                    ),
                                    label: '休憩終了時間',
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(
                                    '${DateFormat('yyyy/MM/dd HH:mm').format(_breaks.endedAt)}',
                                  ),
                                ],
                              );
                            },
                          )
                        : Container(),
                    SizedBox(height: 8.0),
                    CustomIconLabel(
                      icon: Icon(Icons.run_circle, color: Colors.red),
                      label: '退勤時間',
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      '${DateFormat('yyyy/MM/dd HH:mm').format(applyWork.endedAt)}',
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: kBottomBorderDecoration,
              child: ListTile(
                leading: Text('事由'),
                title: Text('${applyWork.reason}'),
              ),
            ),
            Container(
              decoration: kBottomBorderDecoration,
              child: ListTile(
                leading: Text('承認状況'),
                title: applyWork.approval ? Text('承認済み') : Text('承認待ち'),
              ),
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
                        applyWorkProvider.delete(applyWork: applyWork);
                        Navigator.pop(context);
                      },
                      color: Colors.red,
                      label: '却下する',
                    ),
                    SizedBox(width: 4.0),
                    CustomTextButton(
                      onPressed: () async {
                        if (!await applyWorkProvider.update(
                          applyWork: applyWork,
                        )) {
                          return;
                        }
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
