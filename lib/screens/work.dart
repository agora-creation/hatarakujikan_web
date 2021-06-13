import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/date_machine_util.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/models/work.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';
import 'package:hatarakujikan_web/widgets/custom_text_icon_button.dart';
import 'package:hatarakujikan_web/widgets/custom_work_head_list_tile.dart';
import 'package:hatarakujikan_web/widgets/custom_work_list_tile.dart';
import 'package:hatarakujikan_web/widgets/loading.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';

class WorkScreen extends StatefulWidget {
  static const String id = 'work';

  @override
  _WorkScreenState createState() => _WorkScreenState();
}

class _WorkScreenState extends State<WorkScreen> {
  DateTime selectMonth = DateTime.now();
  UserModel selectUser;
  List<DateTime> days = [];

  void _generateDays() async {
    days.clear();
    var _dateMap = DateMachineUtil.getMonthDate(selectMonth, 0);
    DateTime _startAt = DateTime.parse('${_dateMap['start']}');
    DateTime _endAt = DateTime.parse('${_dateMap['end']}');
    for (int i = 0; i <= _endAt.difference(_startAt).inDays; i++) {
      days.add(_startAt.add(Duration(days: i)));
    }
  }

  void changeUser(UserModel user) {
    setState(() => selectUser = user);
  }

  @override
  void initState() {
    super.initState();
    _generateDays();
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController _scrollController = ScrollController();
    final groupProvider = Provider.of<GroupProvider>(context);
    Timestamp _startAt = Timestamp.fromMillisecondsSinceEpoch(DateTime.parse(
            '${DateFormat(formatY_M_D).format(days.first)} 00:00:00.000')
        .millisecondsSinceEpoch);
    Timestamp _endAt = Timestamp.fromMillisecondsSinceEpoch(DateTime.parse(
            '${DateFormat(formatY_M_D).format(days.last)} 23:59:59.999')
        .millisecondsSinceEpoch);
    Stream<QuerySnapshot> _stream = FirebaseFirestore.instance
        .collection('work')
        .where('groupId', isEqualTo: groupProvider.group?.id)
        .where('userId', isEqualTo: selectUser?.id ?? 'error')
        .orderBy('startedAt', descending: false)
        .startAt([_startAt]).endAt([_endAt]).snapshots();
    List<WorkModel> works = [];
    List<String> test = ['a', 'b', 'c', 'd', 'f', 'g', 'h', 'i', 'j'];

    return CustomAdminScaffold(
      groupProvider: groupProvider,
      selectedRoute: WorkScreen.id,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('勤務の管理', style: kAdminTitleTextStyle),
          Text('スタッフが記録した勤務時間を年月形式で表示します。', style: kAdminSubTitleTextStyle),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CustomTextIconButton(
                    onPressed: () async {
                      var selected = await showMonthPicker(
                        context: context,
                        initialDate: selectMonth,
                        firstDate: DateTime(DateTime.now().year - 1),
                        lastDate: DateTime(DateTime.now().year + 1),
                      );
                      if (selected == null) return;
                      setState(() {
                        selectMonth = selected;
                        _generateDays();
                      });
                    },
                    backgroundColor: Colors.lightBlueAccent,
                    iconData: Icons.calendar_today,
                    labelText: '${DateFormat(formatYM).format(selectMonth)}',
                  ),
                  SizedBox(width: 4.0),
                  CustomTextIconButton(
                    onPressed: () {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (_) => AlertDialog(
                          content: Container(
                            width: 450.0,
                            child: ListView(
                              shrinkWrap: true,
                              children: [
                                Container(
                                  height: 350.0,
                                  child: Scrollbar(
                                    isAlwaysShown: true,
                                    controller: _scrollController,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: ScrollPhysics(),
                                      controller: _scrollController,
                                      itemCount: test.length,
                                      itemBuilder: (_, index) {
                                        return Container(
                                          decoration: kBottomBorderDecoration,
                                          child: RadioListTile(
                                            title: Text('${test[index]}'),
                                            value: test,
                                            groupValue: 'a',
                                            activeColor: Colors.blue,
                                            onChanged: (value) {},
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16.0),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomTextButton(
                                      onPressed: () => Navigator.pop(context),
                                      backgroundColor: Colors.grey,
                                      labelText: 'キャンセル',
                                    ),
                                    CustomTextButton(
                                      onPressed: () => Navigator.pop(context),
                                      backgroundColor: Colors.blue,
                                      labelText: 'OK',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    backgroundColor: Colors.lightBlueAccent,
                    iconData: Icons.person,
                    labelText:
                        selectUser != null ? '${selectUser?.name}' : '指定なし',
                  ),
                ],
              ),
              Row(
                children: [
                  CustomTextIconButton(
                    onPressed: () {},
                    backgroundColor: Colors.green,
                    iconData: Icons.file_download,
                    labelText: 'CSV出力',
                  ),
                  SizedBox(width: 4.0),
                  CustomTextIconButton(
                    onPressed: () {},
                    backgroundColor: Colors.redAccent,
                    iconData: Icons.file_download,
                    labelText: 'PDF出力',
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8.0),
          CustomWorkHeadListTile(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Loading(color: Colors.orange);
                }
                works.clear();
                for (DocumentSnapshot work in snapshot.data.docs) {
                  works.add(WorkModel.fromSnapshot(work));
                }
                return ListView.builder(
                  itemCount: days.length,
                  itemBuilder: (_, index) {
                    List<WorkModel> _dayWorks = [];
                    for (WorkModel _work in works) {
                      if (days[index] ==
                          DateTime.parse(DateFormat(formatY_M_D)
                              .format(_work.startedAt))) {
                        _dayWorks.add(_work);
                      }
                    }
                    return CustomWorkListTile(
                      day: days[index],
                      works: _dayWorks,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
