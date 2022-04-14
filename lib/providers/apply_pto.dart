import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/models/user.dart';

class ApplyPTOProvider with ChangeNotifier {
  UserModel? user;
  bool approval = false;

  void changeUser(UserModel value) {
    user = value;
    notifyListeners();
  }

  void changeApproval(bool value) {
    approval = value;
    notifyListeners();
  }
}
