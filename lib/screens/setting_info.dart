import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/side_menu.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/providers/user.dart';
import 'package:hatarakujikan_web/screens/setting_info_panel.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold.dart';
import 'package:provider/provider.dart';

class SettingInfoScreen extends StatelessWidget {
  static const String id = 'setting_info';

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return CustomAdminScaffold(
      groupProvider: groupProvider,
      items: kSideMenu,
      selectedRoute: id,
      body: SettingInfoPanel(
        groupProvider: groupProvider,
        userProvider: userProvider,
      ),
    );
  }
}
