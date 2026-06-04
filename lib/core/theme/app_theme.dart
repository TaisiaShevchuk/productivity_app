import 'package:flutter/material.dart';

class AppTheme {
  static bool isMonochrome(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return scheme.surface == Colors.black && scheme.primary == Colors.white;
  }

  static BoxDecoration pageDecoration(BuildContext context) {
    if (isMonochrome(context)) {
      return const BoxDecoration(color: Colors.black);
    }

    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF2E385A),
          Color(0xFF6C5E82),
          Color(0xFFA091A7),
        ],
      ),
    );
  }

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

  static final ThemeData monochrome = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Colors.white,
      onPrimary: Colors.black,
      secondary: Colors.white70,
      onSecondary: Colors.black,
      surface: Colors.black,
      onSurface: Colors.white,
      error: Colors.white,
      onError: Colors.black,
    ),
    scaffoldBackgroundColor: Colors.black,
    cardColor: const Color(0xFF141414),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      bodySmall: TextStyle(color: Colors.white70),
      titleMedium: TextStyle(color: Colors.white),
      titleLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
    ),
    iconTheme: const IconThemeData(color: Colors.white, size: 24),
  );
}
