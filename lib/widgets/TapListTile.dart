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
        title: Text(
          title ?? '',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle ?? '',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 14.0,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: onTap != null ? Icon(Icons.edit) : null,
        onTap: onTap,
      ),
    );
  }
}
