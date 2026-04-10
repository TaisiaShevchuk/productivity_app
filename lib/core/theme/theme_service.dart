import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const key = "app_theme";

  static Future<void> saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, isDark);
  }

  static Future<bool> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? true; // по умолчанию dark
  }
}
