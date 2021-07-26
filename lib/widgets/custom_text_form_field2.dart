import 'package:flutter/material.dart';

class CustomTextFormField2 extends StatelessWidget {
  final TextEditingController controller;

  CustomTextFormField2({this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
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
