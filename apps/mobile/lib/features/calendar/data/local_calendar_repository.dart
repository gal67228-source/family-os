import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/calendar_event.dart';
import 'calendar_repository.dart';

class LocalCalendarRepository implements CalendarRepository {
  static const String _key = 'family_os_calendar_events';

  @override
  Future<List<CalendarEvent>> loadEvents() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return <CalendarEvent>[];
    }
    final Object? decoded = jsonDecode(raw);
    if (decoded is! List<Object?>) {
      return <CalendarEvent>[];
    }
    return decoded
        .whereType<Map<String, Object?>>()
        .map(CalendarEvent.fromJson)
        .toList();
  }

  @override
  Future<void> saveEvents(List<CalendarEvent> events) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(events.map((CalendarEvent event) => event.toJson()).toList()),
    );
  }
}
