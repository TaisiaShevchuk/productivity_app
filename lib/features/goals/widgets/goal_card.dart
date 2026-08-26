import 'package:flutter/material.dart';
import '../widgets/progress_circle.dart';
import '../models/goal.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/widgets/linked_note_field.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const GoalCard({
    super.key,
    required this.goal,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
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
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //PROGRESS
                ProgressCircle(progress: goal.progress, size: 52),

                const SizedBox(width: 12),

                //TEXT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: tt.titleMedium,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      if (goal.deadline != null)
                        Text(
                          '${_formatDeadlineDate(goal.deadline!)}  '
                          '${_formatDeadlineTime(goal.deadline!)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tt.bodySmall,
                        ),

                      if (totalCount > 0)
                        Text(
                          "$doneCount ${l10n.outOf} $totalCount",
                          style: tt.bodySmall,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          //ACTION BUTTONS
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinkedNoteIconButton(noteId: goal.noteId),
                IconButton(
                  icon: Icon(Icons.edit, color: iconColor),
                  onPressed: onTap,
                  tooltip: l10n.edit,
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: iconColor),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDeadlineDate(int timestamp) {
    final d = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return "${d.day.toString().padLeft(2, '0')}"
        ".${d.month.toString().padLeft(2, '0')}";
  }

  String _formatDeadlineTime(int timestamp) {
    final d = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return "${d.hour.toString().padLeft(2, '0')}:"
        "${d.minute.toString().padLeft(2, '0')}";
  }
}
