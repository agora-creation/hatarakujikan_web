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

  void setGroup(GroupModel group) async {
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

  Future<bool> update({
    String id,
    String name,
    int usersNum,
    bool qrSecurity,
    bool areaSecurity,
  }) async {
    try {
      _groupService.update({
        'id': id,
        'name': name,
        'usersNum': usersNum,
        'qrSecurity': qrSecurity,
        'areaSecurity': areaSecurity,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }
}
