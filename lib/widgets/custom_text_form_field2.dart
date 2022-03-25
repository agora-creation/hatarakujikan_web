import 'package:flutter/material.dart';

class CustomTextFormField2 extends StatelessWidget {
  final TextEditingController? controller;
  final TextInputType? textInputType;
  final int? maxLines;
  final Function(String) onChanged;

  CustomTextFormField2({
    this.controller,
    this.textInputType,
    this.maxLines,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
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
    );
  }
}
