import 'package:flutter/material.dart';

class TextIconButton extends StatelessWidget {
  final IconData? iconData;
  final Color? iconColor;
  final String? label;
  final Color? labelColor;
  final Color? backgroundColor;
  final Function()? onPressed;

  TextIconButton({
    this.iconData,
    this.iconColor,
    this.label,
    this.labelColor,
    this.backgroundColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: Icon(
        iconData,
        color: iconColor,
        size: 18.0,
      ),
      label: Text(
        label ?? '',
        style: TextStyle(
          color: labelColor,
          fontSize: 16.0,
        ),
      ),
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      ),
      onPressed: onPressed,
    );
  }
}
