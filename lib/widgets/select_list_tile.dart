import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';

class SelectListTile extends StatelessWidget {
  final String? label;
  final Function()? onTap;

  SelectListTile({
    this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kBottomBorderDecoration,
      child: ListTile(
        onTap: onTap,
        title: Text(label ?? ''),
        trailing: Icon(Icons.chevron_right),
      ),
    );
  }
}
