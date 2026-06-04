import 'package:flutter/material.dart';
import '../features/habits/models/habit.dart';
import '../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return NavigationRail(
      backgroundColor: Colors.white.withValues(alpha: 0.05),
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelect,
      labelType: NavigationRailLabelType.none,

      destinations: [
        NavigationRailDestination(
          icon: Icon(Icons.calendar_month),
          label: Text(l10n.calendar),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.task_alt),
          label: Text(l10n.tasksForToday),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.repeat),
          label: Text(l10n.habits),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.flag),
          label: Text(l10n.goals),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.note_alt),
          label: Text(l10n.notes),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.auto_awesome),
          label: Text(l10n.scenarios),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.psychology_alt),
          label: Text(l10n.assistant),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.bar_chart),
          label: Text(l10n.stats),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings),
          label: Text(l10n.settings),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.delete_outline),
          label: Text(l10n.trash),
        ),
      ],
    );
  }
}
