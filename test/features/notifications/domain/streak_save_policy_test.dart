import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/notifications/notifications.dart';

void main() {
  test('streak save stays silent on Saturday rest day', () {
    expect(
      const StreakSavePolicy().shouldSchedule(
        streakLength: 5,
        completedToday: false,
        now: DateTime(2026, 10, 3, 12),
        fireAt: DateTime(2026, 10, 3, 18),
        isStudyDay: false,
      ),
      isFalse,
    );
  });

  test('computes streak save time from reminder time', () {
    const policy = StreakSavePolicy();

    expect(
      policy.streakSaveTime(const NotificationTime(hour: 19, minute: 0)),
      const NotificationTime(hour: 18, minute: 0),
    );
    expect(
      policy.streakSaveTime(const NotificationTime(hour: 20, minute: 30)),
      const NotificationTime(hour: 19, minute: 30),
    );
    expect(
      policy.streakSaveTime(const NotificationTime(hour: 21, minute: 0)),
      const NotificationTime(hour: 20, minute: 0),
    );
    expect(
      policy.streakSaveTime(const NotificationTime(hour: 22, minute: 0)),
      const NotificationTime(hour: 20, minute: 0),
    );
    expect(
      policy.streakSaveTime(const NotificationTime(hour: 6, minute: 0)),
      const NotificationTime(hour: 5, minute: 0),
    );
  });

  test('does not schedule streak save for ineligible states', () {
    const policy = StreakSavePolicy();
    final today = DateTime(2026, 5, 22, 12);

    expect(
      policy.shouldSchedule(
        streakLength: 0,
        completedToday: false,
        now: today,
        fireAt: DateTime(2026, 5, 22, 18),
      ),
      isFalse,
    );
    expect(
      policy.shouldSchedule(
        streakLength: 3,
        completedToday: true,
        now: today,
        fireAt: DateTime(2026, 5, 22, 18),
      ),
      isFalse,
    );
    expect(
      policy.shouldSchedule(
        streakLength: 3,
        completedToday: false,
        now: DateTime(2026, 5, 22, 19),
        fireAt: DateTime(2026, 5, 22, 18),
      ),
      isFalse,
    );
  });

  test('schedules streak save for active uncompleted future window', () {
    expect(
      const StreakSavePolicy().shouldSchedule(
        streakLength: 3,
        completedToday: false,
        now: DateTime(2026, 5, 22, 12),
        fireAt: DateTime(2026, 5, 22, 18),
      ),
      isTrue,
    );
  });
}
