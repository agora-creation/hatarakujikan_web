import 'package:flutter/material.dart';

class AdminHeader extends StatelessWidget {
  final String? title;
  final String? message;

  AdminHeader({
    this.title,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title ?? '',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          message ?? '',
          style: TextStyle(
            color: Colors.black45,
            fontSize: 16.0,
          ),
        ),
      ],
    );
  }
}
