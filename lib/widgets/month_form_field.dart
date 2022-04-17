import 'package:flutter/material.dart';

class MonthFormField extends StatelessWidget {
  final String? label;
  final String? month;
  final Function()? onPressed;

  MonthFormField({
    this.label,
    this.month,
    this.onPressed,
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
        Container(
          width: double.infinity,
          child: TextButton.icon(
            icon: Icon(
              Icons.calendar_month,
              color: Colors.black54,
              size: 16.0,
            ),
            label: Text(
              month ?? '----年--月',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 16.0,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
            ),
            onPressed: onPressed,
          ),
        ),
      ],
    );
  }
}
