import 'package:flutter/material.dart';
import '../../../data/database_helper.dart';
import '../models/habit.dart';
import 'widgets/habit_card.dart';
import 'edit_habit_screen.dart';
import 'add_habit_screen.dart';
import '../../trash/ui/confirm_delete.dart';
import '../../../l10n/app_localizations.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  List<Habit> habits = [];

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final data = await DatabaseHelper.instance.getHabits();
    setState(() => habits = data);
  }

  Future<void> _addHabit() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddHabitScreen()),
    );

    if (created == true) _loadHabits();
  }

  Future<void> _deleteHabit(Habit habit) async {
    final confirm = await showConfirmDelete(context);
    if (!confirm) return;

    await DatabaseHelper.instance.deleteItem("habit", habit.id!, habit.toMap());

    _loadHabits();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,

      floatingActionButton: FloatingActionButton(
        onPressed: _addHabit,
        child: const Icon(Icons.add),
      ),

      body: habits.isEmpty
          ? Center(child: Text(l10n.noHabits, style: tt.bodyLarge))
          : ReorderableListView(
              buildDefaultDragHandles: false,
              padding: const EdgeInsets.only(bottom: 80),
              onReorder: (oldIndex, newIndex) async {
                if (newIndex > oldIndex) newIndex--;

                final item = habits.removeAt(oldIndex);
                habits.insert(newIndex, item);

                setState(() {});
              },
              children: [
                for (final habit in habits)
                  HabitCard(
                    key: ValueKey(habit.id),
                    title: habit.title,
                    days: habit.days,
                    noteId: habit.noteId,
                    dragHandle: ReorderableDragStartListener(
                      index: habits.indexOf(habit),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.drag_handle, size: 20),
                      ),
                    ),
                    onToggle: (dayIndex) async {
                      final updatedDays = List<int>.generate(
                        7,
                        (index) =>
                            index < habit.days.length ? habit.days[index] : 0,
                      );
                      updatedDays[dayIndex] = updatedDays[dayIndex] == 1
                          ? 0
                          : 1;

                      await DatabaseHelper.instance.updateHabit(
                        Habit(
                          id: habit.id,
                          title: habit.title,
                          days: updatedDays,
                          lastReset: habit.lastReset,
                          noteId: habit.noteId,
                        ),
                      );

                      _loadHabits();
                    },
                    onEdit: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditHabitScreen(habit: habit),
                        ),
                      ).then((_) => _loadHabits());
                    },
                    onDelete: () => _deleteHabit(habit),
                  ),
              ],
            ),
    );
  }
}
