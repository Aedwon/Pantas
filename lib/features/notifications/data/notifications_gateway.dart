import 'package:cse_cet_reviewer/core/notifications/notification_service.dart';
import 'package:cse_cet_reviewer/features/notifications/domain/notification_payload.dart';

class ScheduledNotification {
  const ScheduledNotification({
    required this.id,
    required this.kind,
    required this.fireAt,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final NotificationKind kind;
  final DateTime fireAt;
  final String title;
  final String body;
  final String payload;
}

abstract interface class NotificationsGateway {
  Future<void> initialize();

  Future<NotificationPermission> permissionStatus();

  Stream<NotificationPermission> watchPermissionStatus();

  Future<NotificationPermission> requestPermission();

  Future<String?> initialNotificationTapPayload();

  Stream<String?> get notificationTapPayloads;

  Future<void> schedule(ScheduledNotification notification);

  Future<void> cancel(int id);

  Future<void> cancelAll();

  Future<void> openAppNotificationSettings();
}
