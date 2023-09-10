import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/group_notice.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/providers/group_notice.dart';
import 'package:hatarakujikan_web/widgets/admin_header.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold.dart';
import 'package:hatarakujikan_web/widgets/custom_checkbox.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';
import 'package:hatarakujikan_web/widgets/custom_text_form_field2.dart';
import 'package:hatarakujikan_web/widgets/tap_list_tile.dart';
import 'package:hatarakujikan_web/widgets/text_icon_button.dart';
import 'package:provider/provider.dart';

class GroupNoticeScreen extends StatelessWidget {
  static const String id = 'group_notice';

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final noticeProvider = Provider.of<GroupNoticeProvider>(context);
    GroupModel? group = groupProvider.group;
    List<GroupNoticeModel> notices = [];

    return CustomAdminScaffold(
      groupProvider: groupProvider,
      selectedRoute: id,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminHeader(
            title: 'お知らせの管理',
            message: 'お知らせを登録し、各スタッフのスマホアプリへ通知を送ることができます。',
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
                      noticeProvider: noticeProvider,
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
              stream: noticeProvider.streamList(groupId: group?.id),
              builder: (context, snapshot) {
                notices.clear();
                if (snapshot.hasData) {
                  for (DocumentSnapshot<Map<String, dynamic>> doc
                      in snapshot.data!.docs) {
                    notices.add(GroupNoticeModel.fromSnapshot(doc));
                  }
                }
                if (notices.length == 0) return Text('現在登録しているお知らせはありません。');
                return DataTable2(
                  columns: [
                    DataColumn2(label: Text('タイトル'), size: ColumnSize.M),
                    DataColumn2(label: Text('メッセージ'), size: ColumnSize.L),
                    DataColumn2(label: Text('修正/削除'), size: ColumnSize.S),
                    DataColumn2(label: Text('スタッフ送信'), size: ColumnSize.S),
                  ],
                  rows: List<DataRow>.generate(
                    notices.length,
                    (index) => DataRow(
                      cells: [
                        DataCell(Text('${notices[index].title}')),
                        DataCell(Text(
                          '${notices[index].message}',
                          overflow: TextOverflow.ellipsis,
                        )),
                        DataCell(IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (_) => EditDialog(
                                noticeProvider: noticeProvider,
                                notice: notices[index],
                              ),
                            );
                          },
                        )),
                        DataCell(IconButton(
                          icon: Icon(Icons.send, color: Colors.blue),
                          onPressed: () {
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (_) => SendDialog(
                                groupProvider: groupProvider,
                                noticeProvider: noticeProvider,
                                notice: notices[index],
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

class AddDialog extends StatefulWidget {
  final GroupNoticeProvider noticeProvider;
  final GroupModel? group;

  AddDialog({
    required this.noticeProvider,
    this.group,
  });

  @override
  State<AddDialog> createState() => _AddDialogState();
}

class _AddDialogState extends State<AddDialog> {
  TextEditingController title = TextEditingController();
  TextEditingController message = TextEditingController();

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
              label: 'タイトル',
              controller: title,
              textInputType: null,
              maxLines: 1,
            ),
            SizedBox(height: 8.0),
            CustomTextFormField2(
              label: 'メッセージ',
              controller: message,
              textInputType: TextInputType.multiline,
              maxLines: null,
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
                    if (!await widget.noticeProvider.create(
                      groupId: widget.group?.id,
                      title: title.text.trim(),
                      message: message.text.trim(),
                    )) {
                      return;
                    }
                    customSnackBar(context, 'お知らせを登録しました');
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
  final GroupNoticeProvider noticeProvider;
  final GroupNoticeModel notice;

  EditDialog({
    required this.noticeProvider,
    required this.notice,
  });

  @override
  State<EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  TextEditingController title = TextEditingController();
  TextEditingController message = TextEditingController();

  void _init() async {
    title.text = widget.notice.title;
    message.text = widget.notice.message;
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
              label: 'タイトル',
              controller: title,
              textInputType: null,
              maxLines: 1,
            ),
            SizedBox(height: 8.0),
            CustomTextFormField2(
              label: 'メッセージ',
              controller: message,
              textInputType: TextInputType.multiline,
              maxLines: null,
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
                        if (!await widget.noticeProvider.delete(
                          id: widget.notice.id,
                          groupId: widget.notice.groupId,
                        )) {
                          return;
                        }
                        customSnackBar(context, 'お知らせを削除しました');
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(width: 4.0),
                    CustomTextButton(
                      label: '保存する',
                      color: Colors.blue,
                      onPressed: () async {
                        if (!await widget.noticeProvider.update(
                          id: widget.notice.id,
                          groupId: widget.notice.groupId,
                          title: title.text.trim(),
                          message: message.text.trim(),
                        )) {
                          return;
                        }
                        customSnackBar(context, 'お知らせを保存しました');
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

class SendDialog extends StatefulWidget {
  final GroupProvider groupProvider;
  final GroupNoticeProvider noticeProvider;
  final GroupNoticeModel notice;

  SendDialog({
    required this.groupProvider,
    required this.noticeProvider,
    required this.notice,
  });

  @override
  State<SendDialog> createState() => _SendDialogState();
}

class _SendDialogState extends State<SendDialog> {
  ScrollController _controller = ScrollController();
  List<UserModel> users = [];
  List<UserModel> selected = [];

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
            Text(
              '送信するスタッフにチェックを入れ、「送信する」ボタンをクリックしてください。',
              style: kDialogTextStyle,
            ),
            SizedBox(height: 16.0),
            TapListTile(
              title: 'タイトル',
              subtitle: widget.notice.title,
            ),
            SizedBox(height: 8.0),
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
                    var contain = selected.where((e) => e.id == _user.id);
                    return CustomCheckbox(
                      label: _user.name,
                      value: contain.isNotEmpty,
                      activeColor: Colors.blue,
                      onChanged: (value) {
                        var _contain = selected.where((e) => e.id == _user.id);
                        setState(() {
                          if (_contain.isEmpty) {
                            selected.add(_user);
                          } else {
                            selected.removeWhere((e) => e.id == _user.id);
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
                  label: '送信する',
                  color: Colors.blue,
                  onPressed: () async {
                    if (!await widget.noticeProvider.send(
                      notice: widget.notice,
                      users: selected,
                    )) {
                      return;
                    }
                    customSnackBar(context, 'お知らせをスタッフに送信しました');
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
