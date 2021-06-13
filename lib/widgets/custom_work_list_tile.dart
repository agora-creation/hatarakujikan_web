import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/work.dart';
import 'package:intl/intl.dart';

class CustomWorkListTile extends StatelessWidget {
  final DateTime day;
  final List<WorkModel> works;

  CustomWorkListTile({
    this.day,
    this.works,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kBottomBorderDecoration,
      child: ListTile(
        leading: Text(
          '${DateFormat('dd (E)', 'ja').format(day)}',
          style: TextStyle(color: Colors.black54, fontSize: 16.0),
        ),
        title: works.length > 0
            ? ListView.separated(
                shrinkWrap: true,
                physics: ScrollPhysics(),
                separatorBuilder: (_, index) => Divider(height: 0.0),
                itemCount: works.length,
                itemBuilder: (_, index) {
                  WorkModel _work = works[index];
                  return ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Chip(
                          label: Text('休み'),
                        ),
                        Text('${DateFormat('HH:mm').format(_work.startedAt)}'),
                        _work.startedAt != _work.endedAt
                            ? Text(
                                '${DateFormat('HH:mm').format(_work.endedAt)}')
                            : Text('---:---'),
                        _work.startedAt != _work.endedAt
                            ? Text('00:00')
                            : Text('---:---'),
                        _work.startedAt != _work.endedAt
                            ? Text('00:00')
                            : Text('---:---'),
                        _work.startedAt != _work.endedAt
                            ? Text('00:00')
                            : Text('---:---'),
                        _work.startedAt != _work.endedAt
                            ? Text('00:00')
                            : Text('---:---'),
                        _work.startedAt != _work.endedAt
                            ? Text('00:00')
                            : Text('---:---'),
                      ],
                    ),
                    onTap: _work.startedAt != _work.endedAt ? () {} : null,
                  );
                },
              )
            : Container(),
      ),
    );
  }
}
