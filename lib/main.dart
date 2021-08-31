import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/providers/apply_work.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/providers/group_notice.dart';
import 'package:hatarakujikan_web/providers/section.dart';
import 'package:hatarakujikan_web/providers/user.dart';
import 'package:hatarakujikan_web/providers/work.dart';
import 'package:hatarakujikan_web/providers/work_state.dart';
import 'package:hatarakujikan_web/screens/apply_work.dart';
import 'package:hatarakujikan_web/screens/login.dart';
import 'package:hatarakujikan_web/screens/notice.dart';
import 'package:hatarakujikan_web/screens/section.dart';
import 'package:hatarakujikan_web/screens/section/apply_work.dart';
import 'package:hatarakujikan_web/screens/section/login.dart';
import 'package:hatarakujikan_web/screens/section/setting_info.dart';
import 'package:hatarakujikan_web/screens/section/user.dart';
import 'package:hatarakujikan_web/screens/section/work.dart';
import 'package:hatarakujikan_web/screens/setting_info.dart';
import 'package:hatarakujikan_web/screens/setting_security.dart';
import 'package:hatarakujikan_web/screens/setting_work.dart';
import 'package:hatarakujikan_web/screens/splash.dart';
import 'package:hatarakujikan_web/screens/user.dart';
import 'package:hatarakujikan_web/screens/work.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        ChangeNotifierProvider.value(value: ApplyWorkProvider()),
        ChangeNotifierProvider.value(value: GroupProvider.initialize()),
        ChangeNotifierProvider.value(value: GroupNoticeProvider()),
        ChangeNotifierProvider.value(value: SectionProvider.initialize()),
        ChangeNotifierProvider.value(value: UserProvider()),
        ChangeNotifierProvider.value(value: WorkProvider()),
        ChangeNotifierProvider.value(value: WorkStateProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
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
          ApplyWorkScreen.id: (context) => ApplyWorkScreen(),
          NoticeScreen.id: (context) => NoticeScreen(),
          SectionScreen.id: (context) => SectionScreen(),
          SettingInfoScreen.id: (context) => SettingInfoScreen(),
          SettingSecurityScreen.id: (context) => SettingSecurityScreen(),
          SettingWorkScreen.id: (context) => SettingWorkScreen(),
          UserScreen.id: (context) => UserScreen(),
          WorkScreen.id: (context) => WorkScreen(),
          SectionApplyWorkScreen.id: (context) => SectionApplyWorkScreen(),
          SectionSettingInfoScreen.id: (context) => SectionSettingInfoScreen(),
          SectionUserScreen.id: (context) => SectionUserScreen(),
          SectionWorkScreen.id: (context) => SectionWorkScreen(),
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
  Widget _widget = SplashScreen();

  void _init() async {
    if (await getPrefs(key: 'groupId') != '') {
      final groupProvider = Provider.of<GroupProvider>(context);
      switch (groupProvider.status) {
        case Status.Uninitialized:
          _widget = SplashScreen();
          break;
        case Status.Unauthenticated:
        case Status.Authenticating:
          _widget = LoginScreen();
          break;
        case Status.Authenticated:
          if (groupProvider.group == null) {
            groupProvider.signOut();
            _widget = LoginScreen();
          } else {
            _widget = WorkScreen();
          }
          break;
        default:
          _widget = LoginScreen();
          break;
      }
    } else if (await getPrefs(key: 'sectionId') != '') {
      final sectionProvider = Provider.of<SectionProvider>(context);
      switch (sectionProvider.status) {
        case SectionStatus.Uninitialized:
          _widget = SplashScreen();
          break;
        case SectionStatus.Unauthenticated:
        case SectionStatus.Authenticating:
          _widget = SectionLoginScreen();
          break;
        case SectionStatus.Authenticated:
          if (sectionProvider.section == null) {
            sectionProvider.signOut();
            _widget = SectionLoginScreen();
          } else {
            _widget = SectionWorkScreen();
          }
          break;
        default:
          _widget = SectionLoginScreen();
          break;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return _widget;
  }
}
