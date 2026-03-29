import 'package:flutter/material.dart';
import '../models/habit.dart';

class HabitStatsScreen extends StatelessWidget {
  final List<Habit> habits;

  const HabitStatsScreen({super.key, required this.habits});

  int calculateStreak(List<int> days) {
    int streak = 0;
    for (int i = days.length - 1; i >= 0; i--) {
      if (days[i] == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Статистика привычек")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: habits.map((habit) {
          final completed = habit.days.where((d) => d == 1).length;
          final percent = completed / 7;
          final streak = calculateStreak(habit.days);

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(habit.title, style: tt.titleMedium),
                const SizedBox(height: 8),

                Text("Completed: $completed of 7"),
                const SizedBox(height: 4),

                LinearProgressIndicator(
                  value: percent,
                  backgroundColor: Colors.white12,
                  color: Colors.green,
                ),

                const SizedBox(height: 12),
                Text("Streak: $streak days 🔥", style: tt.bodyMedium),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
