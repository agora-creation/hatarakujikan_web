import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:hatarakujikan_web/screens/apply_work.dart';
import 'package:hatarakujikan_web/screens/notice.dart';
import 'package:hatarakujikan_web/screens/position.dart';
import 'package:hatarakujikan_web/screens/setting_info.dart';
import 'package:hatarakujikan_web/screens/setting_security.dart';
import 'package:hatarakujikan_web/screens/setting_work.dart';
import 'package:hatarakujikan_web/screens/user.dart';
import 'package:hatarakujikan_web/screens/work.dart';
import 'package:hatarakujikan_web/screens/work_shift.dart';

const List<MenuItem> kSideMenu = [
  MenuItem(
    title: '勤怠の管理',
    icon: Icons.history,
    children: [
      MenuItem(
        title: '勤怠の記録',
        route: WorkScreen.id,
        icon: Icons.chevron_right,
      ),
      MenuItem(
        title: 'シフト表',
        route: WorkShiftScreen.id,
        icon: Icons.chevron_right,
      ),
    ],
  ),
  MenuItem(
    title: '申請/承認の管理',
    icon: Icons.receipt,
    children: [
      MenuItem(
        title: '記録修正申請',
        route: ApplyWorkScreen.id,
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
    title: '雇用形態の管理',
    route: PositionScreen.id,
    icon: Icons.account_tree,
  ),
  MenuItem(
    title: 'お知らせの管理',
    route: NoticeScreen.id,
    icon: Icons.notifications,
  ),
  MenuItem(
    title: '会社/組織の設定',
    icon: Icons.settings,
    children: [
      MenuItem(
        title: '基本情報の変更',
        route: SettingInfoScreen.id,
        icon: Icons.chevron_right,
      ),
      MenuItem(
        title: 'セキュリティ設定',
        route: SettingSecurityScreen.id,
        icon: Icons.chevron_right,
      ),
      MenuItem(
        title: '勤怠ルール設定',
        route: SettingWorkScreen.id,
        icon: Icons.chevron_right,
      ),
    ],
  ),
];
