import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/models/apply_work.dart';
import 'package:hatarakujikan_web/models/breaks.dart';
import 'package:hatarakujikan_web/services/apply_work.dart';
import 'package:hatarakujikan_web/services/work.dart';

class ApplyWorkProvider with ChangeNotifier {
  ApplyWorkService _applyWorkService = ApplyWorkService();
  WorkService _workService = WorkService();

  Future<bool> update({ApplyWorkModel applyWork}) async {
    try {
      _applyWorkService.update({
        'id': applyWork?.id,
        'approval': true,
      });
      List<Map> _breaks = [];
      for (BreaksModel breaks in applyWork?.breaks) {
        _breaks.add(breaks.toMap());
      }
      _workService.update({
        'id': applyWork?.workId,
        'startedAt': applyWork?.startedAt,
        'endedAt': applyWork?.endedAt,
        'breaks': _breaks,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  void delete({ApplyWorkModel applyWork}) {
    _applyWorkService.delete({'id': applyWork.id});
  }
}