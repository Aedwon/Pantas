import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/notifications/notification_service.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/features/notifications/application/reminder_service.dart';
import 'package:pantas/features/notifications/data/notifications_gateway.dart';
import 'package:pantas/features/notifications/domain/notification_body_composer.dart';
import 'package:pantas/features/notifications/domain/notification_payload.dart';
import 'package:pantas/features/notifications/domain/reminder_prefs.dart';
import 'package:pantas/features/paywall/application/trial_ending_notifier.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';

void main() {
  late _Gateway gateway;
  late ReminderPrefs prefs;
  late DateTime now;
  late StudyDays days;
  late ReminderPlanSnapshot plan;
  late ReminderExamSnapshot exam;
  late ReminderActivitySnapshot activity;
  ComeBackReservation? reservation;
  late ReminderService service;
  setUp(() {
    gateway = _Gateway();
    prefs = const ReminderPrefs(
      dailyEnabled: true,
      followUpEnabled: true,
      countdownEnabled: true,
    );
    now = DateTime(2026, 10, 1, 8);
    days = StudyDays.all;
    plan = const ReminderPlanSnapshot(reviewCount: 2);
    exam = const ReminderExamSnapshot();
    activity = const ReminderActivitySnapshot();
    reservation = null;
    service = ReminderService(
      gateway: gateway,
      prefsReader: () async => prefs,
      studyDaysReader: () async => days,
      planReader: () async => plan,
      examReader: () async => exam,
      activityReader: () async => activity,
      reservationReader: () async => reservation,
      reservationWriter: (value) async => reservation = value,
      now: () => now,
    );
  });
  test('daily and follow-up have separate times and both survive scheduling',
      () async {
    await service.rescheduleForForeground();
    expect(
      gateway.pending.values.map((n) => n.kind),
      [NotificationKind.dailyReminder, NotificationKind.followUp],
    );
    expect(
      gateway.pending.values.map((n) => n.fireAt),
      [DateTime(2026, 10, 1, 19), DateTime(2026, 10, 1, 21)],
    );
    expect(gateway.pending.values.last.title, 'Still time today');
    expect(
      gateway.pending.values.last.body,
      "One short session gets today's plan started.",
    );
  });
  test('daily and follow-up skip rest days without borrowing today figures',
      () async {
    now = DateTime(2026, 10, 3, 8);
    days = StudyDays(const [1, 2, 3, 4, 5]);
    await service.rescheduleForForeground();
    expect(
      gateway.pending.values.map((n) => n.fireAt),
      [DateTime(2026, 10, 5, 19), DateTime(2026, 10, 5, 21)],
    );
    expect(gateway.pending.values.first.body, "You've got this.");
  });
  test('follow-up waits until after daily and never follows a started Today',
      () async {
    plan = const ReminderPlanSnapshot(reviewCount: 2, todayStarted: true);
    await service.rescheduleForForeground();
    expect(
      gateway.pending.values.map((n) => n.kind),
      [NotificationKind.dailyReminder],
    );
    plan = const ReminderPlanSnapshot(reviewCount: 2);
    prefs = const ReminderPrefs(
      dailyEnabled: true,
      followUpEnabled: true,
      followUpTime: NotificationTime(hour: 18, minute: 59),
      countdownEnabled: false,
    );
    await service.rescheduleForForeground();
    expect(
      gateway.pending.values.map((n) => n.kind),
      [NotificationKind.dailyReminder],
    );
  });
  test('starting or completing a session removes the pending follow-up',
      () async {
    await service.rescheduleForForeground();
    await service.onSessionStarted();
    expect(
      gateway.pending.values.map((n) => n.kind),
      [NotificationKind.dailyReminder],
    );
    await service.rescheduleForForeground();
    await service.onSessionCompleted();
    expect(
      gateway.pending.values.map((n) => n.kind),
      [NotificationKind.dailyReminder],
    );
  });
  test(
      'daily off suppresses follow-up but keeps the full countdown '
      'independently', () async {
    prefs = const ReminderPrefs(
      dailyEnabled: false,
      followUpEnabled: true,
      countdownEnabled: true,
    );
    exam = ReminderExamSnapshot(
      name: 'CSE Professional',
      date: ExamDate.onDay(DateTime(2026, 10, 31)),
    );
    await service.rescheduleForForeground();
    expect(gateway.pending.length, 7);
    expect(gateway.pending.values.map((n) => n.fireAt), [
      DateTime(2026, 10, 1, 19),
      DateTime(2026, 10, 17, 19),
      DateTime(2026, 10, 24, 19),
      DateTime(2026, 10, 28, 19),
      DateTime(2026, 10, 29, 19),
      DateTime(2026, 10, 30, 19),
      DateTime(2026, 10, 31, 7),
    ]);
    expect(gateway.pending.values.first.title, '30 days to CSE Professional');
    expect(gateway.pending.values.last.title, "Today's the day.");
    expect(gateway.pending.values.last.body, 'Good luck.');
  });
  test(
      'countdown replaces its daily reminder and retains follow-up on that day',
      () async {
    exam = ReminderExamSnapshot(
      name: 'UPCAT',
      date: ExamDate.onDay(DateTime(2026, 10, 8)),
      flaggedCount: 4,
    );
    await service.rescheduleForForeground();
    expect(
      gateway.pending.values
          .where((n) => n.kind == NotificationKind.dailyReminder),
      isEmpty,
    );
    expect(
      gateway.pending.values
          .where((n) => n.kind == NotificationKind.followUp)
          .single
          .fireAt,
      DateTime(2026, 10, 1, 21),
    );
    expect(
      gateway.pending.values.first.body,
      "You've got 4 questions flagged. Want to clear them?",
    );
  });
  test('countdown runs on rest days at chosen daily time and exam day 07:00',
      () async {
    now = DateTime(2026, 10, 3, 8);
    days = StudyDays(const [1]);
    prefs = const ReminderPrefs(
      dailyEnabled: true,
      dailyTime: NotificationTime(hour: 18, minute: 30),
      followUpEnabled: false,
      countdownEnabled: true,
    );
    exam = ReminderExamSnapshot(
      name: 'UPCAT',
      date: ExamDate.onDay(DateTime(2026, 10, 4)),
    );
    await service.rescheduleForForeground();
    final countdowns = gateway.pending.values
        .where((n) => n.kind == NotificationKind.examCountdown);
    expect(
      countdowns.map((n) => n.fireAt),
      [DateTime(2026, 10, 3, 18, 30), DateTime(2026, 10, 4, 7)],
    );
  });
  test(
      'countdown off, absent date, month precision and passed dates schedule '
      'none', () async {
    for (final date in [
      null,
      ExamDate.inMonth(year: 2026, month: 10),
      ExamDate.onDay(DateTime(2026, 9, 30)),
    ]) {
      exam = ReminderExamSnapshot(name: 'UPCAT', date: date);
      await service.rescheduleForForeground();
      expect(
        gateway.pending.values
            .where((n) => n.kind == NotificationKind.examCountdown),
        isEmpty,
      );
    }
    exam = ReminderExamSnapshot(
      name: 'UPCAT',
      date: ExamDate.onDay(DateTime(2026, 10, 8)),
    );
    prefs = const ReminderPrefs(
      dailyEnabled: true,
      followUpEnabled: false,
      countdownEnabled: false,
    );
    await service.rescheduleForForeground();
    expect(gateway.pending.length, 1);
  });
  test(
      'come-back schedules ahead for third missed study day and replaces '
      'daily then', () async {
    days = StudyDays(const [1, 2, 3, 4, 5]);
    activity = ReminderActivitySnapshot(
      lastSessionAt: DateTime(2026, 9, 28, 10),
      subjectName: 'Chemistry',
      correctCount: 12,
      totalCount: 20,
    );
    await service.rescheduleForForeground();
    final comeback = gateway.pending.values
        .where((n) => n.kind == NotificationKind.comeBack)
        .single;
    expect(comeback.fireAt, DateTime(2026, 10, 1, 19));
    expect(
      comeback.body,
      'You got 12 of 20 last time. One session picks it back up.',
    );
    expect(
      gateway.pending.values
          .where((n) => n.kind == NotificationKind.dailyReminder),
      isEmpty,
    );
    expect(
      gateway.pending.values.where((n) => n.kind == NotificationKind.followUp),
      hasLength(1),
    );
    now = DateTime(2026, 10, 1, 20);
    prefs = const ReminderPrefs(
      dailyEnabled: true,
      dailyTime: NotificationTime(hour: 22, minute: 0),
      followUpEnabled: false,
      countdownEnabled: false,
    );
    await service.rescheduleForForeground();
    expect(
      gateway.pending.values.where((n) => n.kind == NotificationKind.comeBack),
      isEmpty,
    );
  });
  test(
      'come-back skips rest days, works with daily off, and rearms only after '
      'a session', () async {
    now = DateTime(2026, 10, 1, 8);
    days = StudyDays(const [1, 2, 3, 4, 5]);
    prefs = const ReminderPrefs(
      dailyEnabled: false,
      followUpEnabled: false,
      countdownEnabled: false,
    );
    activity = ReminderActivitySnapshot(
      lastSessionAt: DateTime(2026, 10, 1, 7),
      subjectName: 'Math',
      correctCount: 2,
      totalCount: 3,
    );
    await service.rescheduleForForeground();
    expect(gateway.pending.values.single.fireAt, DateTime(2026, 10, 6, 19));
    now = DateTime(2026, 10, 7, 8);
    await service.rescheduleForForeground();
    expect(gateway.pending, isEmpty);
    activity = ReminderActivitySnapshot(
      lastSessionAt: DateTime(2026, 10, 7, 7),
      subjectName: 'Math',
      correctCount: 3,
      totalCount: 3,
    );
    await service.rescheduleForForeground();
    expect(gateway.pending.values.single.fireAt, DateTime(2026, 10, 12, 19));
  });
  test('come-back requires a real subject and valid measured score', () async {
    for (final score in [
      (null, 12, 20),
      ('Math', -1, 20),
      ('Math', 21, 20),
      ('Math', 0, 0),
    ]) {
      activity = ReminderActivitySnapshot(
        lastSessionAt: DateTime(2026, 9, 28),
        subjectName: score.$1,
        correctCount: score.$2,
        totalCount: score.$3,
      );
      await service.rescheduleForForeground();
      expect(
        gateway.pending.values
            .where((n) => n.kind == NotificationKind.comeBack),
        isEmpty,
      );
    }
  });
  test(
      'denied or unanswered permission removes pending work and schedules '
      'nothing', () async {
    await service.rescheduleForForeground();
    for (final permission in [
      NotificationPermission.denied,
      NotificationPermission.notYetAsked,
    ]) {
      gateway.permission = permission;
      await service.rescheduleForForeground();
      await service.schedule(DateTime(2026, 10, 2, 12), '₱149');
      expect(gateway.pending, isEmpty);
    }
  });
  test(
      'trial ending uses store price and charge date and coexists with both '
      'daily messages', () async {
    final scheduler =
        TrialEndingScheduler(service, priceTextFor: (_) => '₱149');
    final trial = Entitlement(
      plan: EntitlementPlan.monthly,
      productId: 'pantas_cs_monthly',
      isTrial: true,
      expiresAt: DateTime(2026, 10, 3, 12),
    );
    await scheduler.sync(trial);
    await service.rescheduleForForeground();
    final notification = gateway.pending.values
        .where((n) => n.kind == NotificationKind.trialEnding)
        .single;
    expect(notification.fireAt, DateTime(2026, 10, 2, 12));
    expect(
      notification.body,
      'Google Play charges ₱149 on Oct 3 to keep Pro. Cancel any time before '
      'then.',
    );
    expect(gateway.pending.length, 3);
    await scheduler.sync(const Entitlement(plan: EntitlementPlan.monthly));
    expect(gateway.pending.length, 2);
  });
  test('past trial notification is never sent late', () async {
    await service.schedule(DateTime(2026, 9, 30, 12), '₱99');
    expect(gateway.pending, isEmpty);
  });
  test('daily copy variants still use measured reviews', () async {
    prefs = const ReminderPrefs(
      dailyEnabled: true,
      followUpEnabled: false,
      countdownEnabled: false,
    );
    for (final variant in DailyReminderPlanState.values) {
      plan = ReminderPlanSnapshot(reviewCount: 2, planState: variant);
      await service.rescheduleForForeground();
      expect(
        gateway.pending.values.single.title,
        switch (variant) {
          DailyReminderPlanState.standard => "Today's session is ready",
          DailyReminderPlanState.mock => 'Mock exam day',
          DailyReminderPlanState.behind => 'Welcome back',
          DailyReminderPlanState.calm => 'Quick check-in',
          DailyReminderPlanState.firstPostDiagnostic => 'Your plan is set',
        },
      );
    }
  });
}

class _Gateway implements NotificationsGateway {
  final pending = <int, ScheduledNotification>{};
  NotificationPermission permission = NotificationPermission.granted;
  @override
  Future<void> schedule(ScheduledNotification n) async => pending[n.id] = n;
  @override
  Future<void> cancel(int id) async => pending.remove(id);
  @override
  Future<void> cancelAll() async => pending.clear();
  @override
  Future<void> initialize() async {}
  @override
  Future<void> openAppNotificationSettings() async {}
  @override
  Future<NotificationPermission> permissionStatus() async => permission;
  @override
  Future<NotificationPermission> requestPermission() async => permission;
  @override
  Future<String?> initialNotificationTapPayload() async => null;
  @override
  Stream<String?> get notificationTapPayloads => const Stream.empty();
  @override
  Stream<NotificationPermission> watchPermissionStatus() =>
      Stream.value(permission);
}
