import 'dart:async';

import 'package:drift/drift.dart' show Value;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/notifications/notification_service.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/notifications/application/notifications_providers.dart';
import 'package:pantas/features/notifications/data/notifications_gateway.dart';
import 'package:pantas/features/notifications/data/reminder_activity_reader.dart';
import 'package:pantas/features/notifications/domain/notification_payload.dart';
import 'package:pantas/features/notifications/domain/reminder_prefs.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/paywall_offering.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';
import 'package:pantas/features/roadmap/domain/day_snapshot.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ContentDatabase content;
  late ProviderContainer container;
  late _Gateway gateway;
  late Exam exam;
  late StreamController<Entitlement> entitlements;
  final day = DateTime(2026, 10);
  setUp(() async {
    db = inMemoryDatabase();
    content = inMemoryContentDatabase();
    gateway = _Gateway();
    entitlements = StreamController<Entitlement>.broadcast();
    await seedContentExam(content, examId: 'upcat', name: 'UPCAT');
    await seedContentSubject(
      content,
      subjectId: 'science',
      examId: 'upcat',
      name: 'Science',
    );
    await seedContentTopic(content, topicId: 'chemistry', subjectId: 'science');
    await seedContentQuestion(
      content,
      questionId: 'q1',
      topicId: 'chemistry',
      examId: 'upcat',
    );
    await seedContentQuestion(
      content,
      questionId: 'q2',
      topicId: 'chemistry',
      examId: 'upcat',
    );
    final repo = ContentRepository(content);
    exam = (await repo.listExams()).single;
    final today = RoadmapToday(
      snapshot: DaySnapshot(
        plan: DayPlan(
          day: day,
          lessonIds: const [],
          reviewQuestionIds: const ['q1', 'q2'],
          newQuestionIds: const [],
          isMockDay: false,
          advancedIds: const {},
        ),
        digest: RoadmapDigest(
          examId: 'upcat',
          examDate: 'not_set',
          scopeTopicIds: const ['chemistry'],
          contentRevision: 'test',
          assessmentCompleted: true,
          recordedMockCount: 0,
        ),
        topicOrderHead: const ['chemistry'],
      ),
      remaining: DayPlan(
        day: day,
        lessonIds: const [],
        reviewQuestionIds: const ['q2'],
        newQuestionIds: const [],
        isMockDay: false,
        advancedIds: const {},
      ),
      originalDone: false,
    );
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(content),
        notificationsGatewayProvider.overrideWithValue(gateway),
        notificationClockProvider
            .overrideWithValue(() => DateTime(2026, 10, 1, 8)),
        activeExamFocusProvider
            .overrideWith((ref) async => ActiveExamFocus.selected(exam)),
        roadmapTodayProvider('upcat').overrideWith((ref) async => today),
        entitlementProvider.overrideWith((ref) => entitlements.stream),
        paywallOfferingProvider.overrideWith(
          (ref) async => const PaywallOfferingResult(
            status: PaywallOfferingStatus.available,
            recognizedPackages: [
              PaywallPackage(
                sku: PaywallSku.monthly,
                productId: 'pantas_cs_monthly',
                priceString: '₱149',
                priceAmount: 149,
              ),
            ],
          ),
        ),
      ],
    );
    await DriftSettingsRepository(db).updateReminderPrefs(
      const ReminderPrefs(
        dailyEnabled: true,
        followUpEnabled: true,
        countdownEnabled: false,
      ),
    );
  });
  tearDown(() async {
    container.dispose();
    await entitlements.close();
    await db.close();
    await content.close();
  });

  test('feature binding reads current settings and measured roadmap counts',
      () async {
    final service = container.read(featureNotificationServiceProvider);
    await service.rescheduleForForeground();
    expect(
      gateway.pending.values.first.body,
      "1 questions to review. You've got this.",
    );
    await DriftSettingsRepository(db).updateReminderPrefs(
      const ReminderPrefs(
        dailyEnabled: false,
        followUpEnabled: true,
        countdownEnabled: false,
      ),
    );
    await service.rescheduleForForeground();
    expect(gateway.pending, isEmpty);
  });

  test('recorded quiz start suppresses and cancels follow-up before completion',
      () async {
    final service = container.read(featureNotificationServiceProvider);
    await service.rescheduleForForeground();
    expect(
      gateway.pending.values.where((n) => n.kind == NotificationKind.followUp),
      hasLength(1),
    );
    await db.into(db.quizSessions).insert(
          QuizSessionsCompanion.insert(
            id: 'started',
            userId: 'u',
            examId: 'upcat',
            origin: 'today_topic',
            questionIdsJson: '["q1"]',
            startedAt: DateTime(2026, 10, 1, 9),
          ),
        );
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(
      gateway.pending.values.where((n) => n.kind == NotificationKind.followUp),
      isEmpty,
    );
    await service.rescheduleForForeground();
    expect(
      gateway.pending.values.where((n) => n.kind == NotificationKind.followUp),
      isEmpty,
    );
  });

  test('another exam start cannot cancel the active exam follow-up', () async {
    final service = container.read(featureNotificationServiceProvider);
    await service.rescheduleForForeground();
    await db.into(db.quizSessions).insert(QuizSessionsCompanion.insert(
          id: 'other-start',
          userId: 'u',
          examId: 'other',
          origin: 'today_topic',
          questionIdsJson: '["x"]',
          startedAt: DateTime(2026, 10, 1, 7),
        ));
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(
        gateway.pending.values
            .where((n) => n.kind == NotificationKind.followUp),
        hasLength(1));
  });

  test('resuming an older session today also suppresses follow-up', () async {
    await db.into(db.quizSessions).insert(QuizSessionsCompanion.insert(
          id: 'resumed',
          userId: 'u',
          examId: 'upcat',
          origin: 'today_topic',
          questionIdsJson: '["q1"]',
          startedAt: DateTime(2026, 9, 30, 7),
          lastAnsweredAt: Value(DateTime(2026, 10, 1, 7)),
        ));
    final service = container.read(featureNotificationServiceProvider);
    await service.rescheduleForForeground();
    expect(
        gateway.pending.values
            .where((n) => n.kind == NotificationKind.followUp),
        isEmpty);
  });

  test(
      'activity reader names only the measured subject score and reads starts '
      'across exams separately', () async {
    final items = [
      const AttemptItem(
        questionId: 'q1',
        questionVersion: 1,
        chosenChoiceId: 'q1_a',
        correctChoiceId: 'q1_a',
        responseMs: 1000,
      ),
      const AttemptItem(
        questionId: 'q2',
        questionVersion: 1,
        chosenChoiceId: 'q2_b',
        correctChoiceId: 'q2_a',
        responseMs: 1000,
      ),
    ];
    await container.read(attemptsRepositoryProvider).save(
          Attempt(
            id: 'attempt',
            examId: 'upcat',
            startedAt: DateTime(2026, 9, 28, 9),
            completedAt: DateTime(2026, 9, 28, 10),
            items: items,
          ),
        );
    final reader = ReminderActivityReader(db, ContentRepository(content));
    final result = await reader.read(exam);
    expect(result.subjectName, 'Science');
    expect(result.correctCount, 1);
    expect(result.totalCount, 2);
    expect(result.lastSessionAt, DateTime(2026, 9, 28, 10));
    expect(await reader.todayStarted('upcat', DateTime(2026, 10)), isFalse);
    expect(await reader.lastSessionAt('other'), isNull);
  });

  test(
      'trial eligibility, store price and cancellation reach the real feature '
      'binding', () async {
    container.read(featureNotificationServiceProvider);
    await container.read(paywallOfferingProvider.future);
    entitlements.add(
      Entitlement(
        plan: EntitlementPlan.monthly,
        productId: 'pantas_cs_monthly',
        isTrial: true,
        expiresAt: DateTime(2026, 10, 3, 12),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 30));
    final trial = gateway.pending.values
        .where((n) => n.kind == NotificationKind.trialEnding)
        .single;
    expect(trial.fireAt, DateTime(2026, 10, 2, 12));
    expect(trial.body, contains('₱149 on Oct 3'));
    entitlements.add(const Entitlement(plan: EntitlementPlan.monthly));
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(
      gateway.pending.values
          .where((n) => n.kind == NotificationKind.trialEnding),
      isEmpty,
    );
  });
}

class _Gateway implements NotificationsGateway {
  final pending = <int, ScheduledNotification>{};
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
  Future<NotificationPermission> permissionStatus() async =>
      NotificationPermission.granted;
  @override
  Future<NotificationPermission> requestPermission() async =>
      NotificationPermission.granted;
  @override
  Future<String?> initialNotificationTapPayload() async => null;
  @override
  Stream<String?> get notificationTapPayloads => const Stream.empty();
  @override
  Stream<NotificationPermission> watchPermissionStatus() =>
      Stream.value(NotificationPermission.granted);
}
