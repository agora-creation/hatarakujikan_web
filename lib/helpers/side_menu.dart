import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/screens/apply_pto.dart';
import 'package:hatarakujikan_web/screens/apply_work.dart';
import 'package:hatarakujikan_web/screens/group_info.dart';
import 'package:hatarakujikan_web/screens/group_invoice.dart';
import 'package:hatarakujikan_web/screens/group_notice.dart';
import 'package:hatarakujikan_web/screens/group_position.dart';
import 'package:hatarakujikan_web/screens/group_rule.dart';
import 'package:hatarakujikan_web/screens/user.dart';
import 'package:hatarakujikan_web/screens/work.dart';
import 'package:hatarakujikan_web/screens/work_shift.dart';

List<MenuItem> sideMenu(GroupModel? group) {
  List<MenuItem> ret = [
    MenuItem(
      title: '勤怠の管理',
      icon: Icons.history,
      children: [
        MenuItem(
          title: '勤怠の記録',
          route: WorkScreen.id,
          icon: Icons.chevron_right,
        ),
        group?.optionsShift == true
            ? MenuItem(
                title: 'シフト表',
                route: WorkShiftScreen.id,
                icon: Icons.chevron_right,
              )
            : MenuItem(title: 'シフト表(利用不可)'),
        MenuItem(
          title: '帳票の出力',
          route: WorkShiftScreen.id,
          icon: Icons.chevron_right,
        ),
      ],
    ),
    MenuItem(
      title: '申請の管理',
      icon: Icons.receipt,
      children: [
        MenuItem(
          title: '勤怠修正の申請',
          route: ApplyWorkScreen.id,
          icon: Icons.chevron_right,
        ),
        MenuItem(
          title: '有給休暇の申請',
          route: ApplyPTOScreen.id,
          icon: Icons.chevron_right,
        ),
      ],
    ),
    MenuItem(
      title: 'スタッフの管理',
      route: UserScreen.id,
      icon: Icons.person,
    ),
    MenuItem(
      title: '会社/組織の設定',
      icon: Icons.settings,
      children: [
        MenuItem(
          title: '会社/組織の情報',
          route: GroupInfoScreen.id,
          icon: Icons.chevron_right,
        ),
        MenuItem(
          title: '勤怠ルールの設定',
          route: GroupRuleScreen.id,
          icon: Icons.chevron_right,
        ),
        MenuItem(
          title: '雇用形態の管理',
          route: GroupPositionScreen.id,
          icon: Icons.chevron_right,
        ),
        MenuItem(
          title: 'お知らせの管理',
          route: GroupNoticeScreen.id,
          icon: Icons.chevron_right,
        ),
        MenuItem(
          title: '請求書の管理',
          route: GroupInvoiceScreen.id,
          icon: Icons.chevron_right,
        ),
      ],
    ),
  ];
  return ret;
}
