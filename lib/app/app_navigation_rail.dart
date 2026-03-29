import 'package:flutter/material.dart';
import '../features/habits/models/habit.dart';
import '../features/stats/stats_screen.dart';

class AppNavigationRail extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onSelect;
  final List<Habit> habits;

  const AppNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    required this.habits,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      backgroundColor: Colors.white.withValues(alpha: 0.05),
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelect,
      labelType: NavigationRailLabelType.none,

      // 🔥 СТАТИСТИКА СВЕРХУ
      leading: Column(
        children: [
          const SizedBox(height: 12),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: "Statistics",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StatisticsScreen(habits: habits),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),

      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.note_alt),
          label: Text('Notes'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.task_alt),
          label: Text('Task'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.repeat),
          label: Text('Habits'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.flag),
          label: Text('Goals'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.calendar_month),
          label: Text('Calendar'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings),
          label: Text('Settings'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.delete_outline),
          label: Text('Trash'),
        ),
      ],
    );
  }
}
