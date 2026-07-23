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

enum TaskRecurrence { none, daily, weekly, monthly }

extension TaskRecurrenceLabel on TaskRecurrence {
  String get label {
    switch (this) {
      case TaskRecurrence.none:
        return 'ללא חזרה';
      case TaskRecurrence.daily:
        return 'יומי';
      case TaskRecurrence.weekly:
        return 'שבועי';
      case TaskRecurrence.monthly:
        return 'חודשי';
    }
  }

  DateTime nextDueDate(DateTime current) {
    switch (this) {
      case TaskRecurrence.none:
        return current;
      case TaskRecurrence.daily:
        return current.add(const Duration(days: 1));
      case TaskRecurrence.weekly:
        return current.add(const Duration(days: 7));
      case TaskRecurrence.monthly:
        final int nextMonth = current.month == 12 ? 1 : current.month + 1;
        final int nextYear =
            current.month == 12 ? current.year + 1 : current.year;
        final int lastDay = DateTime(nextYear, nextMonth + 1, 0).day;
        final int day = current.day > lastDay ? lastDay : current.day;
        return DateTime(
          nextYear,
          nextMonth,
          day,
          current.hour,
          current.minute,
        );
    }
  }
}

class FamilyTask {
  const FamilyTask({
    required this.id,
    required this.familyId,
    required this.title,
    required this.assigneeId,
    required this.assigneeName,
    required this.priority,
    required this.dueDate,
    required this.hasDueTime,
    required this.recurrence,
    required this.isCompleted,
    required this.completedAt,
    required this.createdAt,
  });

  final String id;
  final String familyId;
  final String title;
  final String assigneeId;
  final String assigneeName;
  final TaskPriority priority;
  final DateTime dueDate;
  final bool hasDueTime;
  final TaskRecurrence recurrence;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;

  bool get isOverdue {
    if (isCompleted) {
      return false;
    }

    final DateTime now = DateTime.now();
    if (hasDueTime) {
      return dueDate.isBefore(now);
    }

    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime due = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
    );
    return due.isBefore(today);
  }

  FamilyTask copyWith({
    String? title,
    String? assigneeId,
    String? assigneeName,
    TaskPriority? priority,
    DateTime? dueDate,
    bool? hasDueTime,
    TaskRecurrence? recurrence,
    bool? isCompleted,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return FamilyTask(
      id: id,
      familyId: familyId,
      title: title ?? this.title,
      assigneeId: assigneeId ?? this.assigneeId,
      assigneeName: assigneeName ?? this.assigneeName,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      hasDueTime: hasDueTime ?? this.hasDueTime,
      recurrence: recurrence ?? this.recurrence,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
      createdAt: createdAt,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'familyId': familyId,
        'title': title,
        'assigneeId': assigneeId,
        'assigneeName': assigneeName,
        'priority': priority.name,
        'dueDate': dueDate.toIso8601String(),
        'hasDueTime': hasDueTime,
        'recurrence': recurrence.name,
        'isCompleted': isCompleted,
        'completedAt': completedAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory FamilyTask.fromJson(Map<String, Object?> json) {
    final String priorityName =
        json['priority'] as String? ?? TaskPriority.medium.name;
    final String recurrenceName =
        json['recurrence'] as String? ?? TaskRecurrence.none.name;

    return FamilyTask(
      id: json['id'] as String? ?? '',
      familyId: json['familyId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      assigneeId: json['assigneeId'] as String? ?? '',
      assigneeName: json['assigneeName'] as String? ?? '',
      priority: TaskPriority.values.firstWhere(
        (TaskPriority value) => value.name == priorityName,
        orElse: () => TaskPriority.medium,
      ),
      dueDate:
          DateTime.tryParse(json['dueDate'] as String? ?? '') ?? DateTime.now(),
      hasDueTime: json['hasDueTime'] as bool? ?? false,
      recurrence: TaskRecurrence.values.firstWhere(
        (TaskRecurrence value) => value.name == recurrenceName,
        orElse: () => TaskRecurrence.none,
      ),
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: DateTime.tryParse(json['completedAt'] as String? ?? ''),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
