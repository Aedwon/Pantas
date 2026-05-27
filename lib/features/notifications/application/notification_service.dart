import 'package:cse_cet_reviewer/core/notifications/notification_service.dart';
import 'package:cse_cet_reviewer/features/notifications/data/notifications_gateway.dart';
import 'package:cse_cet_reviewer/features/notifications/domain/notification_body_composer.dart';
import 'package:cse_cet_reviewer/features/notifications/domain/notification_payload.dart';
import 'package:cse_cet_reviewer/features/notifications/domain/reminder_schedule.dart';
import 'package:cse_cet_reviewer/features/notifications/domain/streak_save_policy.dart';

class NotificationSettingsSnapshot {
  const NotificationSettingsSnapshot.none() : reminderTime = null;

  NotificationSettingsSnapshot.daily({
    required int hour,
    required int minute,
  }) : reminderTime = NotificationTime(hour: hour, minute: minute);

  final NotificationTime? reminderTime;
}

class NotificationPlanSnapshot {
  const NotificationPlanSnapshot._({
    required this.available,
    required this.reviewCount,
    required this.route,
    required this.planState,
  });

  const NotificationPlanSnapshot.unavailable()
      : this._(
          available: false,
          reviewCount: 0,
          route: null,
          planState: DailyReminderPlanState.standard,
        );

  const NotificationPlanSnapshot.ready({
    required int reviewCount,
    required String route,
    DailyReminderPlanState planState = DailyReminderPlanState.standard,
  }) : this._(
          available: true,
          reviewCount: reviewCount,
          route: route,
          planState: planState,
        );

  final bool available;
  final int reviewCount;
  final String? route;
  final DailyReminderPlanState planState;
}

class NotificationStreakSnapshot {
  const NotificationStreakSnapshot({
    required this.streakLength,
    required this.freezesRemaining,
    required this.completedToday,
  });

  const NotificationStreakSnapshot.empty()
      : this(streakLength: 0, freezesRemaining: 0, completedToday: false);

  final int streakLength;
  final int freezesRemaining;
  final bool completedToday;
}

typedef NotificationSettingsReader = Future<NotificationSettingsSnapshot>
    Function();
typedef NotificationPlanReader = Future<NotificationPlanSnapshot> Function();
typedef NotificationStreakReader = Future<NotificationStreakSnapshot>
    Function();
typedef NotificationClock = DateTime Function();

class NotificationServiceImpl implements NotificationService {
  NotificationServiceImpl({
    required NotificationsGateway gateway,
    required NotificationSettingsReader settingsReader,
    required NotificationPlanReader planReader,
    required NotificationStreakReader streakReader,
    required NotificationClock now,
    NotificationBodyComposer composer = const NotificationBodyComposer(),
    StreakSavePolicy streakPolicy = const StreakSavePolicy(),
    ReminderSchedulerClock schedulerClock = const ReminderSchedulerClock(),
  })  : _gateway = gateway,
        _settingsReader = settingsReader,
        _planReader = planReader,
        _streakReader = streakReader,
        _now = now,
        _composer = composer,
        _streakPolicy = streakPolicy,
        _schedulerClock = schedulerClock;

  final NotificationsGateway _gateway;
  final NotificationSettingsReader _settingsReader;
  final NotificationPlanReader _planReader;
  final NotificationStreakReader _streakReader;
  final NotificationClock _now;
  final NotificationBodyComposer _composer;
  final StreakSavePolicy _streakPolicy;
  final ReminderSchedulerClock _schedulerClock;

  @override
  Future<void> cancelAll() => _gateway.cancelAll();

  @override
  Future<void> openAppNotificationSettings() {
    return _gateway.openAppNotificationSettings();
  }

  @override
  Future<void> onSessionCompleted() =>
      _gateway.cancel(NotificationIds.streakSave);

  @override
  Future<NotificationPermission> requestPermission() {
    return _gateway.requestPermission();
  }

  @override
  Future<void> rescheduleForForeground() async {
    final settings = await _settingsReader();
    final reminderTime = settings.reminderTime;
    if (reminderTime == null) return;
    await scheduleDailyReminder(reminderTime);
  }

  @override
  Future<void> scheduleDailyReminder(NotificationTime time) async {
    if (!(await _gateway.permissionStatus()).canSchedule) return;

    await _gateway.cancel(NotificationIds.dailyReminder);
    await _gateway.cancel(NotificationIds.streakSave);

    final now = _now();
    final plan = await _planReader();
    final dailyFireAt = _schedulerClock.nextOccurrence(now: now, time: time);
    final dailyCopy = plan.available
        ? _composer.dailyReminder(
            DailyReminderInput(
              planState: plan.planState,
              reviewCount: plan.reviewCount,
            ),
          )
        : _composer.fallbackDailyReminder();
    await _gateway.schedule(
      ScheduledNotification(
        id: NotificationIds.dailyReminder,
        kind: NotificationKind.dailyReminder,
        fireAt: dailyFireAt,
        title: dailyCopy.title,
        body: dailyCopy.body,
        payload: NotificationPayload(
          kind: NotificationKind.dailyReminder,
          scheduledFor: dailyFireAt,
          route: plan.route,
        ).encode(),
      ),
    );

    final streak = await _streakReader();
    final streakTime = _streakPolicy.streakSaveTime(time);
    final streakFireAt = DateTime(
      now.year,
      now.month,
      now.day,
      streakTime.hour,
      streakTime.minute,
    );
    if (!_streakPolicy.shouldSchedule(
      streakLength: streak.streakLength,
      completedToday: streak.completedToday,
      now: now,
      fireAt: streakFireAt,
    )) {
      return;
    }

    final streakCopy = _composer.streakSave(
      streakLength: streak.streakLength,
      freezesRemaining: streak.freezesRemaining,
    );
    await _gateway.schedule(
      ScheduledNotification(
        id: NotificationIds.streakSave,
        kind: NotificationKind.streakSave,
        fireAt: streakFireAt,
        title: streakCopy.title,
        body: streakCopy.body,
        payload: NotificationPayload(
          kind: NotificationKind.streakSave,
          scheduledFor: streakFireAt,
          route: plan.route,
        ).encode(),
      ),
    );
  }
}
