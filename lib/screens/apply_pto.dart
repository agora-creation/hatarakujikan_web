import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/apply_pto.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/providers/apply_pto.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/widgets/admin_header.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold.dart';
import 'package:hatarakujikan_web/widgets/custom_radio.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';
import 'package:hatarakujikan_web/widgets/tap_list_tile.dart';
import 'package:hatarakujikan_web/widgets/text_icon_button.dart';
import 'package:provider/provider.dart';

class ApplyPTOScreen extends StatelessWidget {
  static const String id = 'applyPTO';

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final applyPTOProvider = Provider.of<ApplyPTOProvider>(context);
    GroupModel? group = groupProvider.group;
    List<ApplyPTOModel> applyPTOs = [];

    return CustomAdminScaffold(
      groupProvider: groupProvider,
      selectedRoute: id,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminHeader(
            title: '有給休暇の申請',
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
                    label: applyPTOProvider.user == null
                        ? '未選択'
                        : applyPTOProvider.user?.name ?? '',
                    labelColor: Colors.white,
                    backgroundColor: Colors.lightBlueAccent,
                    onPressed: () {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (_) => SearchUserDialog(
                          groupProvider: groupProvider,
                          applyPTOProvider: applyPTOProvider,
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 4.0),
                  TextIconButton(
                    iconData: Icons.approval,
                    iconColor: Colors.white,
                    label: applyPTOProvider.approval == true ? '承認済み' : '承認待ち',
                    labelColor: Colors.white,
                    backgroundColor: Colors.lightBlueAccent,
                    onPressed: () {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (_) => SearchApprovalDialog(
                          applyPTOProvider: applyPTOProvider,
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
              stream: applyPTOProvider.streamList(groupId: group?.id),
              builder: (context, snapshot) {
                applyPTOs.clear();
                if (snapshot.hasData) {
                  for (DocumentSnapshot<Map<String, dynamic>> doc
                      in snapshot.data!.docs) {
                    applyPTOs.add(ApplyPTOModel.fromSnapshot(doc));
                  }
                }
                if (applyPTOs.length == 0) return Text('現在申請はありません。');
                return DataTable2(
                  columns: [
                    DataColumn2(label: Text('申請日時'), size: ColumnSize.M),
                    DataColumn2(label: Text('申請者名'), size: ColumnSize.M),
                    DataColumn2(label: Text('事由'), size: ColumnSize.L),
                    DataColumn2(label: Text('承認状況'), size: ColumnSize.M),
                    DataColumn2(label: Text('承認/却下'), size: ColumnSize.S),
                  ],
                  rows: List<DataRow>.generate(
                    applyPTOs.length,
                    (index) => DataRow(
                      cells: [
                        DataCell(Text(
                          dateText(
                            'yyyy/MM/dd HH:mm',
                            applyPTOs[index].createdAt,
                          ),
                        )),
                        DataCell(Text(applyPTOs[index].userName)),
                        DataCell(Text(
                          applyPTOs[index].reason,
                          overflow: TextOverflow.ellipsis,
                        )),
                        DataCell(Text(
                          applyPTOs[index].approval == true ? '承認済み' : '承認待ち',
                        )),
                        DataCell(IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (_) => EditDialog(
                                applyPTOProvider: applyPTOProvider,
                                applyPTO: applyPTOs[index],
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
  final ApplyPTOProvider applyPTOProvider;

  SearchUserDialog({
    required this.groupProvider,
    required this.applyPTOProvider,
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
                      groupValue: widget.applyPTOProvider.user,
                      activeColor: Colors.lightBlueAccent,
                      onChanged: (value) {
                        widget.applyPTOProvider.changeUser(value);
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
  final ApplyPTOProvider applyPTOProvider;

  SearchApprovalDialog({
    required this.applyPTOProvider,
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
              groupValue: applyPTOProvider.approval,
              activeColor: Colors.lightBlueAccent,
              onChanged: (value) {
                applyPTOProvider.changeApproval(value);
                Navigator.pop(context);
              },
            ),
            CustomRadio(
              label: '承認済み',
              value: true,
              groupValue: applyPTOProvider.approval,
              activeColor: Colors.lightBlueAccent,
              onChanged: (value) {
                applyPTOProvider.changeApproval(value);
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
  final ApplyPTOProvider applyPTOProvider;
  final ApplyPTOModel applyPTO;

  EditDialog({
    required this.applyPTOProvider,
    required this.applyPTO,
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
              subtitle: dateText('yyyy/MM/dd HH:mm', applyPTO.createdAt),
            ),
            TapListTile(
              title: '申請者名',
              subtitle: applyPTO.userName,
            ),
            TapListTile(
              title: '開始日',
              subtitle: dateText('yyyy/MM/dd', applyPTO.startedAt),
            ),
            TapListTile(
              title: '終了日',
              subtitle: dateText('yyyy/MM/dd', applyPTO.endedAt),
            ),
            TapListTile(
              title: '事由',
              subtitle: applyPTO.reason,
            ),
            TapListTile(
              title: '承認状況',
              subtitle: applyPTO.approval == true ? '承認済み' : '承認待ち',
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
                      label: applyPTO.approval == true ? '削除する' : '却下する',
                      color: Colors.red,
                      onPressed: () async {
                        if (applyPTO.approval == true) {
                          if (!await applyPTOProvider.delete(
                            id: applyPTO.id,
                          )) {
                            return;
                          }
                          customSnackBar(context, '申請を削除しました');
                          Navigator.pop(context);
                        } else {
                          if (!await applyPTOProvider.delete(
                            id: applyPTO.id,
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
                      color:
                          applyPTO.approval == true ? Colors.grey : Colors.blue,
                      onPressed: () async {
                        if (applyPTO.approval == true) return;
                        if (!await applyPTOProvider.update(
                          applyPTO: applyPTO,
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
