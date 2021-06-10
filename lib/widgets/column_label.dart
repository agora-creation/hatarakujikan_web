import 'package:flutter/material.dart';

class ColumnLabel extends StatelessWidget {
  final String string;

  ColumnLabel(this.string);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      alignment: Alignment.center,
      child: Text(string),
    );
  }
}
