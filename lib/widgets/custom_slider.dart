import 'package:flutter/material.dart';

class CustomSlider extends StatelessWidget {
  final String? text;
  final String? label;
  final double? value;
  final Function(double)? onChanged;

  CustomSlider({
    this.text,
    this.label,
    this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(text ?? ''),
        Expanded(
          child: Slider(
            label: label,
            min: 0,
            max: 500,
            divisions: 500,
            value: value ?? 0,
            activeColor: Colors.red,
            inactiveColor: Colors.grey.shade300,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
