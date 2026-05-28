import 'package:cse_cet_reviewer/features/notifications/domain/notification_body_composer.dart';
import 'package:cse_cet_reviewer/features/notifications/domain/notification_payload.dart';

class RoutedWrappedNotification {
  const RoutedWrappedNotification({
    required this.copy,
    required this.payload,
  });

  final NotificationCopy copy;
  final NotificationPayload payload;
}

class WrappedTriggerNotificationRouter {
  const WrappedTriggerNotificationRouter();

  RoutedWrappedNotification route({
    required String artifactId,
    required DateTime firedAt,
    required String title,
    required String body,
    required String shareId,
  }) {
    return RoutedWrappedNotification(
      copy: NotificationCopy(title: title, body: body),
      payload: NotificationPayload(
        kind: NotificationKind.wrapped,
        scheduledFor: firedAt,
        route: '/wrapped/$artifactId',
        shareId: shareId,
      ),
    );
  }
}
