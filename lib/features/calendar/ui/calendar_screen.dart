import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime currentMonth = DateTime.now();

  List<DateTime> _generateDaysForMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    final daysBefore = (firstDay.weekday + 6) % 7; // Monday = 0
    final daysAfter = 6 - ((lastDay.weekday + 6) % 7);

    final totalDays = daysBefore + lastDay.day + daysAfter;

    return List.generate(totalDays, (index) {
      return DateTime(
        month.year,
        month.month,
        index - daysBefore + 1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final days = _generateDaysForMonth(currentMonth);

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
          title: Text(
            DateFormat.yMMMM().format(currentMonth),
            style: tt.titleLarge,
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                currentMonth = DateTime(
                  currentMonth.year,
                  currentMonth.month - 1,
                );
              });
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                setState(() {
                  currentMonth = DateTime(
                    currentMonth.year,
                    currentMonth.month + 1,
                  );
                });
              },
            ),
          ],
        ),

        body: Column(
          children: [
            // WEEKDAY LABELS
            Padding(
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
            ),

            // CALENDAR GRID
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: days.length,
                itemBuilder: (context, index) {
                  final day = days[index];
                  final isCurrentMonth = day.month == currentMonth.month;

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
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
                      "${day.day}",
                      style: tt.bodyMedium!.copyWith(
                        color: isCurrentMonth
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
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
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: Colors.white.withValues(alpha: 0.8),
      ),
    );
  }
}
