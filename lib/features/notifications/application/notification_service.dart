import 'package:pantas/core/notifications/notification_service.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/features/notifications/data/notifications_gateway.dart';
import 'package:pantas/features/notifications/domain/exam_countdown_schedule.dart';
import 'package:pantas/features/notifications/domain/lapse_policy.dart';
import 'package:pantas/features/notifications/domain/notification_body_composer.dart';
import 'package:pantas/features/notifications/domain/notification_ceiling.dart';
import 'package:pantas/features/notifications/domain/notification_payload.dart';
import 'package:pantas/features/notifications/domain/reminder_schedule.dart';
import 'package:pantas/features/notifications/domain/streak_save_policy.dart';

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

class NotificationLapseSnapshot {
  const NotificationLapseSnapshot({
    this.lastSessionAt,
    this.subjectName,
    this.correctCount,
    this.totalCount,
  });

  const NotificationLapseSnapshot.empty()
      : lastSessionAt = null,
        subjectName = null,
        correctCount = null,
        totalCount = null;

  final DateTime? lastSessionAt;
  final String? subjectName;
  final int? correctCount;
  final int? totalCount;
}

typedef NotificationSettingsReader = Future<NotificationSettingsSnapshot>
    Function();
typedef NotificationPlanReader = Future<NotificationPlanSnapshot> Function();
typedef NotificationStreakReader = Future<NotificationStreakSnapshot>
    Function();
typedef NotificationExamDateReader = Future<ExamDate?> Function();
typedef NotificationLapseReader = Future<NotificationLapseSnapshot> Function();
typedef NotificationClock = DateTime Function();

class NotificationServiceImpl implements NotificationService {
  NotificationServiceImpl({
    required NotificationsGateway gateway,
    required NotificationSettingsReader settingsReader,
    required NotificationPlanReader planReader,
    required NotificationStreakReader streakReader,
    required NotificationClock now,
    NotificationExamDateReader? examDateReader,
    NotificationLapseReader? lapseReader,
    NotificationBodyComposer composer = const NotificationBodyComposer(),
    StreakSavePolicy streakPolicy = const StreakSavePolicy(),
    LapsePolicy lapsePolicy = const LapsePolicy(),
    ReminderSchedulerClock schedulerClock = const ReminderSchedulerClock(),
  })  : _gateway = gateway,
        _settingsReader = settingsReader,
        _planReader = planReader,
        _streakReader = streakReader,
        _examDateReader = examDateReader ?? (() async => null),
        _lapseReader = lapseReader ??
            (() async => const NotificationLapseSnapshot.empty()),
        _now = now,
        _composer = composer,
        _streakPolicy = streakPolicy,
        _lapsePolicy = lapsePolicy,
        _schedulerClock = schedulerClock;

  final NotificationsGateway _gateway;
  final NotificationSettingsReader _settingsReader;
  final NotificationPlanReader _planReader;
  final NotificationStreakReader _streakReader;
  final NotificationExamDateReader _examDateReader;
  final NotificationLapseReader _lapseReader;
  final NotificationClock _now;
  final NotificationBodyComposer _composer;
  final StreakSavePolicy _streakPolicy;
  final LapsePolicy _lapsePolicy;
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
    await _scheduleNotifications(reminderTime);
  }

  @override
  Future<void> scheduleDailyReminder(NotificationTime time) async {
    await _scheduleNotifications(time);
  }

  Future<void> _scheduleNotifications(NotificationTime? time) async {
    if (!(await _gateway.permissionStatus()).canSchedule) return;

    await _gateway.cancel(NotificationIds.dailyReminder);
    await _gateway.cancel(NotificationIds.streakSave);
    await _gateway.cancel(NotificationIds.examCountdown);
    await _gateway.cancel(NotificationIds.comeBack);

    final now = _now();
    final examDate = await _examDateReader();

    if (time == null) {
      // Reminders OFF: only examCountdown at 3, 2, 1 and day of
      if (examDate == null || examDate.precision != ExamDatePrecision.day) {
        return;
      }
      final fireDates = ExamCountdownSchedule.fireDates(examDate, from: now);
      for (final date in fireDates) {
        final daysLeft = examDate.daysUntil(date) ?? 0;
        if (daysLeft > 3) continue;

        final fireAt = DateTime(date.year, date.month, date.day, 9);
        if (fireAt.isBefore(now)) continue;

        final copy = _composer.examCountdown(
          daysLeft: daysLeft,
          examName: 'UPCAT',
        );
        final payload = NotificationPayload(
          kind: NotificationKind.examCountdown,
          scheduledFor: fireAt,
        );

        await _gateway.schedule(
          ScheduledNotification(
            id: NotificationIds.examCountdown,
            kind: NotificationKind.examCountdown,
            fireAt: fireAt,
            title: copy.title,
            body: copy.body,
            payload: payload.encode(),
          ),
        );
      }
      return;
    }

    // Reminders ON: All four kinds evaluated under Task 3 ceiling
    final candidateNotifications = <ScheduledNotification>[];
    final candidatePayloads = <NotificationPayload>[];

    // 1. Candidate: examCountdown
    if (examDate != null && examDate.precision == ExamDatePrecision.day) {
      final fireDates = ExamCountdownSchedule.fireDates(examDate, from: now);
      for (final date in fireDates) {
        final daysLeft = examDate.daysUntil(date) ?? 0;
        final fireAt = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        if (fireAt.isBefore(now)) continue;

        final copy = _composer.examCountdown(
          daysLeft: daysLeft,
          examName: 'UPCAT',
        );
        final payload = NotificationPayload(
          kind: NotificationKind.examCountdown,
          scheduledFor: fireAt,
        );
        candidatePayloads.add(payload);
        candidateNotifications.add(
          ScheduledNotification(
            id: NotificationIds.examCountdown,
            kind: NotificationKind.examCountdown,
            fireAt: fireAt,
            title: copy.title,
            body: copy.body,
            payload: payload.encode(),
          ),
        );
      }
    }

    // 2. Candidate: streakSave
    final streak = await _streakReader();
    final streakTime = _streakPolicy.streakSaveTime(time);
    final streakFireAt = DateTime(
      now.year,
      now.month,
      now.day,
      streakTime.hour,
      streakTime.minute,
    );
    if (_streakPolicy.shouldSchedule(
      streakLength: streak.streakLength,
      completedToday: streak.completedToday,
      now: now,
      fireAt: streakFireAt,
    )) {
      final streakCopy = _composer.streakSave(
        streakLength: streak.streakLength,
        freezesRemaining: streak.freezesRemaining,
      );
      final payload = NotificationPayload(
        kind: NotificationKind.streakSave,
        scheduledFor: streakFireAt,
      );
      candidatePayloads.add(payload);
      candidateNotifications.add(
        ScheduledNotification(
          id: NotificationIds.streakSave,
          kind: NotificationKind.streakSave,
          fireAt: streakFireAt,
          title: streakCopy.title,
          body: streakCopy.body,
          payload: payload.encode(),
        ),
      );
    }

    // 3. Candidate: dailyReminder
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
    final dailyPayload = NotificationPayload(
      kind: NotificationKind.dailyReminder,
      scheduledFor: dailyFireAt,
      route: plan.route,
    );
    candidatePayloads.add(dailyPayload);
    candidateNotifications.add(
      ScheduledNotification(
        id: NotificationIds.dailyReminder,
        kind: NotificationKind.dailyReminder,
        fireAt: dailyFireAt,
        title: dailyCopy.title,
        body: dailyCopy.body,
        payload: dailyPayload.encode(),
      ),
    );

    // 4. Candidate: comeBack
    final lapse = await _lapseReader();
    if (_lapsePolicy.shouldSchedule(
      lastSessionAt: lapse.lastSessionAt,
      now: now,
    )) {
      final comeBackCopy = _composer.comeBack(
        subjectName: lapse.subjectName,
        correctCount: lapse.correctCount,
        totalCount: lapse.totalCount,
      );
      if (comeBackCopy != null) {
        final comeBackFireAt = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );
        final payload = NotificationPayload(
          kind: NotificationKind.comeBack,
          scheduledFor: comeBackFireAt,
        );
        candidatePayloads.add(payload);
        candidateNotifications.add(
          ScheduledNotification(
            id: NotificationIds.comeBack,
            kind: NotificationKind.comeBack,
            fireAt: comeBackFireAt,
            title: comeBackCopy.title,
            body: comeBackCopy.body,
            payload: payload.encode(),
          ),
        );
      }
    }

    // Group candidate payloads by calendar day, then let the ceiling
    // pick one winner from each day.
    final payloadsByDay = <DateTime, List<NotificationPayload>>{};
    for (final payload in candidatePayloads) {
      final dayKey = DateTime(
        payload.scheduledFor.year,
        payload.scheduledFor.month,
        payload.scheduledFor.day,
      );
      payloadsByDay.putIfAbsent(dayKey, () => []).add(payload);
    }

    for (final dayPayloads in payloadsByDay.values) {
      final winnerPayload = NotificationCeiling.pick(dayPayloads);
      if (winnerPayload != null) {
        final winnerNotification = candidateNotifications.firstWhere(
          (n) =>
              n.kind == winnerPayload.kind &&
              n.fireAt == winnerPayload.scheduledFor,
        );
        await _gateway.schedule(winnerNotification);
      }
    }
  }
}
