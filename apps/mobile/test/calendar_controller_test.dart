import 'package:family_os/features/calendar/application/calendar_controller.dart';
import 'package:family_os/features/calendar/data/calendar_repository.dart';
import 'package:family_os/features/calendar/domain/calendar_event.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryCalendarRepository implements CalendarRepository {
  List<CalendarEvent> events = <CalendarEvent>[];

  @override
  Future<List<CalendarEvent>> loadEvents() async => events;

  @override
  Future<void> saveEvents(List<CalendarEvent> value) async {
    events = value;
  }
}

void main() {
  test('calendar event lifecycle works', () async {
    final MemoryCalendarRepository repository = MemoryCalendarRepository();
    final CalendarController controller = CalendarController(repository);
    await controller.load();

    expect(
      await controller.addEvent(
        familyId: 'f1',
        title: 'יום הולדת',
        type: CalendarEventType.birthday,
        start: DateTime(2030, 5, 1),
        end: DateTime(2030, 5, 1, 23, 59),
        isAllDay: true,
        location: '',
        notes: '',
        participantIds: <String>['m1'],
        colorValue: 0xFF1256E8,
        recurrence: CalendarRecurrence.yearly,
        reminder: CalendarReminder.oneDay,
      ),
      isTrue,
    );

    expect(controller.state.events, hasLength(1));
    final CalendarEvent event = controller.state.events.single;
    expect(event.recurrence, CalendarRecurrence.yearly);

    await controller.updateEvent(event.copyWith(title: 'יום הולדת לנועה'));
    expect(controller.state.events.single.title, 'יום הולדת לנועה');

    await controller.deleteEvent(event.id);
    expect(controller.state.events, isEmpty);
  });
}
