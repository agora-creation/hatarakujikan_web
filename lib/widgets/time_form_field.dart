import 'package:flutter/material.dart';

class TimeFormField extends StatelessWidget {
  final String? label;
  final String? time;
  final Function()? onPressed;

  TimeFormField({
    this.label,
    this.time,
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
              Icons.access_time,
              color: Colors.black54,
              size: 16.0,
            ),
            label: Text(
              time ?? '--:--',
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
