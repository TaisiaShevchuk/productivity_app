import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode {
  dark,
  light,
  monochrome,
}

class ThemeService {
  static const key = "app_theme";

  static Future<void> saveTheme(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, mode.name);
  }

  static Future<AppThemeMode> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.get(key);

    if (stored is bool) {
      return stored ? AppThemeMode.dark : AppThemeMode.light;
    }

    return AppThemeMode.values.firstWhere(
      (mode) => mode.name == stored,
      orElse: () => AppThemeMode.dark,
    );
  }
}
