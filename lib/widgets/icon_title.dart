import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';

class IconTitle extends StatelessWidget {
  final IconData? iconData;
  final String? text;

  IconTitle({
    this.iconData,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      decoration: kBottomBorderDecoration,
      child: Row(
        children: [
          Icon(iconData, color: Colors.black54),
          SizedBox(width: 8.0),
          Text(text ?? '', style: TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}
