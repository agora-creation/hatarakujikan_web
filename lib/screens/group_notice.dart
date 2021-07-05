import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/providers/user.dart';
import 'package:hatarakujikan_web/screens/group_notice_table.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold.dart';
import 'package:provider/provider.dart';

class GroupNoticeScreen extends StatelessWidget {
  static const String id = 'group_notice';

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return CustomAdminScaffold(
      groupProvider: groupProvider,
      selectedRoute: id,
      body: GroupNoticeTable(
        groupProvider: groupProvider,
        userProvider: userProvider,
      ),
    );
  }
}
