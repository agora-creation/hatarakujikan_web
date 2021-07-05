import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/services/group_notice.dart';

class GroupNoticeProvider with ChangeNotifier {
  GroupNoticeService _groupNoticeService = GroupNoticeService();

  Future<bool> create({
    String groupId,
    String title,
    String message,
  }) async {
    if (groupId == '') return false;
    if (title == '') return false;
    try {
      String _id = _groupNoticeService.id(groupId);
      _groupNoticeService.create({
        'id': _id,
        'groupId': groupId,
        'title': title,
        'message': message,
        'createdAt': DateTime.now(),
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }
}
