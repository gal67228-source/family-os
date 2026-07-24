import 'package:family_os/features/notifications/domain/notification_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('notification settings copyWith preserves values', () {
    const NotificationSettings original = NotificationSettings.defaults();

    final NotificationSettings updated = original.copyWith(
      dailySummaryHour: 9,
      taskReminders: false,
    );

    expect(updated.enabled, isTrue);
    expect(updated.dailySummaryHour, 9);
    expect(updated.taskReminders, isFalse);
    expect(updated.eventReminders, isTrue);
  });
}
