import 'package:pantas/features/notifications/domain/notification_payload.dart';

class NotificationTapHandler {
  const NotificationTapHandler();

  String targetFor(String? payload) {
    final decoded = NotificationPayload.tryDecode(payload);
    if (decoded == null) return '/home';
    return decoded.kind == NotificationKind.trialEnding
        ? '/settings/pro'
        : '/home';
  }
}
