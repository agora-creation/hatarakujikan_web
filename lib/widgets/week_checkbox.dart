import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';

class WeekCheckbox extends StatelessWidget {
  final String? label;
  final bool? value;
  final Function(bool?)? onChanged;

  WeekCheckbox({
    this.label,
    this.value,
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
        activeColor: Colors.redAccent,
        controlAffinity: ListTileControlAffinity.leading,
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
