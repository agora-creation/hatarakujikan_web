import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/providers/user.dart';
import 'package:hatarakujikan_web/widgets/custom_text_icon_button.dart';

class PositionTable extends StatefulWidget {
  final GroupProvider groupProvider;
  final UserProvider userProvider;

  PositionTable({
    @required this.groupProvider,
    @required this.userProvider,
  });

  @override
  _PositionTableState createState() => _PositionTableState();
}

class _PositionTableState extends State<PositionTable> {
  List<UserModel> users = [];

  void _init() async {
    await widget.userProvider
        .selectListSP(
      groupId: widget.groupProvider.group?.id,
      smartphone: true,
    )
        .then((value) {
      setState(() => users = value);
    });
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '雇用形態の管理',
          style: kAdminTitleTextStyle,
        ),
        Text(
          '雇用形態を一覧表示します。',
          style: kAdminSubTitleTextStyle,
        ),
        SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(),
            CustomTextIconButton(
              onPressed: () {},
              color: Colors.blue,
              iconData: Icons.add,
              label: '新規登録',
            ),
          ],
        ),
        SizedBox(height: 8.0),
      ],
    );
  }
}
