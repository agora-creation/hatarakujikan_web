import 'package:flutter/material.dart';

class CustomTextFormField2 extends StatelessWidget {
  final String? label;
  final TextEditingController? controller;
  final TextInputType? textInputType;
  final int? maxLines;
  final Function(String)? onChanged;

  CustomTextFormField2({
    this.label,
    this.controller,
    this.textInputType,
    this.maxLines,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label ?? '',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: textInputType,
          maxLines: maxLines,
          style: TextStyle(
            color: Colors.black54,
            fontSize: 14.0,
          ),
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
