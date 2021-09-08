import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class WorkShiftScreen extends StatelessWidget {
  static const String id = 'work_shift';

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);

    return CustomAdminScaffold(
      groupProvider: groupProvider,
      selectedRoute: id,
      body: WorkShiftTable(
        groupProvider: groupProvider,
      ),
    );
  }
}

class WorkShiftTable extends StatefulWidget {
  final GroupProvider groupProvider;

  WorkShiftTable({@required this.groupProvider});

  @override
  _WorkShiftTableState createState() => _WorkShiftTableState();
}

class _WorkShiftTableState extends State<WorkShiftTable> {
  final CalendarController _calendarController = CalendarController();

  @override
  void initState() {
    super.initState();
    _calendarController.view = CalendarView.timelineMonth;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'シフト表',
          style: kAdminTitleTextStyle,
        ),
        SizedBox(height: 16.0),
        Expanded(
          child: SfCalendar(
            showDatePickerButton: true,
            controller: _calendarController,
            allowViewNavigation: false,
            todayHighlightColor: Colors.lightBlue,
          ),
        ),
      ],
    );
  }
}
