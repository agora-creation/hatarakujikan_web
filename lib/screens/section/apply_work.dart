import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/providers/section.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold2.dart';
import 'package:provider/provider.dart';

class SectionApplyWorkScreen extends StatelessWidget {
  static const String id = 'section_apply_work';

  @override
  Widget build(BuildContext context) {
    final sectionProvider = Provider.of<SectionProvider>(context);

    return CustomAdminScaffold2(
      sectionProvider: sectionProvider,
      selectedRoute: id,
      body: Container(),
    );
  }
}
