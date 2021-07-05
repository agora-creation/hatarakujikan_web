import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:hatarakujikan_web/screens/apply_work.dart';
import 'package:hatarakujikan_web/screens/group.dart';
import 'package:hatarakujikan_web/screens/group_notice.dart';
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
    icon: Icons.group,
  ),
  MenuItem(
    title: 'お知らせの管理',
    route: GroupNoticeScreen.id,
    icon: Icons.notifications,
  ),
  MenuItem(
    title: '会社/組織の設定',
    route: GroupScreen.id,
    icon: Icons.store,
  ),
];
