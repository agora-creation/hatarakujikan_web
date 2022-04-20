import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';

class WorkShiftModel {
  String _id = '';
  String _groupId = '';
  String userId = '';
  DateTime startedAt = DateTime.now();
  DateTime endedAt = DateTime.now();
  String state = '';
  DateTime _createdAt = DateTime.now();

  String get id => _id;
  String get groupId => _groupId;
  DateTime get createdAt => _createdAt;

  WorkShiftModel.set(Map data) {
    _id = data['id'] ?? '';
    _groupId = data['groupId'] ?? '';
    userId = data['userId'] ?? '';
    startedAt = data['startedAt'] ?? DateTime.now();
    endedAt = data['endedAt'] ?? DateTime.now();
    state = data['state'] ?? '';
    _createdAt = data['createdAt'] ?? DateTime.now();
  }

  WorkShiftModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    _id = snapshot.data()!['id'] ?? '';
    _groupId = snapshot.data()!['groupId'] ?? '';
    userId = snapshot.data()!['userId'] ?? '';
    startedAt = snapshot.data()!['startedAt'].toDate() ?? DateTime.now();
    endedAt = snapshot.data()!['endedAt'].toDate() ?? DateTime.now();
    state = snapshot.data()!['state'] ?? '';
    _createdAt = snapshot.data()!['createdAt'].toDate() ?? DateTime.now();
  }

  Color stateColor() {
    switch (state) {
      case '勤務予定':
        return Colors.lightBlue;
      case '欠勤':
        return Colors.red;
      case '特別休暇':
        return Colors.green;
      case '有給休暇':
        return Colors.teal;
      case '代休':
        return Colors.pink;
      default:
        return Colors.red;
    }
  }

  Color stateColor2() {
    switch (state) {
      case '勤務予定':
        return Colors.lightBlue.shade300;
      case '欠勤':
        return Colors.red.shade300;
      case '特別休暇':
        return Colors.green.shade300;
      case '有給休暇':
        return Colors.teal.shade300;
      case '代休':
        return Colors.pink.shade300;
      default:
        return Colors.red.shade300;
    }
  }

  PdfColor stateColor3() {
    switch (state) {
      case '勤務予定':
        return PdfColors.lightBlue100;
      case '欠勤':
        return PdfColors.red100;
      case '特別休暇':
        return PdfColors.green100;
      case '有給休暇':
        return PdfColors.teal100;
      case '代休':
        return PdfColors.pink100;
      default:
        return PdfColors.red100;
    }
  }
}
