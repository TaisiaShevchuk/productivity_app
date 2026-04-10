import 'package:flutter/material.dart';

class AppTheme {
  // DARK THEME
  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF3F5B8B),
      onPrimary: Color(0xFFD29797),
      secondary: Color(0xFFD29797),
      onSecondary: Color(0xFF2E385A),
      surface: Color(0xFF2E385A),
      onSurface: Color(0xFF96A4C5),
      error: Colors.red,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.transparent,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF96A4C5)),
      bodyMedium: TextStyle(color: Color(0xFF96A4C5)),
      bodySmall: TextStyle(color: Color(0xFFA091A7)),
      titleLarge: TextStyle(
        color: Color(0xFF96A4C5),
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFFA091A7),
      size: 24,
    ),
  );

  // LIGHT THEME
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF3F5B8B),
      onPrimary: Colors.white,
      secondary: Color(0xFFD29797),
      onSecondary: Colors.white,
      surface: Color(0xFFF2F2F7),
      onSurface: Color(0xFF2E385A),
      error: Colors.red,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.white,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF2E385A)),
      bodyMedium: TextStyle(color: Color(0xFF2E385A)),
      bodySmall: TextStyle(color: Color(0xFF6C5E82)),
      titleLarge: TextStyle(
        color: Color(0xFF2E385A),
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFF6C5E82),
      size: 24,
    ),
  );
}
