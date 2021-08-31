import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/side_menu.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/providers/group_notice.dart';
import 'package:hatarakujikan_web/providers/user.dart';
import 'package:hatarakujikan_web/screens/notice_table.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold.dart';
import 'package:provider/provider.dart';

class NoticeScreen extends StatelessWidget {
  static const String id = 'group_notice';

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final groupNoticeProvider = Provider.of<GroupNoticeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return CustomAdminScaffold(
      groupProvider: groupProvider,
      items: kSideMenu,
      selectedRoute: id,
      body: NoticeTable(
        groupProvider: groupProvider,
        groupNoticeProvider: groupNoticeProvider,
        userProvider: userProvider,
      ),
    );
  }
}
