import 'package:flutter/material.dart';
import '../habits/models/habit.dart';

class StatisticsScreen extends StatelessWidget {
  final List<Habit> habits;

  const StatisticsScreen({super.key, required this.habits});

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

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2E385A),
            Color(0xFF6C5E82),
            Color(0xFFA091A7),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text("Statistics"),
        ),

        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            // ---------- HABITS ----------
            Text("Habits", style: tt.headlineSmall),
            const SizedBox(height: 12),

            ...habits.map((habit) {
              final completed = habit.days.where((d) => d == 1).length;
              final percent = completed / 7;
              final streak = calculateStreak(habit.days);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.25),
                    width: 1,
                  ),
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
            }),

            const SizedBox(height: 32),

            // ---------- TASKS ----------
            Text("Tasks", style: tt.headlineSmall),
            const SizedBox(height: 8),
            Text("Task statistics will appear here later.", style: tt.bodySmall),
            const SizedBox(height: 32),

            // ---------- GOALS ----------
            Text("Goals", style: tt.headlineSmall),
            const SizedBox(height: 8),
            Text("Goal statistics will appear here later.", style: tt.bodySmall),
            const SizedBox(height: 32),

          ],
        ),
      ),
    );
  }
}