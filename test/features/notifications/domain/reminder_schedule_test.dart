import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/features/notifications/notifications.dart';

void main() {
  for (final now in [
    DateTime(2026, 10, 2, 20),
    DateTime(2026, 10, 3, 12),
    DateTime(2026, 10, 2, 19),
  ]) {
    test('weekday reminder skips rest days from $now', () {
      expect(
        const ReminderSchedulerClock().nextOccurrence(
          now: now,
          time: const NotificationTime(hour: 19, minute: 0),
          studyDays: StudyDays(const [1, 2, 3, 4, 5]),
        ),
        DateTime(2026, 10, 5, 19),
      );
    });
  }

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
