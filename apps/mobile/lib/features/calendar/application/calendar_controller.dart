import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../families/application/family_controller.dart';
import '../data/calendar_repository.dart';
import '../data/local_calendar_repository.dart';
import '../domain/calendar_event.dart';

class CalendarState {
  const CalendarState({
    this.events = const <CalendarEvent>[],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<CalendarEvent> events;
  final bool isLoading;
  final String? errorMessage;
}

class CalendarController extends StateNotifier<CalendarState> {
  CalendarController(this._repository) : super(const CalendarState()) {
    load();
  }

  final CalendarRepository _repository;

  Future<void> load() async {
    state = const CalendarState(isLoading: true);
    try {
      state = CalendarState(events: await _repository.loadEvents());
    } catch (_) {
      state = const CalendarState(
        errorMessage: 'לא הצלחנו לטעון את היומן.',
      );
    }
  }

  Future<bool> addEvent({
    required String familyId,
    required String title,
    required CalendarEventType type,
    required DateTime start,
    required DateTime end,
    required bool isAllDay,
    required String location,
    required String notes,
    required List<String> participantIds,
    required int colorValue,
    required CalendarRecurrence recurrence,
    required int recurrenceInterval,
    required DateTime? recurrenceEnd,
    required CalendarReminder reminder,
    required bool isPrivate,
  }) async {
    if (title.trim().length < 2 || end.isBefore(start)) {
      return false;
    }
    final DateTime now = DateTime.now();
    final CalendarEvent event = CalendarEvent(
      id: now.microsecondsSinceEpoch.toString(),
      familyId: familyId,
      title: title.trim(),
      type: type,
      start: start,
      end: end,
      isAllDay: isAllDay,
      location: location.trim(),
      notes: notes.trim(),
      participantIds: participantIds,
      colorValue: colorValue,
      recurrence: recurrence,
      recurrenceInterval: recurrenceInterval,
      recurrenceEnd: recurrenceEnd,
      reminder: reminder,
      isPrivate: isPrivate,
      createdAt: now,
    );
    await _persist(<CalendarEvent>[...state.events, event]);
    return true;
  }

  Future<bool> updateEvent(CalendarEvent event) async {
    if (event.title.trim().length < 2 || event.end.isBefore(event.start)) {
      return false;
    }
    await _persist(state.events.map((CalendarEvent value) {
      return value.id == event.id ? event : value;
    }).toList());
    return true;
  }

  Future<void> deleteEvent(String eventId) async {
    await _persist(
      state.events.where((CalendarEvent event) => event.id != eventId).toList(),
    );
  }

  Future<void> _persist(List<CalendarEvent> events) async {
    await _repository.saveEvents(events);
    state = CalendarState(events: events);
  }
}

final Provider<CalendarRepository> calendarRepositoryProvider =
    Provider<CalendarRepository>(
  (Ref ref) => LocalCalendarRepository(),
);

final StateNotifierProvider<CalendarController, CalendarState>
    calendarControllerProvider =
    StateNotifierProvider<CalendarController, CalendarState>(
  (Ref ref) => CalendarController(ref.watch(calendarRepositoryProvider)),
);

final Provider<List<CalendarEvent>> activeFamilyCalendarEventsProvider =
    Provider<List<CalendarEvent>>((Ref ref) {
  final String? familyId = ref.watch(familyControllerProvider).activeFamilyId;
  if (familyId == null) {
    return <CalendarEvent>[];
  }
  final List<CalendarEvent> events = ref
      .watch(calendarControllerProvider)
      .events
      .where((CalendarEvent event) => event.familyId == familyId)
      .toList()
    ..sort((CalendarEvent first, CalendarEvent second) =>
        first.start.compareTo(second.start));
  return events;
});
