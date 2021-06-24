import 'package:flutter/material.dart';

class CustomLinkButton extends StatelessWidget {
  final String label;
  final Color color;
  final Function onTap;

  CustomLinkButton({
    this.label,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          color: color,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
