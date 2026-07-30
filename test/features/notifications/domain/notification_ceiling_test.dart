import 'package:pantas/features/notifications/domain/notification_ceiling.dart';
import 'package:pantas/features/notifications/domain/notification_payload.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationCeiling', () {
    final day = DateTime(2026, 8, 10, 19);

    final examCountdownPayload = NotificationPayload(
      kind: NotificationKind.examCountdown,
      scheduledFor: day,
    );
    final streakSavePayload = NotificationPayload(
      kind: NotificationKind.streakSave,
      scheduledFor: day,
    );
    final dailyReminderPayload = NotificationPayload(
      kind: NotificationKind.dailyReminder,
      scheduledFor: day,
    );
    final comeBackPayload = NotificationPayload(
      kind: NotificationKind.comeBack,
      scheduledFor: day,
    );

    test('four eligible payloads yield one winner, the highest priority', () {
      final eligible = [
        dailyReminderPayload,
        comeBackPayload,
        examCountdownPayload,
        streakSavePayload,
      ];

      final winner = NotificationCeiling.pick(eligible);

      expect(winner, isNotNull);
      expect(winner!.kind, NotificationKind.examCountdown);
    });

    test('respects priority order when examCountdown is absent', () {
      final eligible = [
        dailyReminderPayload,
        comeBackPayload,
        streakSavePayload,
      ];

      final winner = NotificationCeiling.pick(eligible);

      expect(winner?.kind, NotificationKind.streakSave);
    });

    test(
        'respects priority when only the daily reminder and comeback are '
        'present', () {
      final eligible = [
        comeBackPayload,
        dailyReminderPayload,
      ];

      final winner = NotificationCeiling.pick(eligible);

      expect(winner?.kind, NotificationKind.dailyReminder);
    });

    test('dropped payload is not rescheduled to the following day', () {
      final eligible = [
        examCountdownPayload,
        dailyReminderPayload,
      ];

      final winner = NotificationCeiling.pick(eligible);

      expect(winner?.kind, NotificationKind.examCountdown);
      expect(winner?.scheduledFor, day);
      // The dropped dailyReminderPayload is simply discarded, date is unchanged
    });

    test('empty list yields null', () {
      final winner = NotificationCeiling.pick([]);

      expect(winner, isNull);
    });
  });
}
