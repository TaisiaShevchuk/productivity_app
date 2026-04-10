import 'package:flutter/material.dart';
import '../../../data/database_helper.dart';
import '../models/goal.dart';
import '../widgets/progress_circle.dart';
import '../../trash/ui/confirm_delete.dart';


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

  int get progress {
    if (subtasks.isEmpty) return 0;
    final done = subtasks.where((s) => s.isDone).length;
    return ((done / subtasks.length) * 100).round();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );

    if (!mounted) return;
    if (picked != null) {
      setState(() => deadline = picked.millisecondsSinceEpoch);
    }
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
      subtasks: subtasks,
    );

    await DatabaseHelper.instance.insertGoal(goal);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final iconColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.6);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.85),
      appBar: AppBar(
        title: const Text("New Goal"),
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
            decoration: const InputDecoration(
              labelText: "Goal title",
              border: OutlineInputBorder(),
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
                      ? "No deadline selected"
                      : "Deadline: ${_formatDate(deadline!)}",
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

          //ADD SUBTASK
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: subtaskController,
                  decoration: const InputDecoration(
                    labelText: "New subtask",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _addSubtask,
                child: const Text("Add"),
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
                            title: const Text("Edit subtask"),
                            content: TextField(
                              controller: controller,
                              decoration: const InputDecoration(
                                hintText: "Title",
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, null),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(
                                    context, controller.text.trim()),
                                child: const Text("Save"),
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
        ".${d.year}";
  }
}
