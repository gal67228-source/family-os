import 'package:family_os/features/tasks/domain/family_task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('task reminder offsets are correct', () {
    expect(TaskReminder.atTime.offset, Duration.zero);
    expect(
      TaskReminder.tenMinutes.offset,
      const Duration(minutes: 10),
    );
    expect(
      TaskReminder.oneHour.offset,
      const Duration(hours: 1),
    );
    expect(
      TaskReminder.oneDay.offset,
      const Duration(days: 1),
    );
  });

  test('old task JSON defaults to reminder at due time', () {
    final FamilyTask task = FamilyTask.fromJson(
      <String, Object?>{
        'id': '1',
        'familyId': 'f1',
        'title': 'בדיקה',
        'dueDate': DateTime(2030).toIso8601String(),
        'createdAt': DateTime(2029).toIso8601String(),
      },
    );

    expect(task.reminder, TaskReminder.atTime);
  });
}
