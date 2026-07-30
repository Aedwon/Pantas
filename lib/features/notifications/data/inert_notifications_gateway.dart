import 'dart:async';

import 'package:pantas/core/notifications/notification_service.dart';
import 'package:pantas/features/notifications/data/notifications_gateway.dart';

/// A gateway that schedules nothing, for every environment with no platform
/// behind it.
///
/// **Why this exists, 12 August 2026.** Under `flutter_local_notifications` 17
/// a call into the plugin with no registered platform implementation returned
/// null and the app carried on. Under 22 the platform instance is a `late`
/// field, so the same call throws `LateInitializationError` and takes the whole
/// widget tree with it. Twenty-three tests that mount the real app started
/// failing on the version bump alone.
///
/// **The old behavior was luck, not design.** Those tests were exercising the
/// real gateway and getting silence from it. This makes the silence
/// deliberate: `bootstrap` installs the real gateway, and everything else gets
/// this.
class InertNotificationsGateway implements NotificationsGateway {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> cancel(int id) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Future<String?> initialNotificationTapPayload() async => null;

  @override
  Stream<String?> get notificationTapPayloads => const Stream.empty();

  @override
  Future<void> openAppNotificationSettings() async {}

  @override
  Future<NotificationPermission> permissionStatus() async =>
      NotificationPermission.notYetAsked;

  @override
  Future<NotificationPermission> requestPermission() async =>
      NotificationPermission.notYetAsked;

  @override
  Future<void> schedule(ScheduledNotification notification) async {}

  @override
  Stream<NotificationPermission> watchPermissionStatus() =>
      Stream.value(NotificationPermission.notYetAsked);
}
