import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/side_menu.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/providers/user.dart';
import 'package:hatarakujikan_web/providers/work.dart';
import 'package:hatarakujikan_web/providers/work_state.dart';
import 'package:hatarakujikan_web/screens/work_table.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold.dart';
import 'package:provider/provider.dart';

class WorkScreen extends StatelessWidget {
  static const String id = 'work';

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final workProvider = Provider.of<WorkProvider>(context);
    final workStateProvider = Provider.of<WorkStateProvider>(context);

    return CustomAdminScaffold(
      groupProvider: groupProvider,
      items: kSideMenu,
      selectedRoute: id,
      body: WorkTable(
        groupProvider: groupProvider,
        userProvider: userProvider,
        workProvider: workProvider,
        workStateProvider: workStateProvider,
      ),
    );
  }
}
