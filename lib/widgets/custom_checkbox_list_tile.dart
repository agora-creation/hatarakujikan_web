import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';

class CustomCheckboxListTile extends StatelessWidget {
  final String label;
  final bool value;
  final Function(bool) onChanged;

  CustomCheckboxListTile({
    this.label,
    this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kBottomBorderDecoration,
      child: CheckboxListTile(
        title: Text(label),
        value: value,
        activeColor: Colors.blue,
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: onChanged,
      ),
    );
  }
}
