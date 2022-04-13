import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/apply_work.dart';
import 'package:hatarakujikan_web/models/breaks.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/providers/apply_work.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/widgets/admin_header.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold.dart';
import 'package:hatarakujikan_web/widgets/custom_label_column.dart';
import 'package:hatarakujikan_web/widgets/custom_label_list_tile.dart';
import 'package:hatarakujikan_web/widgets/custom_radio.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';
import 'package:hatarakujikan_web/widgets/text_icon_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ApplyWorkScreen extends StatelessWidget {
  static const String id = 'applyWork';

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final applyWorkProvider = Provider.of<ApplyWorkProvider>(context);
    GroupModel? group = groupProvider.group;
    List<ApplyWorkModel> applyWorks = [];

    return CustomAdminScaffold(
      groupProvider: groupProvider,
      selectedRoute: id,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminHeader(
            title: '勤怠修正の申請',
            message: 'スタッフがスマホアプリから申請した内容を表示しています。承認した場合、自動的に勤怠データが更新されます。',
          ),
          SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  TextIconButton(
                    iconData: Icons.person,
                    iconColor: Colors.white,
                    label: applyWorkProvider.user == null
                        ? '未選択'
                        : applyWorkProvider.user?.name ?? '',
                    labelColor: Colors.white,
                    backgroundColor: Colors.lightBlue,
                    onPressed: () {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (_) => SearchUserDialog(
                          groupProvider: groupProvider,
                          applyWorkProvider: applyWorkProvider,
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 4.0),
                  TextIconButton(
                    iconData: Icons.approval,
                    iconColor: Colors.white,
                    label: '承認待ち',
                    labelColor: Colors.white,
                    backgroundColor: Colors.lightBlue,
                    onPressed: () {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (_) => SearchApprovalDialog(
                          applyWorkProvider: applyWorkProvider,
                        ),
                      );
                    },
                  ),
                ],
              ),
              Container(),
            ],
          ),
          SizedBox(height: 8.0),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: applyWorkProvider.streamList(groupId: group?.id),
              builder: (context, snapshot) {
                applyWorks.clear();
                if (snapshot.hasData) {
                  for (DocumentSnapshot<Map<String, dynamic>> doc
                      in snapshot.data!.docs) {
                    applyWorks.add(ApplyWorkModel.fromSnapshot(doc));
                  }
                }
                if (applyWorks.length == 0) return Text('現在申請はありません。');
                return DataTable2(
                  columns: [
                    DataColumn2(label: Text('申請日時'), size: ColumnSize.M),
                    DataColumn2(label: Text('申請者名'), size: ColumnSize.M),
                    DataColumn2(label: Text('事由'), size: ColumnSize.L),
                    DataColumn2(label: Text('承認状況'), size: ColumnSize.M),
                    DataColumn2(label: Text('承認/却下'), size: ColumnSize.S),
                  ],
                  rows: List<DataRow>.generate(
                    applyWorks.length,
                    (index) => DataRow(
                      cells: [
                        DataCell(Text(
                          dateText(
                            'yyyy/MM/dd HH:mm',
                            applyWorks[index].createdAt,
                          ),
                        )),
                        DataCell(Text(applyWorks[index].userName)),
                        DataCell(Text(
                          applyWorks[index].reason,
                          overflow: TextOverflow.ellipsis,
                        )),
                        DataCell(Text(
                          applyWorks[index].approval == true ? '承認済み' : '承認待ち',
                        )),
                        DataCell(IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {},
                        )),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SearchUserDialog extends StatefulWidget {
  final GroupProvider groupProvider;
  final ApplyWorkProvider applyWorkProvider;

  SearchUserDialog({
    required this.groupProvider,
    required this.applyWorkProvider,
  });

  @override
  State<SearchUserDialog> createState() => _SearchUserDialogState();
}

class _SearchUserDialogState extends State<SearchUserDialog> {
  ScrollController _controller = ScrollController();
  List<UserModel> users = [];

  void _init() async {
    List<UserModel> _users = await widget.groupProvider.selectUsers();
    if (mounted) {
      setState(() => users = _users);
    }
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
            Container(
              height: 350.0,
              child: Scrollbar(
                isAlwaysShown: true,
                controller: _controller,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  controller: _controller,
                  itemCount: users.length,
                  itemBuilder: (_, index) {
                    UserModel _user = users[index];
                    return CustomRadio(
                      label: _user.name,
                      value: _user,
                      groupValue: widget.applyWorkProvider.user,
                      activeColor: Colors.lightBlue,
                      onChanged: (value) {
                        widget.applyWorkProvider.changeUser(value);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextButton(
                  label: 'キャンセル',
                  color: Colors.grey,
                  onPressed: () => Navigator.pop(context),
                ),
                Container(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SearchApprovalDialog extends StatelessWidget {
  final ApplyWorkProvider applyWorkProvider;

  SearchApprovalDialog({
    required this.applyWorkProvider,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        width: 450.0,
        child: ListView(
          shrinkWrap: true,
          children: [
            CustomRadio(
              label: '承認待ち',
              value: false,
              groupValue: applyWorkProvider.approval,
              activeColor: Colors.lightBlue,
              onChanged: (value) {
                applyWorkProvider.changeApproval(value);
                Navigator.pop(context);
              },
            ),
            CustomRadio(
              label: '承認済み',
              value: true,
              groupValue: applyWorkProvider.approval,
              activeColor: Colors.lightBlue,
              onChanged: (value) {
                applyWorkProvider.changeApproval(value);
                Navigator.pop(context);
              },
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
                Container(),
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
    required this.applyWorkProvider,
    required this.applyWork,
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
                dateText('yyyy/MM/dd HH:mm', applyWork.createdAt),
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
                    value: dateText('yyyy/MM/dd HH:mm', applyWork.startedAt),
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
                                  value: dateText(
                                    'yyyy/MM/dd HH:mm',
                                    _breaks.startedAt,
                                  ),
                                ),
                                CustomLabelListTile(
                                  label: '休憩終了時間',
                                  value: dateText(
                                    'yyyy/MM/dd HH:mm',
                                    _breaks.endedAt,
                                  ),
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
