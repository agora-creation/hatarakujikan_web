import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';

class CustomCheckbox extends StatelessWidget {
  final String? label;
  final bool? value;
  final Color? activeColor;
  final Function(bool?)? onChanged;

  CustomCheckbox({
    this.label,
    this.value,
    this.activeColor,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kBottomBorderDecoration,
      child: CheckboxListTile(
        title: Text(
          label ?? '',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 16.0,
          ),
        ),
        activeColor: activeColor,
        controlAffinity: ListTileControlAffinity.leading,
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
