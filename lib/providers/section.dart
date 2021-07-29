import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/models/section.dart';
import 'package:hatarakujikan_web/services/section.dart';

class SectionProvider with ChangeNotifier {
  SectionService _sectionService = SectionService();

  Future<bool> create({
    String groupId,
    String name,
    String adminUserId,
  }) async {
    if (groupId == '') return false;
    if (name == '') return false;
    if (adminUserId == '') return false;
    try {
      String _id = _sectionService.id();
      _sectionService.create({
        'id': _id,
        'groupId': groupId,
        'name': name,
        'adminUserId': adminUserId,
        'createdAt': DateTime.now(),
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> update({
    String id,
    String groupId,
    String name,
    String adminUserId,
  }) async {
    try {
      _sectionService.update({
        'id': id,
        'groupId': groupId,
        'name': name,
        'adminUserId': adminUserId,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  void delete({SectionModel section}) {
    _sectionService.delete({'id': section.id});
  }
}
