import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:hatarakujikan_web/screens/apply_work.dart';
import 'package:hatarakujikan_web/screens/group_info.dart';
import 'package:hatarakujikan_web/screens/group_notice.dart';
import 'package:hatarakujikan_web/screens/group_security.dart';
import 'package:hatarakujikan_web/screens/group_work.dart';
import 'package:hatarakujikan_web/screens/section.dart';
import 'package:hatarakujikan_web/screens/user.dart';
import 'package:hatarakujikan_web/screens/work.dart';

const List<MenuItem> kSideMenu = [
  MenuItem(
    title: '勤怠の管理',
    route: WorkScreen.id,
    icon: Icons.history,
  ),
  MenuItem(
    title: '申請/承認の管理',
    icon: Icons.question_answer,
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
    title: '部署/事業所の管理',
    route: SectionScreen.id,
    icon: Icons.account_tree,
  ),
  MenuItem(
    title: '会社/組織の設定',
    icon: Icons.store,
    children: [
      MenuItem(
        title: '基本情報の変更',
        route: GroupInfoScreen.id,
        icon: Icons.chevron_right,
      ),
      MenuItem(
        title: 'セキュリティ設定',
        route: GroupSecurityScreen.id,
        icon: Icons.chevron_right,
      ),
      MenuItem(
        title: '勤怠ルール設定',
        route: GroupWorkScreen.id,
        icon: Icons.chevron_right,
      ),
      MenuItem(
        title: '雇用形態の管理',
        route: GroupNoticeScreen.id,
        icon: Icons.chevron_right,
      ),
      MenuItem(
        title: 'お知らせの管理',
        route: GroupNoticeScreen.id,
        icon: Icons.chevron_right,
      ),
    ],
  ),
];
