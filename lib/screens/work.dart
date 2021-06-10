import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/date_machine_util.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold.dart';
import 'package:hatarakujikan_web/widgets/custom_text_icon_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class WorkScreen extends StatefulWidget {
  static const String id = 'work';

  @override
  _WorkScreenState createState() => _WorkScreenState();
}

class _WorkScreenState extends State<WorkScreen> {
  DateTime selectMonth = DateTime.now();
  List<DateTime> days = [];

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
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);

    return CustomAdminScaffold(
      groupProvider: groupProvider,
      selectedRoute: WorkScreen.id,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('勤務の管理', style: kAdminTitleTextStyle),
          Text('スタッフが記録した勤務時間を年月形式で表示します。', style: kAdminSubTitleTextStyle),
          SizedBox(height: 16.0),
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
          Expanded(
            child: ListView.builder(
              itemCount: days.length,
              itemBuilder: (_, index) {
                return Container(
                  decoration: kBottomBorderDecoration,
                  child: ListTile(
                    leading: Text(
                        '${DateFormat('dd (E)', 'ja').format(days[index])}'),
                    title: Text('なにか'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
