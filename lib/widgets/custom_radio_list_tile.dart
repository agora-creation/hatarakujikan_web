import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';

class CustomRadioListTile extends StatelessWidget {
  final String label;
  final dynamic value;
  final dynamic groupValue;
  final Function(dynamic) onChanged;

  CustomRadioListTile({
    this.label,
    this.value,
    this.groupValue,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kBottomBorderDecoration,
      child: RadioListTile(
        title: Text(label),
        value: value,
        groupValue: groupValue,
        activeColor: Colors.blue,
        onChanged: onChanged,
      ),
    );
  }
}
