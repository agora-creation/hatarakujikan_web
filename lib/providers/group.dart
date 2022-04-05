import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/services/group.dart';
import 'package:hatarakujikan_web/services/user.dart';

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class GroupProvider with ChangeNotifier {
  Status _status = Status.Uninitialized;
  FirebaseAuth? _auth;
  User? _fUser;
  GroupService _groupService = GroupService();
  UserService _userService = UserService();
  List<GroupModel> _groups = [];
  GroupModel? _group;
  UserModel? _adminUser;
  List<UserModel> _users = [];

  Status get status => _status;
  User? get fUser => _fUser;
  List<GroupModel> get groups => _groups;
  GroupModel? get group => _group;
  UserModel? get adminUser => _adminUser;
  List<UserModel> get users => _users;

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  GroupProvider.initialize() : _auth = FirebaseAuth.instance {
    _auth?.authStateChanges().listen(_onStateChanged);
  }

  Future<void> setGroup(GroupModel? group) async {
    if (group == null) return;
    _group = group;
    await setPrefs('groupId', group.id);
    _users = await _userService.selectList(userIds: _group?.userIds ?? []);
    _users.sort((a, b) => a.recordPassword.compareTo(b.recordPassword));
    _groups.clear();
    notifyListeners();
  }

  Future<bool> signIn() async {
    if (email.text == '') return false;
    if (password.text == '') return false;
    try {
      _status = Status.Authenticating;
      notifyListeners();
      await _auth!
          .signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      )
          .then((value) async {
        _groups.clear();
        _groups =
            await _groupService.selectListAdminUser(userId: value.user?.uid);
        _users.clear();
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
    await _auth!.signOut();
    _status = Status.Unauthenticated;
    _groups.clear();
    _group = null;
    _users.clear();
    await removePrefs('groupId');
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  void clearController() {
    email.text = '';
    password.text = '';
  }

  Future<void> reloadGroup() async {
    String? _groupId = await getPrefs('groupId');
    if (_groupId != null) {
      _group = await _groupService.select(id: _groupId);
    }
    notifyListeners();
  }

  Future<void> reloadGroupModel() async {
    String? _groupId = await getPrefs('groupId');
    if (_groupId != null) {
      _group = await _groupService.select(id: _groupId);
      _users = await _userService.selectList(userIds: _group?.userIds ?? []);
      _users.sort((a, b) => a.recordPassword.compareTo(b.recordPassword));
    }
    _adminUser = await _userService.select(id: _fUser?.uid);
    notifyListeners();
  }

  Future<void> _onStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _status = Status.Unauthenticated;
    } else {
      _fUser = firebaseUser;
      String? _groupId = await getPrefs('groupId');
      if (_groupId == null) {
        _status = Status.Unauthenticated;
        _groups.clear();
        _group = null;
        _users.clear();
      } else {
        _status = Status.Authenticated;
        _groups.clear();
        _group = await _groupService.select(id: _groupId);
        _users = await _userService.selectList(userIds: _group?.userIds ?? []);
        _users.sort((a, b) => a.recordPassword.compareTo(b.recordPassword));
      }
      _adminUser = await _userService.select(id: _fUser?.uid);
    }
    notifyListeners();
  }

  Future<void> reloadUsers() async {
    _users.clear();
    _users = await _userService.selectList(userIds: _group?.userIds ?? []);
    _users.sort((a, b) => a.recordPassword.compareTo(b.recordPassword));
    notifyListeners();
  }

  Future<bool> updateName({
    String? id,
    String? name,
  }) async {
    if (id == null) return false;
    if (name == null) return false;
    try {
      _groupService.update({
        'id': id,
        'name': name,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> updateAddress({
    String? id,
    String? zip,
    String? address,
  }) async {
    if (id == null) return false;
    if (zip == null) return false;
    if (address == null) return false;
    try {
      _groupService.update({
        'id': id,
        'zip': zip,
        'address': address,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> updateTel({
    String? id,
    String? tel,
  }) async {
    if (id == null) return false;
    if (tel == null) return false;
    try {
      _groupService.update({
        'id': id,
        'tel': tel,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> updateEmail({
    String? id,
    String? email,
  }) async {
    if (id == null) return false;
    if (email == null) return false;
    try {
      _groupService.update({
        'id': id,
        'email': email,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> updateAdminUser({
    String? id,
    String? adminUserId,
  }) async {
    if (id == null) return false;
    if (adminUserId == null) return false;
    try {
      _groupService.update({
        'id': id,
        'adminUserId': adminUserId,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> updateRoundStart({
    String? id,
    String? roundStartType,
    int? roundStartNum,
  }) async {
    if (id == null) return false;
    if (roundStartType == null) return false;
    if (roundStartNum == null) return false;
    try {
      _groupService.update({
        'id': id,
        'roundStartType': roundStartType,
        'roundStartNum': roundStartNum,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> updateSecurity({
    required String id,
    required bool qrSecurity,
    required bool areaSecurity,
    required double areaLat,
    required double areaLon,
    required double areaRange,
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
    required String id,
    required String roundStartType,
    required int roundStartNum,
    required String roundEndType,
    required int roundEndNum,
    required String roundBreakStartType,
    required int roundBreakStartNum,
    required String roundBreakEndType,
    required int roundBreakEndNum,
    required String roundWorkType,
    required int roundWorkNum,
    required int legal,
    required String nightStart,
    required String nightEnd,
    required String workStart,
    required String workEnd,
    required List<String> holidays,
    required List<DateTime> holidays2,
    required bool autoBreak,
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
        'workStart': workStart,
        'workEnd': workEnd,
        'holidays': holidays,
        'holidays2': holidays2,
        'autoBreak': autoBreak,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<List<UserModel>> selectUsers({bool? smartphone}) async {
    List<UserModel> _users = [];
    await _userService
        .selectList(
      userIds: _group?.userIds ?? [],
      smartphone: smartphone,
    )
        .then((value) {
      _users = value;
    });
    return _users;
  }
}
