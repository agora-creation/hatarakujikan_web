import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';

class CustomRadio extends StatelessWidget {
  final String? label;
  final dynamic value;
  final dynamic groupValue;
  final Color? activeColor;
  final Function(dynamic)? onChanged;

  CustomRadio({
    this.label,
    this.value,
    this.groupValue,
    this.activeColor,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kBottomBorderDecoration,
      child: RadioListTile(
        title: Text(
          label ?? '',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 16.0,
          ),
        ),
        value: value,
        groupValue: groupValue,
        activeColor: activeColor,
        onChanged: onChanged,
      ),
    );
  }
}
