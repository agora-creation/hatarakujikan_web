import 'package:flutter/material.dart';

class CustomDateButton extends StatelessWidget {
  final String labelText;
  final Function onPressed;

  CustomDateButton({
    this.labelText,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(Icons.today, color: Colors.black54, size: 16.0),
      label: Text(
        labelText,
        style: TextStyle(
          color: Colors.black54,
          fontSize: 16.0,
        ),
      ),
      style: TextButton.styleFrom(
        backgroundColor: Colors.grey.shade200,
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      ),
    );
  }
}
