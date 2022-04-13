import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/widgets/admin_header.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold.dart';
import 'package:hatarakujikan_web/widgets/text_icon_button.dart';
import 'package:provider/provider.dart';

class ApplyPTOScreen extends StatelessWidget {
  static const String id = 'applyPTO';

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    GroupModel? group = groupProvider.group;

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
                    label: '未選択',
                    labelColor: Colors.white,
                    backgroundColor: Colors.lightBlueAccent,
                    onPressed: () {},
                  ),
                  SizedBox(width: 4.0),
                  TextIconButton(
                    iconData: Icons.approval,
                    iconColor: Colors.white,
                    label: '承認待ち',
                    labelColor: Colors.white,
                    backgroundColor: Colors.lightBlueAccent,
                    onPressed: () {},
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
