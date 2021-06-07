import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/screens/work.dart';

class GroupSelect extends StatefulWidget {
  final GroupProvider groupProvider;

  GroupSelect({@required this.groupProvider});

  @override
  _GroupSelectState createState() => _GroupSelectState();
}

class _GroupSelectState extends State<GroupSelect> {
  void _init() async {
    await Future.delayed(Duration(seconds: 3));
    if (widget.groupProvider.groups.length == 1) {
      widget.groupProvider.setGroup(widget.groupProvider.groups.first);
      Navigator.of(context, rootNavigator: true).pop();
      changeScreen(context, WorkScreen());
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            onPressed: () {
              widget.groupProvider.signOut();
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
          return Container(
            decoration: kBottomBorderDecoration,
            child: ListTile(
              title: Text('${_group.name}'),
              trailing: Icon(Icons.chevron_right),
              onTap: () async {
                widget.groupProvider.setGroup(_group);
                Navigator.of(context, rootNavigator: true).pop();
                changeScreen(context, WorkScreen());
              },
            ),
          );
        },
      ),
    );
  }
}
