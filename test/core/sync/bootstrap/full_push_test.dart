import 'package:drift/drift.dart' show Value, Variable;
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/bootstrap/full_push.dart';
import 'package:pantas/core/sync/firestore/firestore_gateway.dart';
import 'package:pantas/core/sync/firestore/functions_gateway.dart';
import 'package:pantas/core/sync/mapping/track_scope_mapper.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  test('keep-device stages exact generation snapshot before activation',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await _seedTenSources(db);
    final events = <String>[];
    final gateway = RecordingGateway(events: events);
    final functions = RecordingFunctionsGateway(events);

    final result = await FullPushBootstrap(
      db: db,
      gateway: gateway,
      functionsGateway: functions,
      uid: 'user-1',
      deviceId: 'device-1',
      generationIdFactory: () => 'gen-new',
      mutationIdFactory: (collection, rowId) => 'm-$collection-$rowId',
    ).run(expectedActiveGenerationId: 'gen-old');

    expect(result.outcome, FullPushOutcome.activated);
    expect(result.generationId, 'gen-new');
    expect(events.last, 'activate:gen-new:gen-old');
    expect(events.where((event) => event.startsWith('commit:')), isNotEmpty);
    expect(
        events.indexOf('activate:gen-new:gen-old'),
        greaterThan(
            events.lastIndexWhere((event) => event.startsWith('commit:'))));

    final root = await gateway.readDocument(
      'users/user-1/sync_generations/gen-new',
    );
    expect(root!['status'], 'staging');
    expect(root['preferences'], {'reminder_time': '07:30'});

    final paths = gateway.documents.keys.toSet();
    expect(paths,
        contains('users/user-1/sync_generations/gen-new/quiz_attempts/a1'));
    expect(paths,
        contains('users/user-1/sync_generations/gen-new/assessments/cse'));
    expect(
        paths, contains('users/user-1/sync_generations/gen-new/fsrs_cards/q1'));
    expect(
        paths,
        contains(
            'users/user-1/sync_generations/gen-new/lesson_progress/lesson_1'));
    expect(
        paths,
        contains(
            'users/user-1/sync_generations/gen-new/lesson_bookmarks/lesson_1'));
    expect(paths,
        contains('users/user-1/sync_generations/gen-new/question_flags/q1'));
    expect(
        paths,
        contains(
            'users/user-1/sync_generations/gen-new/mock_exam_attempts/mock-terminal'));
    expect(paths,
        contains('users/user-1/sync_generations/gen-new/review_logs/review-1'));
    expect(
      paths,
      contains(
        'users/user-1/sync_generations/gen-new/track_scope/'
        '${TrackScopeDocumentId.metadata('exam_custom_1')}',
      ),
    );
    expect(
      paths,
      contains(
        'users/user-1/sync_generations/gen-new/track_scope/'
        '${TrackScopeDocumentId.scope('exam_custom_1', 'topic_1')}',
      ),
    );
    expect(
        paths,
        contains(
            'users/user-1/sync_generations/gen-new/custom_blueprints/exam_custom_1'));
  });

  test('in-progress mock attempt is excluded from keep-device snapshot',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final stamp = DateTime.utc(2026, 8, 30);
    await _insertMock(db,
        id: 'mock-local', status: 'in_progress', stamp: stamp);
    final gateway = RecordingGateway();

    final result = await FullPushBootstrap(
      db: db,
      gateway: gateway,
      functionsGateway: FakeSyncFunctionsGateway(),
      uid: 'user-1',
      deviceId: 'device-1',
      generationIdFactory: () => 'gen-new',
      mutationIdFactory: (collection, rowId) => 'm-$rowId',
    ).run(expectedActiveGenerationId: null);

    expect(result.outcome, FullPushOutcome.activated);
    expect(
      gateway.documents.keys.any((path) => path.contains('mock-local')),
      isFalse,
    );
  });

  test('staging failure leaves old generation untouched and never activates',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await _seedLesson(db);
    final functions = FakeSyncFunctionsGateway();

    final result = await FullPushBootstrap(
      db: db,
      gateway: ThrowingGateway(),
      functionsGateway: functions,
      uid: 'user-1',
      deviceId: 'device-1',
      generationIdFactory: () => 'gen-new',
      mutationIdFactory: (collection, rowId) => 'm-$rowId',
    ).run(expectedActiveGenerationId: 'gen-old');

    expect(result.outcome, FullPushOutcome.retryableFailure);
    expect(functions.activationCalls, isEmpty);
    expect(await _marker(db, 'pending_full_push'), 'gen-new');
  });

  test('epoch advance after snapshot prevents stale generation activation',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await _seedLesson(db);
    await _seedJournal(db, revision: 1, mutationEpoch: 1);
    final functions = FakeSyncFunctionsGateway();
    var mutated = false;
    final gateway = RecordingGateway(
      afterCommit: (writes) async {
        if (mutated ||
            !writes.any((write) => write.path.contains('/lesson_progress/')))
          return;
        mutated = true;
        await db.customStatement(
          "insert into sync_meta (key,value) values ('localMutationEpoch','2') "
          "on conflict(key) do update set value=excluded.value",
        );
        await db.customStatement(
          'update sync_local_mutations set revision=2, mutation_epoch=2 '
          "where collection='lesson_progress' and row_id='lesson_1'",
        );
      },
    );

    final result = await FullPushBootstrap(
      db: db,
      gateway: gateway,
      functionsGateway: functions,
      uid: 'user-1',
      deviceId: 'device-1',
      generationIdFactory: () => 'gen-stale',
      mutationIdFactory: (collection, rowId) => 'm-$rowId',
    ).run(expectedActiveGenerationId: 'gen-old');

    expect(result.outcome, FullPushOutcome.staleLocalEpoch);
    expect(functions.activationCalls, isEmpty);
    final journal = await db
        .customSelect(
            'select revision,mutation_epoch from sync_local_mutations')
        .getSingle();
    expect(journal.read<int>('revision'), 2);
    expect(journal.read<int>('mutation_epoch'), 2);
  });

  test(
      'epoch advance during activation is not treated as current and is not acknowledged',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await _seedLesson(db);
    await _seedJournal(db, revision: 1, mutationEpoch: 1);
    final functions = MutatingActivationGateway(db);

    final result = await FullPushBootstrap(
      db: db,
      gateway: RecordingGateway(),
      functionsGateway: functions,
      uid: 'user-1',
      deviceId: 'device-1',
      generationIdFactory: () => 'gen-raced',
      mutationIdFactory: (collection, rowId) => 'm-$rowId',
    ).run(expectedActiveGenerationId: 'gen-old');

    expect(result.outcome, FullPushOutcome.staleLocalEpoch);
    expect(functions.activationCalls, hasLength(1));
    expect(await db.customSelect('select * from sync_local_mutations').get(),
        isNotEmpty);
    expect(await _marker(db, 'pending_full_push'), 'gen-raced');
  });

  test('successful activation acknowledges only represented journal snapshot',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await _seedLesson(db);
    await _seedJournal(db, revision: 1, mutationEpoch: 1);

    final result = await FullPushBootstrap(
      db: db,
      gateway: RecordingGateway(),
      functionsGateway: FakeSyncFunctionsGateway(),
      uid: 'user-1',
      deviceId: 'device-1',
      generationIdFactory: () => 'gen-new',
      mutationIdFactory: (collection, rowId) => 'm-$rowId',
    ).run(expectedActiveGenerationId: 'gen-old');

    expect(result.outcome, FullPushOutcome.activated);
    expect(await db.customSelect('select * from sync_local_mutations').get(),
        isEmpty);
    expect(await db.select(db.pendingSync).get(), isEmpty);
    expect(await _marker(db, 'pending_full_push'), isNull);
    expect(await _marker(db, 'currentLocalGenerationId'), 'gen-new');
  });
}

class RecordingGateway extends FakeFirestoreGateway {
  RecordingGateway({
    this.events,
    this.afterCommit,
  }) : super(serverNow: () => DateTime.utc(2026, 8, 30, 1));

  final List<String>? events;
  final Future<void> Function(List<FirestoreWrite> writes)? afterCommit;

  @override
  Future<void> commitBatch(List<FirestoreWrite> writes) async {
    events?.add('commit:${writes.length}');
    await super.commitBatch(writes);
    await afterCommit?.call(writes);
  }
}

class ThrowingGateway extends FakeFirestoreGateway {
  @override
  Future<void> commitBatch(List<FirestoreWrite> writes) async {
    throw const SyncGatewayException('unavailable');
  }
}

class RecordingFunctionsGateway extends FakeSyncFunctionsGateway {
  RecordingFunctionsGateway(this.events);
  final List<String> events;

  @override
  Future<void> activateGeneration({
    required String generationId,
    required String? expectedActiveGenerationId,
  }) async {
    await super.activateGeneration(
      generationId: generationId,
      expectedActiveGenerationId: expectedActiveGenerationId,
    );
    events.add('activate:$generationId:$expectedActiveGenerationId');
  }
}

class MutatingActivationGateway extends FakeSyncFunctionsGateway {
  MutatingActivationGateway(this.db);
  final AppDatabase db;

  @override
  Future<void> activateGeneration({
    required String generationId,
    required String? expectedActiveGenerationId,
  }) async {
    await super.activateGeneration(
      generationId: generationId,
      expectedActiveGenerationId: expectedActiveGenerationId,
    );
    await db.customStatement(
      "insert into sync_meta (key,value) values ('localMutationEpoch','2') "
      "on conflict(key) do update set value=excluded.value",
    );
    await db.customStatement(
      'update sync_local_mutations set revision=2, mutation_epoch=2 '
      "where collection='lesson_progress' and row_id='lesson_1'",
    );
  }
}

Future<void> _seedTenSources(AppDatabase db) async {
  final stamp = DateTime.utc(2026, 8, 30);
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
            examId: 'cse', completedAt: stamp, topicScoresJson: '{}'),
      );
  await db.into(db.reviewStateLocal).insert(
        ReviewStateLocalCompanion.insert(
          questionId: 'q1',
          questionVersion: 1,
          stage: 'review',
          stability: 1,
          difficulty: 1,
          due: stamp,
          lastReview: stamp,
          reps: 1,
          lapses: 0,
          elapsedDays: 1,
          scheduledDays: 1,
        ),
      );
  await _seedLesson(db);
  await db.into(db.lessonBookmarksLocal).insert(
        LessonBookmarksLocalCompanion.insert(
            lessonId: 'lesson_1', markedAt: stamp),
      );
  await db.into(db.questionFlagsLocal).insert(
        QuestionFlagsLocalCompanion.insert(questionId: 'q1', flaggedAt: stamp),
      );
  await _insertMock(db, id: 'mock-terminal', status: 'completed', stamp: stamp);
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
  await db.into(db.customTrackMetaLocal).insert(
        CustomTrackMetaLocalCompanion.insert(
            examId: 'exam_custom_1', name: 'My track'),
      );
  await db.into(db.trackScopeLocal).insert(
        TrackScopeLocalCompanion.insert(
            examId: 'exam_custom_1', topicId: 'topic_1'),
      );
  await db.into(db.customBlueprintsLocal).insert(
        CustomBlueprintsLocalCompanion.insert(
          examId: 'exam_custom_1',
          totalQuestions: 50,
          totalMinutes: 60,
          sectionsJson: '[]',
          updatedAt: stamp,
        ),
      );
  await db.into(db.accountPrefs).insert(
        AccountPrefsCompanion.insert(key: 'reminder_time', value: '07:30'),
      );
}

Future<void> _seedLesson(AppDatabase db) =>
    db.into(db.lessonProgressLocal).insertOnConflictUpdate(
          LessonProgressLocalCompanion.insert(
              lessonId: 'lesson_1', readAt: DateTime.utc(2026, 8, 30)),
        );

Future<void> _insertMock(
  AppDatabase db, {
  required String id,
  required String status,
  required DateTime stamp,
}) =>
    db.into(db.mockAttempts).insert(
          MockAttemptsCompanion.insert(
            id: id,
            userId: 'user-1',
            examId: 'cse',
            blueprintId: 'bp-1',
            blueprintName: 'Practice',
            durationMinutes: 30,
            status: status,
            strictMode: false,
            sampledQuestionsJson: '[]',
            startedAt: stamp,
            lastFlushedAt: stamp,
            submittedAt:
                status == 'in_progress' ? const Value(null) : Value(stamp),
            updatedAt: stamp,
          ),
        );

Future<void> _seedJournal(
  AppDatabase db, {
  required int revision,
  required int mutationEpoch,
}) async {
  await db.customStatement(
    'insert into sync_meta (key,value) values (?,?) '
    'on conflict(key) do update set value=excluded.value',
    ['localMutationEpoch', '$mutationEpoch'],
  );
  await db.customStatement(
    'insert into sync_local_mutations '
    '(collection,row_id,op,revision,mutation_epoch,causal_base_state,recorded_at) '
    'values (?,?,?,?,?,?,?)',
    [
      'lesson_progress',
      'lesson_1',
      'upsert',
      revision,
      mutationEpoch,
      'unbound',
      DateTime.utc(2026, 8, 30).millisecondsSinceEpoch,
    ],
  );
}

Future<String?> _marker(AppDatabase db, String key) async {
  final row = await db.customSelect(
    'select value from sync_meta where key = ?',
    variables: [Variable<String>(key)],
  ).getSingleOrNull();
  return row?.read<String>('value');
}
