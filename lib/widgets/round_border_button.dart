import 'package:flutter/material.dart';

class RoundBorderButton extends StatelessWidget {
  final String labelText;
  final Color labelColor;
  final Color borderColor;
  final Function onPressed;

  RoundBorderButton({
    this.labelText,
    this.labelColor,
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
          labelText,
          style: TextStyle(
            color: labelColor,
            fontSize: 16.0,
          ),
        ),
        style: TextButton.styleFrom(
          side: BorderSide(color: borderColor, width: 1),
          shape: StadiumBorder(),
          padding: EdgeInsets.symmetric(vertical: 16.0),
        ),
      ),
    );
  }
}
