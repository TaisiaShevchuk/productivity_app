import 'package:flutter/material.dart';
import '../../../data/database_helper.dart';
import '../models/habit.dart';

class EditHabitScreen extends StatefulWidget {
  final Habit habit;

  const EditHabitScreen({super.key, required this.habit});

  @override
  State<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.habit.title);
  }

  Future<void> _save() async {
    final newTitle = controller.text.trim();
    if (newTitle.isEmpty) return;

    final updated = Habit(
      id: widget.habit.id,
      title: newTitle,
      days: widget.habit.days,
      lastReset: widget.habit.lastReset,
    );

    await DatabaseHelper.instance.updateHabit(updated);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Редактировать привычку"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _save,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: controller,
          style: tt.titleMedium,
          decoration: const InputDecoration(
            labelText: "Название привычки",
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}
