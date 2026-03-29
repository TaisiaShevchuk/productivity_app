import 'package:flutter/material.dart';
import '../../../data/database_helper.dart';
import '../widgets/progress_circle.dart';
import '../models/goal.dart';
import '../../trash/ui/confirm_delete.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onTap;     // открыть редактирование
  final VoidCallback onDelete;  // обновить список после удаления

  const GoalCard({
    super.key,
    required this.goal,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final iconColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.6);

    final doneCount = goal.subtasks.where((s) => s.isDone).length;
    final totalCount = goal.subtasks.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          // --- ПРОГРЕСС ---
          ProgressCircle(
            progress: goal.progress,
            size: 52,
          ),

          const SizedBox(width: 16),

          // --- ТЕКСТ ---
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(goal.title, style: tt.titleMedium),

                  const SizedBox(height: 4),

                  if (goal.deadline != null)
                    Text(
                      "Deadline: ${_formatDate(goal.deadline!)}",
                      style: tt.bodySmall,
                    ),

                  if (totalCount > 0)
                    Text(
                      "$doneCount of $totalCount",
                      style: tt.bodySmall,
                    ),
                ],
              ),
            ),
          ),

          // --- КНОПКИ ДЕЙСТВИЙ ---
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: iconColor),
                onPressed: onTap,
                tooltip: "Edit",
              ),
              IconButton(
                icon: Icon(Icons.delete, color: iconColor),
                onPressed: () async {
                  final confirm = await showConfirmDelete(context);
                  if (!confirm) return;

                  await DatabaseHelper.instance.deleteItem(
                    "goal",
                    goal.id!,
                    goal.toMap(),
                  );

                  onDelete(); // обновляем список
                },
              ),
            ],
          ),
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
