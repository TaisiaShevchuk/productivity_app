import 'package:flutter/material.dart';
import '../../../data/database_helper.dart';
import '../models/task.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/widgets/linked_note_field.dart';
import '../../../core/theme/app_theme.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  int? _deadline;
  int? _noteId;

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline != null
          ? DateTime.fromMillisecondsSinceEpoch(_deadline!)
          : now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );

    if (picked == null) return;
    setState(() => _deadline = picked.millisecondsSinceEpoch);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: AppTheme.pageDecoration(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          title: Text(l10n.addTask, style: tt.titleLarge),
        ),

        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                style: tt.bodyLarge,
                decoration: InputDecoration(
                  hintText: l10n.taskTitleHint,
                ),
              ),

              const SizedBox(height: 30),

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

              const SizedBox(height: 30),

              LinkedNoteField(
                noteId: _noteId,
                onChanged: (value) => setState(() => _noteId = value),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final title = _titleController.text.trim();
                    if (title.isEmpty) return;

                    final task = Task(
                      title: title,
                      isDone: false,
                      deadline: _deadline,
                      noteId: _noteId,
                    );

                    await DatabaseHelper.instance.insertTask(task);

                    if (!mounted) return;
                    Navigator.pop(context, true);
                  },
                  child: Text(l10n.save),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(int timestamp) {
    final d = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${d.day.toString().padLeft(2, '0')}'
        '.${d.month.toString().padLeft(2, '0')}'
        '.${d.year}';
  }
}
