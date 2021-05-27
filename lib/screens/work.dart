import 'package:data_tables/data_tables.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold.dart';
import 'package:provider/provider.dart';

class WorkScreen extends StatefulWidget {
  static const String id = 'work';

  @override
  _WorkScreenState createState() => _WorkScreenState();
}

class _WorkScreenState extends State<WorkScreen> {
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int _sortColumnIndex;
  bool _sortAscending = true;
  int _rowsOffset = 0;
  List<UserModel> _users = [];

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);

    return CustomAdminScaffold(
      groupProvider: groupProvider,
      selectedRoute: WorkScreen.id,
      body: NativeDataTable.builder(
        rowsPerPage: _rowsPerPage,
        itemCount: _users.length ?? 0,
        firstRowIndex: _rowsOffset,
        handleNext: () {},
        handlePrevious: () {},
        itemBuilder: (index) {
          final UserModel user = _users[index];
          return DataRow.byIndex(
            cells: [
              DataCell(Text('')),
            ],
          );
        },
        header: Text('勤怠の管理'),
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _sortAscending,
        onRefresh: () async {},
        onRowsPerPageChanged: (value) {},
        showSelect: false,
        onSelectAll: (value) {},
        rowCountApproximate: true,
        actions: [],
        selectedActions: [],
        noItems: Text('勤怠がありません'),
        columns: [],
      ),
    );
  }
}
