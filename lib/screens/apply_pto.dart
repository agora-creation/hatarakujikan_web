import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/providers/apply_pto.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/widgets/admin_header.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold.dart';
import 'package:hatarakujikan_web/widgets/custom_radio.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';
import 'package:hatarakujikan_web/widgets/text_icon_button.dart';
import 'package:provider/provider.dart';

class ApplyPTOScreen extends StatelessWidget {
  static const String id = 'applyPTO';

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final applyPTOProvider = Provider.of<ApplyPTOProvider>(context);

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
            child: Text('現在申請はありません。'),
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
