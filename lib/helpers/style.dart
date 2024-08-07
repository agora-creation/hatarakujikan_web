import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ThemeData theme() {
  return ThemeData(
    scaffoldBackgroundColor: Color(0xFFFEFFFA),
    fontFamily: 'NotoSansJP',
    appBarTheme: AppBarTheme(
      color: Color(0xFFFEFFFA),
      elevation: 0.0,
      centerTitle: false,
      iconTheme: IconThemeData(color: Colors.black54),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      toolbarTextStyle: TextTheme(
        headlineMedium: TextStyle(
          color: Colors.black54,
          fontSize: 18.0,
        ),
      ).bodyMedium,
      titleTextStyle: TextTheme(
        headlineMedium: TextStyle(
          color: Colors.black54,
          fontSize: 18.0,
        ),
      ).bodyMedium,
    ),
    textTheme: TextTheme(
      bodySmall: TextStyle(color: Colors.black54),
      bodyMedium: TextStyle(color: Colors.black54),
      bodyLarge: TextStyle(color: Colors.black54),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}

const BoxDecoration kLoginDecoration = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFb74D),
      Color(0xFFFF9800),
    ],
  ),
);

const BoxDecoration kBottomBorderDecoration = BoxDecoration(
  border: Border(
    bottom: BorderSide(
      width: 1.0,
      color: Color(0xFFE0E0E0),
    ),
  ),
);

const BoxDecoration kTopBorderDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(
      width: 1.0,
      color: Color(0xFFE0E0E0),
    ),
  ),
);

const BoxDecoration kTopBottomBorderDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(
      width: 1.0,
      color: Color(0xFFE0E0E0),
    ),
    bottom: BorderSide(
      width: 1.0,
      color: Color(0xFFE0E0E0),
    ),
  ),
);

const TextStyle kTitleTextStyle = TextStyle(
  color: Colors.white,
  fontSize: 32.0,
  fontWeight: FontWeight.bold,
);

const TextStyle kSubTitleTextStyle = TextStyle(
  color: Colors.white,
  fontSize: 16.0,
);

const TextStyle kLoginTextStyle = TextStyle(
  color: Colors.white,
  fontSize: 14.0,
);

const TextStyle kDialogTextStyle = TextStyle(
  color: Colors.black54,
  fontSize: 15.0,
);
