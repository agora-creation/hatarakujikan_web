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
import 'package:hatarakujikan_web/widgets/custom_radio.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';
import 'package:hatarakujikan_web/widgets/tap_list_tile.dart';
import 'package:hatarakujikan_web/widgets/text_icon_button.dart';
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
                    backgroundColor: Colors.lightBlueAccent,
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
                    label: applyWorkProvider.approval == true ? '承認済み' : '承認待ち',
                    labelColor: Colors.white,
                    backgroundColor: Colors.lightBlueAccent,
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
                          onPressed: () {
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (_) => EditDialog(
                                applyWorkProvider: applyWorkProvider,
                                applyWork: applyWorks[index],
                              ),
                            );
                          },
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
                thumbVisibility: true,
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
                      activeColor: Colors.lightBlueAccent,
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
              activeColor: Colors.lightBlueAccent,
              onChanged: (value) {
                applyWorkProvider.changeApproval(value);
                Navigator.pop(context);
              },
            ),
            CustomRadio(
              label: '承認済み',
              value: true,
              groupValue: applyWorkProvider.approval,
              activeColor: Colors.lightBlueAccent,
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

class EditDialog extends StatelessWidget {
  final ApplyWorkProvider applyWorkProvider;
  final ApplyWorkModel applyWork;

  EditDialog({
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
            Text(
              '申請内容を確認し、「承認する」ボタンをクリックしてください。',
              style: kDialogTextStyle,
            ),
            SizedBox(height: 16.0),
            TapListTile(
              title: '申請日時',
              subtitle: dateText('yyyy/MM/dd HH:mm', applyWork.createdAt),
            ),
            TapListTile(
              title: '申請者名',
              subtitle: applyWork.userName,
            ),
            TapListTile(
              title: '出勤時間',
              subtitle: dateText('yyyy/MM/dd HH:mm', applyWork.startedAt),
            ),
            applyWork.breaks.length > 0
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    itemCount: applyWork.breaks.length,
                    itemBuilder: (_, index) {
                      BreaksModel _breaks = applyWork.breaks[index];
                      return Column(
                        children: [
                          TapListTile(
                            title: '休憩開始時間',
                            subtitle: dateText(
                              'yyyy/MM/dd HH:mm',
                              _breaks.startedAt,
                            ),
                          ),
                          TapListTile(
                            title: '休憩終了時間',
                            subtitle: dateText(
                              'yyyy/MM/dd HH:mm',
                              _breaks.endedAt,
                            ),
                          ),
                        ],
                      );
                    },
                  )
                : Container(),
            TapListTile(
              title: '退勤時間',
              subtitle: dateText('yyyy/MM/dd HH:mm', applyWork.endedAt),
            ),
            TapListTile(
              title: '事由',
              subtitle: applyWork.reason,
            ),
            TapListTile(
              title: '承認状況',
              subtitle: applyWork.approval == true ? '承認済み' : '承認待ち',
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
                Row(
                  children: [
                    CustomTextButton(
                      label: applyWork.approval == true ? '削除する' : '却下する',
                      color: Colors.red,
                      onPressed: () async {
                        if (applyWork.approval == true) {
                          if (!await applyWorkProvider.delete(
                            id: applyWork.id,
                          )) {
                            return;
                          }
                          customSnackBar(context, '申請を削除しました');
                          Navigator.pop(context);
                        } else {
                          if (!await applyWorkProvider.delete(
                            id: applyWork.id,
                          )) {
                            return;
                          }
                          customSnackBar(context, '申請を却下しました');
                          Navigator.pop(context);
                        }
                      },
                    ),
                    SizedBox(width: 4.0),
                    CustomTextButton(
                      label: '承認する',
                      color: applyWork.approval == true
                          ? Colors.grey
                          : Colors.blue,
                      onPressed: () async {
                        if (applyWork.approval == true) return;
                        if (!await applyWorkProvider.update(
                          applyWork: applyWork,
                        )) {
                          return;
                        }
                        customSnackBar(context, '申請を承認しました');
                        Navigator.pop(context);
                      },
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
