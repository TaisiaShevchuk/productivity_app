import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../goals/data/goals_repository.dart';
import '../../goals/models/goal.dart';
import '../../goals/ui/edit_goal_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime currentMonth = DateTime.now();
  DateTime nextMonth = DateTime(DateTime.now().year, DateTime.now().month + 1);

  List<DateTime> goalDeadlines = [];
  List<Goal> allGoals = [];

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final goals = await GoalsRepository().getGoals();

    allGoals = goals;

    goalDeadlines = goals
        .where((g) => g.deadline != null)
        .map((g) => DateTime.fromMillisecondsSinceEpoch(g.deadline!))
        .toList();

    setState(() {});
  }

  bool hasGoal(DateTime day) {
    return goalDeadlines.any(
          (d) =>
      d.year == day.year &&
          d.month == day.month &&
          d.day == day.day,
    );
  }

  List<Goal> goalsForDay(DateTime day) {
    return allGoals.where((g) {
      if (g.deadline == null) return false;
      final d = DateTime.fromMillisecondsSinceEpoch(g.deadline!);
      return d.year == day.year && d.month == day.month && d.day == day.day;
    }).toList();
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

  Widget _buildWeekdayLabels(TextTheme tt) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          _WeekdayLabel("Mon"),
          _WeekdayLabel("Tue"),
          _WeekdayLabel("Wed"),
          _WeekdayLabel("Thu"),
          _WeekdayLabel("Fri"),
          _WeekdayLabel("Sat"),
          _WeekdayLabel("Sun"),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader({
    required DateTime month,
    required VoidCallback onPrev,
    required VoidCallback onNext,
    required TextTheme tt,
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
            DateFormat.yMMMM().format(month),
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

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2E385A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          "${day.day} ${DateFormat.MMMM().format(day)}",
          style: tt.titleMedium!.copyWith(color: Colors.white),
        ),
        content: todayGoals.isEmpty
            ? Text(
          "No goals",
          style: tt.bodyLarge!.copyWith(color: Colors.white70),
        )
            : Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: todayGoals.map((goal) {
            return GestureDetector(
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditGoalScreen(goal: goal),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  "• ${goal.title}",
                  style: tt.bodyLarge!.copyWith(
                    color: Colors.orangeAccent,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Close",
              style: TextStyle(color: Colors.white),
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

        final isToday =
            day.year == today.year &&
                day.month == today.month &&
                day.day == today.day;

        return GestureDetector(
          onTap: () => _showDayPopup(context, day, tt),
          child: Container(
            decoration: BoxDecoration(
              color: (!isToday && hasGoal(day))
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

            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                "${day.day}",
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
          ),
        );
      },
    );
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

      child: Column(
        children: [
          _buildCalendarHeader(
            month: currentMonth,
            tt: tt,
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
          _buildWeekdayLabels(tt),
          Expanded(
            child: _buildCalendarGrid(
              month: currentMonth,
              tt: tt,
            ),
          ),

          _buildCalendarHeader(
            month: nextMonth,
            tt: tt,
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
          _buildWeekdayLabels(tt),
          Expanded(
            child: _buildCalendarGrid(
              month: nextMonth,
              tt: tt,
            ),
          ),
        ],
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
