import 'package:flutter/material.dart';

import '../../../data/database_helper.dart';
import '../../../l10n/app_localizations.dart';
import '../../goals/models/goal.dart';
import '../../habits/models/habit.dart';
import '../../tasks/models/task.dart';
import '../data/recommendation_service.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final RecommendationService _recommendations = RecommendationService();

  bool _loading = true;
  List<Task> _tasks = [];
  List<Habit> _habits = [];
  List<Goal> _goals = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = DatabaseHelper.instance;
    final tasks = await db.getTasks();
    final habits = await db.getHabits();
    final goals = await db.getGoals();

    if (!mounted) return;
    setState(() {
      _tasks = tasks;
      _habits = habits;
      _goals = goals;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final summary = _recommendations.buildSummary(
      tasks: _tasks,
      habits: _habits,
      goals: _goals,
    );

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          _AssistantCard(
            icon: Icons.today,
            title: l10n.assistantTodayTitle,
            body: summary.openTasks == 0
                ? l10n.assistantNoOpenTasks
                : l10n.assistantOpenTasks(summary.openTasks),
          ),
          _AssistantCard(
            icon: Icons.flag,
            title: l10n.assistantGoalsTitle,
            body: summary.urgentGoal == null
                ? l10n.assistantNoUrgentGoals
                : l10n.assistantGoalWarning(
                    summary.urgentGoal!.title,
                    _formatDate(summary.urgentGoal!.deadline),
                  ),
          ),
          _AssistantCard(
            icon: Icons.repeat,
            title: l10n.assistantHabitsTitle,
            body: summary.weakestHabit == null
                ? l10n.assistantNoHabits
                : l10n.assistantHabitAdvice(summary.weakestHabit!.title),
          ),
          _AssistantCard(
            icon: Icons.insights,
            title: l10n.assistantForecastTitle,
            body: l10n.assistantForecastBody,
          ),
        ],
      ),
    );
  }

  String _formatDate(int? timestamp) {
    if (timestamp == null) {
      return AppLocalizations.of(context)!.noDeadlineSelected;
    }

    final d = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${d.day.toString().padLeft(2, '0')}'
        '.${d.month.toString().padLeft(2, '0')}'
        '.${d.year}';
  }
}

class _AssistantCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _AssistantCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: tt.titleMedium),
                const SizedBox(height: 8),
                Text(
                  body,
                  style: tt.bodyMedium!.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
