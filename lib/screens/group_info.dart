import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/widgets/TapListTile.dart';
import 'package:hatarakujikan_web/widgets/admin_header.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold.dart';
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
                  title: '会社/組織の名前',
                  subtitle: 'アゴラクリエーション',
                  onTap: () {},
                ),
                TapListTile(
                  title: '会社/組織の住所',
                  subtitle: 'アゴラクリエーション',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
