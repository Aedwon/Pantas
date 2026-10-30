import 'package:pantas/core/notifications/notification_service.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/time/local_day.dart';
import 'package:pantas/core/time/pantas_dates.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/features/notifications/data/notifications_gateway.dart';
import 'package:pantas/features/notifications/domain/exam_countdown_schedule.dart';
import 'package:pantas/features/notifications/domain/notification_body_composer.dart';
import 'package:pantas/features/notifications/domain/notification_payload.dart';
import 'package:pantas/features/notifications/domain/reminder_prefs.dart';
import 'package:pantas/features/notifications/domain/reminder_schedule.dart';
import 'package:pantas/features/paywall/application/trial_ending_notifier.dart';

class ReminderPlanSnapshot {
  const ReminderPlanSnapshot({
    this.reviewCount,
    this.planState = DailyReminderPlanState.standard,
    this.todayStarted = false,
  });
  final int? reviewCount;
  final DailyReminderPlanState planState;
  final bool todayStarted;
}

class ReminderExamSnapshot {
  const ReminderExamSnapshot({this.date, this.name, this.flaggedCount = 0});
  final ExamDate? date;
  final String? name;
  final int flaggedCount;
}

class ReminderActivitySnapshot {
  const ReminderActivitySnapshot({
    this.lastSessionAt,
    this.subjectName,
    this.correctCount,
    this.totalCount,
  });
  final DateTime? lastSessionAt;
  final String? subjectName;
  final int? correctCount;
  final int? totalCount;
}

/// Keeps one come-back per lapse even when its time changes after delivery.
class ComeBackReservation {
  const ComeBackReservation({
    required this.lastSessionAt,
    required this.fireAt,
  });
  final DateTime lastSessionAt;
  final DateTime fireAt;
}

class ReminderService implements NotificationService, TrialEndingNotifier {
  ReminderService({
    required NotificationsGateway gateway,
    required Future<ReminderPrefs> Function() prefsReader,
    required Future<StudyDays> Function() studyDaysReader,
    required Future<ReminderPlanSnapshot> Function() planReader,
    required Future<ReminderExamSnapshot> Function() examReader,
    required Future<ReminderActivitySnapshot> Function() activityReader,
    required Future<ComeBackReservation?> Function() reservationReader,
    required Future<void> Function(ComeBackReservation) reservationWriter,
    required DateTime Function() now,
  })  : _gateway = gateway,
        _prefsReader = prefsReader,
        _studyDaysReader = studyDaysReader,
        _planReader = planReader,
        _examReader = examReader,
        _activityReader = activityReader,
        _reservationReader = reservationReader,
        _reservationWriter = reservationWriter,
        _now = now;

  final NotificationsGateway _gateway;
  final Future<ReminderPrefs> Function() _prefsReader;
  final Future<StudyDays> Function() _studyDaysReader;
  final Future<ReminderPlanSnapshot> Function() _planReader;
  final Future<ReminderExamSnapshot> Function() _examReader;
  final Future<ReminderActivitySnapshot> Function() _activityReader;
  final Future<ComeBackReservation?> Function() _reservationReader;
  final Future<void> Function(ComeBackReservation) _reservationWriter;
  final DateTime Function() _now;
  static const _composer = NotificationBodyComposer();
  Future<void> _pending = Future<void>.value();

  // Foreground, session and entitlement changes share the same OS queue.
  Future<void> _serial(Future<void> Function() action) {
    final result = _pending.then((_) => action());
    _pending = result.then((_) {}, onError: (Object _, StackTrace __) {});
    return result;
  }

  @override
  Future<void> rescheduleForForeground() => _serial(() async {
        await _reschedule(await _prefsReader());
      });

  @override
  Future<void> scheduleDailyReminder(NotificationTime time) =>
      _serial(() async {
        final prefs = await _prefsReader();
        await _reschedule(
          ReminderPrefs(
            dailyEnabled: true,
            dailyTime: time,
            followUpEnabled: prefs.followUpEnabled,
            followUpTime: prefs.followUpTime,
            countdownEnabled: prefs.countdownEnabled,
          ),
        );
      });

  Future<void> _reschedule(ReminderPrefs prefs) async {
    if (!(await _gateway.permissionStatus()).canSchedule) {
      await _gateway.cancelAll();
      return;
    }
    final now = _now();
    final days = await _studyDaysReader();
    final exam = await _examReader();
    final plan = await _planReader();
    final activity = await _activityReader();
    final reservation = await _reservationReader();
    final time = prefs.dailyEnabled
        ? prefs.dailyTime
        : const NotificationTime(hour: 19, minute: 0);
    final countdownDates =
        prefs.countdownEnabled && exam.name != null && exam.date != null
            ? ExamCountdownSchedule.fireDates(exam.date!, from: now)
            : <DateTime>[];
    final comebackCopy = _composer.comeBack(
      subjectName: activity.subjectName,
      correctCount: activity.correctCount,
      totalCount: activity.totalCount,
    );
    DateTime? comebackAt;
    final lastSession = activity.lastSessionAt;
    if (lastSession != null && comebackCopy != null) {
      if (reservation?.lastSessionAt == lastSession &&
          !reservation!.fireAt.isAfter(now)) {
        // The original delivery passed. Changing a setting cannot rearm it.
        comebackAt = reservation.fireAt;
      } else {
        var day = localDay(lastSession);
        for (var i = 0; i < 3; i++) {
          day = days.nextAfter(day)!;
        }
        comebackAt = _at(day, time);
      }
    }
    // Each countdown needs its own OS id. Reusing one id drops six dates.
    for (final id in [
      NotificationIds.dailyReminder,
      NotificationIds.followUp,
      NotificationIds.examCountdown,
      NotificationIds.comeBack,
      for (final offset in countdownDays) NotificationIds.countdown(offset),
    ]) {
      await _gateway.cancel(id);
    }
    for (final date in countdownDates) {
      final offset = exam.date!.daysUntil(date)!;
      await _post(
        NotificationIds.countdown(offset),
        NotificationKind.examCountdown,
        _at(
          date,
          offset == 0 ? const NotificationTime(hour: 7, minute: 0) : time,
        ),
        _composer.examCountdown(
          daysLeft: offset,
          examName: exam.name!,
          flaggedCount: exam.flaggedCount,
        ),
      );
    }
    if (comebackAt != null && comebackAt.isAfter(now)) {
      await _post(
        NotificationIds.comeBack,
        NotificationKind.comeBack,
        comebackAt,
        comebackCopy!,
      );
      await _reservationWriter(
        ComeBackReservation(lastSessionAt: lastSession!, fireAt: comebackAt),
      );
    }
    if (prefs.dailyEnabled) {
      final dailyAt = const ReminderSchedulerClock().nextOccurrence(
        now: now,
        time: prefs.dailyTime,
        studyDays: days,
      );
      if (!countdownDates.contains(localDay(dailyAt)) &&
          (comebackAt == null || localDay(comebackAt) != localDay(dailyAt))) {
        final copy =
            localDay(dailyAt) == localDay(now) && plan.reviewCount != null
                ? _composer.dailyReminder(
                    DailyReminderInput(
                      planState: plan.planState,
                      reviewCount: plan.reviewCount!,
                    ),
                  )
                : _composer.fallbackDailyReminder();
        await _post(
          NotificationIds.dailyReminder,
          NotificationKind.dailyReminder,
          dailyAt,
          copy,
        );
      }
      if (prefs.followUpEnabled && prefs.followUpAfterDaily) {
        final followAt = const ReminderSchedulerClock().nextOccurrence(
          now: now,
          time: prefs.followUpTime,
          studyDays: days,
        );
        if (localDay(followAt) != localDay(now) || !plan.todayStarted) {
          await _post(
            NotificationIds.followUp,
            NotificationKind.followUp,
            followAt,
            const NotificationCopy(
              title: 'Still time today',
              body: "One short session gets today's plan started.",
            ),
          );
        }
      }
    }
  }

  Future<void> _post(
    int id,
    NotificationKind kind,
    DateTime fireAt,
    NotificationCopy copy,
  ) async {
    if (!fireAt.isAfter(_now())) return;
    await _gateway.schedule(
      ScheduledNotification(
        id: id,
        kind: kind,
        fireAt: fireAt,
        title: copy.title,
        body: copy.body,
        payload: NotificationPayload(kind: kind, scheduledFor: fireAt).encode(),
      ),
    );
  }

  static DateTime _at(DateTime date, NotificationTime time) =>
      DateTime(date.year, date.month, date.day, time.hour, time.minute);

  /// Database activity starts suppressing Follow up before session completion.
  Future<void> onSessionStarted() => _serial(() async {
        await _gateway.cancel(NotificationIds.followUp);
        await _gateway.cancel(NotificationIds.comeBack);
      });

  @override
  Future<void> onSessionCompleted() => onSessionStarted();

  /// W3 passes the delivery instant, already 24 hours before the charge.
  @override
  Future<void> schedule(DateTime chargeAt, String priceText) =>
      _serial(() async {
        await _gateway.cancel(NotificationIds.trialEnding);
        if (!(await _gateway.permissionStatus()).canSchedule ||
            priceText.isEmpty) {
          return;
        }
        final chargeDate = chargeAt.add(const Duration(hours: 24)).toLocal();
        await _post(
          NotificationIds.trialEnding,
          NotificationKind.trialEnding,
          chargeAt,
          NotificationCopy(
            title: 'Pro trial ends in 1 day',
            body: 'Google Play charges $priceText on '
                '${PantasDates.short(chargeDate, now: _now())} to keep Pro. '
                'Cancel any time before then.',
          ),
        );
      });

  @override
  Future<void> cancel() =>
      _serial(() => _gateway.cancel(NotificationIds.trialEnding));
  @override
  Future<void> cancelAll() => _serial(_gateway.cancelAll);
  @override
  Future<NotificationPermission> requestPermission() =>
      _gateway.requestPermission();
  @override
  Future<void> openAppNotificationSettings() =>
      _gateway.openAppNotificationSettings();
}
