import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fi.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fi'),
    Locale('ru')
  ];

  String get appTitle;

  /// **'Calendar'**
  String get calendar;

  /// **'Tasks'**
  String get tasks;

  /// **'Habits'**
  String get habits;

  /// **'Goals'**
  String get goals;

  /// **'Notes'**
  String get notes;

  /// **'Statistics'**
  String get stats;

  /// **'Settings'**
  String get settings;

  /// **'Trash'**
  String get trash;

  /// **'Add'**
  String get add;

  /// **'Edit'**
  String get edit;

  /// **'Delete'**
  String get delete;

  /// **'Confirm'**
  String get confirm;

  /// **'Cancel'**
  String get cancel;

  /// **'Close'**
  String get close;

  /// **'No notes yet'**
  String get noNotes;

  /// **'No tasks yet'**
  String get noTasks;

  /// **'No habits yet'**
  String get noHabits;

  /// **'No goals yet'**
  String get noGoals;

  /// **'Trash is empty'**
  String get noTrash;

  /// **'Support'**
  String get support;

  /// **'If you experience any issues or have questions, please contact us at:'**
  String get supportMessage;

  /// **'Language'**
  String get language;

  /// **'Choose language'**
  String get chooseLanguage;

  /// **'Are you sure you want to delete this item?'**
  String get deleteConfirmation;

  /// **'Restore'**
  String get restore;

  /// **'Delete permanently'**
  String get permanentlyDelete;

  /// **'Task completed'**
  String get taskCompleted;

  /// **'Task not completed'**
  String get taskNotCompleted;

  /// **'Streak'**
  String get habitStreak;

  /// **'Progress'**
  String get goalProgress;

  /// **'Today'**
  String get calendarToday;

  /// **'Selected date'**
  String get calendarSelectedDate;

  /// **'Theme'**
  String get settingsTheme;

  /// **'Support'**
  String get settingsSupport;

  /// **'About app'**
  String get settingsAbout;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fi', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'fi': return AppLocalizationsFi();
    case 'ru': return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
