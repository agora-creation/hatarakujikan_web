import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/date_machine_util.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold.dart';
import 'package:hatarakujikan_web/widgets/custom_text_icon_button.dart';
import 'package:hatarakujikan_web/widgets/grid_column_label.dart';
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
          Text(
            '勤務の管理',
            style: kAdminTitleTextStyle,
          ),
          Text(
            'スタッフが記録した勤務時間を年月形式で表示します。',
            style: kAdminSubTitleTextStyle,
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CustomTextIconButton(
                    onPressed: () {},
                    backgroundColor: Colors.lightBlue,
                    iconData: Icons.group,
                    labelText: '指定なし',
                  ),
                ],
              ),
              CustomTextIconButton(
                onPressed: () {},
                backgroundColor: Colors.green,
                iconData: Icons.file_download,
                labelText: 'CSVダウンロード',
              ),
            ],
          ),
          SizedBox(height: 16.0),
          Expanded(
            child: WorkTable(),
          ),
        ],
      ),
    );
  }
}

class WorkTable extends StatefulWidget {
  @override
  _WorkTableState createState() => _WorkTableState();
}

class _WorkTableState extends State<WorkTable> {
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
    return SfDataGrid(
      source: workDataSource,
      columnWidthMode: ColumnWidthMode.fill,
      columns: [
        GridTextColumn(
          columnName: 'days',
          label: GridColumnLabel(labelText: '日付'),
        ),
        GridTextColumn(
          columnName: 'status',
          label: GridColumnLabel(labelText: '勤務状況'),
        ),
        GridTextColumn(
          columnName: 'start',
          label: GridColumnLabel(labelText: '出勤時間'),
        ),
        GridTextColumn(
          columnName: 'end',
          label: GridColumnLabel(labelText: '退勤時間'),
        ),
        GridTextColumn(
          columnName: 'breaks',
          label: GridColumnLabel(labelText: '休憩時間'),
        ),
        GridTextColumn(
          columnName: 'work',
          label: GridColumnLabel(labelText: '勤務時間'),
        ),
      ],
    );
  }
}

class WorkDataSource extends DataGridSource {
  WorkDataSource(List<DateTime> days) {
    dataGridRows = days
        .map<DataGridRow>((e) => DataGridRow(
              cells: [
                DataGridCell<String>(
                  columnName: 'days',
                  value: '02/01',
                ),
                DataGridCell<String>(
                  columnName: 'status',
                  value: '通常勤務',
                ),
                DataGridCell<String>(
                  columnName: 'start',
                  value: '00:00',
                ),
                DataGridCell<String>(
                  columnName: 'end',
                  value: '00:00',
                ),
                DataGridCell<String>(
                  columnName: 'breaks',
                  value: '00:00',
                ),
                DataGridCell<String>(
                  columnName: 'work',
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
        cells: row.getCells().map<Widget>((e) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(8.0),
        child: Text(e.value.toString()),
      );
    }).toList());
  }
}
