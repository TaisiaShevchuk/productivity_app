import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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

  static void setTheme(BuildContext context, bool isDark) {
    final state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeTheme(isDark);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale _locale;
  bool _isDark = true;

  @override
  void initState() {
    super.initState();
    _locale = widget.startLocale;

    ThemeService.loadTheme().then((value) {
      setState(() => _isDark = value);
    });
  }

  void changeLocale(Locale locale) {
    setState(() => _locale = locale);
    LocaleService.saveLocale(locale.languageCode);
  }

  void changeTheme(bool isDark) {
    setState(() => _isDark = isDark);
    ThemeService.saveTheme(isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Productivity App',

      theme: _isDark ? AppTheme.dark : AppTheme.light,

      locale: _locale,

      supportedLocales: const [
        Locale('en'),
        Locale('ru'),
        Locale('fi'),
      ],

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      home: const HomeScreen(),
    );
  }
}
