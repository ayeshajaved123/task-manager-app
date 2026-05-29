import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    fontFamily: 'Roboto',
    brightness: Brightness.light,
    primaryColor: Color(0xFF1E88E5),
    scaffoldBackgroundColor: Color(0xFFF5F5F5),
    cardColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF1E88E5),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    colorScheme: ColorScheme.light(
      primary: Color(0xFF1E88E5),
      secondary: Color(0xFFFF7043),
      tertiary: Color(0xFF26A69A),
      error: Color(0xFFEF5350),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      titleMedium: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
      bodyLarge: TextStyle(fontSize: 16),
      bodyMedium: TextStyle(fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(vertical: 16),
        textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
  );

  static final darkTheme = ThemeData(
    fontFamily: 'Roboto',
    brightness: Brightness.dark,
    primaryColor: Color(0xFF1E88E5),
    scaffoldBackgroundColor: Color(0xFF121212),
    cardColor: Color(0xFF1E1E1E),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF1565C0),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF1E88E5),
      secondary: Color(0xFFFF7043),
      tertiary: Color(0xFF26A69A),
      error: Color(0xFFEF5350),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      titleMedium: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
      bodyLarge: TextStyle(fontSize: 16),
      bodyMedium: TextStyle(fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(vertical: 16),
        textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
  );
}