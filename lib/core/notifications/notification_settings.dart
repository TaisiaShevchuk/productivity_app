import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettings {
  final bool dailyEnabled;
  final int dailyHour;
  final int dailyMinute;
  final bool deadlineEnabled;
  final List<int> deadlineReminderHours;

  const NotificationSettings({
    this.dailyEnabled = true,
    this.dailyHour = 8,
    this.dailyMinute = 0,
    this.deadlineEnabled = true,
    this.deadlineReminderHours = const [24, 1],
  });

  NotificationSettings copyWith({
    bool? dailyEnabled,
    int? dailyHour,
    int? dailyMinute,
    bool? deadlineEnabled,
    List<int>? deadlineReminderHours,
  }) {
    return NotificationSettings(
      dailyEnabled: dailyEnabled ?? this.dailyEnabled,
      dailyHour: dailyHour ?? this.dailyHour,
      dailyMinute: dailyMinute ?? this.dailyMinute,
      deadlineEnabled: deadlineEnabled ?? this.deadlineEnabled,
      deadlineReminderHours:
          deadlineReminderHours ?? this.deadlineReminderHours,
    );
  }
}

class NotificationSettingsService {
  static const _dailyEnabled = 'notifications_daily_enabled';
  static const _dailyHour = 'notifications_daily_hour';
  static const _dailyMinute = 'notifications_daily_minute';
  static const _deadlineEnabled = 'notifications_deadline_enabled';
  static const _deadlineCount = 'notifications_deadline_count';
  static const _firstHours = 'notifications_first_hours';
  static const _secondHours = 'notifications_second_hours';
  static const _reminderHours = 'notifications_reminder_hours';

  static Future<NotificationSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final storedHours = prefs
        .getStringList(_reminderHours)
        ?.map(int.tryParse)
        .whereType<int>()
        .where((value) => value > 0)
        .toList();
    final oldCount = prefs.getInt(_deadlineCount) ?? 2;
    final oldHours = [
      prefs.getInt(_firstHours) ?? 24,
      if (oldCount > 1) prefs.getInt(_secondHours) ?? 1,
    ];

    return NotificationSettings(
      dailyEnabled: prefs.getBool(_dailyEnabled) ?? true,
      dailyHour: prefs.getInt(_dailyHour) ?? 8,
      dailyMinute: prefs.getInt(_dailyMinute) ?? 0,
      deadlineEnabled: prefs.getBool(_deadlineEnabled) ?? true,
      deadlineReminderHours: storedHours ?? oldHours,
    );
  }

  static Future<void> save(NotificationSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setBool(_dailyEnabled, settings.dailyEnabled),
      prefs.setInt(_dailyHour, settings.dailyHour),
      prefs.setInt(_dailyMinute, settings.dailyMinute),
      prefs.setBool(_deadlineEnabled, settings.deadlineEnabled),
      prefs.setStringList(
        _reminderHours,
        settings.deadlineReminderHours.map((value) => '$value').toList(),
      ),
    ]);
  }
}
