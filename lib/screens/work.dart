import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/date_machine_util.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/widgets/column_label.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold.dart';
import 'package:hatarakujikan_web/widgets/custom_text_icon_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class WorkScreen extends StatelessWidget {
  static const String id = 'work';

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);

    return CustomAdminScaffold(
      groupProvider: groupProvider,
      selectedRoute: id,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('勤務の管理', style: kAdminTitleTextStyle),
          Text('スタッフが記録した勤務時間を年月形式で表示します。', style: kAdminSubTitleTextStyle),
          SizedBox(height: 16.0),
          WorkDataGrid(),
        ],
      ),
    );
  }
}

class WorkDataGrid extends StatefulWidget {
  @override
  _WorkDataGridState createState() => _WorkDataGridState();
}

class _WorkDataGridState extends State<WorkDataGrid> {
  DateTime selectMonth = DateTime.now();
  List<DateTime> days = [];
  WorkDataSource workDataSource;

  void _generateDays() async {
    days.clear();
    var _dateMap = DateMachineUtil.getMonthDate(selectMonth, 0);
    DateTime _startAt = DateTime.parse('${_dateMap['start']}');
    DateTime _endAt = DateTime.parse('${_dateMap['end']}');
    for (int i = 0; i <= _endAt.difference(_startAt).inDays; i++) {
      days.add(_startAt.add(Duration(days: i)));
    }
  }

  @override
  void initState() {
    super.initState();
    _generateDays();
    workDataSource = WorkDataSource(days);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CustomTextIconButton(
                  onPressed: () {},
                  backgroundColor: Colors.lightBlueAccent,
                  iconData: Icons.calendar_today,
                  labelText: '2021年06月',
                ),
                SizedBox(width: 4.0),
                CustomTextIconButton(
                  onPressed: () {},
                  backgroundColor: Colors.lightBlueAccent,
                  iconData: Icons.group,
                  labelText: '指定なし',
                ),
              ],
            ),
            Row(
              children: [
                CustomTextIconButton(
                  onPressed: () {},
                  backgroundColor: Colors.green,
                  iconData: Icons.file_download,
                  labelText: 'CSV出力',
                ),
                SizedBox(width: 4.0),
                CustomTextIconButton(
                  onPressed: () {},
                  backgroundColor: Colors.redAccent,
                  iconData: Icons.file_download,
                  labelText: 'PDF出力',
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 8.0),
        SfDataGrid(
          source: workDataSource,
          columnWidthMode: ColumnWidthMode.fill,
          isScrollbarAlwaysShown: true,
          horizontalScrollPhysics: NeverScrollableScrollPhysics(),
          columns: [
            GridTextColumn(
              columnName: 'days',
              label: ColumnLabel('日付'),
            ),
            GridTextColumn(
              columnName: 'status',
              label: ColumnLabel('勤務状況'),
            ),
            GridTextColumn(
              columnName: 'start',
              label: ColumnLabel('出勤時間'),
            ),
            GridTextColumn(
              columnName: 'end',
              label: ColumnLabel('退勤時間'),
            ),
            GridTextColumn(
              columnName: 'breaks',
              label: ColumnLabel('休憩時間'),
            ),
            GridTextColumn(
              columnName: 'work',
              label: ColumnLabel('勤務時間'),
            ),
            GridTextColumn(
              columnName: 'work_statutory',
              label: ColumnLabel('法定内時間'),
            ),
            GridTextColumn(
              columnName: 'work_statutory_non',
              label: ColumnLabel('法定外時間'),
            ),
            GridTextColumn(
              columnName: 'work_over',
              label: ColumnLabel('残業時間'),
            ),
          ],
        ),
      ],
    );
  }
}

class WorkDataSource extends DataGridSource {
  WorkDataSource(List<DateTime> days) {
    dataGridRows = days
        .map((dataGridRow) => DataGridRow(
              cells: [
                DataGridCell(
                  columnName: 'days',
                  value: '${DateFormat('dd (E)', 'ja').format(dataGridRow)}',
                ),
                DataGridCell(
                  columnName: 'status',
                  value: '',
                ),
                DataGridCell(
                  columnName: 'start',
                  value: '00:00',
                ),
                DataGridCell(
                  columnName: 'end',
                  value: '00:00',
                ),
                DataGridCell(
                  columnName: 'breaks',
                  value: '00:00',
                ),
                DataGridCell(
                  columnName: 'work',
                  value: '00:00',
                ),
                DataGridCell(
                  columnName: 'work_statutory',
                  value: '00:00',
                ),
                DataGridCell(
                  columnName: 'work_statutory_non',
                  value: '00:00',
                ),
                DataGridCell(
                  columnName: 'work_over',
                  value: '00:00',
                ),
              ],
            ))
        .toList();
  }

  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(8.0),
        child: Text(dataGridCell.value.toString()),
      );
    }).toList());
  }
}
