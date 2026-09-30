import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/features/notifications/application/notification_service.dart';
import 'package:pantas/features/notifications/application/notifications_providers.dart';
import 'package:pantas/features/notifications/data/notifications_gateway.dart';
import 'package:pantas/features/notifications/notifications.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';
import 'package:pantas/features/roadmap/domain/day_snapshot.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';

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
