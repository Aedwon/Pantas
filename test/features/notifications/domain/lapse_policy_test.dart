import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/features/notifications/application/notification_service.dart';
import 'package:pantas/features/notifications/data/notifications_gateway.dart';
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

  group('The Switch (reminders off and permission denied)', () {
    test(
        'with reminders off, only the last four countdown rungs fire '
        'and the comeback never does', () async {
      final gateway = RecordingNotificationsGateway()
        ..permission = NotificationPermission.granted;

      final examDate = ExamDate.onDay(DateTime(2026, 9, 15));
      final lastSessionAt = DateTime(2026, 8, 7, 10);

      // Current time is 2026-08-10.
      // Sept 15 minus 30 days = Aug 16 (rung 30)
      // Sept 15 minus 14 days = Sept 1 (rung 14)
      // Sept 15 minus 7 days = Sept 8 (rung 7)
      // Sept 15 minus 3 days = Sept 12 (rung 3)
      // Sept 15 minus 2 days = Sept 13 (rung 2)
      // Sept 15 minus 1 day = Sept 14 (rung 1)
      // Sept 15 minus 0 days = Sept 15 (rung 0)
      final service = NotificationServiceImpl(
        gateway: gateway,
        settingsReader: () async => const NotificationSettingsSnapshot.none(),
        planReader: () async => const NotificationPlanSnapshot.unavailable(),
        streakReader: () async => const NotificationStreakSnapshot.empty(),
        examDateReader: () async => examDate,
        lapseReader: () async => NotificationLapseSnapshot(
          lastSessionAt: lastSessionAt,
          subjectName: 'Chemistry',
          correctCount: 12,
          totalCount: 20,
        ),
        now: () => DateTime(2026, 8, 10, 12),
      );

      await service.rescheduleForForeground();

      // No comeBack notification should be scheduled.
      final kinds = gateway.scheduled.map((n) => n.kind).toList();
      expect(kinds.contains(NotificationKind.comeBack), isFalse);

      // Only countdown rungs 3, 2, 1 and 0 are scheduled: four dates.
      expect(kinds.every((k) => k == NotificationKind.examCountdown), isTrue);
      expect(gateway.scheduled.length, 4);

      final scheduledDates = gateway.scheduled
          .map(
            (n) => DateTime.parse(
              NotificationPayload.tryDecode(n.payload)!
                  .scheduledFor
                  .toIso8601String(),
            ),
          )
          .toList();

      expect(
        scheduledDates.any((d) => d.day == 16),
        isFalse,
      ); // rung 30 excluded
      expect(
        scheduledDates.any((d) => d.day == 1),
        isFalse,
      ); // rung 14 excluded
      expect(scheduledDates.any((d) => d.day == 8), isFalse); // rung 7 excluded
      expect(scheduledDates.any((d) => d.day == 12), isTrue); // rung 3 included
      expect(scheduledDates.any((d) => d.day == 13), isTrue); // rung 2 included
      expect(scheduledDates.any((d) => d.day == 14), isTrue); // rung 1 included
      expect(scheduledDates.any((d) => d.day == 15), isTrue); // rung 0 included
    });

    test('with permission denied nothing is scheduled at all', () async {
      final gateway = RecordingNotificationsGateway()
        ..permission = NotificationPermission.denied;

      final examDate = ExamDate.onDay(DateTime(2026, 9, 15));
      final service = NotificationServiceImpl(
        gateway: gateway,
        settingsReader: () async =>
            NotificationSettingsSnapshot.daily(hour: 19, minute: 0),
        planReader: () async => const NotificationPlanSnapshot.ready(
          reviewCount: 10,
          route: '/study',
        ),
        streakReader: () async => const NotificationStreakSnapshot(
          streakLength: 5,
          freezesRemaining: 1,
          completedToday: false,
        ),
        examDateReader: () async => examDate,
        lapseReader: () async => NotificationLapseSnapshot(
          lastSessionAt: DateTime(2026, 8, 7, 10),
          subjectName: 'Chemistry',
          correctCount: 12,
          totalCount: 20,
        ),
        now: () => DateTime(2026, 8, 10, 12),
      );

      await service.rescheduleForForeground();

      expect(gateway.scheduled, isEmpty);
    });
  });
}

class RecordingNotificationsGateway implements NotificationsGateway {
  final log = <String>[];
  final scheduled = <ScheduledNotification>[];
  NotificationPermission permission = NotificationPermission.notYetAsked;

  @override
  Future<void> cancel(int id) async => log.add('cancel:$id');

  @override
  Future<void> cancelAll() async => log.add('cancelAll');

  @override
  Future<void> initialize() async => log.add('initialize');

  @override
  Future<String?> initialNotificationTapPayload() async => null;

  @override
  Stream<String?> get notificationTapPayloads => const Stream.empty();

  @override
  Future<void> openAppNotificationSettings() async => log.add('openSettings');

  @override
  Future<NotificationPermission> permissionStatus() async => permission;

  @override
  Future<NotificationPermission> requestPermission() async => permission;

  @override
  Future<void> schedule(ScheduledNotification notification) async {
    log.add('schedule:${notification.id}');
    scheduled.add(notification);
  }

  @override
  Stream<NotificationPermission> watchPermissionStatus() async* {
    yield permission;
  }
}
