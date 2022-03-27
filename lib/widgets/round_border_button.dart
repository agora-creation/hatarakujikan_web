import 'package:flutter/material.dart';

class RoundBorderButton extends StatelessWidget {
  final String? label;
  final Color? color;
  final Color? borderColor;
  final Function()? onPressed;

  RoundBorderButton({
    this.label,
    this.color,
    this.borderColor,
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
          side: BorderSide(color: borderColor!, width: 1),
          shape: StadiumBorder(),
          padding: EdgeInsets.symmetric(vertical: 16.0),
        ),
      ),
    );
  }
}
