import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';

class TapListTile extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Function()? onTap;

  TapListTile({
    this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kBottomBorderDecoration,
      child: ListTile(
        title: Text(title ?? ''),
        subtitle: Text(subtitle ?? ''),
        trailing: Icon(Icons.edit),
        onTap: onTap,
      ),
    );
  }
}
