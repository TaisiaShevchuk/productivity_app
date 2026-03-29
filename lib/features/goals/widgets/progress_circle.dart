import 'package:flutter/material.dart';

class ProgressCircle extends StatelessWidget {
  final int progress; // 0–100
  final double size;

  const ProgressCircle({
    super.key,
    required this.progress,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = progress >= 100;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // --- ФОНОВЫЙ КРУГ ---
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 6,
              valueColor: AlwaysStoppedAnimation(
                Colors.grey.withOpacity(0.2),
              ),
            ),
          ),

          // --- АКТИВНЫЙ ПРОГРЕСС ---
          SizedBox(
            width: size,
            height: size,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress / 100),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              builder: (_, value, __) {
                return CircularProgressIndicator(
                  value: value,
                  strokeWidth: 6,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation(
                    isDone
                        ? Colors.green
                        : Theme.of(context).colorScheme.primary,
                  ),
                );
              },
            ),
          ),

          // --- ИКОНКА В ЦЕНТРЕ ---
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: isDone
                ? Icon(
              Icons.check,
              key: const ValueKey("done"),
              color: Colors.green,
              size: size * 0.55,
            )
                : Text(
              "$progress%",
              key: const ValueKey("progress"),
              style: TextStyle(
                fontSize: size * 0.32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
