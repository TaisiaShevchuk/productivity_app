import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../goals/data/goals_repository.dart';
import '../../goals/models/goal.dart';
import '../../goals/ui/edit_goal_screen.dart';
import '../../tasks/data/tasks_repository.dart';
import '../../tasks/models/task.dart';
import '../../tasks/ui/edit_task_screen.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime currentMonth = DateTime.now();
  DateTime nextMonth = DateTime(DateTime.now().year, DateTime.now().month + 1);

  List<Goal> allGoals = [];
  List<Task> allTasks = [];

  @override
  void initState() {
    super.initState();
    _loadCalendarItems();
  }

  Future<void> _loadCalendarItems() async {
    final goals = await GoalsRepository().getGoals();
    final tasks = await TasksRepository().getTasks();

    if (!mounted) return;
    setState(() {
      allGoals = goals;
      allTasks = tasks;
    });
  }

  bool hasItems(DateTime day) {
    return goalsForDay(day).isNotEmpty || tasksForDay(day).isNotEmpty;
  }

  List<Goal> goalsForDay(DateTime day) {
    return allGoals.where((g) {
      if (g.deadline == null) return false;
      final d = DateTime.fromMillisecondsSinceEpoch(g.deadline!);
      return _isSameDay(d, day);
    }).toList();
  }

  List<Task> tasksForDay(DateTime day) {
    return allTasks.where((task) {
      if (task.deadline == null) return false;
      final d = DateTime.fromMillisecondsSinceEpoch(task.deadline!);
      return _isSameDay(d, day);
    }).toList();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<DateTime> _generateDaysForMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    final daysBefore = (firstDay.weekday + 6) % 7;
    final daysAfter = 6 - ((lastDay.weekday + 6) % 7);
    final totalDays = daysBefore + lastDay.day + daysAfter;

    return List.generate(totalDays, (index) {
      final dayNumber = index - daysBefore + 1;
      return DateTime(month.year, month.month, dayNumber);
    });
  }

  Widget _buildWeekdayLabels(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _WeekdayLabel(l10n.weekdayMon),
          _WeekdayLabel(l10n.weekdayTue),
          _WeekdayLabel(l10n.weekdayWed),
          _WeekdayLabel(l10n.weekdayThu),
          _WeekdayLabel(l10n.weekdayFri),
          _WeekdayLabel(l10n.weekdaySat),
          _WeekdayLabel(l10n.weekdaySun),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader({
    required DateTime month,
    required VoidCallback onPrev,
    required VoidCallback onNext,
    required TextTheme tt,
    required AppLocalizations l10n,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white),
            onPressed: onPrev,
          ),
          Text(
            DateFormat.yMMMM(l10n.localeName).format(month),
            style: tt.titleLarge!.copyWith(color: Colors.white),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }

  void _showDayPopup(BuildContext context, DateTime day, TextTheme tt) {
    final todayGoals = goalsForDay(day);
    final todayTasks = tasksForDay(day);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2E385A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '${day.day} ${DateFormat.MMMM(l10n.localeName).format(day)}',
          style: tt.titleMedium!.copyWith(color: Colors.white),
        ),
        content: todayGoals.isEmpty && todayTasks.isEmpty
            ? Text(
                l10n.noCalendarItems,
                style: tt.bodyLarge!.copyWith(color: Colors.white70),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (todayGoals.isNotEmpty) ...[
                      _PopupSectionTitle(l10n.goals),
                      ...todayGoals.map((goal) {
                        return _PopupItem(
                          title: goal.title,
                          color: Colors.orangeAccent,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditGoalScreen(goal: goal),
                              ),
                            ).then((_) => _loadCalendarItems());
                          },
                        );
                      }),
                    ],
                    if (todayTasks.isNotEmpty) ...[
                      if (todayGoals.isNotEmpty) const SizedBox(height: 12),
                      _PopupSectionTitle(l10n.tasks),
                      ...todayTasks.map((task) {
                        return _PopupItem(
                          title: task.title,
                          color: Colors.lightBlueAccent,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditTaskScreen(task: task),
                              ),
                            ).then((_) => _loadCalendarItems());
                          },
                        );
                      }),
                    ],
                  ],
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.close,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid({
    required DateTime month,
    required TextTheme tt,
  }) {
    final days = _generateDaysForMonth(month);
    final today = DateTime.now();

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        final isCurrentMonth = day.month == month.month;
        final isToday = _isSameDay(day, today);

        return GestureDetector(
          onTap: () => _showDayPopup(context, day, tt),
          child: Container(
            decoration: BoxDecoration(
              color: (!isToday && hasItems(day))
                  ? Colors.orange.withValues(alpha: 0.8)
                  : Colors.white.withValues(
                      alpha: isCurrentMonth ? 0.12 : 0.05,
                    ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(6),
            alignment: Alignment.topLeft,
            child: Text(
              '${day.day}',
              style: tt.bodyMedium!.copyWith(
                color: isToday
                    ? Colors.lightBlueAccent
                    : (isCurrentMonth
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.4)),
                fontWeight: isToday ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: AppTheme.pageDecoration(context),
      child: Column(
        children: [
          _buildCalendarHeader(
            month: currentMonth,
            tt: tt,
            l10n: l10n,
            onPrev: () {
              setState(() {
                currentMonth = DateTime(
                  currentMonth.year,
                  currentMonth.month - 1,
                );
              });
            },
            onNext: () {
              setState(() {
                currentMonth = DateTime(
                  currentMonth.year,
                  currentMonth.month + 1,
                );
              });
            },
          ),
          _buildWeekdayLabels(l10n),
          Expanded(
            child: _buildCalendarGrid(month: currentMonth, tt: tt),
          ),
          _buildCalendarHeader(
            month: nextMonth,
            tt: tt,
            l10n: l10n,
            onPrev: () {
              setState(() {
                nextMonth = DateTime(
                  nextMonth.year,
                  nextMonth.month - 1,
                );
              });
            },
            onNext: () {
              setState(() {
                nextMonth = DateTime(
                  nextMonth.year,
                  nextMonth.month + 1,
                );
              });
            },
          ),
          _buildWeekdayLabels(l10n),
          Expanded(
            child: _buildCalendarGrid(month: nextMonth, tt: tt),
          ),
        ],
      ),
    );
  }
}

class _PopupSectionTitle extends StatelessWidget {
  final String text;

  const _PopupSectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleSmall!
            .copyWith(color: Colors.white),
      ),
    );
  }
}

class _PopupItem extends StatelessWidget {
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _PopupItem({
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          '- $title',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: color,
                decoration: TextDecoration.underline,
              ),
        ),
      ),
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String text;
  const _WeekdayLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .bodyMedium!
          .copyWith(color: Colors.white.withValues(alpha: 0.8)),
    );
  }
}
