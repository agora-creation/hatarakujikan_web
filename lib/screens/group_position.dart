import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/position.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/providers/position.dart';
import 'package:hatarakujikan_web/widgets/TapListTile.dart';
import 'package:hatarakujikan_web/widgets/admin_header.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold.dart';
import 'package:hatarakujikan_web/widgets/custom_checkbox.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';
import 'package:hatarakujikan_web/widgets/custom_text_form_field2.dart';
import 'package:hatarakujikan_web/widgets/text_icon_button.dart';
import 'package:provider/provider.dart';

class GroupPositionScreen extends StatelessWidget {
  static const String id = 'group_position';

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final positionProvider = Provider.of<PositionProvider>(context);
    GroupModel? group = groupProvider.group;
    List<PositionModel> positions = [];

    return CustomAdminScaffold(
      groupProvider: groupProvider,
      selectedRoute: id,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminHeader(
            title: '雇用形態の管理',
            message: '雇用形態を登録し、各スタッフへ設定できます。',
          ),
          SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(),
              TextIconButton(
                iconData: Icons.add,
                iconColor: Colors.white,
                label: '新規登録',
                labelColor: Colors.white,
                backgroundColor: Colors.blue,
                onPressed: () {
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (_) => AddDialog(
                      positionProvider: positionProvider,
                      group: group,
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: positionProvider.streamList(groupId: group?.id),
              builder: (context, snapshot) {
                positions.clear();
                if (snapshot.hasData) {
                  for (DocumentSnapshot<Map<String, dynamic>> doc
                      in snapshot.data!.docs) {
                    positions.add(PositionModel.fromSnapshot(doc));
                  }
                }
                if (positions.length == 0) return Text('現在登録している雇用形態はありません。');
                return DataTable2(
                  columns: [
                    DataColumn2(label: Text('雇用形態名'), size: ColumnSize.S),
                    DataColumn2(label: Text('修正/削除'), size: ColumnSize.S),
                    DataColumn2(label: Text('スタッフ割当'), size: ColumnSize.S),
                  ],
                  rows: List<DataRow>.generate(
                    positions.length,
                    (index) {
                      return DataRow(
                        cells: [
                          DataCell(Text('${positions[index].name}')),
                          DataCell(IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (_) => EditDialog(
                                  positionProvider: positionProvider,
                                  position: positions[index],
                                ),
                              );
                            },
                          )),
                          DataCell(IconButton(
                            icon: Icon(Icons.checklist, color: Colors.blue),
                            onPressed: () {
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (_) => InUserDialog(
                                  groupProvider: groupProvider,
                                  positionProvider: positionProvider,
                                  position: positions[index],
                                ),
                              );
                            },
                          )),
                        ],
                      );
                    },
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

class AddDialog extends StatefulWidget {
  final PositionProvider positionProvider;
  final GroupModel? group;

  AddDialog({
    required this.positionProvider,
    this.group,
  });

  @override
  State<AddDialog> createState() => _AddDialogState();
}

class _AddDialogState extends State<AddDialog> {
  TextEditingController name = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        width: 450.0,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              '情報を入力し、「登録する」ボタンをクリックしてください。',
              style: kDialogTextStyle,
            ),
            SizedBox(height: 16.0),
            CustomTextFormField2(
              label: '雇用形態名',
              controller: name,
              textInputType: null,
              maxLines: 1,
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
                CustomTextButton(
                  label: '登録する',
                  color: Colors.blue,
                  onPressed: () async {
                    if (!await widget.positionProvider.create(
                      groupId: widget.group?.id,
                      name: name.text.trim(),
                    )) {
                      return;
                    }
                    customSnackBar(context, '雇用形態を登録しました');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EditDialog extends StatefulWidget {
  final PositionProvider positionProvider;
  final PositionModel position;

  EditDialog({
    required this.positionProvider,
    required this.position,
  });

  @override
  State<EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  TextEditingController name = TextEditingController();

  void _init() async {
    name.text = widget.position.name;
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
            Text(
              '情報を変更し、「保存する」ボタンをクリックしてください。',
              style: kDialogTextStyle,
            ),
            SizedBox(height: 16.0),
            CustomTextFormField2(
              label: '雇用形態名',
              controller: name,
              textInputType: null,
              maxLines: 1,
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
                      label: '削除する',
                      color: Colors.red,
                      onPressed: () async {
                        if (!await widget.positionProvider.delete(
                          id: widget.position.id,
                        )) {
                          return;
                        }
                        customSnackBar(context, '雇用形態を削除しました');
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(width: 4.0),
                    CustomTextButton(
                      label: '保存する',
                      color: Colors.blue,
                      onPressed: () async {
                        if (!await widget.positionProvider.update(
                          id: widget.position.id,
                          name: name.text.trim(),
                        )) {
                          return;
                        }
                        customSnackBar(context, '雇用形態を保存しました');
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

class InUserDialog extends StatefulWidget {
  final GroupProvider groupProvider;
  final PositionProvider positionProvider;
  final PositionModel position;

  InUserDialog({
    required this.groupProvider,
    required this.positionProvider,
    required this.position,
  });

  @override
  State<InUserDialog> createState() => _InUserDialogState();
}

class _InUserDialogState extends State<InUserDialog> {
  ScrollController _controller = ScrollController();
  List<UserModel> users = [];
  List<String> userIds = [];

  void _init() async {
    List<UserModel> _users = await widget.groupProvider.selectUsers();
    if (mounted) {
      setState(() {
        users = _users;
        for (String _id in widget.position.userIds) {
          UserModel? _user = users.singleWhere((e) => e.id == _id);
          if (_user.id != '') userIds.add(_user.id);
        }
      });
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
            Text(
              '割り当てるスタッフにチェックを入れ、「保存する」ボタンをクリックしてください。',
              style: kDialogTextStyle,
            ),
            SizedBox(height: 16.0),
            TapListTile(
              title: '雇用形態名',
              subtitle: widget.position.name,
            ),
            SizedBox(height: 8.0),
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
                    var contain = userIds.where((e) => e == _user.id);
                    return CustomCheckbox(
                      label: _user.name,
                      value: contain.isNotEmpty,
                      activeColor: Colors.blue,
                      onChanged: (value) {
                        var _contain = userIds.where((e) => e == _user.id);
                        setState(() {
                          if (_contain.isEmpty) {
                            userIds.add(_user.id);
                          } else {
                            userIds.removeWhere((e) => e == _user.id);
                          }
                        });
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
                CustomTextButton(
                  label: '保存する',
                  color: Colors.blue,
                  onPressed: () async {
                    if (!await widget.positionProvider.updateUserIds(
                      id: widget.position.id,
                      userIds: userIds,
                    )) {
                      return;
                    }
                    customSnackBar(context, 'スタッフ割当を保存しました');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
