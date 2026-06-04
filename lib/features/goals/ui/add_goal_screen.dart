import 'package:flutter/material.dart';
import '../../../data/database_helper.dart';
import '../models/goal.dart';
import '../widgets/progress_circle.dart';
import '../../trash/ui/confirm_delete.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/widgets/linked_note_field.dart';


class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final titleController = TextEditingController();
  final subtaskController = TextEditingController();

  List<Subtask> subtasks = [];
  int? deadline;
  int? noteId;

  int get progress {
    if (subtasks.isEmpty) return 0;
    final done = subtasks.where((s) => s.isDone).length;
    return ((done / subtasks.length) * 100).round();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final current = deadline != null
        ? DateTime.fromMillisecondsSinceEpoch(deadline!)
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

    final value = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    setState(() => deadline = value.millisecondsSinceEpoch);
  }

  void _addSubtask() {
    final text = subtaskController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      subtasks.add(Subtask(title: text, isDone: false));
      subtaskController.clear();
    });
  }

  Future<void> _saveGoal() async {
    final title = titleController.text.trim();
    if (title.isEmpty) return;

    final now = DateTime.now().millisecondsSinceEpoch;

    final goal = Goal(
      title: title,
      isDone: progress == 100,
      progress: progress,
      createdAt: now,
      deadline: deadline,
      noteId: noteId,
      subtasks: subtasks,
    );

    await DatabaseHelper.instance.insertGoal(goal);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final iconColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.6);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.85),
      appBar: AppBar(
        title: Text(l10n.newGoal),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveGoal,
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          //TITLE
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              labelText: l10n.goalTitle,
              border: const OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),

          //PROGRESS
          Center(
            child: ProgressCircle(
              progress: progress,
              size: 80,
            ),
          ),

          const SizedBox(height: 20),

          //DEADLINE
          Row(
            children: [
              Expanded(
                child: Text(
                  deadline == null
                      ? l10n.noDeadlineSelected
                      : "${l10n.deadline}: ${_formatDate(deadline!)}",
                  style: tt.bodyLarge,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.calendar_month),
                onPressed: _pickDeadline,
              ),
              if (deadline != null)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => deadline = null),
                ),
            ],
          ),

          const SizedBox(height: 20),

          LinkedNoteField(
            noteId: noteId,
            onChanged: (value) => setState(() => noteId = value),
          ),

          const SizedBox(height: 20),

          //ADD SUBTASK
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: subtaskController,
                  decoration: InputDecoration(
                    labelText: l10n.newSubtask,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _addSubtask,
                child: Text(l10n.add),
              ),
            ],
          ),

          const SizedBox(height: 20),

          //SUBTASK LIST
          ...subtasks.asMap().entries.map((entry) {
            final index = entry.key;
            final sub = entry.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.surface.withOpacity(0.2),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: sub.isDone,
                    onChanged: (v) {
                      setState(() {
                        subtasks[index] =
                            Subtask(title: sub.title, isDone: v ?? false);
                      });
                    },
                  ),

                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final controller =
                        TextEditingController(text: sub.title);

                        final newTitle = await showDialog<String>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(l10n.editSubtask),
                            content: TextField(
                              controller: controller,
                              decoration: InputDecoration(
                                hintText: l10n.title,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, null),
                                child: Text(l10n.cancel),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(
                                    context, controller.text.trim()),
                                child: Text(l10n.save),
                              ),
                            ],
                          ),
                        );

                        if (newTitle != null && newTitle.isNotEmpty) {
                          setState(() {
                            subtasks[index] = Subtask(
                              title: newTitle,
                              isDone: sub.isDone,
                            );
                          });
                        }
                      },
                      child: Text(sub.title, style: tt.bodyLarge),
                    ),
                  ),

                  IconButton(
                    icon: Icon(Icons.delete, color: iconColor),
                    onPressed: () async {
                      final confirm = await showConfirmDelete(context);
                      if (!confirm) return;

                      setState(() => subtasks.removeAt(index));
                    },

                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatDate(int timestamp) {
    final d = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return "${d.day.toString().padLeft(2, '0')}"
        ".${d.month.toString().padLeft(2, '0')}"
        ".${d.year} "
        "${d.hour.toString().padLeft(2, '0')}:"
        "${d.minute.toString().padLeft(2, '0')}";
  }
}
