import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LogProvider with ChangeNotifier {
  Stream<QuerySnapshot<Map<String, dynamic>>>? streamList({String? groupId}) {
    Stream<QuerySnapshot<Map<String, dynamic>>>? _ret;
    _ret = FirebaseFirestore.instance
        .collection('log')
        .where('groupId', isEqualTo: groupId ?? 'error')
        .orderBy('createdAt', descending: true)
        .snapshots();
    return _ret;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? streamList2({
    String? groupId,
    String? userId,
  }) {
    Stream<QuerySnapshot<Map<String, dynamic>>>? _ret;
    _ret = FirebaseFirestore.instance
        .collection('log')
        .where('groupId', isEqualTo: groupId ?? 'error')
        .where('userId', isEqualTo: userId ?? 'error')
        .orderBy('createdAt', descending: true)
        .snapshots();
    return _ret;
  }
}
