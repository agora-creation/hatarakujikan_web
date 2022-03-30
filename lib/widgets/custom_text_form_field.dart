import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final bool? obscureText;
  final TextInputType? textInputType;
  final int? maxLines;
  final String? label;
  final Color? color;
  final IconData? prefix;
  final IconData? suffix;
  final Function()? onTap;

  CustomTextFormField({
    this.controller,
    this.obscureText,
    this.textInputType,
    this.maxLines,
    this.label,
    this.color,
    this.prefix,
    this.suffix,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText ?? false,
      keyboardType: textInputType,
      maxLines: maxLines,
      style: TextStyle(
        color: color,
        fontSize: 14.0,
      ),
      cursorColor: color,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          prefix,
          size: 18.0,
          color: color,
        ),
        suffixIcon: GestureDetector(
          onTap: onTap,
          child: Icon(
            suffix,
            size: 18.0,
            color: color,
          ),
        ),
        filled: true,
        enabledBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: color ?? Colors.black),
        ),
        labelStyle: TextStyle(color: color),
        focusColor: color,
      ),
    );
  }
}
