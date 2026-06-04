import 'package:flutter/material.dart';
import '../../../data/database_helper.dart';
import '../models/task.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/widgets/linked_note_field.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController _titleController;
  int? _deadline;
  int? _noteId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _deadline = widget.task.deadline;
    _noteId = widget.task.noteId;
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final current = _deadline != null
        ? DateTime.fromMillisecondsSinceEpoch(_deadline!)
        : now.add(const Duration(hours: 1));
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );

    if (pickedDate == null || !mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (pickedTime == null) return;

    final deadline = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    setState(() => _deadline = deadline.millisecondsSinceEpoch);
  }

  Future<void> _updateTask() async {
    final updatedTask = Task(
      id: widget.task.id,
      title: _titleController.text,
      isDone: widget.task.isDone,
      deadline: _deadline,
      noteId: _noteId,
    );

    await DatabaseHelper.instance.updateTask(updatedTask);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editTask)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: l10n.taskTitle),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _deadline == null
                        ? l10n.noDeadlineSelected
                        : '${l10n.deadline}: ${_formatDate(_deadline!)}',
                    style: tt.bodyLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: _pickDeadline,
                ),
                if (_deadline != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _deadline = null),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            LinkedNoteField(
              noteId: _noteId,
              onChanged: (value) => setState(() => _noteId = value),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateTask,
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(int timestamp) {
    final d = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${d.day.toString().padLeft(2, '0')}'
        '.${d.month.toString().padLeft(2, '0')}'
        '.${d.year} '
        '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }
}
