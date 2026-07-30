import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/notifications/notification_service.dart';
import 'package:pantas/features/notifications/presentation/notifications_lifecycle_observer.dart';

// ignore_for_file: cascade_invocations

void main() {
  test('resume reschedules notifications and starts foreground watcher',
      () async {
    final service = RecordingNotificationService();
    var timerStarts = 0;

    final observer = NotificationsLifecycleObserver(
      service: service,
      now: () => DateTime(2026, 5, 23, 9),
      startPeriodic: (_, __) {
        timerStarts += 1;
        return () {};
      },
    );

    observer.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await pumpEventQueue();

    expect(service.rescheduleCount, 1);
    expect(timerStarts, 1);
  });

  test('foreground day boundary reschedules once per new local day', () async {
    final service = RecordingNotificationService();
    var now = DateTime(2026, 5, 23, 23, 59);
    VoidCallback? tick;

    final observer = NotificationsLifecycleObserver(
      service: service,
      now: () => now,
      startPeriodic: (_, callback) {
        tick = callback;
        return () {};
      },
    );

    observer.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await pumpEventQueue();
    expect(service.rescheduleCount, 1);

    now = DateTime(2026, 5, 24);
    tick!();
    await pumpEventQueue();
    expect(service.rescheduleCount, 2);

    now = DateTime(2026, 5, 24, 1);
    tick!();
    await pumpEventQueue();
    expect(service.rescheduleCount, 2);
  });

  test('pausing cancels the foreground day-boundary watcher', () {
    var cancelCount = 0;
    final observer = NotificationsLifecycleObserver(
      service: RecordingNotificationService(),
      now: () => DateTime(2026, 5, 23),
      startPeriodic: (_, __) => () {
        cancelCount += 1;
      },
    );

    observer.didChangeAppLifecycleState(AppLifecycleState.resumed);
    observer.didChangeAppLifecycleState(AppLifecycleState.paused);

    expect(cancelCount, 1);
  });
}

class RecordingNotificationService implements NotificationService {
  int rescheduleCount = 0;

  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> onSessionCompleted() async {}

  @override
  Future<void> openAppNotificationSettings() async {}

  @override
  Future<NotificationPermission> requestPermission() async {
    return NotificationPermission.granted;
  }

  @override
  Future<void> rescheduleForForeground() async {
    rescheduleCount += 1;
  }

  @override
  Future<void> scheduleDailyReminder(NotificationTime time) async {}
}
