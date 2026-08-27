import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/local_state_wiper.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  test('hasMeaningfulProgress is false for non-meaningful local state',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final stamp = DateTime.utc(2026, 5, 18);
    await db.into(db.devicePrefs).insert(
          DevicePrefsCompanion.insert(key: 'selected_exam_id', value: 'cse'),
        );
    await db.into(db.appPreferencesLocal).insert(
          AppPreferencesLocalCompanion.insert(key: 'age_gate', value: 'passed'),
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
    await db.into(db.dailyNewCardIntro).insert(
          DailyNewCardIntroCompanion.insert(
            userId: 'user-1',
            examId: 'cse',
            day: stamp,
          ),
        );
    await db.into(db.quizSessions).insert(
          QuizSessionsCompanion.insert(
            id: 'session-1',
            userId: 'user-1',
            examId: 'cse',
            origin: 'quiz',
            questionIdsJson: '[]',
            startedAt: stamp,
          ),
        );
    await db.into(db.quizNudgeDismissedLocal).insert(
          QuizNudgeDismissedLocalCompanion.insert(dismissedAt: stamp),
        );

    expect(await SyncLocalStateWiper(db).hasMeaningfulProgress(), isFalse);
  });

  test('hasMeaningfulProgress is true for quiz attempts', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await db.into(db.attemptsLocal).insert(
          AttemptsLocalCompanion.insert(
            id: 'a1',
            examId: 'cse',
            startedAt: DateTime.utc(2026, 5, 18),
            completedAt: const Value(null),
            itemsJson: '[]',
          ),
        );

    expect(await SyncLocalStateWiper(db).hasMeaningfulProgress(), isTrue);
  });

  test('hasMeaningfulProgress is true for assessment results', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await db.into(db.assessmentResultsLocal).insert(
          AssessmentResultsLocalCompanion.insert(
            examId: 'cse',
            completedAt: DateTime.utc(2026, 5, 18),
            topicScoresJson: '{}',
          ),
        );

    expect(await SyncLocalStateWiper(db).hasMeaningfulProgress(), isTrue);
  });

  test('hasMeaningfulProgress is true for review state', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await db.into(db.reviewStateLocal).insert(
          ReviewStateLocalCompanion.insert(
            questionId: 'q1',
            questionVersion: 1,
            stage: 'review',
            stability: 1,
            difficulty: 1,
            due: DateTime.utc(2026, 5, 19),
            lastReview: DateTime.utc(2026, 5, 18),
            reps: 1,
            lapses: 0,
            elapsedDays: 1,
            scheduledDays: 1,
          ),
        );

    expect(await SyncLocalStateWiper(db).hasMeaningfulProgress(), isTrue);
  });

  test('hasMeaningfulProgress is true for streak state', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await db.into(db.streakLocal).insert(
          StreakLocalCompanion.insert(current: const Value(1)),
        );

    expect(await SyncLocalStateWiper(db).hasMeaningfulProgress(), isTrue);
  });

  test('hasMeaningfulProgress is true for lesson progress', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await db.into(db.lessonProgressLocal).insert(
          LessonProgressLocalCompanion.insert(
            lessonId: 'lesson_1',
            readAt: DateTime.utc(2026, 5, 18),
          ),
        );

    expect(await SyncLocalStateWiper(db).hasMeaningfulProgress(), isTrue);
  });

  test('hasMeaningfulProgress is true for lesson bookmarks', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await seedTopicWithQuestions(
      db,
      examId: 'cse',
      topicId: 'topic_1',
      topicName: 'Topic 1',
      questionIds: const [],
      lessonIds: const ['lesson_1'],
    );
    await db.into(db.lessonBookmarksLocal).insert(
          LessonBookmarksLocalCompanion.insert(
            lessonId: 'lesson_1',
            markedAt: DateTime.utc(2026, 5, 18),
          ),
        );

    expect(await SyncLocalStateWiper(db).hasMeaningfulProgress(), isTrue);
  });

  test('hasMeaningfulProgress is true for question flags', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await seedTopicWithQuestions(
      db,
      examId: 'cse',
      topicId: 'topic_1',
      topicName: 'Topic 1',
      questionIds: const ['q1'],
    );
    await db.into(db.questionFlagsLocal).insert(
          QuestionFlagsLocalCompanion.insert(
            questionId: 'q1',
            flaggedAt: DateTime.utc(2026, 5, 18),
          ),
        );

    expect(await SyncLocalStateWiper(db).hasMeaningfulProgress(), isTrue);
  });

  test('hasMeaningfulProgress is true for mock attempts', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final stamp = DateTime.utc(2026, 5, 18);
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
            sampledQuestionsJson: '[]',
            startedAt: stamp,
            lastFlushedAt: stamp,
            updatedAt: stamp,
          ),
        );

    expect(await SyncLocalStateWiper(db).hasMeaningfulProgress(), isTrue);
  });

  test('hasMeaningfulProgress is true for review logs', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final stamp = DateTime.utc(2026, 5, 18);
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

    expect(await SyncLocalStateWiper(db).hasMeaningfulProgress(), isTrue);
  });

  test('hasMeaningfulProgress is true for track scope', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await seedTopicWithQuestions(
      db,
      examId: 'cse',
      topicId: 'topic_1',
      topicName: 'Topic 1',
      questionIds: const [],
    );
    await db.into(db.trackScopeLocal).insert(
          TrackScopeLocalCompanion.insert(examId: 'cse', topicId: 'topic_1'),
        );

    expect(await SyncLocalStateWiper(db).hasMeaningfulProgress(), isTrue);
  });

  test('hasMeaningfulProgress is true for custom blueprints', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await seedTopicWithQuestions(
      db,
      examId: 'cse',
      topicId: 'topic_1',
      topicName: 'Topic 1',
      questionIds: const [],
    );
    await db.into(db.customBlueprintsLocal).insert(
          CustomBlueprintsLocalCompanion.insert(
            examId: 'cse',
            totalQuestions: 50,
            totalMinutes: 60,
            sectionsJson: '[]',
            updatedAt: DateTime.utc(2026, 5, 18),
          ),
        );

    expect(await SyncLocalStateWiper(db).hasMeaningfulProgress(), isTrue);
  });
}
