import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/widgets/TapListTile.dart';
import 'package:hatarakujikan_web/widgets/admin_header.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold.dart';
import 'package:hatarakujikan_web/widgets/custom_dropdown_button.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';
import 'package:hatarakujikan_web/widgets/custom_text_form_field2.dart';
import 'package:provider/provider.dart';

class GroupInfoScreen extends StatelessWidget {
  static const String id = 'group_info';

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);

    return CustomAdminScaffold(
      groupProvider: groupProvider,
      selectedRoute: id,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminHeader(
            title: '会社/組織の情報',
            message: '会社/組織の名前や住所などを変更できます。',
          ),
          SizedBox(height: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TapListTile(
                  title: '名前',
                  subtitle: groupProvider.group?.name,
                  onTap: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (_) => EditNameDialog(
                        groupProvider: groupProvider,
                      ),
                    );
                  },
                ),
                TapListTile(
                  title: '住所',
                  subtitle:
                      '${groupProvider.group?.zip} ${groupProvider.group?.address}',
                  onTap: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (_) => EditAddressDialog(
                        groupProvider: groupProvider,
                      ),
                    );
                  },
                ),
                TapListTile(
                  title: '電話番号',
                  subtitle: groupProvider.group?.tel,
                  onTap: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (_) => EditTelDialog(
                        groupProvider: groupProvider,
                      ),
                    );
                  },
                ),
                TapListTile(
                  title: 'メールアドレス',
                  subtitle: groupProvider.group?.email,
                  onTap: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (_) => EditEmailDialog(
                        groupProvider: groupProvider,
                      ),
                    );
                  },
                ),
                TapListTile(
                  title: '管理者',
                  subtitle: groupProvider.adminUser?.name,
                  onTap: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (_) => EditAdminUserDialog(
                        groupProvider: groupProvider,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EditNameDialog extends StatefulWidget {
  final GroupProvider groupProvider;

  EditNameDialog({required this.groupProvider});

  @override
  State<EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<EditNameDialog> {
  TextEditingController _name = TextEditingController();

  void _init() async {
    _name.text = widget.groupProvider.group?.name ?? '';
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
              label: '名前',
              controller: _name,
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
                  label: '保存する',
                  color: Colors.blue,
                  onPressed: () async {
                    if (!await widget.groupProvider.updateName(
                      id: widget.groupProvider.group?.id,
                      name: _name.text.trim(),
                    )) {
                      return;
                    }
                    widget.groupProvider.reloadGroup();
                    customSnackBar(context, '会社/組織の名前を保存しました');
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

class EditAddressDialog extends StatefulWidget {
  final GroupProvider groupProvider;

  EditAddressDialog({required this.groupProvider});

  @override
  State<EditAddressDialog> createState() => _EditAddressDialogState();
}

class _EditAddressDialogState extends State<EditAddressDialog> {
  TextEditingController _zip = TextEditingController();
  TextEditingController _address = TextEditingController();

  void _init() async {
    _zip.text = widget.groupProvider.group?.zip ?? '';
    _address.text = widget.groupProvider.group?.address ?? '';
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
              label: '郵便番号',
              controller: _zip,
              textInputType: null,
              maxLines: 1,
            ),
            SizedBox(height: 8.0),
            CustomTextFormField2(
              label: '住所',
              controller: _address,
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
                  label: '保存する',
                  color: Colors.blue,
                  onPressed: () async {
                    if (!await widget.groupProvider.updateAddress(
                      id: widget.groupProvider.group?.id,
                      zip: _zip.text.trim(),
                      address: _address.text.trim(),
                    )) {
                      return;
                    }
                    widget.groupProvider.reloadGroup();
                    customSnackBar(context, '会社/組織の住所を保存しました');
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

class EditTelDialog extends StatefulWidget {
  final GroupProvider groupProvider;

  EditTelDialog({required this.groupProvider});

  @override
  State<EditTelDialog> createState() => _EditTelDialogState();
}

class _EditTelDialogState extends State<EditTelDialog> {
  TextEditingController _tel = TextEditingController();

  void _init() async {
    _tel.text = widget.groupProvider.group?.tel ?? '';
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
              label: '電話番号',
              controller: _tel,
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
                  label: '保存する',
                  color: Colors.blue,
                  onPressed: () async {
                    if (!await widget.groupProvider.updateTel(
                      id: widget.groupProvider.group?.id,
                      tel: _tel.text.trim(),
                    )) {
                      return;
                    }
                    widget.groupProvider.reloadGroup();
                    customSnackBar(context, '会社/組織の電話番号を保存しました');
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

class EditEmailDialog extends StatefulWidget {
  final GroupProvider groupProvider;

  EditEmailDialog({required this.groupProvider});

  @override
  State<EditEmailDialog> createState() => _EditEmailDialogState();
}

class _EditEmailDialogState extends State<EditEmailDialog> {
  TextEditingController _email = TextEditingController();

  void _init() async {
    _email.text = widget.groupProvider.group?.email ?? '';
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
              label: 'メールアドレス',
              controller: _email,
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
                  label: '保存する',
                  color: Colors.blue,
                  onPressed: () async {
                    if (!await widget.groupProvider.updateEmail(
                      id: widget.groupProvider.group?.id,
                      email: _email.text.trim(),
                    )) {
                      return;
                    }
                    widget.groupProvider.reloadGroup();
                    customSnackBar(context, '会社/組織のメールアドレスを保存しました');
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

class EditAdminUserDialog extends StatefulWidget {
  final GroupProvider groupProvider;

  EditAdminUserDialog({required this.groupProvider});

  @override
  State<EditAdminUserDialog> createState() => _EditAdminUserDialogState();
}

class _EditAdminUserDialogState extends State<EditAdminUserDialog> {
  String? _adminUserId;

  void _init() async {
    _adminUserId = widget.groupProvider.group?.adminUserId;
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
            Text(
              '保存後、自動的にログアウトします。再度変更後の管理者アカウントでログインしてください。',
              style: kDialogTextStyle,
            ),
            SizedBox(height: 16.0),
            CustomDropdownButton(
              label: 'スタッフから選択',
              isExpanded: true,
              value: _adminUserId,
              onChanged: (value) {
                setState(() => _adminUserId = value);
              },
              items: widget.groupProvider.users.map((user) {
                return DropdownMenuItem(
                  value: user.id,
                  child: Text(
                    user.name,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14.0,
                    ),
                  ),
                );
              }).toList(),
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
                    if (!await widget.groupProvider.updateAdminUser(
                      id: widget.groupProvider.group?.id,
                      adminUserId: _adminUserId,
                    )) {
                      return;
                    }
                    widget.groupProvider.reloadGroup();
                    customSnackBar(context, '会社/組織のメールアドレスを保存しました');
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
