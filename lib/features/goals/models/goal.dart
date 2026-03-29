import 'dart:convert';

class Goal {
  final int? id;
  final String title;

  // старое поле — оставляем для совместимости
  final bool isDone;

  // прогресс выполнения (0–100)
  final int progress;

  // дата создания (timestamp)
  final int createdAt;

  // дедлайн (timestamp, может быть null)
  final int? deadline;

  // список подзадач
  final List<Subtask> subtasks;

  Goal({
    this.id,
    required this.title,
    required this.isDone,
    required this.progress,
    required this.createdAt,
    this.deadline,
    required this.subtasks,
  });

  /// Удобный метод пересчёта прогресса
  int calculateProgress() {
    if (subtasks.isEmpty) return 0;
    final done = subtasks.where((s) => s.isDone).length;
    return ((done / subtasks.length) * 100).round();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone ? 1 : 0,
      'progress': progress,
      'createdAt': createdAt,
      'deadline': deadline,
      'subtasks': jsonEncode(subtasks.map((e) => e.toMap()).toList()),
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      title: map['title'],
      isDone: map['isDone'] == 1,

      // если старые записи в базе — progress может отсутствовать
      progress: map['progress'] ?? 0,

      createdAt: map['createdAt'] ??
          DateTime.now().millisecondsSinceEpoch,

      deadline: map['deadline'],

      subtasks: map['subtasks'] != null
          ? (jsonDecode(map['subtasks']) as List)
          .map((e) => Subtask.fromMap(e))
          .toList()
          : [],
    );
  }
}

class Subtask {
  final String title;
  final bool isDone;

  Subtask({
    required this.title,
    required this.isDone,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'isDone': isDone ? 1 : 0,
  };

  factory Subtask.fromMap(Map<String, dynamic> map) => Subtask(
    title: map['title'],
    isDone: map['isDone'] == 1,
  );
}
