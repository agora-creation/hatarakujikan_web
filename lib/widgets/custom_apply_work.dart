import 'package:flutter/material.dart';

class CustomApplyWork extends StatelessWidget {
  final String label;
  final Widget child;

  CustomApplyWork({
    this.label,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.black54, fontSize: 14.0),
        ),
        child,
      ],
    );
  }
}
