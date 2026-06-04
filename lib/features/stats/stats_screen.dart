import 'package:flutter/material.dart';
import '../../data/database_helper.dart';
import '../../l10n/app_localizations.dart';
import '../goals/models/goal.dart';
import '../habits/models/habit.dart';
import '../tasks/models/task.dart';
import '../../core/theme/app_theme.dart';

class StatisticsScreen extends StatefulWidget {
  final List<Habit> habits;

  const StatisticsScreen({super.key, required this.habits});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _loading = true;
  List<Habit> _habits = [];
  List<Task> _tasks = [];
  List<Goal> _goals = [];

  @override
  void initState() {
    super.initState();
    _habits = widget.habits;
    _loadStats();
  }

  Future<void> _loadStats() async {
    final db = DatabaseHelper.instance;
    final habits = await db.getHabits();
    final tasks = await db.getTasks();
    final goals = await db.getGoals();

    if (!mounted) return;
    setState(() {
      _habits = habits;
      _tasks = tasks;
      _goals = goals;
      _loading = false;
    });
  }

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
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: AppTheme.pageDecoration(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(l10n.stats),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadStats,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(l10n.habits, style: tt.headlineSmall),
                    const SizedBox(height: 12),
                    ..._habits.map(_buildHabitStats),
                    if (_habits.isEmpty) _EmptyStatsText(l10n.noHabits),
                    const SizedBox(height: 32),
                    Text(l10n.tasks, style: tt.headlineSmall),
                    const SizedBox(height: 12),
                    _SummaryCard(
                      title: l10n.taskStats,
                      completed: _tasks.where((task) => task.isDone).length,
                      total: _tasks.length,
                    ),
                    ..._tasks
                        .where((task) => !task.isDone)
                        .map((task) => _TextStatsCard(
                              icon: Icons.circle_outlined,
                              title: task.title,
                              subtitle: task.deadline == null
                                  ? l10n.noDeadlineSelected
                                  : '${l10n.deadline}: ${_formatDate(task.deadline!)}',
                            )),
                    if (_tasks.isEmpty) _EmptyStatsText(l10n.noTasks),
                    const SizedBox(height: 32),
                    Text(l10n.goals, style: tt.headlineSmall),
                    const SizedBox(height: 12),
                    _SummaryCard(
                      title: l10n.goalStats,
                      completed: _goals.where((goal) => goal.isDone).length,
                      total: _goals.length,
                    ),
                    ..._goals
                        .where((goal) => !goal.isDone)
                        .map((goal) => _TextStatsCard(
                              icon: Icons.flag_outlined,
                              title: goal.title,
                              subtitle: '${l10n.goalProgress}: ${goal.progress}%',
                            )),
                    if (_goals.isEmpty) _EmptyStatsText(l10n.noGoals),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHabitStats(Habit habit) {
    final l10n = AppLocalizations.of(context)!;
    final completed = habit.days.where((d) => d == 1).length;
    final percent = completed / 7;
    final streak = calculateStreak(habit.days);

    return _StatsContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(habit.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('${l10n.completed}: $completed ${l10n.outOf} 7'),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percent,
            backgroundColor: Colors.white12,
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          Text(
            '${l10n.habitStreak}: $streak ${l10n.days}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  String _formatDate(int timestamp) {
    final d = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${d.day.toString().padLeft(2, '0')}'
        '.${d.month.toString().padLeft(2, '0')}'
        '.${d.year} '
        '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final int completed;
  final int total;

  const _SummaryCard({
    required this.title,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final percent = total == 0 ? 0.0 : completed / total;

    return _StatsContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('${l10n.completed}: $completed ${l10n.outOf} $total'),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: percent,
            backgroundColor: Colors.white12,
            color: Colors.lightBlueAccent,
          ),
        ],
      ),
    );
  }
}

class _TextStatsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _TextStatsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return _StatsContainer(
      child: Row(
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: tt.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: tt.bodySmall!.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStatsText extends StatelessWidget {
  final String text;

  const _EmptyStatsText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _StatsContainer extends StatelessWidget {
  final Widget child;

  const _StatsContainer({required this.child});

  @override
  Widget build(BuildContext context) {
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
      child: child,
    );
  }
}
