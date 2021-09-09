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
  final List<Appointment> _shiftCollection = [];
  final List<CalendarResource> _userCollection = [];
  _ShiftDataSource _events;

  void _init() async {
    _calendarController.view = CalendarView.timelineMonth;
    widget.groupProvider.users.forEach((user) {
      _userCollection.add(CalendarResource(
        id: '${user.id}',
        displayName: '${user.name}',
        color: Colors.orangeAccent.shade100,
      ));
    });
    _events = _ShiftDataSource(_shiftCollection, _userCollection);
  }

  @override
  void initState() {
    super.initState();
    _init();
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
            dataSource: _events,
            resourceViewSettings: ResourceViewSettings(
              showAvatar: false,
              displayNameTextStyle: TextStyle(fontSize: 16.0),
            ),
          ),
        ),
      ],
    );
  }
}

class _ShiftDataSource extends CalendarDataSource {
  _ShiftDataSource(
      List<Appointment> source, List<CalendarResource> resourceColl) {
    appointments = source;
    resources = resourceColl;
  }
}
