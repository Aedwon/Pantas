import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

@immutable
class NotificationTime {
  const NotificationTime({required this.hour, required this.minute})
      : assert(hour >= 0 && hour <= 23, 'hour must be 0 through 23'),
        assert(minute >= 0 && minute <= 59, 'minute must be 0 through 59');

  final int hour;
  final int minute;

  @override
  bool operator ==(Object other) {
    return other is NotificationTime &&
        other.hour == hour &&
        other.minute == minute;
  }

  @override
  int get hashCode => Object.hash(hour, minute);
}

enum NotificationPermission {
  notYetAsked,
  granted,
  denied;

  bool get canSchedule => this == NotificationPermission.granted;
}

abstract interface class NotificationService {
  Future<void> scheduleDailyReminder(NotificationTime time);

  Future<void> onSessionCompleted();

  Future<void> rescheduleForForeground();

  Future<NotificationPermission> requestPermission();

  Future<void> cancelAll();

  Future<void> openAppNotificationSettings();
}

class NoopNotificationService implements NotificationService {
  const NoopNotificationService();

  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> onSessionCompleted() async {}

  @override
  Future<void> openAppNotificationSettings() async {}

  @override
  Future<NotificationPermission> requestPermission() async {
    return NotificationPermission.notYetAsked;
  }

  @override
  Future<void> rescheduleForForeground() async {}

  @override
  Future<void> scheduleDailyReminder(NotificationTime time) async {}
}

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => const NoopNotificationService(),
);

final notificationPermissionStatusProvider =
    StreamProvider<NotificationPermission>(
  (ref) => Stream.value(NotificationPermission.notYetAsked),
);
