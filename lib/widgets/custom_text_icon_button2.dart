import 'package:flutter/material.dart';

class CustomTextIconButton2 extends StatelessWidget {
  final IconData? iconData;
  final String? label;
  final Function()? onPressed;

  CustomTextIconButton2({
    this.iconData,
    this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(
        iconData,
        color: Colors.black54,
        size: 18.0,
      ),
      label: Text(
        label ?? '',
        style: TextStyle(
          color: Colors.black54,
          fontSize: 16.0,
        ),
      ),
      style: TextButton.styleFrom(
        side: BorderSide(color: Colors.black38, width: 1),
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      ),
    );
  }
}
