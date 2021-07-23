import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/widgets/custom_text_icon_button.dart';

class SectionTable extends StatefulWidget {
  final GroupProvider groupProvider;

  SectionTable({@required this.groupProvider});

  @override
  _SectionTableState createState() => _SectionTableState();
}

class _SectionTableState extends State<SectionTable> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '部署の管理',
          style: kAdminTitleTextStyle,
        ),
        Text(
          '部署の情報を一覧表示します。登録した部署は、「スタッフの管理」から割り当ててください。部署の管理者は別管理画面でログインして、部署毎のスタッフを管理できます。',
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
        Expanded(
          child: Container(),
        ),
      ],
    );
  }
}
