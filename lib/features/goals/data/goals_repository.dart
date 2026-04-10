import '../../../data/database_helper.dart';
import '../models/goal.dart';

class GoalsRepository {
  Future<List<Goal>> getGoals() async {
    return await DatabaseHelper.instance.getGoals();
  }

  Future<List<Goal>> getGoalsForDate(DateTime day) async {
    final db = await DatabaseHelper.instance.database;

    final start = DateTime(day.year, day.month, day.day).millisecondsSinceEpoch;
    final end = DateTime(day.year, day.month, day.day, 23, 59, 59).millisecondsSinceEpoch;

    final maps = await db.query(
      'goals',
      where: 'deadline BETWEEN ? AND ?',
      whereArgs: [start, end],
    );

    return maps.map((m) => Goal.fromMap(m)).toList();
  }
}
