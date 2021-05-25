import 'package:flutter/material.dart';

class RoundBackgroundButton extends StatelessWidget {
  final String labelText;
  final Color labelColor;
  final Color backgroundColor;
  final Function onPressed;

  RoundBackgroundButton({
    this.labelText,
    this.labelColor,
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
          labelText,
          style: TextStyle(
            color: labelColor,
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
