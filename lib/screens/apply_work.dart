import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/apply_work.dart';
import 'package:hatarakujikan_web/models/breaks.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/providers/apply_work.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold.dart';
import 'package:hatarakujikan_web/widgets/custom_label_column.dart';
import 'package:hatarakujikan_web/widgets/custom_label_list_tile.dart';
import 'package:hatarakujikan_web/widgets/custom_radio_list_tile.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';
import 'package:hatarakujikan_web/widgets/custom_text_icon_button.dart';
import 'package:hatarakujikan_web/widgets/loading.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ApplyWorkScreen extends StatelessWidget {
  static const String id = 'applyWork';

  @override
  Widget build(BuildContext context) {
    final applyWorkProvider = Provider.of<ApplyWorkProvider>(context);
    final groupProvider = Provider.of<GroupProvider>(context);

    return CustomAdminScaffold(
      groupProvider: groupProvider,
      selectedRoute: id,
      body: ApplyWorkTable(
        applyWorkProvider: applyWorkProvider,
        groupProvider: groupProvider,
      ),
    );
  }
}

class ApplyWorkTable extends StatefulWidget {
  final ApplyWorkProvider applyWorkProvider;
  final GroupProvider groupProvider;

  ApplyWorkTable({
    @required this.applyWorkProvider,
    @required this.groupProvider,
  });

  @override
  _ApplyWorkTableState createState() => _ApplyWorkTableState();
}

class _ApplyWorkTableState extends State<ApplyWorkTable> {
  UserModel user;
  bool approval = false;

  void userChange(UserModel userModel) {
    setState(() => user = userModel);
  }

  void approvalChange(bool selApproval) {
    setState(() => approval = selApproval);
  }

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> _stream;
    GroupModel _group = widget.groupProvider.group;
    if (user != null) {
      _stream = FirebaseFirestore.instance
          .collection('applyWork')
          .where('groupId', isEqualTo: _group?.id ?? 'error')
          .where('userId', isEqualTo: user?.id ?? 'error')
          .where('approval', isEqualTo: approval)
          .orderBy('createdAt', descending: true)
          .snapshots();
    } else {
      _stream = FirebaseFirestore.instance
          .collection('applyWork')
          .where('groupId', isEqualTo: _group?.id ?? 'error')
          .where('approval', isEqualTo: approval)
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
                        users: widget.groupProvider.users,
                        user: user,
                        userChange: userChange,
                      ),
                    );
                  },
                  color: Colors.lightBlueAccent,
                  iconData: Icons.person,
                  label: user?.name ?? '選択してください',
                ),
                SizedBox(width: 4.0),
                CustomTextIconButton(
                  onPressed: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (_) => SearchApprovalDialog(
                        approval: approval,
                        approvalChange: approvalChange,
                      ),
                    );
                  },
                  color: Colors.lightBlueAccent,
                  iconData: Icons.approval,
                  label: approval ? '承認済み' : '承認待ち',
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
              for (DocumentSnapshot doc in snapshot.data.docs) {
                applyWorks.add(ApplyWorkModel.fromSnapshot(doc));
              }
              if (applyWorks.length > 0) {
                return DataTable2(
                  columns: [
                    DataColumn2(label: Text('申請日時')),
                    DataColumn2(label: Text('申請者名')),
                    DataColumn2(label: Text('事由'), size: ColumnSize.L),
                    DataColumn2(label: Text('承認状況')),
                    DataColumn2(label: Text('承認/却下'), size: ColumnSize.S),
                  ],
                  rows: List<DataRow>.generate(
                    applyWorks.length,
                    (index) => DataRow(
                      cells: [
                        DataCell(Text(
                          '${DateFormat('yyyy/MM/dd HH:mm').format(applyWorks[index].createdAt)}',
                        )),
                        DataCell(Text('${applyWorks[index].userName}')),
                        DataCell(Text(
                          '${applyWorks[index].reason}',
                          overflow: TextOverflow.ellipsis,
                        )),
                        applyWorks[index].approval
                            ? DataCell(Text('承認済み'))
                            : DataCell(Text('承認待ち')),
                        DataCell(IconButton(
                          onPressed: () {
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (_) => EditApplyWorkDialog(
                                applyWorkProvider: widget.applyWorkProvider,
                                applyWork: applyWorks[index],
                              ),
                            );
                          },
                          icon: Icon(Icons.edit, color: Colors.blue),
                        )),
                      ],
                    ),
                  ),
                );
              } else {
                return Text('現在申請/承認データはありません');
              }
            },
          ),
        ),
      ],
    );
  }
}

class SearchUserDialog extends StatelessWidget {
  final List<UserModel> users;
  final UserModel user;
  final Function userChange;

  SearchUserDialog({
    @required this.users,
    @required this.user,
    @required this.userChange,
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
                    return CustomRadioListTile(
                      onChanged: (value) {
                        userChange(value);
                        Navigator.pop(context);
                      },
                      label: '${_user.name}',
                      value: _user,
                      groupValue: user,
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
  final bool approval;
  final Function approvalChange;

  SearchApprovalDialog({
    @required this.approval,
    @required this.approvalChange,
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
            CustomRadioListTile(
              onChanged: (value) {
                approvalChange(value);
                Navigator.pop(context);
              },
              label: '承認待ち',
              value: false,
              groupValue: approval,
            ),
            CustomRadioListTile(
              onChanged: (value) {
                approvalChange(value);
                Navigator.pop(context);
              },
              label: '承認済み',
              value: true,
              groupValue: approval,
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

class EditApplyWorkDialog extends StatelessWidget {
  final ApplyWorkProvider applyWorkProvider;
  final ApplyWorkModel applyWork;

  EditApplyWorkDialog({
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
              style: kDefaultTextStyle,
            ),
            SizedBox(height: 16.0),
            CustomLabelColumn(
              label: '申請日時',
              child: Text(
                '${DateFormat('yyyy/MM/dd HH:mm').format(applyWork.createdAt)}',
              ),
            ),
            Divider(),
            CustomLabelColumn(
              label: '申請者名',
              child: Text('${applyWork.userName}'),
            ),
            Divider(),
            CustomLabelColumn(
              label: '申請内容',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomLabelListTile(
                    label: '出勤時間',
                    value:
                        '${DateFormat('yyyy/MM/dd HH:mm').format(applyWork.startedAt)}',
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
                                CustomLabelListTile(
                                  label: '休憩開始時間',
                                  value:
                                      '${DateFormat('yyyy/MM/dd HH:mm').format(_breaks.startedAt)}',
                                ),
                                CustomLabelListTile(
                                  label: '休憩終了時間',
                                  value:
                                      '${DateFormat('yyyy/MM/dd HH:mm').format(_breaks.endedAt)}',
                                ),
                              ],
                            );
                          },
                        )
                      : Container(),
                  CustomLabelListTile(
                    label: '退勤時間',
                    value:
                        '${DateFormat('yyyy/MM/dd HH:mm').format(applyWork.endedAt)}',
                  ),
                ],
              ),
            ),
            Divider(),
            CustomLabelColumn(
              label: '事由',
              child: Text('${applyWork.reason}'),
            ),
            Divider(),
            CustomLabelColumn(
              label: '承認状況',
              child: applyWork.approval ? Text('承認済み') : Text('承認待ち'),
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
