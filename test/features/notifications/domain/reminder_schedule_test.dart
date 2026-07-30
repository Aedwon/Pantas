import 'package:pantas/features/notifications/notifications.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('daily reminder schedules next occurrence today when future', () {
    final fireAt = const ReminderSchedulerClock().nextOccurrence(
      now: DateTime(2026, 5, 22, 12),
      time: const NotificationTime(hour: 19, minute: 0),
    );

    expect(fireAt, DateTime(2026, 5, 22, 19));
  });

  test('daily reminder schedules tomorrow when time already passed', () {
    final fireAt = const ReminderSchedulerClock().nextOccurrence(
      now: DateTime(2026, 5, 22, 20),
      time: const NotificationTime(hour: 19, minute: 0),
    );

    expect(fireAt, DateTime(2026, 5, 23, 19));
  });
}
