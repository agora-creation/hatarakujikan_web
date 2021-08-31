import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/models/section.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/services/section.dart';
import 'package:hatarakujikan_web/services/user.dart';

enum SectionStatus {
  Uninitialized,
  Authenticated,
  Authenticating,
  Unauthenticated
}

class SectionProvider with ChangeNotifier {
  SectionStatus _status = SectionStatus.Uninitialized;
  FirebaseAuth _auth;
  User _fUser;
  SectionService _sectionService = SectionService();
  UserService _userService = UserService();
  List<SectionModel> _sections = [];
  SectionModel _section;
  UserModel _adminUser;

  SectionStatus get status => _status;
  User get fUser => _fUser;
  List<SectionModel> get sections => _sections;
  SectionModel get section => _section;
  UserModel get adminUser => _adminUser;

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  SectionProvider.initialize() : _auth = FirebaseAuth.instance {
    _auth.authStateChanges().listen(_onStateChanged);
  }

  Future<void> setSection(SectionModel section) async {
    _sections.clear();
    _section = section;
    await setPrefs(key: 'sectionId', value: section.id);
    notifyListeners();
  }

  Future<bool> signIn() async {
    if (email.text == null) return false;
    if (password.text == null) return false;
    try {
      _status = SectionStatus.Authenticating;
      notifyListeners();
      await _auth
          .signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      )
          .then((value) async {
        _sections.clear();
        _sections = await _sectionService.selectList(
          adminUserId: value.user.uid,
        );
      });
      return true;
    } catch (e) {
      _status = SectionStatus.Unauthenticated;
      notifyListeners();
      print(e.toString());
      return false;
    }
  }

  Future signOut() async {
    await _auth.signOut();
    _status = SectionStatus.Unauthenticated;
    _sections.clear();
    _section = null;
    await removePrefs(key: 'sectionId');
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  void clearController() {
    email.text = '';
    password.text = '';
  }

  Future reloadSectionModel() async {
    String _sectionId = await getPrefs(key: 'sectionId');
    if (_sectionId != '') {
      _section = await _sectionService.select(sectionId: _sectionId);
    }
    _adminUser = await _userService.select(userId: _fUser.uid);
    notifyListeners();
  }

  Future _onStateChanged(User firebaseUser) async {
    if (firebaseUser == null) {
      _status = SectionStatus.Unauthenticated;
    } else {
      _fUser = firebaseUser;
      String _sectionId = await getPrefs(key: 'sectionId');
      if (_sectionId == '') {
        _status = SectionStatus.Unauthenticated;
        _sections.clear();
        _section = null;
      } else {
        _status = SectionStatus.Authenticated;
        _sections.clear();
        _section = await _sectionService.select(sectionId: _sectionId);
      }
      _adminUser = await _userService.select(userId: _fUser.uid);
    }
    notifyListeners();
  }

  Future<bool> create({
    String groupId,
    String name,
  }) async {
    if (groupId == '') return false;
    if (name == '') return false;
    try {
      String _id = _sectionService.id();
      _sectionService.create({
        'id': _id,
        'groupId': groupId,
        'name': name,
        'adminUserId': '',
        'userIds': [],
        'createdAt': DateTime.now(),
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> update({
    SectionModel section,
    String name,
  }) async {
    try {
      _sectionService.update({
        'id': section.id,
        'name': name,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> updateUsers({
    SectionModel section,
    List<UserModel> users,
  }) async {
    try {
      List<String> _userIds = [];
      for (UserModel _user in users) {
        _userIds.add(_user.id);
      }
      String _adminUserId = '';
      var _contain = _userIds.where((e) => e == section.adminUserId);
      if (_contain.isNotEmpty) {
        _adminUserId = section.adminUserId;
      }
      _sectionService.update({
        'id': section.id,
        'adminUserId': _adminUserId,
        'userIds': _userIds,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> updateAdminUser({
    SectionModel section,
    UserModel user,
  }) async {
    if (user == null) return false;
    try {
      _sectionService.update({
        'id': section.id,
        'adminUserId': user.id,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  void delete({SectionModel section}) {
    _sectionService.delete({'id': section.id});
  }
}
