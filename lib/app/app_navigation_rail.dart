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
      onDestinationSelected: (index) {

        if (index == 5) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StatisticsScreen(habits: habits),
            ),
          );
          return;
        }

        onSelect(index);
      },
      labelType: NavigationRailLabelType.none,

      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.calendar_month),
          label: Text('Calendar'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.task_alt),
          label: Text('Tasks for Today'),
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
          icon: Icon(Icons.note_alt),
          label: Text('Notes'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.bar_chart),
          label: Text('Stats'),
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
