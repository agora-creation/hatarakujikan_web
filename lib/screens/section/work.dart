import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/models/work.dart';
import 'package:hatarakujikan_web/models/work_state.dart';
import 'package:hatarakujikan_web/providers/section.dart';
import 'package:hatarakujikan_web/providers/user.dart';
import 'package:hatarakujikan_web/providers/work.dart';
import 'package:hatarakujikan_web/providers/work_state.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold2.dart';
import 'package:hatarakujikan_web/widgets/custom_text_icon_button.dart';
import 'package:hatarakujikan_web/widgets/custom_work_header_list_tile.dart';
import 'package:hatarakujikan_web/widgets/custom_work_list_tile.dart';
import 'package:hatarakujikan_web/widgets/loading.dart';
import 'package:intl/intl.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:provider/provider.dart';

class SectionWorkScreen extends StatelessWidget {
  static const String id = 'section_work';

  @override
  Widget build(BuildContext context) {
    final sectionProvider = Provider.of<SectionProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final workProvider = Provider.of<WorkProvider>(context);
    final workStateProvider = Provider.of<WorkStateProvider>(context);

    return CustomAdminScaffold2(
      sectionProvider: sectionProvider,
      selectedRoute: id,
      body: SectionWorkTable(
        sectionProvider: sectionProvider,
        userProvider: userProvider,
        workProvider: workProvider,
        workStateProvider: workStateProvider,
      ),
    );
  }
}

class SectionWorkTable extends StatefulWidget {
  final SectionProvider sectionProvider;
  final UserProvider userProvider;
  final WorkProvider workProvider;
  final WorkStateProvider workStateProvider;

  SectionWorkTable({
    @required this.sectionProvider,
    @required this.userProvider,
    @required this.workProvider,
    @required this.workStateProvider,
  });

  @override
  _SectionWorkTableState createState() => _SectionWorkTableState();
}

class _SectionWorkTableState extends State<SectionWorkTable> {
  DateTime searchMonth = DateTime.now();
  List<UserModel> users = [];
  UserModel searchUser;
  List<DateTime> days = [];

  void _init() async {
    setState(() => days = generateDays(searchMonth));
  }

  void searchUserChange(UserModel user) {
    setState(() => searchUser = user);
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    Timestamp _startAt = Timestamp.fromMillisecondsSinceEpoch(DateTime.parse(
            '${DateFormat('yyyy-MM-dd').format(days.first)} 00:00:00.000')
        .millisecondsSinceEpoch);
    Timestamp _endAt = Timestamp.fromMillisecondsSinceEpoch(DateTime.parse(
            '${DateFormat('yyyy-MM-dd').format(days.last)} 23:59:59.999')
        .millisecondsSinceEpoch);
    Stream<QuerySnapshot> _streamWork = FirebaseFirestore.instance
        .collection('work')
        .where('groupId', isEqualTo: widget.sectionProvider.group?.id)
        .where('userId', isEqualTo: searchUser?.id ?? 'error')
        .orderBy('startedAt', descending: false)
        .startAt([_startAt]).endAt([_endAt]).snapshots();
    Stream<QuerySnapshot> _streamWorkState = FirebaseFirestore.instance
        .collection('workState')
        .where('groupId', isEqualTo: widget.sectionProvider.group?.id)
        .where('userId', isEqualTo: searchUser?.id ?? 'error')
        .orderBy('startedAt', descending: false)
        .startAt([_startAt]).endAt([_endAt]).snapshots();
    List<WorkModel> works = [];
    List<WorkStateModel> workStates = [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '勤怠の管理',
          style: kAdminTitleTextStyle,
        ),
        Text(
          'スタッフがスマートフォンアプリやタブレットアプリで記録した勤怠時間を年月形式で一覧表示します。この画面から追加や修正ができます。',
          style: kAdminSubTitleTextStyle,
        ),
        SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CustomTextIconButton(
                  onPressed: () {},
                  color: Colors.lightBlueAccent,
                  iconData: Icons.today,
                  label: '${DateFormat('yyyy年MM月').format(searchMonth)}',
                ),
                SizedBox(width: 4.0),
                CustomTextIconButton(
                  onPressed: () {},
                  color: Colors.lightBlueAccent,
                  iconData: Icons.person,
                  label: searchUser?.name ?? '選択してください',
                ),
              ],
            ),
            Row(
              children: [
                CustomTextIconButton(
                  onPressed: () {},
                  color: Colors.green,
                  iconData: Icons.file_download,
                  label: 'CSV出力',
                ),
                SizedBox(width: 4.0),
                CustomTextIconButton(
                  onPressed: () {},
                  color: Colors.redAccent,
                  iconData: Icons.file_download,
                  label: 'PDF出力',
                ),
                SizedBox(width: 4.0),
                CustomTextIconButton(
                  onPressed: () {},
                  color: Colors.blue,
                  iconData: Icons.add,
                  label: '新規登録',
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 8.0),
        CustomWorkHeaderListTile(),
        Expanded(
          child: StreamBuilder2<QuerySnapshot, QuerySnapshot>(
            streams: Tuple2(_streamWork, _streamWorkState),
            builder: (context, snapshot) {
              if (!snapshot.item1.hasData || !snapshot.item2.hasData) {
                return Loading(color: Colors.orange);
              }
              works.clear();
              for (DocumentSnapshot work in snapshot.item1.data.docs) {
                works.add(WorkModel.fromSnapshot(work));
              }
              workStates.clear();
              for (DocumentSnapshot workState in snapshot.item2.data.docs) {
                workStates.add(WorkStateModel.fromSnapshot(workState));
              }
              return ListView.builder(
                itemCount: days.length,
                itemBuilder: (_, index) {
                  List<WorkModel> _dayWorks = [];
                  for (WorkModel _work in works) {
                    String _startedAt =
                        '${DateFormat('yyyy-MM-dd').format(_work.startedAt)}';
                    if (days[index] == DateTime.parse(_startedAt)) {
                      _dayWorks.add(_work);
                    }
                  }
                  WorkStateModel _dayWorkState;
                  for (WorkStateModel _workState in workStates) {
                    String _startedAt =
                        '${DateFormat('yyyy-MM-dd').format(_workState.startedAt)}';
                    if (days[index] == DateTime.parse(_startedAt)) {
                      _dayWorkState = _workState;
                    }
                  }
                  return CustomWorkListTile(
                    workProvider: widget.workProvider,
                    workStateProvider: widget.workStateProvider,
                    day: days[index],
                    dayWorks: _dayWorks,
                    dayWorkState: _dayWorkState,
                    group: widget.sectionProvider.group,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
