import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/group_notice.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/providers/group_notice.dart';
import 'package:hatarakujikan_web/providers/user.dart';
import 'package:hatarakujikan_web/widgets/custom_icon_label.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';
import 'package:hatarakujikan_web/widgets/custom_text_form_field2.dart';
import 'package:hatarakujikan_web/widgets/custom_text_icon_button.dart';
import 'package:hatarakujikan_web/widgets/loading.dart';

class GroupNoticeTable extends StatefulWidget {
  final GroupProvider groupProvider;
  final GroupNoticeProvider groupNoticeProvider;
  final UserProvider userProvider;

  GroupNoticeTable({
    @required this.groupProvider,
    @required this.groupNoticeProvider,
    @required this.userProvider,
  });

  @override
  _GroupNoticeTableState createState() => _GroupNoticeTableState();
}

class _GroupNoticeTableState extends State<GroupNoticeTable> {
  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> _stream = FirebaseFirestore.instance
        .collection('group')
        .doc(widget.groupProvider.group?.id)
        .collection('notice')
        .where('groupId', isEqualTo: widget.groupProvider.group?.id)
        .orderBy('createdAt', descending: true)
        .snapshots();
    List<GroupNoticeModel> groupNotices = [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'お知らせの管理',
          style: kAdminTitleTextStyle,
        ),
        Text(
          'お知らせを一覧表示します。このお知らせはスマートフォンアプリのスタッフにのみ送信できます。',
          style: kAdminSubTitleTextStyle,
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
                  builder: (_) => AddGroupNoticeDialog(
                    groupNoticeProvider: widget.groupNoticeProvider,
                    groupId: widget.groupProvider.group?.id,
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
          child: StreamBuilder<QuerySnapshot>(
            stream: _stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Loading(color: Colors.orange);
              }
              groupNotices.clear();
              for (DocumentSnapshot groupNotice in snapshot.data.docs) {
                groupNotices.add(GroupNoticeModel.fromSnapshot(groupNotice));
              }
              if (groupNotices.length > 0) {
                return DataTable2(
                  columns: [
                    DataColumn(label: Text('タイトル')),
                    DataColumn2(label: Text('メッセージ'), size: ColumnSize.L),
                    DataColumn2(label: Text('修正/削除'), size: ColumnSize.S),
                    DataColumn2(label: Text('送信'), size: ColumnSize.S),
                  ],
                  rows: List<DataRow>.generate(
                    groupNotices.length,
                    (index) => DataRow(
                      cells: [
                        DataCell(Text('${groupNotices[index].title}')),
                        DataCell(Text('${groupNotices[index].message}')),
                        DataCell(IconButton(
                          onPressed: () {
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (_) => EditGroupNoticeDialog(
                                groupNoticeProvider: widget.groupNoticeProvider,
                                groupNotice: groupNotices[index],
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
                              builder: (_) => SendGroupNoticeDialog(
                                groupNoticeProvider: widget.groupNoticeProvider,
                                userProvider: widget.userProvider,
                                groupNotice: groupNotices[index],
                              ),
                            );
                          },
                          icon: Icon(Icons.send, color: Colors.blue),
                        )),
                      ],
                    ),
                  ),
                );
              } else {
                return Text('現在登録されているお知らせはありません');
              }
            },
          ),
        ),
      ],
    );
  }
}

class AddGroupNoticeDialog extends StatefulWidget {
  final GroupNoticeProvider groupNoticeProvider;
  final String groupId;

  AddGroupNoticeDialog({
    @required this.groupNoticeProvider,
    @required this.groupId,
  });

  @override
  _AddGroupNoticeDialogState createState() => _AddGroupNoticeDialogState();
}

class _AddGroupNoticeDialogState extends State<AddGroupNoticeDialog> {
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
            SizedBox(height: 16.0),
            Text(
              '項目を全て入力して、最後に「登録する」ボタンを押してください。',
              style: TextStyle(color: Colors.black54, fontSize: 14.0),
            ),
            Text(
              '※ここでは登録のみで、送信はされません。',
              style: TextStyle(color: Colors.redAccent, fontSize: 14.0),
            ),
            SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('タイトル', style: TextStyle(fontSize: 14.0)),
                CustomTextFormField2(
                  textInputType: null,
                  maxLines: 1,
                  controller: title,
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('メッセージ', style: TextStyle(fontSize: 14.0)),
                CustomTextFormField2(
                  textInputType: TextInputType.multiline,
                  maxLines: null,
                  controller: message,
                ),
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
                CustomTextButton(
                  onPressed: () async {
                    if (!await widget.groupNoticeProvider.create(
                      groupId: widget.groupId,
                      title: title.text.trim(),
                      message: message.text,
                    )) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('お知らせを登録しました')),
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

class EditGroupNoticeDialog extends StatefulWidget {
  final GroupNoticeProvider groupNoticeProvider;
  final GroupNoticeModel groupNotice;

  EditGroupNoticeDialog({
    @required this.groupNoticeProvider,
    @required this.groupNotice,
  });

  @override
  _EditGroupNoticeDialogState createState() => _EditGroupNoticeDialogState();
}

class _EditGroupNoticeDialogState extends State<EditGroupNoticeDialog> {
  TextEditingController title = TextEditingController();
  TextEditingController message = TextEditingController();

  void _init() async {
    setState(() {
      title.text = widget.groupNotice?.title;
      message.text = widget.groupNotice?.message;
    });
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
              'お知らせ情報を修正できます。',
              style: TextStyle(color: Colors.black54, fontSize: 14.0),
            ),
            SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('タイトル', style: TextStyle(fontSize: 14.0)),
                CustomTextFormField2(
                  textInputType: null,
                  maxLines: 1,
                  controller: title,
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('メッセージ', style: TextStyle(fontSize: 14.0)),
                CustomTextFormField2(
                  textInputType: TextInputType.multiline,
                  maxLines: null,
                  controller: message,
                ),
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
                    CustomTextButton(
                      onPressed: () {
                        widget.groupNoticeProvider.delete(
                          groupNotice: widget.groupNotice,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('お知らせを削除しました')),
                        );
                        Navigator.pop(context);
                      },
                      color: Colors.red,
                      label: '削除する',
                    ),
                    SizedBox(width: 4.0),
                    CustomTextButton(
                      onPressed: () async {
                        if (!await widget.groupNoticeProvider.update(
                          id: widget.groupNotice.id,
                          groupId: widget.groupNotice.groupId,
                          title: title.text.trim(),
                          message: message.text,
                        )) {
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('お知らせを修正しました')),
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

class SendGroupNoticeDialog extends StatefulWidget {
  final GroupNoticeProvider groupNoticeProvider;
  final UserProvider userProvider;
  final GroupNoticeModel groupNotice;

  SendGroupNoticeDialog({
    @required this.groupNoticeProvider,
    @required this.userProvider,
    @required this.groupNotice,
  });

  @override
  _SendGroupNoticeDialogState createState() => _SendGroupNoticeDialogState();
}

class _SendGroupNoticeDialogState extends State<SendGroupNoticeDialog> {
  final ScrollController _scrollController = ScrollController();
  List<UserModel> _users = [];
  List<UserModel> _selected = [];

  void _init() async {
    await widget.userProvider
        .selectListNotice(
      groupId: widget.groupNotice?.groupId,
      noticeId: widget.groupNotice?.id,
    )
        .then((value) {
      setState(() => _users = value);
    });
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
              'お知らせ情報を送信先スタッフを選択して、送信してください。',
              style: TextStyle(color: Colors.black54, fontSize: 14.0),
            ),
            SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'タイトル',
                  style: TextStyle(color: Colors.black54, fontSize: 14.0),
                ),
                Text('${widget.groupNotice?.title}'),
              ],
            ),
            Divider(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'メッセージ',
                  style: TextStyle(color: Colors.black54, fontSize: 14.0),
                ),
                Text('${widget.groupNotice?.message}'),
              ],
            ),
            Divider(),
            SizedBox(height: 8.0),
            CustomIconLabel(
              iconData: Icons.person,
              label: '送信先スタッフ',
            ),
            Container(
              height: 350.0,
              child: Scrollbar(
                isAlwaysShown: true,
                controller: _scrollController,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  controller: _scrollController,
                  itemCount: _users.length,
                  itemBuilder: (_, index) {
                    UserModel _user = _users[index];
                    var contain = _selected.where((e) => e.id == _user.id);
                    return Container(
                      decoration: kBottomBorderDecoration,
                      child: CheckboxListTile(
                        title: Text('${_user.name}'),
                        value: contain.isNotEmpty,
                        activeColor: Colors.blue,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (value) {
                          var _contain =
                              _selected.where((e) => e.id == _user.id);
                          setState(() {
                            if (_contain.isEmpty) {
                              _selected.add(_user);
                            } else {
                              _selected.removeWhere((e) => e.id == _user.id);
                            }
                          });
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
                _selected.length > 0
                    ? CustomTextButton(
                        onPressed: () async {
                          if (!await widget.groupNoticeProvider.send(
                            users: _selected,
                            id: widget.groupNotice.id,
                            groupId: widget.groupNotice.groupId,
                            title: widget.groupNotice.title,
                            message: widget.groupNotice.message,
                          )) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('お知らせを送信しました')),
                          );
                          Navigator.pop(context);
                        },
                        color: Colors.cyan,
                        label: '送信する',
                      )
                    : CustomTextButton(
                        onPressed: null,
                        color: Colors.grey,
                        label: '送信する',
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
