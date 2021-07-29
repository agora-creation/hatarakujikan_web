import 'package:flutter/material.dart';

class CustomTextFormField2 extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType textInputType;
  final int maxLines;

  CustomTextFormField2({
    this.controller,
    this.textInputType,
    this.maxLines,
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
    );
  }
}
