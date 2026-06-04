import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../core/utils/locale_service.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_service.dart';
import 'home_screen.dart';

class MyApp extends StatefulWidget {
  final Locale startLocale;

  const MyApp({super.key, required this.startLocale});

  static void setLocale(BuildContext context, Locale locale) {
    final state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeLocale(locale);
  }

  static void setTheme(BuildContext context, AppThemeMode mode) {
    final state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeTheme(mode);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale _locale;
  AppThemeMode _themeMode = AppThemeMode.dark;

  @override
  void initState() {
    super.initState();
    _locale = widget.startLocale;

    ThemeService.loadTheme().then((value) {
      setState(() => _themeMode = value);
    });
  }

  void changeLocale(Locale locale) {
    setState(() => _locale = locale);
    LocaleService.saveLocale(locale.languageCode);
  }

  void changeTheme(AppThemeMode mode) {
    setState(() => _themeMode = mode);
    ThemeService.saveTheme(mode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,

      theme: switch (_themeMode) {
        AppThemeMode.dark => AppTheme.dark,
        AppThemeMode.light => AppTheme.light,
        AppThemeMode.monochrome => AppTheme.monochrome,
      },

      locale: _locale,

      supportedLocales: AppLocalizations.supportedLocales,

      localizationsDelegates: AppLocalizations.localizationsDelegates,

      home: const HomeScreen(),
    );
  }
}
