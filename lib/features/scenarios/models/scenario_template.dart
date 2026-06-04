class ScenarioTemplate {
  final String id;
  final String name;
  final String description;
  final List<GoalTemplate> goals;
  final List<String> habits;
  final List<String> tasks;

  const ScenarioTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.goals,
    required this.habits,
    required this.tasks,
  });

  ScenarioTemplate copyWith({
    String? id,
    String? name,
    String? description,
    List<GoalTemplate>? goals,
    List<String>? habits,
    List<String>? tasks,
  }) {
    return ScenarioTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      goals: goals ?? this.goals,
      habits: habits ?? this.habits,
      tasks: tasks ?? this.tasks,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'goals': goals.map((goal) => goal.toJson()).toList(),
      'habits': habits,
      'tasks': tasks,
    };
  }

  factory ScenarioTemplate.fromJson(Map<String, dynamic> json) {
    return ScenarioTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      goals: ((json['goals'] as List?) ?? [])
          .map((goal) => GoalTemplate.fromJson(
                Map<String, dynamic>.from(goal as Map),
              ))
          .toList(),
      habits: ((json['habits'] as List?) ?? [])
          .map((habit) => habit.toString())
          .toList(),
      tasks: ((json['tasks'] as List?) ?? [])
          .map((task) => task.toString())
          .toList(),
    );
  }
}

class GoalTemplate {
  final String title;
  final int deadlineDaysFromNow;
  final List<String> subtasks;

  const GoalTemplate({
    required this.title,
    required this.deadlineDaysFromNow,
    required this.subtasks,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'deadlineDaysFromNow': deadlineDaysFromNow,
      'subtasks': subtasks,
    };
  }

  factory GoalTemplate.fromJson(Map<String, dynamic> json) {
    return GoalTemplate(
      title: json['title'] as String,
      deadlineDaysFromNow: json['deadlineDaysFromNow'] as int? ?? 30,
      subtasks: ((json['subtasks'] as List?) ?? [])
          .map((subtask) => subtask.toString())
          .toList(),
    );
  }
}
