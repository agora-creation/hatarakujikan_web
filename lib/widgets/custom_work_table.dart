import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/work.dart';

class CustomWorkTable extends StatelessWidget {
  final GroupModel? group;
  final WorkModel? work;

  CustomWorkTable({
    this.group,
    this.work,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Table(
          border: TableBorder.all(color: Colors.grey.shade300),
          children: [
            TableRow(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '勤務時間',
                        style: kDefaultTextStyle,
                      ),
                      Text('${work?.workTime(group)}'),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '法定内時間',
                        style: kDefaultTextStyle,
                      ),
                      Text('${work?.legalTimes(group).first}'),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '法定外時間',
                        style: kDefaultTextStyle,
                      ),
                      Text('${work?.legalTimes(group).last}'),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '深夜時間',
                        style: kDefaultTextStyle,
                      ),
                      Text('${work?.nightTimes(group).last}'),
                    ],
                  ),
                ),
              ],
            ),
            TableRow(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '通常時間※1',
                        style: kDefaultTextStyle,
                      ),
                      Text('${work?.calTimes01(group)[0]}'),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '深夜時間(-)※2',
                        style: kDefaultTextStyle,
                      ),
                      Text('${work?.calTimes01(group)[1]}'),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '通常時間外※3',
                        style: kDefaultTextStyle,
                      ),
                      Text('${work?.calTimes01(group)[2]}'),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '深夜時間外※4',
                        style: kDefaultTextStyle,
                      ),
                      Text('${work?.calTimes01(group)[3]}'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 4.0),
        Text(
          '※1・・・深夜時間帯外の勤務時間です。',
          style: kDefaultTextStyle,
        ),
        Text(
          '※2・・・深夜時間帯の勤務時間です。深夜時間外の分も引いた時間です。',
          style: kDefaultTextStyle,
        ),
        Text(
          '※3・・・深夜時間帯外で法定時間を超えた時間です。',
          style: kDefaultTextStyle,
        ),
        Text(
          '※4・・・深夜時間帯で法定時間を超えた時間です。',
          style: kDefaultTextStyle,
        ),
      ],
    );
  }
}
