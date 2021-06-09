import 'package:flutter/material.dart';

class CustomTextIconButton extends StatelessWidget {
  final IconData iconData;
  final String labelText;
  final Color backgroundColor;
  final Function onPressed;

  CustomTextIconButton({
    this.iconData,
    this.labelText,
    this.backgroundColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(iconData, color: Colors.white, size: 16.0),
      label: Text(
        labelText,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
      ),
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
      ),
    );
  }
}
