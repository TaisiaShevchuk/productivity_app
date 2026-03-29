import 'package:flutter/material.dart';
import '../../../data/database_helper.dart';
import '../models/habit.dart';
import 'widgets/habit_card.dart';
import 'edit_habit_screen.dart';
import '../../trash/ui/confirm_delete.dart';

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
    final controller = TextEditingController();

    final title = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("New habit"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Habit name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text("Add"),
          ),
        ],
      ),
    );

    if (title != null && title.trim().isNotEmpty) {
      await DatabaseHelper.instance.insertHabit(
        Habit(
          title: title.trim(),
          days: [0, 0, 0, 0, 0, 0, 0],
          lastReset: DateTime.now().millisecondsSinceEpoch,
        ),
      );
      _loadHabits();
    }
  }

  Future<void> _deleteHabit(Habit habit) async {
    final confirm = await showConfirmDelete(context);
    if (!confirm) return;

    await DatabaseHelper.instance.deleteItem(
      "habit",
      habit.id!,
      habit.toMap(),
    );

    _loadHabits();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,

      floatingActionButton: FloatingActionButton(
        onPressed: _addHabit,
        child: const Icon(Icons.add),
      ),

      body: habits.isEmpty
          ? Center(
        child: Text(
          "No habits yet",
          style: tt.bodyLarge,
        ),
      )
          : ReorderableListView(
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
              onToggle: (dayIndex) async {
                final updatedDays = [...habit.days];
                updatedDays[dayIndex] =
                updatedDays[dayIndex] == 1 ? 0 : 1;

                await DatabaseHelper.instance.updateHabit(
                  Habit(
                    id: habit.id,
                    title: habit.title,
                    days: updatedDays,
                    lastReset: habit.lastReset,
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
