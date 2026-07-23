enum CalendarEventType {
  birthday,
  appointment,
  school,
  work,
  car,
  shopping,
  vacation,
  family,
  other,
}

extension CalendarEventTypeDetails on CalendarEventType {
  String get label {
    switch (this) {
      case CalendarEventType.birthday:
        return 'יום הולדת';
      case CalendarEventType.appointment:
        return 'תור';
      case CalendarEventType.school:
        return 'בית ספר';
      case CalendarEventType.work:
        return 'עבודה';
      case CalendarEventType.car:
        return 'רכב';
      case CalendarEventType.shopping:
        return 'קניות';
      case CalendarEventType.vacation:
        return 'חופשה';
      case CalendarEventType.family:
        return 'אירוע משפחתי';
      case CalendarEventType.other:
        return 'אחר';
    }
  }
}

enum CalendarRecurrence { none, daily, weekly, monthly, yearly }

extension CalendarRecurrenceLabel on CalendarRecurrence {
  String get label {
    switch (this) {
      case CalendarRecurrence.none:
        return 'ללא חזרה';
      case CalendarRecurrence.daily:
        return 'יומי';
      case CalendarRecurrence.weekly:
        return 'שבועי';
      case CalendarRecurrence.monthly:
        return 'חודשי';
      case CalendarRecurrence.yearly:
        return 'שנתי';
    }
  }
}

enum CalendarReminder {
  none,
  tenMinutes,
  thirtyMinutes,
  oneHour,
  oneDay,
  oneWeek,
}

extension CalendarReminderLabel on CalendarReminder {
  String get label {
    switch (this) {
      case CalendarReminder.none:
        return 'ללא תזכורת';
      case CalendarReminder.tenMinutes:
        return '10 דקות לפני';
      case CalendarReminder.thirtyMinutes:
        return '30 דקות לפני';
      case CalendarReminder.oneHour:
        return 'שעה לפני';
      case CalendarReminder.oneDay:
        return 'יום לפני';
      case CalendarReminder.oneWeek:
        return 'שבוע לפני';
    }
  }
}

class CalendarEvent {
  const CalendarEvent({
    required this.id,
    required this.familyId,
    required this.title,
    required this.type,
    required this.start,
    required this.end,
    required this.isAllDay,
    required this.location,
    required this.notes,
    required this.participantIds,
    required this.colorValue,
    required this.recurrence,
    required this.recurrenceInterval,
    required this.recurrenceEnd,
    required this.reminder,
    required this.isPrivate,
    required this.createdAt,
  });

  final String id;
  final String familyId;
  final String title;
  final CalendarEventType type;
  final DateTime start;
  final DateTime end;
  final bool isAllDay;
  final String location;
  final String notes;
  final List<String> participantIds;
  final int colorValue;
  final CalendarRecurrence recurrence;
  final int recurrenceInterval;
  final DateTime? recurrenceEnd;
  final CalendarReminder reminder;
  final bool isPrivate;
  final DateTime createdAt;

  CalendarEvent copyWith({
    String? title,
    CalendarEventType? type,
    DateTime? start,
    DateTime? end,
    bool? isAllDay,
    String? location,
    String? notes,
    List<String>? participantIds,
    int? colorValue,
    CalendarRecurrence? recurrence,
    int? recurrenceInterval,
    DateTime? recurrenceEnd,
    bool clearRecurrenceEnd = false,
    CalendarReminder? reminder,
    bool? isPrivate,
  }) {
    return CalendarEvent(
      id: id,
      familyId: familyId,
      title: title ?? this.title,
      type: type ?? this.type,
      start: start ?? this.start,
      end: end ?? this.end,
      isAllDay: isAllDay ?? this.isAllDay,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      participantIds: participantIds ?? this.participantIds,
      colorValue: colorValue ?? this.colorValue,
      recurrence: recurrence ?? this.recurrence,
      recurrenceInterval: recurrenceInterval ?? this.recurrenceInterval,
      recurrenceEnd:
          clearRecurrenceEnd ? null : recurrenceEnd ?? this.recurrenceEnd,
      reminder: reminder ?? this.reminder,
      isPrivate: isPrivate ?? this.isPrivate,
      createdAt: createdAt,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'familyId': familyId,
        'title': title,
        'type': type.name,
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        'isAllDay': isAllDay,
        'location': location,
        'notes': notes,
        'participantIds': participantIds,
        'colorValue': colorValue,
        'recurrence': recurrence.name,
        'recurrenceInterval': recurrenceInterval,
        'recurrenceEnd': recurrenceEnd?.toIso8601String(),
        'reminder': reminder.name,
        'isPrivate': isPrivate,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CalendarEvent.fromJson(Map<String, Object?> json) {
    final String typeName =
        json['type'] as String? ?? CalendarEventType.other.name;
    final String recurrenceName =
        json['recurrence'] as String? ?? CalendarRecurrence.none.name;
    final String reminderName =
        json['reminder'] as String? ?? CalendarReminder.none.name;
    final List<Object?> rawParticipants =
        json['participantIds'] as List<Object?>? ?? <Object?>[];

    return CalendarEvent(
      id: json['id'] as String? ?? '',
      familyId: json['familyId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      type: CalendarEventType.values.firstWhere(
        (CalendarEventType value) => value.name == typeName,
        orElse: () => CalendarEventType.other,
      ),
      start:
          DateTime.tryParse(json['start'] as String? ?? '') ?? DateTime.now(),
      end: DateTime.tryParse(json['end'] as String? ?? '') ?? DateTime.now(),
      isAllDay: json['isAllDay'] as bool? ?? false,
      location: json['location'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      participantIds: rawParticipants.whereType<String>().toList(),
      colorValue: json['colorValue'] as int? ?? 0xFF1256E8,
      recurrence: CalendarRecurrence.values.firstWhere(
        (CalendarRecurrence value) => value.name == recurrenceName,
        orElse: () => CalendarRecurrence.none,
      ),
      recurrenceInterval: json['recurrenceInterval'] as int? ?? 1,
      recurrenceEnd: DateTime.tryParse(json['recurrenceEnd'] as String? ?? ''),
      reminder: CalendarReminder.values.firstWhere(
        (CalendarReminder value) => value.name == reminderName,
        orElse: () => CalendarReminder.none,
      ),
      isPrivate: json['isPrivate'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
