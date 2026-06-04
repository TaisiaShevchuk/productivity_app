import 'dart:convert';

class Goal {
  final int? id;
  final String title;
  final bool isDone;
  final int progress;
  final int createdAt;
  final int? deadline;
  final int? noteId;
  final List<Subtask> subtasks;

  Goal({
    this.id,
    required this.title,
    required this.isDone,
    required this.progress,
    required this.createdAt,
    this.deadline,
    this.noteId,
    required this.subtasks,
  });

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
      'noteId': noteId,
      'subtasks': jsonEncode(subtasks.map((e) => e.toMap()).toList()),
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      title: map['title'],
      isDone: map['isDone'] == 1,

      progress: map['progress'] ?? 0,

      createdAt: map['createdAt'] ??
          DateTime.now().millisecondsSinceEpoch,

      deadline: map['deadline'],
      noteId: map['noteId'] as int?,

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
