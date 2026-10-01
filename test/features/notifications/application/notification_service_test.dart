import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/features/notifications/application/notification_service.dart';
import 'package:pantas/features/notifications/application/notifications_providers.dart';
import 'package:pantas/features/notifications/data/notifications_gateway.dart';
import 'package:pantas/features/notifications/notifications.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';
import 'package:pantas/features/roadmap/domain/day_snapshot.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  group('roadmap reminder provider', () {
    const exam = Exam(
      id: 'upcat',
      code: 'UPCAT',
      name: 'UPCAT',
      shortName: 'UPCAT',
      language: 'en',
      isActive: true,
      subjects: [],
    );
    final day = DateTime(2026, 10);
    late RecordingNotificationsGateway gateway;
    late ProviderContainer container;
    late RoadmapToday today;
    late ActiveExamFocus focus;

    RoadmapToday planned({
      RoadmapState state = RoadmapState.planning,
      bool mock = false,
      List<String> remainingReviews = const ['r2', 'r3'],
    }) {
      return RoadmapToday(
        snapshot: DaySnapshot(
          plan: DayPlan(
            day: day,
            lessonIds: const [],
            reviewQuestionIds: const ['r1', 'r2', 'r3'],
            newQuestionIds: const ['n1', 'n2', 'n3', 'n4'],
            isMockDay: mock,
            advancedIds: const {},
          ),
          digest: RoadmapDigest(
            examId: 'upcat',
            examDate: '2026-12-07:day',
            scopeTopicIds: const ['chemistry'],
            contentRevision: 'test',
            assessmentCompleted: state != RoadmapState.needsAssessment,
            recordedMockCount: 0,
          ),
          topicOrderHead: const ['chemistry'],
          state: state,
        ),
        remaining: DayPlan(
          day: day,
          lessonIds: const [],
          reviewQuestionIds: remainingReviews,
          newQuestionIds: const ['n1', 'n2', 'n3', 'n4'],
          isMockDay: mock,
          advancedIds: const {},
        ),
        originalDone: false,
      );
    }

    setUp(() {
      gateway = RecordingNotificationsGateway()
        ..permission = NotificationPermission.granted;
      today = planned();
      focus = const ActiveExamFocus.selected(exam);
      container = ProviderContainer(
        overrides: [
          notificationsGatewayProvider.overrideWithValue(gateway),
          notificationStudyDaysReaderProvider
              .overrideWithValue(() async => StudyDays.all),
          activeExamFocusProvider.overrideWith((ref) async => focus),
          roadmapTodayProvider('upcat').overrideWith((ref) async => today),
        ],
      );
    });

    tearDown(() => container.dispose());

    Future<ScheduledNotification> remind() async {
      await container
          .read(featureNotificationServiceProvider)
          .scheduleDailyReminder(const NotificationTime(hour: 19, minute: 0));
      return gateway.scheduled.last;
    }

    for (final state in RoadmapState.values.where(
      (state) =>
          state != RoadmapState.needsAssessment &&
          state != RoadmapState.noContent,
    )) {
      test('${state.name} uses remaining review count and the quiz route',
          () async {
        today = planned(state: state);

        final notification = await remind();

        expect(notification.body, "2 questions to review. You've got this.");
        expect(
          NotificationPayload.tryDecode(notification.payload)?.route,
          '/quiz',
        );
      });
    }

    test('mock day uses the mock reminder and quiz route', () async {
      today = planned(mock: true);

      final notification = await remind();

      expect(notification.title, 'Mock exam day');
      expect(
        NotificationPayload.tryDecode(notification.payload)?.route,
        '/quiz',
      );
    });

    test('zero reviews uses the standard reminder', () async {
      today = planned(remainingReviews: []);

      final notification = await remind();

      expect(notification.body, "0 questions to review. You've got this.");
      expect(
        NotificationPayload.tryDecode(notification.payload)?.route,
        '/quiz',
      );
    });

    for (final state in [
      RoadmapState.needsAssessment,
      RoadmapState.noContent,
    ]) {
      test('${state.name} uses the unavailable fallback even on a mock day',
          () async {
        today = planned(state: state, mock: true);

        final notification = await remind();

        expect(notification.title, "Time for today's session");
        expect(
          NotificationPayload.tryDecode(notification.payload)?.route,
          isNull,
        );
      });
    }

    test('no selected exam uses the unavailable fallback', () async {
      focus = const ActiveExamFocus.needsSelection();

      final notification = await remind();

      expect(notification.title, "Time for today's session");
      expect(
        NotificationPayload.tryDecode(notification.payload)?.route,
        isNull,
      );
    });

    test('each scheduling reads the current remaining reviews', () async {
      await remind();
      today = planned(remainingReviews: ['r3']);
      container.invalidate(roadmapTodayProvider('upcat'));

      final notification = await remind();

      expect(notification.body, "1 questions to review. You've got this.");
    });
  });

  for (final foreground in [false, true]) {
    test('study-day reader applies when foreground is $foreground', () async {
      final gateway = RecordingNotificationsGateway()
        ..permission = NotificationPermission.granted;
      var days = StudyDays(const [1, 2, 3, 4, 5]);
      final service = NotificationServiceImpl(
        gateway: gateway,
        settingsReader: () async =>
            NotificationSettingsSnapshot.daily(hour: 19, minute: 0),
        studyDaysReader: () async => days,
        planReader: () async => const NotificationPlanSnapshot.unavailable(),
        streakReader: () async => const NotificationStreakSnapshot(
          streakLength: 5,
          freezesRemaining: 1,
          completedToday: false,
        ),
        now: () => DateTime(2026, 10, 3, 12),
      );
      Future<void> schedule() => foreground
          ? service.rescheduleForForeground()
          : service.scheduleDailyReminder(
              const NotificationTime(hour: 19, minute: 0),
            );
      await schedule();
      expect(gateway.scheduled.single.kind, NotificationKind.dailyReminder);
      expect(gateway.scheduled.single.fireAt, DateTime(2026, 10, 5, 19));
      days = StudyDays(const [7]);
      gateway.scheduled.clear();
      await schedule();
      expect(gateway.scheduled.single.fireAt, DateTime(2026, 10, 4, 19));
    });
  }

  for (final scenario in [
    (
      name: 'Saturday schedules Monday without rest-day counts',
      now: DateTime(2026, 10, 3, 12),
      days: StudyDays(const [1, 2, 3, 4, 5]),
      fireAt: DateTime(2026, 10, 5, 19),
      reviews: 0,
      planState: DailyReminderPlanState.standard,
    ),
    (
      name: 'all seven after reminder time uses generic text tomorrow',
      now: DateTime(2026, 10, 1, 20),
      days: StudyDays.all,
      fireAt: DateTime(2026, 10, 2, 19),
      reviews: 14,
      planState: DailyReminderPlanState.standard,
    ),
    (
      name: 'a future reminder cannot claim today is mock day',
      now: DateTime(2026, 10, 1, 20),
      days: StudyDays.all,
      fireAt: DateTime(2026, 10, 2, 19),
      reviews: 0,
      planState: DailyReminderPlanState.mock,
    ),
  ]) {
    test(scenario.name, () async {
      final gateway = RecordingNotificationsGateway()
        ..permission = NotificationPermission.granted;
      final service = NotificationServiceImpl(
        gateway: gateway,
        settingsReader: () async =>
            NotificationSettingsSnapshot.daily(hour: 19, minute: 0),
        studyDaysReader: () async => scenario.days,
        planReader: () async => NotificationPlanSnapshot.ready(
          reviewCount: scenario.reviews,
          route: '/quiz',
          planState: scenario.planState,
        ),
        streakReader: () async => const NotificationStreakSnapshot.empty(),
        now: () => scenario.now,
      );
      await service.scheduleDailyReminder(
        const NotificationTime(hour: 19, minute: 0),
      );
      final notification = gateway.scheduled.single;
      expect(notification.fireAt, scenario.fireAt);
      final fallback = const NotificationBodyComposer().fallbackDailyReminder();
      expect(notification.title, fallback.title);
      expect(notification.body, fallback.body);
      final payload = NotificationPayload.tryDecode(notification.payload)!;
      expect(payload.kind, NotificationKind.dailyReminder);
      expect(payload.scheduledFor, scenario.fireAt);
      expect(payload.route, isNull);
    });
  }

  test('foreground schedules comeback at the third missed study day', () async {
    final gateway = RecordingNotificationsGateway()
      ..permission = NotificationPermission.granted;
    var now = DateTime(2026, 10, 3, 12);
    final service = NotificationServiceImpl(
      gateway: gateway,
      settingsReader: () async =>
          NotificationSettingsSnapshot.daily(hour: 19, minute: 0),
      studyDaysReader: () async => StudyDays(const [1, 2, 3, 4, 5]),
      planReader: () async => const NotificationPlanSnapshot.unavailable(),
      streakReader: () async => const NotificationStreakSnapshot.empty(),
      lapseReader: () async => NotificationLapseSnapshot(
        lastSessionAt: DateTime(2026, 10),
        subjectName: 'Chemistry',
        correctCount: 12,
        totalCount: 20,
      ),
      now: () => now,
      // Put the competing daily reminder on the next day so the ceiling
      // does not hide the comeback candidate being tested.
      schedulerClock: const NextStudyDayReminderClock(),
    );
    await service.rescheduleForForeground();
    expect(
      gateway.scheduled.map((n) => n.kind),
      [NotificationKind.dailyReminder],
    );
    gateway.scheduled.clear();
    now = DateTime(2026, 10, 6, 12);
    await service.rescheduleForForeground();
    final comeback = gateway.scheduled
        .where((n) => n.kind == NotificationKind.comeBack)
        .single;
    expect(comeback.fireAt, DateTime(2026, 10, 6, 19));
  });

  test('exam countdown remains scheduled on a rest day', () async {
    final gateway = RecordingNotificationsGateway()
      ..permission = NotificationPermission.granted;
    final service = NotificationServiceImpl(
      gateway: gateway,
      settingsReader: () async => const NotificationSettingsSnapshot.none(),
      studyDaysReader: () async => StudyDays(const [1, 2, 3, 4, 5]),
      planReader: () async => const NotificationPlanSnapshot.unavailable(),
      streakReader: () async => const NotificationStreakSnapshot.empty(),
      examDateReader: () async => ExamDate.onDay(DateTime(2026, 10, 4)),
      now: () => DateTime(2026, 10, 3, 8),
    );
    await service.rescheduleForForeground();
    expect(
      gateway.scheduled.map((n) => n.kind),
      everyElement(NotificationKind.examCountdown),
    );
    expect(gateway.scheduled.first.fireAt, DateTime(2026, 10, 3, 9));
  });

  test('notification provider reads stored study days afresh', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final gateway = RecordingNotificationsGateway()
      ..permission = NotificationPermission.granted;
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        notificationsGatewayProvider.overrideWithValue(gateway),
        activeExamFocusProvider.overrideWith(
          (ref) async => const ActiveExamFocus.needsSelection(),
        ),
      ],
    );
    addTearDown(container.dispose);
    // Only one weekday makes the expected fire date independent of wall time.
    final now = DateTime.now();
    final target = DateTime(now.year, now.month, now.day + 2);
    await db.into(db.accountPrefs).insert(
          AccountPrefsCompanion.insert(
            key: 'settings.study_days',
            value: '${target.weekday}',
          ),
        );
    await container
        .read(featureNotificationServiceProvider)
        .scheduleDailyReminder(const NotificationTime(hour: 19, minute: 0));
    expect(
      gateway.scheduled.single.fireAt,
      DateTime(target.year, target.month, target.day, 19),
    );
    gateway.scheduled.clear();
    await db.into(db.accountPrefs).insertOnConflictUpdate(
          AccountPrefsCompanion.insert(
            key: 'settings.study_days',
            value: '${DateTime(now.year, now.month, now.day + 3).weekday}',
          ),
        );
    await container
        .read(featureNotificationServiceProvider)
        .scheduleDailyReminder(const NotificationTime(hour: 19, minute: 0));
    expect(
      gateway.scheduled.single.fireAt,
      DateTime(now.year, now.month, now.day + 3, 19),
    );
  });

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

class NextStudyDayReminderClock extends ReminderSchedulerClock {
  const NextStudyDayReminderClock();

  @override
  DateTime nextOccurrence({
    required DateTime now,
    required NotificationTime time,
    StudyDays studyDays = StudyDays.all,
  }) {
    final next = studyDays.nextAfter(now)!;
    return DateTime(next.year, next.month, next.day, time.hour, time.minute);
  }
}
