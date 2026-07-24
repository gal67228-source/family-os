class NotificationSettings {
  const NotificationSettings({
    required this.enabled,
    required this.eventReminders,
    required this.taskReminders,
    required this.shoppingReminders,
    required this.dailySummary,
    required this.dailySummaryHour,
    required this.dailySummaryMinute,
  });

  const NotificationSettings.defaults()
      : enabled = true,
        eventReminders = true,
        taskReminders = true,
        shoppingReminders = true,
        dailySummary = true,
        dailySummaryHour = 8,
        dailySummaryMinute = 0;

  final bool enabled;
  final bool eventReminders;
  final bool taskReminders;
  final bool shoppingReminders;
  final bool dailySummary;
  final int dailySummaryHour;
  final int dailySummaryMinute;

  NotificationSettings copyWith({
    bool? enabled,
    bool? eventReminders,
    bool? taskReminders,
    bool? shoppingReminders,
    bool? dailySummary,
    int? dailySummaryHour,
    int? dailySummaryMinute,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      eventReminders: eventReminders ?? this.eventReminders,
      taskReminders: taskReminders ?? this.taskReminders,
      shoppingReminders: shoppingReminders ?? this.shoppingReminders,
      dailySummary: dailySummary ?? this.dailySummary,
      dailySummaryHour: dailySummaryHour ?? this.dailySummaryHour,
      dailySummaryMinute: dailySummaryMinute ?? this.dailySummaryMinute,
    );
  }
}
