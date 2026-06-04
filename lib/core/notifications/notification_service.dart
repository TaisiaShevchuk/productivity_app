import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../features/goals/models/goal.dart';
import '../../features/tasks/models/task.dart';
import '../utils/locale_service.dart';
import 'notification_settings.dart';

class NotificationService {
  NotificationService._();

  static final instance = NotificationService._();
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _dailyId = 100;
  static const _nextIdKey = 'notification_next_unique_id';

  Future<void> initialize() async {
    if (kIsWeb) return;

    tz_data.initializeTimeZones();
    final timezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezone.identifier));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
  }

  Future<void> scheduleDaily(NotificationSettings settings) async {
    await _plugin.cancel(id: _dailyId);
    if (!settings.dailyEnabled) return;

    final text = await _text();
    final now = tz.TZDateTime.now(tz.local);
    var date = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      settings.dailyHour,
      settings.dailyMinute,
    );
    if (!date.isAfter(now)) date = date.add(const Duration(days: 1));

    await _zonedSchedule(
      id: _dailyId,
      title: text.dailyTitle,
      body: text.dailyBody,
      scheduledDate: date,
      notificationDetails: _details(),
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleTask(Task task) async {
    if (task.id == null) return;
    if (task.isDone) {
      await cancelTask(task.id!);
      return;
    }
    await _scheduleDeadline(
      scheduleKey: 'task_${task.id}',
      deadline: task.deadline,
      itemTitle: task.title,
      isGoal: false,
    );
  }

  Future<void> scheduleGoal(Goal goal) async {
    if (goal.id == null) return;
    if (goal.isDone) {
      await cancelGoal(goal.id!);
      return;
    }
    await _scheduleDeadline(
      scheduleKey: 'goal_${goal.id}',
      deadline: goal.deadline,
      itemTitle: goal.title,
      isGoal: true,
    );
  }

  Future<void> cancelTask(int id) => _cancelDeadline('task_$id');
  Future<void> cancelGoal(int id) => _cancelDeadline('goal_$id');

  Future<void> _scheduleDeadline({
    required String scheduleKey,
    required int? deadline,
    required String itemTitle,
    required bool isGoal,
  }) async {
    await _cancelDeadline(scheduleKey);
    final settings = await NotificationSettingsService.load();
    if (!settings.deadlineEnabled || deadline == null) return;

    final text = await _text();
    final offsets = settings.deadlineReminderHours;
    final notificationIds = <int>[];

    for (var index = 0; index < offsets.length; index++) {
      final scheduled = DateTime.fromMillisecondsSinceEpoch(
        deadline,
      ).subtract(Duration(hours: offsets[index]));
      if (!scheduled.isAfter(DateTime.now())) continue;

      final notificationId = await _nextNotificationId();
      await _zonedSchedule(
        id: notificationId,
        title: isGoal ? text.goalDeadlineTitle : text.taskDeadlineTitle,
        body: text.deadlineBody(itemTitle, offsets[index]),
        scheduledDate: tz.TZDateTime.from(scheduled, tz.local),
        notificationDetails: _details(),
      );
      notificationIds.add(notificationId);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _scheduledIdsKey(scheduleKey),
      notificationIds.map((id) => '$id').toList(),
    );
  }

  Future<void> _cancelDeadline(String scheduleKey) async {
    final prefs = await SharedPreferences.getInstance();
    final ids =
        prefs
            .getStringList(_scheduledIdsKey(scheduleKey))
            ?.map(int.tryParse)
            .whereType<int>() ??
        const <int>[];
    for (final id in ids) {
      await _plugin.cancel(id: id);
    }
    await prefs.remove(_scheduledIdsKey(scheduleKey));
  }

  String _scheduledIdsKey(String scheduleKey) {
    return 'scheduled_deadline_notification_ids_$scheduleKey';
  }

  Future<int> _nextNotificationId() async {
    final prefs = await SharedPreferences.getInstance();
    final next = prefs.getInt(_nextIdKey) ?? 1000000;
    final following = next >= 2000000000 ? 1000000 : next + 1;
    await prefs.setInt(_nextIdKey, following);
    return next;
  }

  NotificationDetails _details() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'productivity_reminders',
        'Productivity reminders',
        channelDescription: 'Daily reminders and deadline notifications',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  Future<void> _zonedSchedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails notificationDetails,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: matchDateTimeComponents,
      );
    } catch (_) {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: matchDateTimeComponents,
      );
    }
  }

  Future<_NotificationText> _text() async {
    final locale = await LocaleService.loadLocale();
    return switch (locale.languageCode) {
      'ru' => const _NotificationText(
        dailyTitle: 'Пора заглянуть в приложение',
        dailyBody: 'Проверь задачи, цели и привычки на сегодня.',
        taskDeadlineTitle: 'Скоро дедлайн задачи',
        goalDeadlineTitle: 'Скоро дедлайн цели',
        hoursWord: 'ч.',
      ),
      'fi' => const _NotificationText(
        dailyTitle: 'Aika avata sovellus',
        dailyBody: 'Tarkista päivän tehtävät, tavoitteet ja tavat.',
        taskDeadlineTitle: 'Tehtävän määräaika lähestyy',
        goalDeadlineTitle: 'Tavoitteen määräaika lähestyy',
        hoursWord: 'h',
      ),
      _ => const _NotificationText(
        dailyTitle: 'Time to check the app',
        dailyBody: 'Review today’s tasks, goals, and habits.',
        taskDeadlineTitle: 'Task deadline is approaching',
        goalDeadlineTitle: 'Goal deadline is approaching',
        hoursWord: 'h',
      ),
    };
  }
}

class _NotificationText {
  final String dailyTitle;
  final String dailyBody;
  final String taskDeadlineTitle;
  final String goalDeadlineTitle;
  final String hoursWord;

  const _NotificationText({
    required this.dailyTitle,
    required this.dailyBody,
    required this.taskDeadlineTitle,
    required this.goalDeadlineTitle,
    required this.hoursWord,
  });

  String deadlineBody(String title, int hours) {
    return '$title: $hours $hoursWord';
  }
}
