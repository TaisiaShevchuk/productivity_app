import 'package:flutter/material.dart';

class HabitCard extends StatelessWidget {
  final String title;
  final List<int> days;
  final void Function(int index) onToggle;

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const HabitCard({
    super.key,
    required this.title,
    required this.days,
    required this.onToggle,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    //TODAY
    final todayIndex = (DateTime.now().weekday - 1) % 7;

    //Execution statistics
    final completed = days.where((d) => d == 1).length;
    final percent = completed / 7;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: tt.titleMedium),

              Row(
                children: [
                  if (onEdit != null)
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: onEdit,
                    ),

                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: onDelete,
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            "Progress: $completed / 7",
            style: tt.bodySmall!.copyWith(color: Colors.white70),
          ),

          const SizedBox(height: 6),

          LinearProgressIndicator(
            value: percent,
            backgroundColor: Colors.white12,
            color: Colors.green,
            minHeight: 6,
            borderRadius: BorderRadius.circular(4),
          ),

          const SizedBox(height: 16),

          //Days of the week
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (i) {
              final done = days[i] == 1;
              final isToday = i == todayIndex;

              return GestureDetector(
                onTap: () => onToggle(i),
                child: Column(
                  children: [
                    Text(
                      labels[i],
                      style: tt.bodySmall!.copyWith(
                        color: isToday ? Colors.blueAccent : Colors.white,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),

                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      width: done ? 32 : 28,
                      height: done ? 32 : 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done ? Colors.green : Colors.transparent,
                        border: Border.all(
                          color: done
                              ? Colors.green
                              : isToday
                              ? Colors.blueAccent
                              : cs.secondary,
                          width: isToday ? 3 : 2,
                        ),
                      ),
                      child: done
                          ? const Icon(Icons.check, size: 18, color: Colors.white)
                          : null,
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
