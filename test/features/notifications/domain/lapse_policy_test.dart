import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/features/notifications/notifications.dart';

void main() {
  for (final scenario in [
    (day: 2, want: false),
    (day: 3, want: false),
    (day: 4, want: false),
    (day: 5, want: false),
    (day: 6, want: true),
    (day: 7, want: false),
  ]) {
    test('Thursday lapse counts only study days on October ${scenario.day}',
        () {
      const policy = LapsePolicy();
      final now = DateTime(2026, 10, scenario.day, 12);
      final days = StudyDays(const [1, 2, 3, 4, 5]);
      expect(
        policy.shouldSchedule(
          lastSessionAt: DateTime(2026, 10, 1, 10),
          now: now,
          studyDays: days,
        ),
        scenario.want,
      );
      expect(
        policy.scheduledTime(
          lastSessionAt: DateTime(2026, 10, 1, 10),
          now: now,
          reminderTime: const NotificationTime(hour: 19, minute: 0),
          studyDays: days,
        ),
        scenario.want ? DateTime(2026, 10, 6, 19) : null,
      );
    });
  }

  group('LapsePolicy', () {
    const policy = LapsePolicy();
    final lastSession = DateTime(2026, 8, 1, 10);

    test('two quiet days send nothing', () {
      final now = DateTime(2026, 8, 3, 12); // 2 days after Aug 1
      expect(
        policy.shouldSchedule(lastSessionAt: lastSession, now: now),
        isFalse,
      );
    });

    test('three quiet days send one', () {
      final now = DateTime(2026, 8, 4, 12); // 3 days after Aug 1
      expect(
        policy.shouldSchedule(lastSessionAt: lastSession, now: now),
        isTrue,
      );
    });

    test('four quiet days send nothing more', () {
      final now = DateTime(2026, 8, 5, 12); // 4 days after Aug 1
      expect(
        policy.shouldSchedule(lastSessionAt: lastSession, now: now),
        isFalse,
      );
    });

    test('returning and lapsing again sends one more', () {
      final newSession = DateTime(2026, 8, 6, 14); // returned on Aug 6
      final now = DateTime(2026, 8, 9, 12); // 3 days after Aug 6
      expect(
        policy.shouldSchedule(lastSessionAt: newSession, now: now),
        isTrue,
      );
    });
  });
}
