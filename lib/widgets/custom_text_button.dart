import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  final String? label;
  final Color? color;
  final Function()? onPressed;

  CustomTextButton({
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
          fontSize: 16.0,
        ),
      ),
      style: TextButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      ),
      onPressed: onPressed,
    );
  }
}
