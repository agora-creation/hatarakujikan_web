import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/screens/work.dart';
import 'package:hatarakujikan_web/widgets/TapListTile.dart';
import 'package:hatarakujikan_web/widgets/loading.dart';

class SelectScreen extends StatefulWidget {
  final GroupProvider groupProvider;

  SelectScreen({required this.groupProvider});

  @override
  _SelectScreenState createState() => _SelectScreenState();
}

class _SelectScreenState extends State<SelectScreen> {
  bool isLoading = false;

  Future _next(GroupModel? group) async {
    setState(() => isLoading = true);
    await widget.groupProvider.setGroup(group);
    setState(() => isLoading = false);
    Navigator.of(context, rootNavigator: true).pop();
    changeScreen(context, WorkScreen());
  }

  void _init() async {
    await Future.delayed(Duration(seconds: 2));
    List<GroupModel> _groups = widget.groupProvider.groups;
    if (_groups.length == 1) {
      await _next(_groups.first);
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Loading(color: Colors.orange)
        : Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.orange,
              elevation: 0.0,
              centerTitle: true,
              title: Text('会社/組織の選択', style: TextStyle(color: Colors.white)),
              actions: [
                IconButton(
                  onPressed: () async {
                    await widget.groupProvider.signOut();
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  icon: Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
            body: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              itemCount: widget.groupProvider.groups.length,
              itemBuilder: (_, index) {
                GroupModel _group = widget.groupProvider.groups[index];
                return TapListTile(
                  title: '会社/組織名',
                  subtitle: _group.name,
                  iconData: Icons.chevron_right,
                  onTap: () async => await _next(_group),
                );
              },
            ),
          );
  }
}
