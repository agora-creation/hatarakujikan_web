import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  final String labelText;
  final Color backgroundColor;
  final Function onPressed;

  CustomTextButton({
    this.labelText,
    this.backgroundColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        labelText,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
        ),
      ),
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
      ),
    );
  }
}
