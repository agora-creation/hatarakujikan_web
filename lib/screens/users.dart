import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/models/user.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/widgets/user_list_tile.dart';

class UsersScreen extends StatelessWidget {
  final GroupProvider groupProvider;

  UsersScreen({required this.groupProvider});

  @override
  Widget build(BuildContext context) {
    List<String> userIds = groupProvider.group?.userIds ?? [];
    List<UserModel> users = [];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFFFEFFFA),
        elevation: 0.0,
        centerTitle: true,
        title: Text('スタッフの出勤状況'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            icon: Icon(Icons.close),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: groupProvider.streamUsers(),
        builder: (context, snapshot) {
          users.clear();
          if (snapshot.hasData) {
            for (DocumentSnapshot<Map<String, dynamic>> doc
                in snapshot.data!.docs) {
              UserModel _user = UserModel.fromSnapshot(doc);
              if (!_user.retired) {
                if (userIds.contains(_user.id)) {
                  users.add(_user);
                }
              }
            }
          }
          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
            itemCount: users.length,
            itemBuilder: (_, index) {
              return UserListTile(user: users[index]);
            },
          );
        },
      ),
    );
  }
}
