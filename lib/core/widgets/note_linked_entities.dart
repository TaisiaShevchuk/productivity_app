import 'package:flutter/material.dart';

import '../../data/database_helper.dart';
import '../../features/goals/models/goal.dart';
import '../../features/goals/ui/edit_goal_screen.dart';
import '../../features/habits/models/habit.dart';
import '../../features/habits/ui/edit_habit_screen.dart';
import '../../features/tasks/models/task.dart';
import '../../features/tasks/ui/edit_task_screen.dart';
import '../../l10n/app_localizations.dart';

class NoteLinkedEntities extends StatefulWidget {
  final int noteId;

  const NoteLinkedEntities({
    super.key,
    required this.noteId,
  });

  @override
  State<NoteLinkedEntities> createState() => _NoteLinkedEntitiesState();
}

class _NoteLinkedEntitiesState extends State<NoteLinkedEntities> {
  List<Task> _tasks = [];
  List<Goal> _goals = [];
  List<Habit> _habits = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = await DatabaseHelper.instance.database;
    final taskRows =
        await db.query('tasks', where: 'noteId = ?', whereArgs: [widget.noteId]);
    final goalRows =
        await db.query('goals', where: 'noteId = ?', whereArgs: [widget.noteId]);
    final habitRows = await db
        .query('habits', where: 'noteId = ?', whereArgs: [widget.noteId]);

    if (!mounted) return;
    setState(() {
      _tasks = taskRows.map(Task.fromMap).toList();
      _goals = goalRows.map(Goal.fromMap).toList();
      _habits = habitRows.map(Habit.fromMap).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final links = <Widget>[
      ..._tasks.map((task) => _LinkButton(
            icon: Icons.task_alt,
            title: task.title,
            tooltip: l10n.openLinkedTask,
            onPressed: () => _open(EditTaskScreen(task: task)),
          )),
      ..._goals.map((goal) => _LinkButton(
            icon: Icons.flag_outlined,
            title: goal.title,
            tooltip: l10n.openLinkedGoal,
            onPressed: () => _open(EditGoalScreen(goal: goal)),
          )),
      ..._habits.map((habit) => _LinkButton(
            icon: Icons.repeat,
            title: habit.title,
            tooltip: l10n.openLinkedHabit,
            onPressed: () => _open(EditHabitScreen(habit: habit)),
          )),
    ];

    if (links.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: links,
      ),
    );
  }

  Future<void> _open(Widget screen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
    await _load();
  }
}

class _LinkButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String tooltip;
  final VoidCallback onPressed;

  const _LinkButton({
    required this.icon,
    required this.title,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: ActionChip(
        avatar: Icon(icon, size: 18),
        label: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 220),
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
