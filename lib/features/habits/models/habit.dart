class Habit {
  final int? id;
  final String title;
  List<int> days;
  int lastReset;

  Habit({
    this.id,
    required this.title,
    required this.days,
    required this.lastReset,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'days': days.join(','),
      'lastReset': lastReset,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    final raw = map['days'];

    List<int> parsedDays;

    if (raw == null || raw.toString().isEmpty) {
      parsedDays = [0, 0, 0, 0, 0, 0, 0];
    } else if (raw is String) {
      parsedDays = raw
          .split(',')
          .map((e) => int.tryParse(e) ?? 0)
          .toList();
    } else {
      parsedDays = [0, 0, 0, 0, 0, 0, 0];
    }

    return Habit(
      id: map['id'],
      title: map['title'],
      days: parsedDays,
      lastReset: map['lastReset'] ?? 0,
    );
  }
}
