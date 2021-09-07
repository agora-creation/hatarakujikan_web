import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/helpers/pdf_api.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/screens/login.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold.dart';
import 'package:hatarakujikan_web/widgets/custom_dropdown_button.dart';
import 'package:hatarakujikan_web/widgets/custom_label_column.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';
import 'package:hatarakujikan_web/widgets/custom_text_form_field2.dart';
import 'package:hatarakujikan_web/widgets/custom_text_icon_button.dart';
import 'package:provider/provider.dart';

class SettingInfoScreen extends StatelessWidget {
  static const String id = 'setting_info';

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);

    return CustomAdminScaffold(
      groupProvider: groupProvider,
      selectedRoute: id,
      body: SettingInfoPanel(groupProvider: groupProvider),
    );
  }
}

class SettingInfoPanel extends StatefulWidget {
  final GroupProvider groupProvider;

  SettingInfoPanel({@required this.groupProvider});

  @override
  _SettingInfoPanelState createState() => _SettingInfoPanelState();
}

class _SettingInfoPanelState extends State<SettingInfoPanel> {
  TextEditingController name = TextEditingController();
  List<UserModel> _users = [];
  UserModel adminUser;

  void _init() async {
    name.text = widget.groupProvider.group?.name;
    widget.groupProvider.users.forEach((user) {
      if (user.smartphone == true) {
        _users.add(user);
      }
    });
    adminUser = _users.singleWhere(
      (user) => user.id == widget.groupProvider.group?.adminUserId,
    );
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '基本情報の変更',
          style: kAdminTitleTextStyle,
        ),
        Text(
          '会社/組織の基本情報を変更できます。また、以下の「QRコード出力」で会社/組織IDが入ったQRコードをプリントして、スタッフの見える位置に貼ってください。',
          style: kAdminSubTitleTextStyle,
        ),
        SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(),
            Row(
              children: [
                CustomTextIconButton(
                  onPressed: () async {
                    await PdfApi.qrcode(group: widget.groupProvider.group);
                  },
                  color: Colors.redAccent,
                  iconData: Icons.qr_code,
                  label: 'QRコード出力',
                ),
                SizedBox(width: 4.0),
                CustomTextIconButton(
                  onPressed: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (_) => ConfirmDialog(
                        groupProvider: widget.groupProvider,
                        name: name.text.trim(),
                        adminUserId: adminUser?.id,
                      ),
                    );
                  },
                  color: Colors.blue,
                  iconData: Icons.save,
                  label: '変更を保存',
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 8.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomLabelColumn(
                label: '会社/組織名',
                child: CustomTextFormField2(
                  textInputType: null,
                  maxLines: 1,
                  controller: name,
                ),
              ),
              SizedBox(height: 8.0),
              CustomLabelColumn(
                label: '管理者を選ぶ',
                child: CustomDropdownButton(
                  isExpanded: false,
                  value: adminUser,
                  onChanged: (value) {
                    setState(() => adminUser = value);
                  },
                  items: _users.map((value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(
                        '${value.name}',
                        style: kDefaultTextStyle,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ConfirmDialog extends StatelessWidget {
  final GroupProvider groupProvider;
  final String name;
  final String adminUserId;

  ConfirmDialog({
    @required this.groupProvider,
    @required this.name,
    @required this.adminUserId,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.0),
          Text(
            '変更内容を保存します。よろしいですか？',
            style: TextStyle(fontSize: 16.0),
          ),
          Text(
            '※変更完了後、自動的にログアウトされます。',
            style: TextStyle(color: Colors.redAccent, fontSize: 14.0),
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
                  if (!await groupProvider.updateInfo(
                    id: groupProvider.group?.id,
                    name: name,
                    adminUserId: adminUserId,
                  )) {
                    return;
                  }
                  await groupProvider.signOut();
                  Navigator.pop(context);
                  changeScreen(context, LoginScreen());
                },
                color: Colors.blue,
                label: 'はい',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
