import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/helpers/pdf_file.dart';
import 'package:hatarakujikan_web/helpers/side_menu.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/screens/login.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';

class CustomAdminScaffold extends StatelessWidget {
  final GroupProvider groupProvider;
  final String selectedRoute;
  final Widget? body;

  CustomAdminScaffold({
    required this.groupProvider,
    required this.selectedRoute,
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
            icon: Icon(Icons.qr_code),
            onPressed: () async {
              await PDFFile.qrcode(group: groupProvider.group);
            },
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (_) => SignOutDialog(groupProvider: groupProvider),
              );
            },
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
        items: sideMenu(groupProvider.group),
        selectedRoute: selectedRoute,
        onSelected: (item) {
          if (item.route != null) {
            Navigator.pushNamed(context, item.route!);
          }
        },
        footer: Container(
          height: 50.0,
          width: double.infinity,
          color: Color(0xFF616161),
          child: Center(
            child: Text(
              '?? ?????????????????????????????????',
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
              margin: EdgeInsets.all(8.0),
              padding: EdgeInsets.all(16.0),
              constraints: BoxConstraints(maxHeight: 850.0),
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

  SignOutDialog({required this.groupProvider});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        width: 450.0,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              '???????????????????????????????????????????????????',
              style: kDialogTextStyle,
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextButton(
                  label: '???????????????',
                  color: Colors.grey,
                  onPressed: () => Navigator.pop(context),
                ),
                CustomTextButton(
                  label: '??????',
                  color: Colors.blue,
                  onPressed: () async {
                    await groupProvider.signOut();
                    changeScreen(context, LoginScreen());
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
