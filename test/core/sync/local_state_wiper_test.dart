import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/notifications/notification_service.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/local_state_wiper.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  test('wipeAll cancels notifications before deleting synced state', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await _seedAccountOwnedState(db);
    final notifications = RecordingNotificationService(db);

    await SyncLocalStateWiper(
      db,
      notifications: notifications,
    ).wipeAll();

    expect(notifications.log, ['cancelAll']);
    expect(notifications.hadAttemptsAtCancellation, isTrue);
    expect(await db.select(db.attemptsLocal).get(), isEmpty);
  });

  test('wipeAll removes the study-days preference', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await db.into(db.accountPrefs).insert(
          AccountPrefsCompanion.insert(
            key: 'settings.study_days',
            value: '1,2,3,4,5',
          ),
        );
    expect(
      (await db.select(db.accountPrefs).get()).single.value,
      '1,2,3,4,5',
    );

    await SyncLocalStateWiper(db).wipeAll();

    expect(
      await (db.select(db.accountPrefs)
            ..where((pref) => pref.key.equals('settings.study_days')))
          .get(),
      isEmpty,
    );
  });

  test('wipeAll deletes all account-owned local state', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await _seedAccountOwnedState(db);

    await SyncLocalStateWiper(db).wipeAll();

    expect(await db.select(db.attemptsLocal).get(), isEmpty);
    expect(await db.select(db.assessmentResultsLocal).get(), isEmpty);
    expect(await db.select(db.reviewStateLocal).get(), isEmpty);
    expect(await db.select(db.streakLocal).get(), isEmpty);
    expect(await db.select(db.lessonProgressLocal).get(), isEmpty);
    expect(await db.select(db.lessonBookmarksLocal).get(), isEmpty);
    expect(await db.select(db.questionFlagsLocal).get(), isEmpty);
    expect(await db.select(db.accountPrefs).get(), isEmpty);
    expect(await db.select(db.pendingSync).get(), isEmpty);
    expect(await db.select(db.quizSessions).get(), isEmpty);
    expect(await db.select(db.dailyNewCardIntro).get(), isEmpty);
    expect(await db.select(db.mockAttempts).get(), isEmpty);
    expect(await db.select(db.userMetricsArchetypesLocal).get(), isEmpty);
    expect(await db.select(db.userMetricsArtifactsLocal).get(), isEmpty);
    expect(await db.select(db.reviewLogs).get(), isEmpty);
    expect(await db.select(db.trackScopeLocal).get(), isEmpty);
    expect(await db.select(db.customBlueprintsLocal).get(), isEmpty);
  });

  test(
      'wipeAll preserves device and reference state and only deviceId sync '
      'meta', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await _seedAccountOwnedState(db);
    await db.into(db.devicePrefs).insert(
          DevicePrefsCompanion.insert(key: 'selected_exam_id', value: 'cse'),
        );
    await db.into(db.appPreferencesLocal).insert(
          AppPreferencesLocalCompanion.insert(
            key: 'onboarding_complete',
            value: 'true',
          ),
        );
    await db.into(db.quizNudgeDismissedLocal).insert(
          QuizNudgeDismissedLocalCompanion.insert(
            dismissedAt: DateTime.utc(2026, 5, 18),
          ),
        );
    await db.into(db.syncMeta).insert(
          SyncMetaCompanion.insert(key: 'deviceId', value: 'device-1'),
        );
    await db.into(db.syncMeta).insert(
          SyncMetaCompanion.insert(key: 'failedSince', value: 'yesterday'),
        );

    await SyncLocalStateWiper(db).wipeAll();

    expect(await db.select(db.devicePrefs).get(), hasLength(1));
    expect(await db.select(db.appPreferencesLocal).get(), hasLength(1));
    expect(await db.select(db.quizNudgeDismissedLocal).get(), hasLength(1));
    expect((await db.select(db.syncMeta).get()).single.key, 'deviceId');
    expect(await db.select(db.exams).get(), hasLength(1));
    expect(await db.select(db.subjects).get(), hasLength(1));
    expect(await db.select(db.topics).get(), hasLength(1));
    expect(await db.select(db.lessons).get(), hasLength(1));
    expect(await db.select(db.questions).get(), hasLength(1));
  });
}

class RecordingNotificationService implements NotificationService {
  RecordingNotificationService(this.db);

  final AppDatabase db;
  final log = <String>[];
  bool hadAttemptsAtCancellation = false;

  @override
  Future<void> cancelAll() async {
    log.add('cancelAll');
    hadAttemptsAtCancellation =
        (await db.select(db.attemptsLocal).get()).isNotEmpty;
  }

  @override
  Future<void> onSessionCompleted() async {}

  @override
  Future<void> openAppNotificationSettings() async {}

  @override
  Future<NotificationPermission> requestPermission() async {
    return NotificationPermission.granted;
  }

  @override
  Future<void> rescheduleForForeground() async {}

  @override
  Future<void> scheduleDailyReminder(NotificationTime time) async {}
}

Future<void> _seedAccountOwnedState(AppDatabase db) async {
  final stamp = DateTime.utc(2026, 5, 18);
  await seedTopicWithQuestions(
    db,
    examId: 'cse',
    topicId: 'topic_1',
    topicName: 'Topic 1',
    questionIds: const ['q1'],
    lessonIds: const ['lesson_1'],
    questionLessonMap: const {'q1': 'lesson_1'},
  );
  await db.into(db.attemptsLocal).insert(
        AttemptsLocalCompanion.insert(
          id: 'a1',
          examId: 'cse',
          startedAt: stamp,
          completedAt: const Value(null),
          itemsJson: '[]',
        ),
      );
  await db.into(db.assessmentResultsLocal).insert(
        AssessmentResultsLocalCompanion.insert(
          examId: 'cse',
          completedAt: stamp,
          topicScoresJson: '{}',
        ),
      );
  await db.into(db.reviewStateLocal).insert(
        ReviewStateLocalCompanion.insert(
          questionId: 'q1',
          questionVersion: 1,
          stage: 'review',
          stability: 1,
          difficulty: 1,
          due: stamp.add(const Duration(days: 1)),
          lastReview: stamp,
          reps: 1,
          lapses: 0,
          elapsedDays: 1,
          scheduledDays: 1,
        ),
      );
  await db.into(db.streakLocal).insert(
        StreakLocalCompanion.insert(current: const Value(1)),
      );
  await db.into(db.lessonProgressLocal).insert(
        LessonProgressLocalCompanion.insert(
          lessonId: 'lesson_1',
          readAt: stamp,
        ),
      );
  await db.into(db.lessonBookmarksLocal).insert(
        LessonBookmarksLocalCompanion.insert(
          lessonId: 'lesson_1',
          markedAt: stamp,
        ),
      );
  await db.into(db.questionFlagsLocal).insert(
        QuestionFlagsLocalCompanion.insert(
          questionId: 'q1',
          flaggedAt: stamp,
        ),
      );
  await db.into(db.accountPrefs).insert(
        AccountPrefsCompanion.insert(key: 'reminder_time', value: '07:30'),
      );
  await db.into(db.pendingSync).insert(
        PendingSyncCompanion.insert(
          tableType: 'quiz_attempts',
          rowId: 'a1',
          op: 'upsert',
          queuedAt: stamp,
        ),
      );
  await db.into(db.quizSessions).insert(
        QuizSessionsCompanion.insert(
          id: 'session-1',
          userId: 'user-1',
          examId: 'cse',
          origin: 'quiz',
          questionIdsJson: '["q1"]',
          startedAt: stamp,
        ),
      );
  await db.into(db.dailyNewCardIntro).insert(
        DailyNewCardIntroCompanion.insert(
          userId: 'user-1',
          examId: 'cse',
          day: stamp,
        ),
      );
  await db.into(db.mockAttempts).insert(
        MockAttemptsCompanion.insert(
          id: 'mock-1',
          userId: 'user-1',
          examId: 'cse',
          blueprintId: 'blueprint-1',
          blueprintName: 'Practice',
          durationMinutes: 30,
          status: 'in_progress',
          strictMode: false,
          sampledQuestionsJson: '["q1"]',
          startedAt: stamp,
          lastFlushedAt: stamp,
          updatedAt: stamp,
        ),
      );
  await db.into(db.userMetricsArchetypesLocal).insert(
        UserMetricsArchetypesLocalCompanion.insert(
          userId: 'user-1',
          examId: 'cse',
          window: '30d',
          archetypeId: 'night-owl',
          matchScore: 0.8,
          synthesizedCopy: 'copy',
          computedAt: stamp,
          validUntil: stamp.add(const Duration(days: 1)),
        ),
      );
  await db.into(db.userMetricsArtifactsLocal).insert(
        UserMetricsArtifactsLocalCompanion.insert(
          userId: 'user-1',
          examId: 'cse',
          artifactId: 'artifact-1',
          shareId: 'share-1',
          payloadJson: '{}',
          firedAt: stamp,
        ),
      );
  await db.into(db.reviewLogs).insert(
        ReviewLogsCompanion.insert(
          id: 'review-1',
          questionId: 'q1',
          rating: 3,
          state: 2,
          due: stamp,
          stability: 1,
          difficulty: 1,
          elapsedDays: 1,
          lastElapsedDays: 1,
          scheduledDays: 1,
          review: stamp,
          durationMs: 1000,
          isCorrect: true,
        ),
      );
  await db.into(db.trackScopeLocal).insert(
        TrackScopeLocalCompanion.insert(examId: 'cse', topicId: 'topic_1'),
      );
  await db.into(db.customBlueprintsLocal).insert(
        CustomBlueprintsLocalCompanion.insert(
          examId: 'cse',
          totalQuestions: 50,
          totalMinutes: 60,
          sectionsJson: '[]',
          updatedAt: stamp,
        ),
      );
}
