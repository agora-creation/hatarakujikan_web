import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/log.dart';

class LogListTile extends StatelessWidget {
  final LogModel log;

  const LogListTile({
    required this.log,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kBottomBorderDecoration,
      child: ExpansionTile(
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        title: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${dateText('yyyy/MM/dd', log.createdAt)} (${log.userName})',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
              Text(
                log.title,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        children: [
          ListTile(
            title: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                log.details,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
