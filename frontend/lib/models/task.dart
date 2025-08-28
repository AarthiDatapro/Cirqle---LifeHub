enum Priority {
  high,
  medium,
  low,
}

class Task {
  final String id;
  final String title;
  final String? description;
  final String? notes; // Added notes field
  final DateTime? dueDate;
  final bool completed;
  final Priority priority; // Changed to enum
  final String? userId;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.notes,
    this.dueDate,
    this.completed = false,
    this.priority = Priority.medium,
    this.userId,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      notes: json['notes'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      completed: json['completed'] ?? false,
      priority: Priority.values.firstWhere(
        (e) => e.name == (json['priority'] ?? 'medium'),
        orElse: () => Priority.medium,
      ),
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'notes': notes,
      'dueDate': dueDate?.toIso8601String(),
      'completed': completed,
      'priority': priority.name,
      'userId': userId,
    };
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? notes,
    DateTime? dueDate,
    bool? completed,
    Priority? priority,
    String? userId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      dueDate: dueDate ?? this.dueDate,
      completed: completed ?? this.completed,
      priority: priority ?? this.priority,
      userId: userId ?? this.userId,
    );
  }
}
