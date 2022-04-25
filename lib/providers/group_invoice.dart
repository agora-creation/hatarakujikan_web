import 'package:flutter/material.dart';

class GroupInvoiceProvider with ChangeNotifier {
  DateTime month = DateTime.now();

  void changeMonth(DateTime value) {
    month = value;
    notifyListeners();
  }
}
