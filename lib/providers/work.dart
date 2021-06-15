import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/models/breaks.dart';
import 'package:hatarakujikan_web/models/work.dart';
import 'package:hatarakujikan_web/services/work.dart';

class WorkProvider with ChangeNotifier {
  WorkService _workService = WorkService();

  Future<bool> update({WorkModel work}) async {
    try {
      List<Map> _breaks = [];
      for (BreaksModel breaks in work?.breaks) {
        _breaks.add(breaks.toMap());
      }
      _workService.update({
        'id': work?.id,
        'startedAt': work?.startedAt,
        'endedAt': work?.endedAt,
        'breaks': _breaks,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }
}
