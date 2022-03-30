import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/screens/work.dart';
import 'package:hatarakujikan_web/widgets/custom_select_list_tile.dart';
import 'package:hatarakujikan_web/widgets/loading.dart';

class SelectScreen extends StatefulWidget {
  final GroupProvider groupProvider;

  SelectScreen({required this.groupProvider});

  @override
  _SelectScreenState createState() => _SelectScreenState();
}

class _SelectScreenState extends State<SelectScreen> {
  bool _isLoading = false;

  void _init() async {
    setState(() => _isLoading = true);
    await Future.delayed(Duration(seconds: 2));
    List<GroupModel> _groups = widget.groupProvider.groups;
    if (_groups.length == 1) {
      await widget.groupProvider.setGroup(_groups.first);
      setState(() => _isLoading = false);
      Navigator.of(context, rootNavigator: true).pop();
      changeScreen(context, WorkScreen());
    }
    setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Loading(color: Colors.orange)
        : Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.orange,
              elevation: 0.0,
              centerTitle: true,
              title: Text(
                '会社/組織の選択',
                style: TextStyle(color: Colors.white),
              ),
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
                return CustomSelectListTile(
                  onTap: () async {
                    setState(() => _isLoading = true);
                    await widget.groupProvider.setGroup(_group);
                    setState(() => _isLoading = false);
                    Navigator.of(context, rootNavigator: true).pop();
                    changeScreen(context, WorkScreen());
                  },
                  label: _group.name,
                );
              },
            ),
          );
  }
}
