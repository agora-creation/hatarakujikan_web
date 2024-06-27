import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/providers/apply_pto.dart';
import 'package:hatarakujikan_web/providers/apply_work.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/providers/group_invoice.dart';
import 'package:hatarakujikan_web/providers/group_notice.dart';
import 'package:hatarakujikan_web/providers/log.dart';
import 'package:hatarakujikan_web/providers/position.dart';
import 'package:hatarakujikan_web/providers/user.dart';
import 'package:hatarakujikan_web/providers/work.dart';
import 'package:hatarakujikan_web/providers/work_shift.dart';
import 'package:hatarakujikan_web/screens/apply_pto.dart';
import 'package:hatarakujikan_web/screens/apply_work.dart';
import 'package:hatarakujikan_web/screens/group_info.dart';
import 'package:hatarakujikan_web/screens/group_invoice.dart';
import 'package:hatarakujikan_web/screens/group_notice.dart';
import 'package:hatarakujikan_web/screens/group_position.dart';
import 'package:hatarakujikan_web/screens/group_rule.dart';
import 'package:hatarakujikan_web/screens/login.dart';
import 'package:hatarakujikan_web/screens/splash.dart';
import 'package:hatarakujikan_web/screens/user.dart';
import 'package:hatarakujikan_web/screens/work.dart';
import 'package:hatarakujikan_web/screens/work_download.dart';
import 'package:hatarakujikan_web/screens/work_shift.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyCCEn5twtEVssNBtIH3pxq_W-VNQryOCd8",
      authDomain: "hatarakujikan.firebaseapp.com",
      projectId: "hatarakujikan",
      storageBucket: "hatarakujikan.appspot.com",
      messagingSenderId: "433017475057",
      appId: "1:433017475057:web:87260307fae0432cebfe50",
      measurementId: "G-E0W5WH5047",
    ),
  );
  await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  if (FirebaseAuth.instance.currentUser == null) {
    await Future.any([
      FirebaseAuth.instance.userChanges().firstWhere((e) => e != null),
      Future.delayed(Duration(milliseconds: 3000)),
    ]);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: ApplyPTOProvider()),
        ChangeNotifierProvider.value(value: ApplyWorkProvider()),
        ChangeNotifierProvider.value(value: GroupProvider.initialize()),
        ChangeNotifierProvider.value(value: GroupInvoiceProvider()),
        ChangeNotifierProvider.value(value: GroupNoticeProvider()),
        ChangeNotifierProvider.value(value: LogProvider()),
        ChangeNotifierProvider.value(value: PositionProvider()),
        ChangeNotifierProvider.value(value: UserProvider()),
        ChangeNotifierProvider.value(value: WorkProvider()),
        ChangeNotifierProvider.value(value: WorkShiftProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('ja'),
        ],
        locale: const Locale('ja'),
        title: 'はたらくじかんforWEB',
        theme: theme(),
        home: SplashController(),
        routes: {
          ApplyPTOScreen.id: (context) => ApplyPTOScreen(),
          ApplyWorkScreen.id: (context) => ApplyWorkScreen(),
          GroupInfoScreen.id: (context) => GroupInfoScreen(),
          GroupInvoiceScreen.id: (context) => GroupInvoiceScreen(),
          GroupNoticeScreen.id: (context) => GroupNoticeScreen(),
          GroupPositionScreen.id: (context) => GroupPositionScreen(),
          GroupRuleScreen.id: (context) => GroupRuleScreen(),
          UserScreen.id: (context) => UserScreen(),
          WorkScreen.id: (context) => WorkScreen(),
          WorkDownloadScreen.id: (context) => WorkDownloadScreen(),
          WorkShiftScreen.id: (context) => WorkShiftScreen(),
        },
      ),
    );
  }
}

class SplashController extends StatefulWidget {
  @override
  State<SplashController> createState() => _SplashControllerState();
}

class _SplashControllerState extends State<SplashController> {
  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    switch (groupProvider.status) {
      case Status.Uninitialized:
        return SplashScreen();
      case Status.Unauthenticated:
      case Status.Authenticating:
        return LoginScreen();
      case Status.Authenticated:
        return WorkScreen();
      default:
        return LoginScreen();
    }
  }
}
