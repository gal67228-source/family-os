enum TaskPriority { low, medium, high }

extension TaskPriorityLabel on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'נמוכה';
      case TaskPriority.medium:
        return 'בינונית';
      case TaskPriority.high:
        return 'גבוהה';
    }
  }
}

class FamilyTask {
  const FamilyTask({
    required this.id,
    required this.familyId,
    required this.title,
    required this.assigneeName,
    required this.priority,
    required this.dueDate,
    required this.isCompleted,
    required this.createdAt,
  });

  final String id;
  final String familyId;
  final String title;
  final String assigneeName;
  final TaskPriority priority;
  final DateTime dueDate;
  final bool isCompleted;
  final DateTime createdAt;

  bool get isOverdue {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return !isCompleted && due.isBefore(today);
  }

  FamilyTask copyWith({bool? isCompleted}) {
    return FamilyTask(
      id: id,
      familyId: familyId,
      title: title,
      assigneeName: assigneeName,
      priority: priority,
      dueDate: dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'familyId': familyId,
        'title': title,
        'assigneeName': assigneeName,
        'priority': priority.name,
        'dueDate': dueDate.toIso8601String(),
        'isCompleted': isCompleted,
        'createdAt': createdAt.toIso8601String(),
      };

  factory FamilyTask.fromJson(Map<String, Object?> json) {
    final String priorityName =
        json['priority'] as String? ?? TaskPriority.medium.name;
    return FamilyTask(
      id: json['id'] as String? ?? '',
      familyId: json['familyId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      assigneeName: json['assigneeName'] as String? ?? '',
      priority: TaskPriority.values.firstWhere(
        (TaskPriority value) => value.name == priorityName,
        orElse: () => TaskPriority.medium,
      ),
      dueDate:
          DateTime.tryParse(json['dueDate'] as String? ?? '') ?? DateTime.now(),
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
