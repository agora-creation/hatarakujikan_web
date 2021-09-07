import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/models/section.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/services/group.dart';
import 'package:hatarakujikan_web/services/section.dart';
import 'package:hatarakujikan_web/services/user.dart';

enum Status2 { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class SectionProvider with ChangeNotifier {
  Status2 _status = Status2.Uninitialized;
  FirebaseAuth _auth;
  User _fUser;
  GroupService _groupService = GroupService();
  SectionService _sectionService = SectionService();
  UserService _userService = UserService();
  GroupModel _group;
  List<SectionModel> _sections = [];
  SectionModel _section;
  UserModel _adminUser;
  List<UserModel> _users = [];

  Status2 get status => _status;
  User get fUser => _fUser;
  GroupModel get group => _group;
  List<SectionModel> get sections => _sections;
  SectionModel get section => _section;
  UserModel get adminUser => _adminUser;
  List<UserModel> get users => _users;

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  SectionProvider.initialize() : _auth = FirebaseAuth.instance {
    _auth.authStateChanges().listen(_onStateChanged);
  }

  Future<void> setSection(SectionModel section) async {
    _group = await _groupService.select(id: section.groupId);
    _sections.clear();
    _section = section;
    _users.clear();
    _users = await _userService.selectList(userIds: _section.userIds);
    _users.sort((a, b) => a.recordPassword.compareTo(b.recordPassword));
    await setPrefs(key: 'sectionId', value: section.id);
    notifyListeners();
  }

  Future<bool> signIn() async {
    if (email.text == null) return false;
    if (password.text == null) return false;
    try {
      _status = Status2.Authenticating;
      notifyListeners();
      await _auth
          .signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      )
          .then((value) async {
        _sections.clear();
        _sections = await _sectionService.selectListAdminUser(
          adminUserId: value.user.uid,
        );
        _group = await _groupService.select(id: _sections.first.groupId);
      });
      return true;
    } catch (e) {
      _status = Status2.Unauthenticated;
      notifyListeners();
      print(e.toString());
      return false;
    }
  }

  Future signOut() async {
    await _auth.signOut();
    _status = Status2.Unauthenticated;
    _group = null;
    _sections.clear();
    _section = null;
    _users.clear();
    await removePrefs(key: 'sectionId');
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  void clearController() {
    email.text = '';
    password.text = '';
  }

  Future<void> reloadSectionModel() async {
    String _sectionId = await getPrefs(key: 'sectionId');
    if (_sectionId != '') {
      _section = await _sectionService.select(id: _sectionId);
      _users.clear();
      _users = await _userService.selectList(userIds: _section.userIds);
      _users.sort((a, b) => a.recordPassword.compareTo(b.recordPassword));
      _group = await _groupService.select(id: _section.groupId);
    }
    _adminUser = await _userService.select(id: _fUser.uid);
    notifyListeners();
  }

  Future _onStateChanged(User firebaseUser) async {
    if (firebaseUser == null) {
      _status = Status2.Unauthenticated;
    } else {
      _fUser = firebaseUser;
      String _sectionId = await getPrefs(key: 'sectionId');
      if (_sectionId == '') {
        _status = Status2.Unauthenticated;
        _group = null;
        _sections.clear();
        _section = null;
      } else {
        _status = Status2.Authenticated;
        _sections.clear();
        _section = await _sectionService.select(id: _sectionId);
        _users.clear();
        _users = await _userService.selectList(userIds: _section.userIds);
        _users.sort((a, b) => a.recordPassword.compareTo(b.recordPassword));
        _group = await _groupService.select(id: _section.groupId);
      }
      _adminUser = await _userService.select(id: _fUser.uid);
    }
    notifyListeners();
  }

  Future<void> reloadUsers() async {
    _users.clear();
    _users = await _userService.selectList(userIds: _section.userIds);
    _users.sort((a, b) => a.recordPassword.compareTo(b.recordPassword));
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
    String id,
    String name,
  }) async {
    try {
      _sectionService.update({
        'id': id,
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
