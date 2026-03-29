import 'package:flutter/material.dart';
import 'app/home_screen.dart';

// ---------- ТВОЯ ТЕМА ----------
final ThemeData appTheme = ThemeData(
  useMaterial3: true,

  colorScheme: const ColorScheme(
    brightness: Brightness.dark,

    primary: Color(0xFF3F5B8B),
    onPrimary: Color(0xFFD29797),

    secondary: Color(0xFFD29797),
    onSecondary: Color(0xFF2E385A),

    surface: Color(0xFF2E385A),
    onSurface: Color(0xFF96A4C5),

    background: Color(0xFF2E385A),
    onBackground: Color(0xFF96A4C5),

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

  cardTheme: CardThemeData(
    color: const Color(0xFF2E385A).withValues(alpha: 0.45),
    elevation: 6,
    shadowColor: const Color(0xFF6C5E82).withValues(alpha: 0.3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF3F5B8B),
      foregroundColor: const Color(0xFFD29797),
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    hintStyle: const TextStyle(color: Color(0xFFA091A7)),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.1),
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Color(0xFF96A4C5),
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  ),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Productivity App',
      theme: appTheme,
      home: const HomeScreen(),
    );
  }
}
