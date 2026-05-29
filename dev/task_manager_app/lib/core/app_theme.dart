import 'package:flutter/material.dart';

class AppTheme {
  static const Color seedColor = Color(0xFF4A6FA5);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: seedColor,
    brightness: Brightness.light,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: seedColor,
    brightness: Brightness.dark,
  );
}