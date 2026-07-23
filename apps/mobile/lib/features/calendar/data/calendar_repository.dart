import '../domain/calendar_event.dart';

abstract interface class CalendarRepository {
  Future<List<CalendarEvent>> loadEvents();
  Future<void> saveEvents(List<CalendarEvent> events);
}
