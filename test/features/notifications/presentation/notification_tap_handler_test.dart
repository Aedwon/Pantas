import 'package:pantas/features/notifications/notifications.dart';
import 'package:pantas/features/notifications/presentation/notification_tap_handler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fresh payload with route opens that route', () {
    final handler = NotificationTapHandler(
      now: () => DateTime.parse('2026-05-22T20:00:00+08:00'),
    );
    final payload = NotificationPayload(
      kind: NotificationKind.dailyReminder,
      scheduledFor: DateTime.parse('2026-05-22T19:00:00+08:00'),
      route: '/quiz/today/cse',
    ).encode();

    expect(handler.targetFor(payload), '/quiz/today/cse');
  });

  test('payload older than four hours opens home', () {
    final handler = NotificationTapHandler(
      now: () => DateTime.parse('2026-05-23T00:01:00+08:00'),
    );
    final payload = NotificationPayload(
      kind: NotificationKind.streakSave,
      scheduledFor: DateTime.parse('2026-05-22T20:00:00+08:00'),
      route: '/quiz/today/cse',
    ).encode();

    expect(handler.targetFor(payload), '/home');
  });

  test('malformed or plan-not-ready payload opens home', () {
    const handler = NotificationTapHandler(now: DateTime.now);

    expect(handler.targetFor('not-json'), '/home');
    expect(
      handler.targetFor(
        NotificationPayload(
          kind: NotificationKind.dailyReminder,
          scheduledFor: DateTime.now(),
        ).encode(),
      ),
      '/home',
    );
  });
}
