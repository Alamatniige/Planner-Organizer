class Task {
  final String id;
  final String userId;
  final String description;
  final String dueDate;
  final String? dueTime;
  final String priority;

  Task({
    required this.id,
    required this.userId,
    required this.description,
    required this.dueDate,
    this.dueTime,
    required this.priority,
  });

  // Factory method to create Task from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      description: json['description'] ?? 'No Description',
      dueDate: json['due_date'] ?? '',
      dueTime: json['due_time'],
      priority: json['priority'] ?? 'Low',
    );
  }

  // Convert Task to JSON for database insertion
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'description': description,
      'due_date': dueDate,
      'due_time': dueTime,
      'priority': priority,
    };
  }
}
