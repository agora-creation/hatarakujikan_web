import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/side_menu.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/screens/setting_work_panel.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold.dart';
import 'package:provider/provider.dart';

class SettingWorkScreen extends StatelessWidget {
  static const String id = 'group_work';

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);

    return CustomAdminScaffold(
      groupProvider: groupProvider,
      items: kSideMenu,
      selectedRoute: id,
      body: SettingWorkPanel(groupProvider: groupProvider),
    );
  }
}
