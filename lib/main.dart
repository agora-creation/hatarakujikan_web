import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/screens/home.dart';
import 'package:hatarakujikan_web/screens/login.dart';
import 'package:hatarakujikan_web/screens/splash.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        ChangeNotifierProvider.value(value: GroupProvider.initialize()),
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
      ),
    );
  }
}

class SplashController extends StatelessWidget {
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
        if (groupProvider.group == null) {
          groupProvider.signOut();
          return LoginScreen();
        }
        return HomeScreen();
      default:
        return LoginScreen();
    }
  }
}
