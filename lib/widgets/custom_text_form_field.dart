import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType textInputType;
  final int maxLines;
  final String labelText;
  final Color labelColor;
  final IconData prefixIconData;
  final IconData suffixIconData;
  final Function onTap;

  CustomTextFormField({
    this.controller,
    this.obscureText,
    this.textInputType,
    this.maxLines,
    this.labelText,
    this.labelColor,
    this.prefixIconData,
    this.suffixIconData,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: textInputType,
      maxLines: maxLines,
      style: TextStyle(
        color: labelColor,
        fontSize: 14.0,
      ),
      cursorColor: labelColor,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(
          prefixIconData,
          size: 18.0,
          color: labelColor,
        ),
        suffixIcon: GestureDetector(
          onTap: onTap,
          child: Icon(
            suffixIconData,
            size: 18.0,
            color: labelColor,
          ),
        ),
        filled: true,
        enabledBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: labelColor),
        ),
        labelStyle: TextStyle(color: labelColor),
        focusColor: labelColor,
      ),
    );
  }
}
