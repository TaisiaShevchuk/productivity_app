import 'package:flutter/material.dart';

import '../../../core/widgets/linked_note_field.dart';
import '../../../data/database_helper.dart';
import '../../../l10n/app_localizations.dart';
import '../models/habit.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final TextEditingController _titleController = TextEditingController();
  int? _noteId;

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    await DatabaseHelper.instance.insertHabit(
      Habit(
        title: title,
        days: [0, 0, 0, 0, 0, 0, 0],
        lastReset: DateTime.now().millisecondsSinceEpoch,
        noteId: _noteId,
      ),
    );

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.newHabit),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _save),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: l10n.habitName,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          LinkedNoteField(
            noteId: _noteId,
            onChanged: (value) => setState(() => _noteId = value),
          ),
        ],
      ),
    );
  }
}
