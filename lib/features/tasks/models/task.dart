class Task {
  final int? id;
  final String title;
  final bool isDone;
  final int? deadline;
  final int? noteId;

  Task({
    this.id,
    required this.title,
    this.isDone = false,
    this.deadline,
    this.noteId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone ? 1 : 0,
      'deadline': deadline,
      'noteId': noteId,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      isDone: map['isDone'] == 1,
      deadline: map['deadline'] as int?,
      noteId: map['noteId'] as int?,
    );
  }
}
