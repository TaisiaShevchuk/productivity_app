import '../../../data/database_helper.dart';
import '../../goals/models/goal.dart';
import '../../habits/models/habit.dart';
import '../../tasks/models/task.dart';
import '../models/scenario_template.dart';

class ScenarioService {
  final DatabaseHelper _db;

  ScenarioService({DatabaseHelper? database})
      : _db = database ?? DatabaseHelper.instance;

  Future<void> applyScenario(ScenarioTemplate template) async {
    final now = DateTime.now();

    for (final goalTemplate in template.goals) {
      final deadline = now
          .add(Duration(days: goalTemplate.deadlineDaysFromNow))
          .millisecondsSinceEpoch;

      await _db.insertGoal(
        Goal(
          title: goalTemplate.title,
          isDone: false,
          progress: 0,
          createdAt: now.millisecondsSinceEpoch,
          deadline: deadline,
          subtasks: goalTemplate.subtasks
              .map((title) => Subtask(title: title, isDone: false))
              .toList(),
        ),
      );
    }

    for (final habitTitle in template.habits) {
      await _db.insertHabit(
        Habit(
          title: habitTitle,
          days: [0, 0, 0, 0, 0, 0, 0],
          lastReset: now.millisecondsSinceEpoch,
        ),
      );
    }

    for (final taskTitle in template.tasks) {
      await _db.insertTask(Task(title: taskTitle));
    }
  }
}
