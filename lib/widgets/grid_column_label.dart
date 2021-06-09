import 'package:flutter/material.dart';

class GridColumnLabel extends StatelessWidget {
  final String labelText;

  GridColumnLabel({this.labelText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      alignment: Alignment.center,
      child: Text(labelText),
    );
  }
}
