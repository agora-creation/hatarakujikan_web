import 'package:flutter/material.dart';

class CustomTextButtonMini extends StatelessWidget {
  final String? label;
  final Color? color;
  final Function()? onPressed;

  CustomTextButtonMini({
    this.label,
    this.color,
    this.onPressed,
  });
  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Text(
        label ?? '',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14.0,
        ),
      ),
      style: TextButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 22.0),
      ),
      onPressed: onPressed,
    );
  }
}
