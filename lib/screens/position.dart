import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/position.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/providers/position.dart';
import 'package:hatarakujikan_web/widgets/admin_header.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold.dart';
import 'package:hatarakujikan_web/widgets/custom_checkbox_list_tile.dart';
import 'package:hatarakujikan_web/widgets/custom_icon_label.dart';
import 'package:hatarakujikan_web/widgets/custom_label_column.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';
import 'package:hatarakujikan_web/widgets/custom_text_form_field2.dart';
import 'package:hatarakujikan_web/widgets/custom_text_icon_button.dart';
import 'package:provider/provider.dart';

class PositionScreen extends StatelessWidget {
  static const String id = 'position';

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final positionProvider = Provider.of<PositionProvider>(context);

    return CustomAdminScaffold(
      groupProvider: groupProvider,
      selectedRoute: id,
      body: PositionTable(
        groupProvider: groupProvider,
        positionProvider: positionProvider,
      ),
    );
  }
}

class PositionTable extends StatefulWidget {
  final GroupProvider groupProvider;
  final PositionProvider positionProvider;

  PositionTable({
    required this.groupProvider,
    required this.positionProvider,
  });

  @override
  _PositionTableState createState() => _PositionTableState();
}

class _PositionTableState extends State<PositionTable> {
  @override
  Widget build(BuildContext context) {
    GroupModel? _group = widget.groupProvider.group;
    Stream<QuerySnapshot<Map<String, dynamic>>> _stream = FirebaseFirestore
        .instance
        .collection('position')
        .where('groupId', isEqualTo: _group?.id ?? 'error')
        .orderBy('createdAt', descending: true)
        .snapshots();
    List<PositionModel> _positions = [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminHeader(
          title: '雇用形態の管理',
          message: '雇用形態を一覧表示します。雇用形態毎にスタッフを登録してください',
        ),
        SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(),
            CustomTextIconButton(
              onPressed: () {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (_) => AddPositionDialog(
                    positionProvider: widget.positionProvider,
                    group: widget.groupProvider.group!,
                  ),
                );
              },
              color: Colors.blue,
              iconData: Icons.add,
              label: '新規登録',
            ),
          ],
        ),
        SizedBox(height: 8.0),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _stream,
            builder: (context, snapshot) {
              _positions.clear();
              if (snapshot.hasData) {
                for (DocumentSnapshot<Map<String, dynamic>> doc
                    in snapshot.data!.docs) {
                  _positions.add(PositionModel.fromSnapshot(doc));
                }
              }
              return DataTable2(
                columns: [
                  DataColumn2(label: Text('雇用形態名'), size: ColumnSize.S),
                  DataColumn2(label: Text('現在の登録スタッフ'), size: ColumnSize.L),
                  DataColumn2(label: Text('修正/削除'), size: ColumnSize.S),
                  DataColumn2(label: Text('スタッフ登録'), size: ColumnSize.S),
                ],
                rows: List<DataRow>.generate(
                  _positions.length,
                  (index) {
                    List<UserModel?> _users = widget.groupProvider.users;
                    String _positionUsers = '';
                    if (_positions[index].userIds.length != 0) {
                      for (String _id in _positions[index].userIds) {
                        if (_positionUsers != '') _positionUsers += ',';
                        UserModel? _user = _users.singleWhere(
                          (e) => e?.id == _id,
                          orElse: () => null,
                        );
                        if (_user != null) {
                          _positionUsers += _user.name;
                        }
                      }
                    }
                    return DataRow(
                      cells: [
                        DataCell(Text('${_positions[index].name}')),
                        DataCell(Text(
                          '$_positionUsers',
                          overflow: TextOverflow.ellipsis,
                        )),
                        DataCell(IconButton(
                          onPressed: () {
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (_) => EditPositionDialog(
                                positionProvider: widget.positionProvider,
                                position: _positions[index],
                              ),
                            );
                          },
                          icon: Icon(Icons.edit, color: Colors.blue),
                        )),
                        DataCell(IconButton(
                          onPressed: () {
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (_) => UserPositionDialog(
                                groupProvider: widget.groupProvider,
                                positionProvider: widget.positionProvider,
                                position: _positions[index],
                              ),
                            );
                          },
                          icon: Icon(Icons.person, color: Colors.blue),
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
    );
  }
}

class AddPositionDialog extends StatefulWidget {
  final PositionProvider positionProvider;
  final GroupModel group;

  AddPositionDialog({
    required this.positionProvider,
    required this.group,
  });

  @override
  _AddPositionDialogState createState() => _AddPositionDialogState();
}

class _AddPositionDialogState extends State<AddPositionDialog> {
  TextEditingController name = TextEditingController();

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
              '項目を全て入力して、最後に「登録する」ボタンを押してください。',
              style: kDefaultTextStyle,
            ),
            SizedBox(height: 16.0),
            CustomLabelColumn(
              label: '雇用形態名',
              child: CustomTextFormField2(
                textInputType: null,
                maxLines: 1,
                controller: name,
                onChanged: (value) {},
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
                CustomTextButton(
                  onPressed: () async {
                    if (!await widget.positionProvider.create(
                      groupId: widget.group.id,
                      name: name.text.trim(),
                    )) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('雇用形態を登録しました')),
                    );
                    Navigator.pop(context);
                  },
                  color: Colors.blue,
                  label: '登録する',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EditPositionDialog extends StatefulWidget {
  final PositionProvider positionProvider;
  final PositionModel position;

  EditPositionDialog({
    required this.positionProvider,
    required this.position,
  });

  @override
  _EditPositionDialogState createState() => _EditPositionDialogState();
}

class _EditPositionDialogState extends State<EditPositionDialog> {
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
            SizedBox(height: 16.0),
            Text(
              '雇用形態の情報を修正できます。',
              style: kDefaultTextStyle,
            ),
            SizedBox(height: 16.0),
            CustomLabelColumn(
              label: '雇用形態名',
              child: CustomTextFormField2(
                textInputType: null,
                maxLines: 1,
                controller: name,
                onChanged: (value) {},
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
                        widget.positionProvider.delete(
                          id: widget.position.id,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('雇用形態を削除しました')),
                        );
                        Navigator.pop(context);
                      },
                      color: Colors.red,
                      label: '削除する',
                    ),
                    SizedBox(width: 4.0),
                    CustomTextButton(
                      onPressed: () async {
                        if (!await widget.positionProvider.update(
                          id: widget.position.id,
                          name: name.text.trim(),
                        )) {
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('雇用形態を修正しました')),
                        );
                        Navigator.pop(context);
                      },
                      color: Colors.blue,
                      label: '修正する',
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

class UserPositionDialog extends StatefulWidget {
  final GroupProvider groupProvider;
  final PositionProvider positionProvider;
  final PositionModel position;

  UserPositionDialog({
    required this.groupProvider,
    required this.positionProvider,
    required this.position,
  });

  @override
  _UserPositionDialogState createState() => _UserPositionDialogState();
}

class _UserPositionDialogState extends State<UserPositionDialog> {
  final ScrollController _scrollController = ScrollController();
  List<UserModel> _selected = [];

  void _init() async {
    for (String _id in widget.position.userIds) {
      UserModel? _user =
          widget.groupProvider.users.singleWhere((e) => e.id == _id);
      if (_user.id != '') {
        _selected.add(_user);
      }
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
            SizedBox(height: 16.0),
            Text(
              '登録した雇用形態情報にスタッフ情報を紐付けします。各スタッフを選択して、登録してください。',
              style: kDefaultTextStyle,
            ),
            SizedBox(height: 16.0),
            CustomLabelColumn(
              label: '雇用形態名',
              child: Text(widget.position.name),
            ),
            Divider(),
            SizedBox(height: 8.0),
            CustomIconLabel(
              iconData: Icons.person,
              label: 'スタッフ',
            ),
            Container(
              width: 250.0,
              child: Scrollbar(
                isAlwaysShown: true,
                controller: _scrollController,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  controller: _scrollController,
                  itemCount: widget.groupProvider.users.length,
                  itemBuilder: (_, index) {
                    UserModel _user = widget.groupProvider.users[index];
                    var contain = _selected.where((e) => e.id == _user.id);
                    return CustomCheckboxListTile(
                      onChanged: (value) {
                        var _contain = _selected.where((e) => e.id == _user.id);
                        setState(() {
                          if (_contain.isEmpty) {
                            _selected.add(_user);
                          } else {
                            _selected.removeWhere((e) => e.id == _user.id);
                          }
                        });
                      },
                      label: '${_user.name}',
                      value: contain.isNotEmpty,
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
                  onPressed: () async {
                    if (!await widget.positionProvider.updateUsers(
                      position: widget.position,
                      users: _selected,
                    )) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('雇用形態情報にスタッフ情報を登録しました')),
                    );
                    Navigator.pop(context);
                  },
                  color: Colors.blue,
                  label: '登録する',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
