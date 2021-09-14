import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CustomSfCalendar extends StatelessWidget {
  final CalendarDataSource dataSource;
  final Function(CalendarTapDetails) onTap;

  CustomSfCalendar({
    this.dataSource,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final CalendarController _calendarController = CalendarController();
    _calendarController.view = CalendarView.timelineMonth;

    return SfCalendar(
      showDatePickerButton: true,
      controller: _calendarController,
      allowViewNavigation: false,
      dataSource: dataSource,
      resourceViewSettings: ResourceViewSettings(
        showAvatar: false,
        displayNameTextStyle: TextStyle(
          color: Colors.black54,
          fontSize: 12.0,
        ),
      ),
      onTap: onTap,
      onViewChanged: null,
    );
  }
}
