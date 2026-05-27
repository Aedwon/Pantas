import 'package:cse_cet_reviewer/core/notifications/notification_service.dart';
import 'package:cse_cet_reviewer/features/notifications/application/notification_service.dart';
import 'package:cse_cet_reviewer/features/notifications/data/flutter_local_notifications_gateway.dart';
import 'package:cse_cet_reviewer/features/notifications/data/notifications_gateway.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationsGatewayProvider = Provider<NotificationsGateway>((ref) {
  final gateway = FlutterLocalNotificationsGateway();
  ref.onDispose(gateway.cancelAll);
  return gateway;
});

final featureNotificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationServiceImpl(
    gateway: ref.watch(notificationsGatewayProvider),
    settingsReader: () async => const NotificationSettingsSnapshot.none(),
    planReader: () async => const NotificationPlanSnapshot.unavailable(),
    streakReader: () async => const NotificationStreakSnapshot.empty(),
    now: DateTime.now,
  );
});

final featurePermissionStatusStreamProvider =
    Provider<Stream<NotificationPermission>>((ref) {
  return ref.watch(notificationsGatewayProvider).watchPermissionStatus();
});

final featurePermissionStatusProvider =
    StreamProvider<NotificationPermission>((ref) {
  return ref.watch(featurePermissionStatusStreamProvider);
});
