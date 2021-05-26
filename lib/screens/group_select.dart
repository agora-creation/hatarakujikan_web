import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/screens/home.dart';

class GroupSelect extends StatelessWidget {
  final GroupProvider groupProvider;

  GroupSelect({@required this.groupProvider});

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
              groupProvider.signOut();
              Navigator.of(context, rootNavigator: true).pop();
            },
            icon: Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
        itemCount: groupProvider.groups.length,
        itemBuilder: (_, index) {
          GroupModel _group = groupProvider.groups[index];
          return Container(
            decoration: kBottomBorderDecoration,
            child: ListTile(
              title: Text('${_group.name}'),
              trailing: Icon(Icons.chevron_right),
              onTap: () async {
                groupProvider.setGroup(_group);
                Navigator.of(context, rootNavigator: true).pop();
                changeScreen(context, HomeScreen());
              },
            ),
          );
        },
      ),
    );
  }
}
