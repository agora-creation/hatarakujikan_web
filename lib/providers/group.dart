import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/services/group.dart';
import 'package:hatarakujikan_web/services/user.dart';

const List<String> roundTypeList = ['切捨', '切上'];
const List<int> roundNumList = [1, 5, 10, 15, 30];
const List<int> legalList = [8];
const List<String> weekList = ['日', '月', '火', '水', '木', '金', '土'];

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class GroupProvider with ChangeNotifier {
  Status _status = Status.Uninitialized;
  FirebaseAuth _auth;
  User _fUser;
  GroupService _groupService = GroupService();
  UserService _userService = UserService();
  List<GroupModel> _groups = [];
  GroupModel _group;
  UserModel _adminUser;
  List<UserModel> _users = [];

  Status get status => _status;
  User get fUser => _fUser;
  List<GroupModel> get groups => _groups;
  GroupModel get group => _group;
  UserModel get adminUser => _adminUser;
  List<UserModel> get users => _users;

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  GroupProvider.initialize() : _auth = FirebaseAuth.instance {
    _auth.authStateChanges().listen(_onStateChanged);
  }

  Future<void> setGroup(GroupModel group) async {
    _groups.clear();
    _group = group;
    _users = await _userService.selectList(userIds: _group.userIds);
    _users.sort((a, b) => a.recordPassword.compareTo(b.recordPassword));
    await setPrefs(key: 'groupId', value: group.id);
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
        _groups = await _groupService.selectListAdminUser(
          adminUserId: value.user.uid,
        );
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
    await _auth.signOut();
    _status = Status.Unauthenticated;
    _groups.clear();
    _group = null;
    _users.clear();
    await removePrefs(key: 'groupId');
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  void clearController() {
    email.text = '';
    password.text = '';
  }

  Future reloadGroupModel() async {
    String _groupId = await getPrefs(key: 'groupId');
    if (_groupId != '') {
      _group = await _groupService.select(id: _groupId);
      _users = await _userService.selectList(userIds: _group.userIds);
      _users.sort((a, b) => a.recordPassword.compareTo(b.recordPassword));
    }
    _adminUser = await _userService.select(id: _fUser.uid);
    notifyListeners();
  }

  Future _onStateChanged(User firebaseUser) async {
    if (firebaseUser == null) {
      _status = Status.Unauthenticated;
    } else {
      _fUser = firebaseUser;
      String _groupId = await getPrefs(key: 'groupId');
      if (_groupId == '') {
        _status = Status.Unauthenticated;
        _groups.clear();
        _group = null;
        _users.clear();
      } else {
        _status = Status.Authenticated;
        _groups.clear();
        _group = await _groupService.select(id: _groupId);
        _users = await _userService.selectList(userIds: _group.userIds);
        _users.sort((a, b) => a.recordPassword.compareTo(b.recordPassword));
      }
      _adminUser = await _userService.select(id: _fUser.uid);
    }
    notifyListeners();
  }

  Future<bool> updateInfo({
    String id,
    String name,
    String adminUserId,
  }) async {
    try {
      _groupService.update({
        'id': id,
        'name': name,
        'adminUserId': adminUserId,
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
    String workStart,
    String workEnd,
    List<String> holidays,
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
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }
}
