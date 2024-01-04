import 'package:flutter/material.dart';

class TotalList extends StatelessWidget {
  final String userName;
  final int workDays;
  final int absenceDays;
  final int specialDays;
  final int leaveDays;
  final int compensatoryDays;

  const TotalList({
    required this.userName,
    required this.workDays,
    required this.absenceDays,
    required this.specialDays,
    required this.leaveDays,
    required this.compensatoryDays,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey)),
      ),
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            userName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text('通常勤務'),
                  Text('$workDays日'),
                ],
              ),
              Column(
                children: [
                  Text('欠勤'),
                  Text('$absenceDays日'),
                ],
              ),
              Column(
                children: [
                  Text('特別休暇'),
                  Text('$specialDays日'),
                ],
              ),
              Column(
                children: [
                  Text('有給休暇'),
                  Text('$leaveDays日'),
                ],
              ),
              Column(
                children: [
                  Text('代休'),
                  Text('$compensatoryDays日'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
