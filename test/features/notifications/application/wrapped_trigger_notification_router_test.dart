import 'package:cse_cet_reviewer/features/notifications/application/wrapped_trigger_notification_router.dart';
import 'package:cse_cet_reviewer/features/notifications/domain/notification_payload.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('routes wrapped trigger using payload title and deep link', () {
    final routed = const WrappedTriggerNotificationRouter().route(
      artifactId: 'post_mock_recap',
      firedAt: DateTime.utc(2026, 6, 10),
      title: 'Mock 3 - Personal Best',
      body: 'Tap to see your Wrapped.',
      shareId: 'share_1',
    );

    expect(routed.copy.title, 'Mock 3 - Personal Best');
    expect(routed.copy.body, 'Tap to see your Wrapped.');
    expect(routed.payload.kind, NotificationKind.wrapped);
    expect(routed.payload.route, '/wrapped/post_mock_recap');
    expect(routed.payload.shareId, 'share_1');
  });
}
