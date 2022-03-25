import 'package:flutter/material.dart';

class CustomTextIconButton extends StatelessWidget {
  final IconData? iconData;
  final String? label;
  final Color? color;
  final Function()? onPressed;

  CustomTextIconButton({
    this.iconData,
    this.label,
    this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(
        iconData,
        color: Colors.white,
        size: 18.0,
      ),
      label: Text(
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
    );
  }
}
