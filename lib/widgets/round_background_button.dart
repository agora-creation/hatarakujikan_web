import 'package:flutter/material.dart';

class RoundBackgroundButton extends StatelessWidget {
  final String? label;
  final Color? color;
  final Color? backgroundColor;
  final Function()? onPressed;

  RoundBackgroundButton({
    this.label,
    this.color,
    this.backgroundColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          label ?? '',
          style: TextStyle(
            color: color,
            fontSize: 16.0,
          ),
        ),
        style: TextButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: StadiumBorder(),
          padding: EdgeInsets.symmetric(vertical: 16.0),
        ),
      ),
    );
  }
}
