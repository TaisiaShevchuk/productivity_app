import 'package:flutter/material.dart';
import '../../../data/database_helper.dart';
import '../models/habit.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/widgets/linked_note_field.dart';

class EditHabitScreen extends StatefulWidget {
  final Habit habit;

  const EditHabitScreen({super.key, required this.habit});

  @override
  State<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  late TextEditingController controller;
  int? noteId;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.habit.title);
    noteId = widget.habit.noteId;
  }

  Future<void> _save() async {
    final newTitle = controller.text.trim();
    if (newTitle.isEmpty) return;

    final updated = Habit(
      id: widget.habit.id,
      title: newTitle,
      days: widget.habit.days,
      lastReset: widget.habit.lastReset,
      noteId: noteId,
    );

    await DatabaseHelper.instance.updateHabit(updated);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editHabit),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _save,
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: controller,
            style: tt.titleMedium,
            decoration: InputDecoration(
              labelText: l10n.habitName,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          LinkedNoteField(
            noteId: noteId,
            onChanged: (value) => setState(() => noteId = value),
          ),
        ],
      ),
    );
  }
}
