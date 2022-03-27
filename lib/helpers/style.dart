import 'package:flutter/material.dart';

ThemeData theme() {
  return ThemeData(
    scaffoldBackgroundColor: Color(0xFFFEFFFA),
    fontFamily: 'NotoSansJP',
    appBarTheme: AppBarTheme(
      color: Color(0xFFFEFFFA),
      elevation: 0.0,
      centerTitle: false,
      brightness: Brightness.light,
      textTheme: TextTheme(
        headline6: TextStyle(
          color: Colors.black54,
          fontSize: 18.0,
        ),
      ),
      iconTheme: IconThemeData(color: Colors.black54),
    ),
    textTheme: TextTheme(
      bodyText1: TextStyle(color: Colors.black54),
      bodyText2: TextStyle(color: Colors.black54),
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

const TextStyle kAdminTitleTextStyle = TextStyle(
  color: Colors.black54,
  fontSize: 18.0,
  fontWeight: FontWeight.bold,
);

const TextStyle kAdminSubTitleTextStyle = TextStyle(
  color: Colors.black45,
  fontSize: 16.0,
);

const TextStyle kListDayTextStyle = TextStyle(
  color: Colors.black54,
  fontSize: 15.0,
);

const TextStyle kListTimeTextStyle = TextStyle(
  color: Colors.black87,
  fontSize: 15.0,
);

const TextStyle kListTime2TextStyle = TextStyle(
  color: Colors.transparent,
  fontSize: 15.0,
);

const TextStyle kDefaultTextStyle = TextStyle(
  color: Colors.black54,
  fontSize: 14.0,
);
