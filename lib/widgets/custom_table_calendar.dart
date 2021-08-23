import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CustomTableCalendar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black38),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: TableCalendar(
          locale: 'ja_JP',
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.black12),
              ),
            ),
          ),
          daysOfWeekHeight: 40.0,
          daysOfWeekStyle: DaysOfWeekStyle(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.black12),
              ),
            ),
          ),
          rowHeight: 60.0,
          calendarStyle: CalendarStyle(
            rowDecoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.black12),
              ),
            ),
          ),
          focusedDay: DateTime.now(),
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          onDaySelected: (selectedDay, focusedDay) {
            print(selectedDay);
          },
        ),
      ),
    );
  }
}
