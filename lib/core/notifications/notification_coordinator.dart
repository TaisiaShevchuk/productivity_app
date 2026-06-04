import '../../data/database_helper.dart';
import 'notification_service.dart';
import 'notification_settings.dart';

class NotificationCoordinator {
  static Future<void> rescheduleAll() async {
    final settings = await NotificationSettingsService.load();
    await NotificationService.instance.scheduleDaily(settings);

    final db = DatabaseHelper.instance;
    final tasks = await db.getTasks();
    final goals = await db.getGoals();

    for (final task in tasks) {
      await NotificationService.instance.scheduleTask(task);
    }
    for (final goal in goals) {
      await NotificationService.instance.scheduleGoal(goal);
    }
  }
}
