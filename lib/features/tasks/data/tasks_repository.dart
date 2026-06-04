import '../models/task.dart';
import '../../../data/database_helper.dart';
import '../../../core/notifications/notification_service.dart';

class TasksRepository {
  Future<List<Task>> getTasks() async {
    return await DatabaseHelper.instance.getTasks();
  }

  Future<void> insertTask(Task task) async {
    await DatabaseHelper.instance.insertTask(task);
  }

  Future<void> updateTask(Task task) async {
    await DatabaseHelper.instance.updateTask(task);
  }

  Future<void> toggleTask(int id, bool isDone) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'tasks',
      {'isDone': isDone ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
    if (isDone) {
      await NotificationService.instance.cancelTask(id);
    } else {
      final result = await db.query('tasks', where: 'id = ?', whereArgs: [id]);
      if (result.isNotEmpty) {
        await NotificationService.instance.scheduleTask(
          Task.fromMap(result.first),
        );
      }
    }
  }
}
