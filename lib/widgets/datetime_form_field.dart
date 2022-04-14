import 'package:flutter/material.dart';

class DateTimeFormField extends StatelessWidget {
  final String? label;
  final String? date;
  final Function()? dateOnPressed;
  final String? time;
  final Function()? timeOnPressed;

  DateTimeFormField({
    this.label,
    this.date,
    this.dateOnPressed,
    this.time,
    this.timeOnPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label ?? '',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextButton.icon(
                icon: Icon(
                  Icons.today,
                  color: Colors.black54,
                  size: 16.0,
                ),
                label: Text(
                  date ?? '',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16.0,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  padding: EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 24.0,
                  ),
                ),
                onPressed: dateOnPressed,
              ),
            ),
            SizedBox(width: 4.0),
            Expanded(
              flex: 2,
              child: TextButton.icon(
                icon: Icon(
                  Icons.access_time,
                  color: Colors.black54,
                  size: 16.0,
                ),
                label: Text(
                  time ?? '',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16.0,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  padding: EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 24.0,
                  ),
                ),
                onPressed: timeOnPressed,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
