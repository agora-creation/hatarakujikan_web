import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/screens/group_info_panel.dart';
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
      body: GroupInfoPanel(groupProvider: groupProvider),
    );
  }
}