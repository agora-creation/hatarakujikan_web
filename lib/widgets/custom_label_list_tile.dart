import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';

class CustomLabelListTile extends StatelessWidget {
  final String label;
  final String value;

  CustomLabelListTile({
    this.label,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kBottomBorderDecoration,
      child: ListTile(
        leading: Text(label),
        title: Text(value),
      ),
    );
  }
}
