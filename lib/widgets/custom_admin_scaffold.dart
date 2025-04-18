import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/helpers/pdf_file.dart';
import 'package:hatarakujikan_web/helpers/side_menu.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/log.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/providers/log.dart';
import 'package:hatarakujikan_web/screens/login.dart';
import 'package:hatarakujikan_web/screens/users.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';
import 'package:hatarakujikan_web/widgets/log_list_tile.dart';
import 'package:provider/provider.dart';

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
            icon: Icon(Icons.directions_run),
            onPressed: () => overlayScreen(
              context,
              UsersScreen(groupProvider: groupProvider),
            ),
          ),
          IconButton(
            icon: Icon(Icons.list_alt),
            onPressed: () {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (_) => LogDialog(groupId: groupProvider.group?.id),
              );
            },
          ),
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

class LogDialog extends StatefulWidget {
  final String? groupId;

  const LogDialog({
    this.groupId,
    Key? key,
  }) : super(key: key);

  @override
  State<LogDialog> createState() => _LogDialogState();
}

class _LogDialogState extends State<LogDialog> {
  ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    final logProvider = Provider.of<LogProvider>(context);

    return AlertDialog(
      title: Text('勤怠操作ログ'),
      content: Container(
        width: 600.0,
        child: ListView(
          shrinkWrap: true,
          children: [
            Divider(height: 0),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: logProvider.streamList(groupId: widget.groupId),
                builder: (context, snapshot) {
                  List<LogModel> logs = [];
                  if (snapshot.hasData) {
                    for (DocumentSnapshot<Map<String, dynamic>> doc
                        in snapshot.data!.docs) {
                      LogModel _log = LogModel.fromSnapshot(doc);
                      logs.add(_log);
                    }
                  }
                  return Container(
                    height: 350.0,
                    child: Scrollbar(
                      thumbVisibility: true,
                      controller: _controller,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        controller: _controller,
                        itemCount: logs.length,
                        itemBuilder: (_, index) {
                          LogModel _log = logs[index];
                          return LogListTile(log: _log);
                        },
                      ),
                    ),
                  );
                }),
            Divider(height: 0),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextButton(
                  label: 'キャンセル',
                  color: Colors.grey,
                  onPressed: () => Navigator.pop(context),
                ),
                Container(),
              ],
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
              'ログアウトします。よろしいですか？',
              style: kDialogTextStyle,
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextButton(
                  label: 'キャンセル',
                  color: Colors.grey,
                  onPressed: () => Navigator.pop(context),
                ),
                CustomTextButton(
                  label: 'はい',
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
