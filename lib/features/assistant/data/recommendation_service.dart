import '../../goals/models/goal.dart';
import '../../habits/models/habit.dart';
import '../../tasks/models/task.dart';

class RecommendationSummary {
  final int openTasks;
  final int completedHabitsToday;
  final Goal? urgentGoal;
  final Habit? weakestHabit;

  const RecommendationSummary({
    required this.openTasks,
    required this.completedHabitsToday,
    this.urgentGoal,
    this.weakestHabit,
  });
}

class RecommendationService {
  RecommendationSummary buildSummary({
    required List<Task> tasks,
    required List<Habit> habits,
    required List<Goal> goals,
  }) {
    final openTasks = tasks.where((task) => !task.isDone).length;
    final todayIndex = (DateTime.now().weekday - 1) % 7;
    final completedHabitsToday = habits
        .where((habit) =>
            habit.days.length > todayIndex && habit.days[todayIndex] == 1)
        .length;

    final activeGoals = goals.where((goal) => !goal.isDone).toList()
      ..sort((a, b) {
        final aDeadline = a.deadline ?? 1 << 62;
        final bDeadline = b.deadline ?? 1 << 62;
        return aDeadline.compareTo(bDeadline);
      });

    final sortedHabits = [...habits]
      ..sort((a, b) => _completionCount(a).compareTo(_completionCount(b)));

    return RecommendationSummary(
      openTasks: openTasks,
      completedHabitsToday: completedHabitsToday,
      urgentGoal: activeGoals.isEmpty ? null : activeGoals.first,
      weakestHabit: sortedHabits.isEmpty ? null : sortedHabits.first,
    );
  }

  int _completionCount(Habit habit) {
    return habit.days.where((day) => day == 1).length;
  }
}
