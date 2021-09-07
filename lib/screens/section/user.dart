import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/providers/section.dart';
import 'package:hatarakujikan_web/providers/user.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold2.dart';
import 'package:provider/provider.dart';

class SectionUserScreen extends StatelessWidget {
  static const String id = 'section_user';

  @override
  Widget build(BuildContext context) {
    final sectionProvider = Provider.of<SectionProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return CustomAdminScaffold2(
      sectionProvider: sectionProvider,
      selectedRoute: id,
      body: SectionUserTable(
        sectionProvider: sectionProvider,
        userProvider: userProvider,
      ),
    );
  }
}

class SectionUserTable extends StatefulWidget {
  final SectionProvider sectionProvider;
  final UserProvider userProvider;

  SectionUserTable({
    @required this.sectionProvider,
    @required this.userProvider,
  });

  @override
  _SectionUserTableState createState() => _SectionUserTableState();
}

class _SectionUserTableState extends State<SectionUserTable> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'スタッフの管理',
          style: kAdminTitleTextStyle,
        ),
        Text(
          'スタッフを一覧表示します。',
          style: kAdminSubTitleTextStyle,
        ),
        SizedBox(height: 16.0),
        Expanded(
          child: DataTable2(
            columns: [
              DataColumn2(label: Text('スタッフ名')),
              DataColumn2(label: Text('タブレット用暗証番号'), size: ColumnSize.L),
              DataColumn2(label: Text('メールアドレス')),
            ],
            rows: List<DataRow>.generate(
              widget.sectionProvider.users.length,
              (index) => DataRow(
                cells: [
                  DataCell(Text('${widget.sectionProvider.users[index].name}')),
                  DataCell(Text(
                    '${widget.sectionProvider.users[index].recordPassword}',
                  )),
                  DataCell(Text(
                    '${widget.sectionProvider.users[index].email}',
                  )),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
