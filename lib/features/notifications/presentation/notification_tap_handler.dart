import 'package:cse_cet_reviewer/features/notifications/domain/notification_payload.dart';

class NotificationTapHandler {
  const NotificationTapHandler({
    required DateTime Function() now,
  }) : _now = now;

  final DateTime Function() _now;

  String targetFor(String? payload) {
    final decoded = NotificationPayload.tryDecode(payload);
    if (decoded == null) return '/home';
    if (_now().difference(decoded.scheduledFor) > const Duration(hours: 4)) {
      return '/home';
    }
    return decoded.route ?? '/home';
  }
}
