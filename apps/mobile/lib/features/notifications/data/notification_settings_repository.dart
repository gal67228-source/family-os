import 'package:shared_preferences/shared_preferences.dart';

import '../domain/notification_settings.dart';

class NotificationSettingsRepository {
  static const String _enabled = 'notifications_enabled';
  static const String _events = 'notifications_events';
  static const String _tasks = 'notifications_tasks';
  static const String _shopping = 'notifications_shopping';
  static const String _daily = 'notifications_daily';
  static const String _dailyHour = 'notifications_daily_hour';
  static const String _dailyMinute = 'notifications_daily_minute';

  Future<NotificationSettings> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return NotificationSettings(
      enabled: prefs.getBool(_enabled) ?? true,
      eventReminders: prefs.getBool(_events) ?? true,
      taskReminders: prefs.getBool(_tasks) ?? true,
      shoppingReminders: prefs.getBool(_shopping) ?? true,
      dailySummary: prefs.getBool(_daily) ?? true,
      dailySummaryHour: prefs.getInt(_dailyHour) ?? 8,
      dailySummaryMinute: prefs.getInt(_dailyMinute) ?? 0,
    );
  }

  Future<void> save(NotificationSettings settings) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await Future.wait(<Future<bool>>[
      prefs.setBool(_enabled, settings.enabled),
      prefs.setBool(_events, settings.eventReminders),
      prefs.setBool(_tasks, settings.taskReminders),
      prefs.setBool(_shopping, settings.shoppingReminders),
      prefs.setBool(_daily, settings.dailySummary),
      prefs.setInt(_dailyHour, settings.dailySummaryHour),
      prefs.setInt(_dailyMinute, settings.dailySummaryMinute),
    ]);
  }
}
