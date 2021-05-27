import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/helpers/side_menu.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/screens/login.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';

class CustomAdminScaffold extends StatelessWidget {
  final GroupProvider groupProvider;
  final String selectedRoute;
  final Widget body;

  CustomAdminScaffold({
    this.groupProvider,
    this.selectedRoute,
    this.body,
  });

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          groupProvider.group?.name ?? '',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (_) => SignOutDialog(groupProvider: groupProvider),
              );
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      sideBar: SideBar(
        backgroundColor: Color(0xFFFFE0B2),
        iconColor: Colors.black54,
        textStyle: TextStyle(color: Colors.black54, fontSize: 14.0),
        activeBackgroundColor: Colors.white,
        activeIconColor: Colors.black54,
        activeTextStyle: TextStyle(color: Colors.black54, fontSize: 14.0),
        items: kSideMenu,
        selectedRoute: selectedRoute,
        onSelected: (item) {
          if (item.route != null) {
            Navigator.pushNamed(context, item.route);
          }
        },
        footer: Container(
          height: 50.0,
          width: double.infinity,
          color: Color(0xFF616161),
          child: Center(
            child: Text(
              '© アゴラ・クリエーション',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.0,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.all(10.0),
              padding: EdgeInsets.all(0.0),
              constraints: BoxConstraints(maxHeight: 750.0),
              child: body,
            ),
          ],
        ),
      ),
    );
  }
}

class SignOutDialog extends StatelessWidget {
  final GroupProvider groupProvider;

  SignOutDialog({@required this.groupProvider});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ログアウトします。よろしいですか？',
            style: TextStyle(fontSize: 20.0),
          ),
          SizedBox(height: 24.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextButton(
                onPressed: () => Navigator.pop(context),
                backgroundColor: Colors.grey,
                labelText: 'キャンセル',
              ),
              CustomTextButton(
                onPressed: () {
                  groupProvider.signOut();
                  Navigator.pop(context);
                  changeScreen(context, LoginScreen());
                },
                backgroundColor: Colors.blue,
                labelText: 'はい',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
