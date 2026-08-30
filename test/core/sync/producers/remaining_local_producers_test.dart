import 'package:drift/drift.dart' show Value, Variable;
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/fsrs/rating.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/review_log_repository.dart';
import 'package:pantas/core/storage/domain/review_log.dart';
import 'package:pantas/core/storage/domain/review_state.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/core/sync/engine/sync_row_meta_repository.dart';
import 'package:pantas/features/mock_exam/data/custom_blueprint_repository.dart';
import 'package:pantas/features/mock_exam/data/mock_attempt_repo.dart';
import 'package:pantas/features/mock_exam/domain/custom_blueprint.dart';
import 'package:pantas/features/mock_exam/domain/mock_attempt.dart';
import 'package:pantas/features/mock_exam/domain/mock_results.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;

  Future<Map<String, Object?>?> journalOrNull(
    String collection,
    String rowId,
  ) async {
    final row = await db.customSelect(
      'select collection,row_id,op,revision,mutation_epoch,causal_uid,'
      'causal_generation_id,causal_base_state,'
      'cast(base_updated_at as integer) as base_updated_at '
      'from sync_local_mutations where collection = ? and row_id = ?',
      variables: [Variable<String>(collection), Variable<String>(rowId)],
    ).getSingleOrNull();
    return row?.data;
  }

  Future<Map<String, Object?>> journal(String collection, String rowId) async =>
      (await journalOrNull(collection, rowId))!;

  Future<int> epoch() async {
    final row = await db
        .customSelect(
          "select value from sync_meta where key = 'localMutationEpoch'",
        )
        .getSingleOrNull();
    return row == null ? 0 : int.parse(row.read<String>('value'));
  }

  ReviewLog reviewLog({String id = 'review_1'}) => ReviewLog(
        id: id,
        questionId: 'q1',
        rating: Rating.good,
        state: ReviewStage.review,
        due: DateTime.utc(2026, 8, 31),
        stability: 5,
        difficulty: 3,
        elapsedDays: 2,
        lastElapsedDays: 1,
        scheduledDays: 4,
        review: DateTime.utc(2026, 8, 30),
        durationMs: 1200,
        isCorrect: true,
        heuristicVersion: 1,
      );

  MockAttemptStart mockStart(String id) => MockAttemptStart(
        id: id,
        userId: 'user_1',
        examId: 'exam_1',
        blueprintId: 'blueprint_1',
        blueprintName: 'Practice',
        durationMinutes: 60,
        strictMode: false,
        sampledQuestionsJson: '[]',
        startedAt: DateTime.utc(2026, 8, 30),
      );

  const mockResults = MockResults(
    scoreRaw: 8,
    scoreTotal: 10,
    percent: 80,
    sections: [],
    topWeak: [],
    totalTimeSeconds: 1200,
    wasStrict: false,
  );

  const blueprint = CustomBlueprint(
    examId: 'exam_custom_1',
    totalQuestions: 100,
    totalMinutes: 90,
  );

  setUp(() async {
    db = inMemoryDatabase();
    await db.into(db.exams).insert(
          ExamsCompanion.insert(
            id: 'exam_custom_1',
            code: 'custom',
            name: 'Custom exam',
            shortName: 'Custom exam',
            language: 'en',
            isCustom: const Value(true),
          ),
        );
  });

  tearDown(() => db.close());

  test('review log insert journals one append-only logical row atomically',
      () async {
    final repo = ReviewLogRepository(db);

    await repo.insert(reviewLog());

    final row = await journal('review_logs', 'review_1');
    expect(row['op'], 'upsert');
    expect(row['revision'], 1);
    expect(await db.select(db.reviewLogs).get(), hasLength(1));
    expect(await epoch(), 1);
  });

  test('mock insertStart and flushProgress remain local-only', () async {
    final repo = MockAttemptRepo(db);

    await repo.insertStart(mockStart('mock_local'));
    expect(await journalOrNull('mock_exam_attempts', 'mock_local'), isNull);
    expect(await epoch(), 0);

    await repo.flushProgress(
      attemptId: 'mock_local',
      elapsedSeconds: 30,
      accumulatedPausedSeconds: 0,
      pausedAtLastFlush: false,
      answersJson: '{}',
      flagsJson: '[]',
      currentIndex: 1,
      flushedAt: DateTime.utc(2026, 8, 30, 0, 0, 30),
    );

    expect(await journalOrNull('mock_exam_attempts', 'mock_local'), isNull);
    expect(await epoch(), 0);
  });

  test('mock discard journals the final terminal row', () async {
    final repo = MockAttemptRepo(db);
    await repo.insertStart(mockStart('mock_discard'));

    await repo.discard(
      'mock_discard',
      DateTime.utc(2026, 8, 30, 0, 10),
    );

    final row = await journal('mock_exam_attempts', 'mock_discard');
    expect(row['op'], 'upsert');
    expect(row['revision'], 1);
    expect((await repo.findById('mock_discard'))!.status,
        MockAttemptStatus.discarded);
    expect(await epoch(), 1);
  });

  test('mock submit journals terminal statuses but not in-progress state',
      () async {
    final repo = MockAttemptRepo(db);
    for (final id in ['mock_in_progress', 'mock_completed', 'mock_forfeited']) {
      await repo.insertStart(mockStart(id));
    }

    await repo.submit(
      attemptId: 'mock_in_progress',
      status: MockAttemptStatus.inProgress,
      results: mockResults,
      sectionResultsJson: '{}',
      submittedAt: DateTime.utc(2026, 8, 30, 0, 20),
    );
    expect(
      await journalOrNull('mock_exam_attempts', 'mock_in_progress'),
      isNull,
    );

    await repo.submit(
      attemptId: 'mock_completed',
      status: MockAttemptStatus.completed,
      results: mockResults,
      sectionResultsJson: '{}',
      submittedAt: DateTime.utc(2026, 8, 30, 0, 21),
    );
    await repo.submit(
      attemptId: 'mock_forfeited',
      status: MockAttemptStatus.forfeited,
      results: mockResults,
      sectionResultsJson: '{}',
      submittedAt: DateTime.utc(2026, 8, 30, 0, 22),
    );

    expect((await journal('mock_exam_attempts', 'mock_completed'))['op'],
        'upsert');
    expect((await journal('mock_exam_attempts', 'mock_forfeited'))['op'],
        'upsert');
    final completed = await repo.findById('mock_completed');
    expect(completed!.status, MockAttemptStatus.completed);
    expect(completed.scoreRaw, 8);
    expect(completed.scoreTotal, 10);
    expect(completed.totalTimeSeconds, 1200);
    expect(await epoch(), 2);
  });

  test('custom blueprint save journals the authoritative upsert', () async {
    final repo = CustomBlueprintRepository(db);

    await repo.save(
      blueprint,
      topicsBySubject: const {
        'math': ['algebra']
      },
      now: DateTime.utc(2026, 8, 30),
    );

    final row = await journal('custom_blueprints', 'exam_custom_1');
    expect(row['op'], 'upsert');
    expect(row['revision'], 1);
    expect((await repo.read('exam_custom_1'))!.totalQuestions, 100);
    expect(await epoch(), 1);
  });

  test('repeated blueprint save advances revision with its observed base',
      () async {
    final context = SyncActiveContextStore(db);
    final rowMeta = SyncRowMetaRepository(db);
    final repo = CustomBlueprintRepository(db);
    final v1 = DateTime.utc(2026, 8, 29, 1);
    final v2 = DateTime.utc(2026, 8, 29, 2);

    await context.publishStable(uid: 'user_1', generationId: 'gen_1');
    await rowMeta.acceptKnownVersion(
      collection: 'custom_blueprints',
      rowId: 'exam_custom_1',
      updatedAt: v1,
    );
    await repo.save(
      blueprint,
      topicsBySubject: const {
        'math': ['algebra']
      },
      now: DateTime.utc(2026, 8, 30, 1),
    );
    final drainedRevision = Map<String, Object?>.from(
        await journal('custom_blueprints', 'exam_custom_1'));

    await rowMeta.acceptKnownVersion(
      collection: 'custom_blueprints',
      rowId: 'exam_custom_1',
      updatedAt: v2,
    );
    await repo.save(
      const CustomBlueprint(
        examId: 'exam_custom_1',
        totalQuestions: 80,
        totalMinutes: 75,
      ),
      topicsBySubject: const {
        'math': ['algebra']
      },
      now: DateTime.utc(2026, 8, 30, 2),
    );
    final current = await journal('custom_blueprints', 'exam_custom_1');

    expect(drainedRevision['revision'], 1);
    expect(drainedRevision['causal_uid'], 'user_1');
    expect(drainedRevision['causal_generation_id'], 'gen_1');
    expect(drainedRevision['causal_base_state'], 'knownVersion');
    expect(drainedRevision['base_updated_at'], v1.millisecondsSinceEpoch);
    expect(current['revision'], 2);
    expect(current['base_updated_at'], v2.millisecondsSinceEpoch);
    expect(await epoch(), 2);
  });
}
