import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/screens/section_table.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold.dart';
import 'package:provider/provider.dart';

class SectionScreen extends StatelessWidget {
  static const String id = 'section';

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);

    return CustomAdminScaffold(
      groupProvider: groupProvider,
      selectedRoute: id,
      body: SectionTable(
        groupProvider: groupProvider,
      ),
    );
  }
}
