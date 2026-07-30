import 'package:pantas/features/notifications/notifications.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('payload encodes kind scheduled timestamp and optional route', () {
    final payload = NotificationPayload(
      kind: NotificationKind.dailyReminder,
      scheduledFor: DateTime.parse('2026-05-22T19:00:00+08:00'),
      route: '/quiz/today/cse',
    );

    final decoded = NotificationPayload.tryDecode(payload.encode());

    expect(decoded?.kind, NotificationKind.dailyReminder);
    expect(decoded?.scheduledFor, DateTime.parse('2026-05-22T11:00:00Z'));
    expect(decoded?.route, '/quiz/today/cse');
  });

  test('payload rejects unknown kind and malformed scheduled timestamp', () {
    expect(
      NotificationPayload.tryDecode(
        '{"kind":"server_push","scheduled_for":"2026-05-22T19:00:00+08:00"}',
      ),
      isNull,
    );
    expect(
      NotificationPayload.tryDecode(
        '{"kind":"daily_reminder","scheduled_for":"soon"}',
      ),
      isNull,
    );
  });
}
