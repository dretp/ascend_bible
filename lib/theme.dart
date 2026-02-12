import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Colors.blue;
  static const Color accentColor = Colors.blueAccent;

  static final ThemeData mainTheme = ThemeData(
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    cardColor: Colors.white,
    textTheme: TextTheme(
      bodyLarge: TextStyle(fontSize: 18, color: Colors.black87),
      bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
      titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
    ),
  );

  static const verseTextStyle = TextStyle(
    fontSize: 18,
    color: Colors.black87,
    fontStyle: FontStyle.italic,
  );

  static const moodDropdownTextStyle = TextStyle(
    fontSize: 16,
    color: Colors.blueGrey,
  );
}
