import 'package:cse_cet_reviewer/features/notifications/application/notification_service.dart';
import 'package:cse_cet_reviewer/features/notifications/data/notifications_gateway.dart';
import 'package:cse_cet_reviewer/features/notifications/notifications.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('scheduleDailyReminder cancels ids then schedules daily reminder',
      () async {
    final gateway = RecordingNotificationsGateway()
      ..permission = NotificationPermission.granted;
    final service = NotificationServiceImpl(
      gateway: gateway,
      settingsReader: () async =>
          NotificationSettingsSnapshot.daily(hour: 19, minute: 0),
      planReader: () async => const NotificationPlanSnapshot.ready(
        reviewCount: 14,
        route: '/quiz/today/cse',
      ),
      streakReader: () async => const NotificationStreakSnapshot.empty(),
      now: () => DateTime(2026, 5, 22, 12),
    );

    await service.scheduleDailyReminder(
      const NotificationTime(hour: 19, minute: 0),
    );

    expect(gateway.log.where((entry) => entry.startsWith('cancel')).length, 4);
    expect(
      gateway.log.where((entry) => entry.startsWith('schedule')).length,
      1,
    );
    expect(gateway.scheduled.single.title, "Today's session is ready");
    expect(
      gateway.scheduled.single.body,
      "14 questions to review. You've got this.",
    );
  });

  test(
      'scheduleDailyReminder chooses higher priority streak save under ceiling',
      () async {
    final gateway = RecordingNotificationsGateway()
      ..permission = NotificationPermission.granted;
    final service = NotificationServiceImpl(
      gateway: gateway,
      settingsReader: () async =>
          NotificationSettingsSnapshot.daily(hour: 19, minute: 0),
      planReader: () async => const NotificationPlanSnapshot.ready(
        reviewCount: 14,
        route: '/quiz/today/cse',
      ),
      streakReader: () async => const NotificationStreakSnapshot(
        streakLength: 3,
        freezesRemaining: 1,
        completedToday: false,
      ),
      now: () => DateTime(2026, 5, 22, 12),
    );

    await service.rescheduleForForeground();

    expect(gateway.scheduled.map((n) => n.id), [
      NotificationIds.streakSave,
    ]);
    expect(gateway.scheduled.single.title, "Your 3-day streak's safe tonight");
  });

  test('scheduleDailyReminder skips scheduling when permission is denied',
      () async {
    final gateway = RecordingNotificationsGateway()
      ..permission = NotificationPermission.denied;
    final service = NotificationServiceImpl(
      gateway: gateway,
      settingsReader: () async =>
          NotificationSettingsSnapshot.daily(hour: 19, minute: 0),
      planReader: () async => const NotificationPlanSnapshot.unavailable(),
      streakReader: () async => const NotificationStreakSnapshot.empty(),
      now: () => DateTime(2026, 5, 22, 12),
    );

    await service.scheduleDailyReminder(
      const NotificationTime(hour: 19, minute: 0),
    );

    expect(gateway.scheduled, isEmpty);
    expect(gateway.log, isEmpty);
  });

  test('onSessionCompleted cancels only streak save notification', () async {
    final gateway = RecordingNotificationsGateway();
    final service = NotificationServiceImpl(
      gateway: gateway,
      settingsReader: () async => const NotificationSettingsSnapshot.none(),
      planReader: () async => const NotificationPlanSnapshot.unavailable(),
      streakReader: () async => const NotificationStreakSnapshot.empty(),
      now: DateTime.now,
    );

    await service.onSessionCompleted();

    expect(gateway.log, ['cancel:9002']);
  });

  test('requestPermission delegates to gateway', () async {
    final gateway = RecordingNotificationsGateway()
      ..permission = NotificationPermission.granted;
    final service = NotificationServiceImpl(
      gateway: gateway,
      settingsReader: () async => const NotificationSettingsSnapshot.none(),
      planReader: () async => const NotificationPlanSnapshot.unavailable(),
      streakReader: () async => const NotificationStreakSnapshot.empty(),
      now: DateTime.now,
    );

    expect(await service.requestPermission(), NotificationPermission.granted);
  });
}

class RecordingNotificationsGateway implements NotificationsGateway {
  final log = <String>[];
  final scheduled = <ScheduledNotification>[];
  NotificationPermission permission = NotificationPermission.notYetAsked;

  @override
  Future<void> cancel(int id) async => log.add('cancel:$id');

  @override
  Future<void> cancelAll() async => log.add('cancelAll');

  @override
  Future<void> initialize() async => log.add('initialize');

  @override
  Future<String?> initialNotificationTapPayload() async => null;

  @override
  Stream<String?> get notificationTapPayloads => const Stream.empty();

  @override
  Future<void> openAppNotificationSettings() async => log.add('openSettings');

  @override
  Future<NotificationPermission> permissionStatus() async => permission;

  @override
  Future<NotificationPermission> requestPermission() async => permission;

  @override
  Future<void> schedule(ScheduledNotification notification) async {
    log.add('schedule:${notification.id}');
    scheduled.add(notification);
  }

  @override
  Stream<NotificationPermission> watchPermissionStatus() async* {
    yield permission;
  }
}
