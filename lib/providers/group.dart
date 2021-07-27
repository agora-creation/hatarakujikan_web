import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/services/group.dart';

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class GroupProvider with ChangeNotifier {
  Status _status = Status.Uninitialized;
  FirebaseAuth _auth;
  User _fUser;
  GroupService _groupService = GroupService();
  List<GroupModel> _groups = [];
  GroupModel _group;

  Status get status => _status;
  User get fUser => _fUser;
  List<GroupModel> get groups => _groups;
  GroupModel get group => _group;

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool isHidden = false;

  GroupProvider.initialize() : _auth = FirebaseAuth.instance {
    _auth.authStateChanges().listen(_onStateChanged);
  }

  void changeHidden() {
    isHidden = !isHidden;
    notifyListeners();
  }

  Future<void> setGroup(GroupModel group) async {
    _groups.clear();
    _group = group;
    await setPrefs(group.id);
    notifyListeners();
  }

  Future<bool> signIn() async {
    if (email.text == null) return false;
    if (password.text == null) return false;
    try {
      _status = Status.Authenticating;
      notifyListeners();
      await _auth
          .signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      )
          .then((value) async {
        _groups.clear();
        _groups = await _groupService.selectList(adminUserId: value.user.uid);
      });
      return true;
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      print(e.toString());
      return false;
    }
  }

  Future signOut() async {
    _auth.signOut();
    _status = Status.Unauthenticated;
    _groups.clear();
    _group = null;
    await removePrefs();
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  void clearController() {
    email.text = '';
    password.text = '';
  }

  Future reloadGroupModel() async {
    String _groupId = await getPrefs();
    if (_groupId != "") {
      _group = await _groupService.select(groupId: _groupId);
    }
    notifyListeners();
  }

  Future _onStateChanged(User firebaseUser) async {
    if (firebaseUser == null) {
      _status = Status.Unauthenticated;
    } else {
      _fUser = firebaseUser;
      String _groupId = await getPrefs();
      if (_groupId == '') {
        _status = Status.Unauthenticated;
        _groups.clear();
        _group = null;
      } else {
        _status = Status.Authenticated;
        _groups.clear();
        _group = await _groupService.select(groupId: _groupId);
      }
    }
    notifyListeners();
  }

  Future<bool> updateInfo({
    String id,
    String name,
    String adminUserId,
    String positions,
  }) async {
    try {
      List<String> _positions = [];
      List<String> _tmp = positions.split(',') ?? [];
      for (String _position in _tmp) {
        _positions.add(_position);
      }
      _groupService.update({
        'id': id,
        'name': name,
        'adminUserId': adminUserId,
        'positions': _positions,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> updateSecurity({
    String id,
    bool qrSecurity,
    bool areaSecurity,
    double areaLat,
    double areaLon,
    double areaRange,
  }) async {
    try {
      _groupService.update({
        'id': id,
        'qrSecurity': qrSecurity,
        'areaSecurity': areaSecurity,
        'areaLat': areaLat,
        'areaLon': areaLon,
        'areaRange': areaRange,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> updateWork({
    String id,
    String roundStartType,
    int roundStartNum,
    String roundEndType,
    int roundEndNum,
    String roundBreakStartType,
    int roundBreakStartNum,
    String roundBreakEndType,
    int roundBreakEndNum,
    String roundWorkType,
    int roundWorkNum,
    int legal,
    String nightStart,
    String nightEnd,
  }) async {
    try {
      _groupService.update({
        'id': id,
        'roundStartType': roundStartType,
        'roundStartNum': roundStartNum,
        'roundEndType': roundEndType,
        'roundEndNum': roundEndNum,
        'roundBreakStartType': roundBreakStartType,
        'roundBreakStartNum': roundBreakStartNum,
        'roundBreakEndType': roundBreakEndType,
        'roundBreakEndNum': roundBreakEndNum,
        'roundWorkType': roundWorkType,
        'roundWorkNum': roundWorkNum,
        'legal': legal,
        'nightStart': nightStart,
        'nightEnd': nightEnd,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }
}
