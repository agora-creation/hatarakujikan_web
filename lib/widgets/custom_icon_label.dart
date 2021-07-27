import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';

class CustomIconLabel extends StatelessWidget {
  final IconData iconData;
  final String label;

  CustomIconLabel({
    this.iconData,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      decoration: kBottomBorderDecoration,
      child: Row(
        children: [
          Icon(iconData, color: Colors.black54),
          SizedBox(width: 4.0),
          Text(label, style: TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}
