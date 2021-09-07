import 'package:flutter/material.dart';

class CustomDropdownItem extends StatelessWidget {
  final String label;
  final dynamic value;

  CustomDropdownItem({
    this.label,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownMenuItem(
      value: value,
      child: Text(
        label,
        style: TextStyle(
          color: Colors.black54,
          fontSize: 14.0,
        ),
      ),
    );
  }
}
