import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/notifications/domain/notification_payload.dart';
import 'package:pantas/features/notifications/presentation/notification_tap_handler.dart';

void main() {
  const handler = NotificationTapHandler();
  for (final kind in NotificationKind.values) {
    test('${kind.name} routes by kind for fresh and stale legacy payloads', () {
      for (final date in [DateTime(2026, 10, 12), DateTime(2020)]) {
        final payload = NotificationPayload(
                kind: kind, scheduledFor: date, route: '/quiz/today/cse')
            .encode();
        expect(handler.targetFor(payload),
            kind == NotificationKind.trialEnding ? '/settings/pro' : '/home');
      }
    });
  }
  test('malformed payload opens Home', () {
    expect(handler.targetFor('not-json'), '/home');
    expect(handler.targetFor(null), '/home');
    expect(handler.targetFor('{"kind":12}'), '/home');
  });
}
