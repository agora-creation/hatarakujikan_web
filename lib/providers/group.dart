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

  Status get status => _status;
  User? get fUser => _fUser;
  List<GroupModel> get groups => _groups;
  GroupModel? get group => _group;
  UserModel? get adminUser => _adminUser;

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  GroupProvider.initialize() : _auth = FirebaseAuth.instance {
    _auth?.authStateChanges().listen(_onStateChanged);
  }

  Future setGroup(GroupModel? group) async {
    if (group == null) return;
    _group = group;
    await setPrefs('groupId', group.id);
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
        _groups = await _groupService.selectListAdminUser(
          userId: value.user?.uid,
        );
      });
      return true;
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      print(e.toString());
      return false;
    }
  }

  Future<bool> signIn2() async {
    if (adminUser?.email == '') return false;
    if (adminUser?.password == '') return false;
    try {
      await _auth!
          .signInWithEmailAndPassword(
        email: adminUser?.email ?? '',
        password: adminUser?.password ?? '',
      )
          .then((value) {
        _fUser = value.user;
      });
      notifyListeners();
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future signOut() async {
    await _auth!.signOut();
    _status = Status.Unauthenticated;
    _groups.clear();
    _group = null;
    await removePrefs('groupId');
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  Future signOut2() async {
    await _auth!.signOut();
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  void clearController() {
    email.text = '';
    password.text = '';
  }

  Future reloadGroup() async {
    String? _groupId = await getPrefs('groupId');
    if (_groupId != null) {
      _group = await _groupService.select(id: _groupId);
    }
    notifyListeners();
  }

  Future reloadGroupModel() async {
    String? _groupId = await getPrefs('groupId');
    if (_groupId != null) {
      _group = await _groupService.select(id: _groupId);
    }
    _adminUser = await _userService.select(id: _fUser?.uid);
    notifyListeners();
  }

  Future _onStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _status = Status.Unauthenticated;
    } else {
      _fUser = firebaseUser;
      String? _groupId = await getPrefs('groupId');
      if (_groupId == null) {
        _status = Status.Unauthenticated;
        _groups.clear();
        _group = null;
      } else {
        _status = Status.Authenticated;
        _groups.clear();
        _group = await _groupService.select(id: _groupId);
      }
      _adminUser = await _userService.select(id: _fUser?.uid);
    }
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

  Future<bool> updateRoundEnd({
    String? id,
    String? roundEndType,
    int? roundEndNum,
  }) async {
    if (id == null) return false;
    if (roundEndType == null) return false;
    if (roundEndNum == null) return false;
    try {
      _groupService.update({
        'id': id,
        'roundEndType': roundEndType,
        'roundEndNum': roundEndNum,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> updateRoundBreakStart({
    String? id,
    String? roundBreakStartType,
    int? roundBreakStartNum,
  }) async {
    if (id == null) return false;
    if (roundBreakStartType == null) return false;
    if (roundBreakStartNum == null) return false;
    try {
      _groupService.update({
        'id': id,
        'roundBreakStartType': roundBreakStartType,
        'roundBreakStartNum': roundBreakStartNum,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> updateRoundBreakEnd({
    String? id,
    String? roundBreakEndType,
    int? roundBreakEndNum,
  }) async {
    if (id == null) return false;
    if (roundBreakEndType == null) return false;
    if (roundBreakEndNum == null) return false;
    try {
      _groupService.update({
        'id': id,
        'roundBreakEndType': roundBreakEndType,
        'roundBreakEndNum': roundBreakEndNum,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> updateRoundWork({
    String? id,
    String? roundWorkType,
    int? roundWorkNum,
  }) async {
    if (id == null) return false;
    if (roundWorkType == null) return false;
    if (roundWorkNum == null) return false;
    try {
      _groupService.update({
        'id': id,
        'roundWorkType': roundWorkType,
        'roundWorkNum': roundWorkNum,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> updateLegal({
    String? id,
    int? legal,
  }) async {
    if (id == null) return false;
    if (legal == null) return false;
    try {
      _groupService.update({
        'id': id,
        'legal': legal,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> updateNight({
    String? id,
    String? nightStart,
    String? nightEnd,
  }) async {
    if (id == null) return false;
    if (nightStart == null) return false;
    if (nightEnd == null) return false;
    try {
      _groupService.update({
        'id': id,
        'nightStart': nightStart,
        'nightEnd': nightEnd,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> updateWork({
    String? id,
    String? workStart,
    String? workEnd,
  }) async {
    if (id == null) return false;
    if (workStart == null) return false;
    if (workEnd == null) return false;
    try {
      _groupService.update({
        'id': id,
        'workStart': workStart,
        'workEnd': workEnd,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> updateHolidays({
    String? id,
    List<String>? holidays,
  }) async {
    if (id == null) return false;
    if (holidays == null) return false;
    try {
      _groupService.update({
        'id': id,
        'holidays': holidays,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> updateHolidays2({
    String? id,
    List<DateTime>? holidays2,
  }) async {
    if (id == null) return false;
    if (holidays2 == null) return false;
    try {
      _groupService.update({
        'id': id,
        'holidays2': holidays2,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> updateAutoBreak({
    String? id,
    bool? autoBreak,
  }) async {
    if (id == null) return false;
    if (autoBreak == null) return false;
    try {
      _groupService.update({
        'id': id,
        'autoBreak': autoBreak,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> updateQrSecurity({
    String? id,
    bool? qrSecurity,
  }) async {
    if (id == null) return false;
    if (qrSecurity == null) return false;
    try {
      _groupService.update({
        'id': id,
        'qrSecurity': qrSecurity,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> updateAreaSecurity({
    String? id,
    bool? areaSecurity,
  }) async {
    if (id == null) return false;
    if (areaSecurity == null) return false;
    try {
      _groupService.update({
        'id': id,
        'areaSecurity': areaSecurity,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> updateAreaLatLon({
    String? id,
    double? areaLat,
    double? areaLon,
    double? areaRange,
  }) async {
    if (id == null) return false;
    if (areaLat == null) return false;
    if (areaLon == null) return false;
    if (areaRange == null) return false;
    try {
      _groupService.update({
        'id': id,
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
