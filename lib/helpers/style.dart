import 'package:flutter/material.dart';

ThemeData theme() {
  return ThemeData(
    scaffoldBackgroundColor: Color(0xFFFEFFFA),
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

const BoxDecoration kBottomBorderDecoration = BoxDecoration(
  border: Border(
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
