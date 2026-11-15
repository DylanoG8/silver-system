/// A single task.
class Todo {
  Todo({
    required this.id,
    required this.title,
    this.notes = '',
    this.isDone = false,
    DateTime? createdAt,
    this.dueDate,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String title;
  final String notes;
  final bool isDone;
  final DateTime createdAt;
  final DateTime? dueDate;

  /// True when the task is unfinished and its due date is before today.
  bool get isOverdue {
    if (isDone || dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return dueDate!.isBefore(today);
  }

  Todo copyWith({
    String? title,
    String? notes,
    bool? isDone,
    DateTime? dueDate,
    bool clearDueDate = false,
  }) {
    return Todo(
      id: id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'notes': notes,
    'isDone': isDone,
    'createdAt': createdAt.toIso8601String(),
    'dueDate': dueDate?.toIso8601String(),
  };

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as String,
      title: json['title'] as String,
      notes: (json['notes'] as String?) ?? '',
      isDone: (json['isDone'] as bool?) ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.tryParse(json['dueDate'] as String),
    );
  }
}
