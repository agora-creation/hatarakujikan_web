import 'package:flutter/material.dart';

class CustomWeekCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final Function(bool) onChanged;

  CustomWeekCheckbox({
    this.label,
    this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black38),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: CheckboxListTile(
          onChanged: onChanged,
          value: value,
          title: Text(
            label,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 16.0,
            ),
          ),
          activeColor: Colors.redAccent,
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ),
    );
  }
}
