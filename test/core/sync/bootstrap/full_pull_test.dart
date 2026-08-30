import 'package:drift/drift.dart' show Value, Variable;
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/bootstrap/full_pull.dart';
import 'package:pantas/core/sync/firestore/firestore_gateway.dart';
import 'package:pantas/core/sync/mapping/track_scope_mapper.dart';
import 'package:pantas/core/sync/model/sync_document.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  test('keep-account downloads and validates before destructive replacement',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await _putLesson(db, 'local-before');
    final gateway = ThrowingReadGateway(_cloudGateway(),
        throwCollection: 'lesson_progress');

    final result = await FullPullBootstrap(
      db: db,
      gateway: gateway,
      uid: 'user-1',
    ).run(generationId: 'gen-1');

    expect(result.outcome, FullPullOutcome.retryableFailure);
    expect((await db.select(db.lessonProgressLocal).get()).single.lessonId,
        'local-before');
  });

  test(
      'epoch advance after download aborts replacement and preserves concurrent local action',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await _putLesson(db, 'local-before');
    await _setEpoch(db, 1);
    var mutated = false;
    final gateway = HookReadGateway(
      _cloudGateway(),
      afterCollectionRead: (path) async {
        if (mutated || !path.endsWith('/custom_blueprints')) return;
        mutated = true;
        await _putLesson(db, 'concurrent-local');
        await _setEpoch(db, 2);
        await _seedJournal(db,
            rowId: 'concurrent-local', revision: 1, mutationEpoch: 2);
      },
    );

    final result = await FullPullBootstrap(
      db: db,
      gateway: gateway,
      uid: 'user-1',
    ).run(generationId: 'gen-1');

    expect(result.outcome, FullPullOutcome.staleLocalEpoch);
    final lessonIds = (await db.select(db.lessonProgressLocal).get())
        .map((row) => row.lessonId)
        .toSet();
    expect(lessonIds, {'local-before', 'concurrent-local'});
    expect(await db.customSelect('select * from sync_local_mutations').get(),
        isNotEmpty);
  });

  test(
      'successful keep-account replaces Sync state but preserves in-progress mock',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await _putLesson(db, 'local-before');
    final stamp = DateTime.utc(2026, 8, 30);
    await db.into(db.mockAttempts).insert(
          MockAttemptsCompanion.insert(
            id: 'mock-local',
            userId: 'user-1',
            examId: 'cse',
            blueprintId: 'bp-1',
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
    await db.into(db.accountPrefs).insert(
          AccountPrefsCompanion.insert(key: 'old_pref', value: 'old'),
        );

    final result = await FullPullBootstrap(
      db: db,
      gateway: _cloudGateway(),
      uid: 'user-1',
    ).run(generationId: 'gen-1');

    expect(result.outcome, FullPullOutcome.applied);
    expect((await db.select(db.lessonProgressLocal).get()).single.lessonId,
        'cloud-lesson');
    expect((await db.select(db.mockAttempts).get()).single.id, 'mock-local');
    final prefs = await db.select(db.accountPrefs).get();
    expect(prefs.map((row) => '${row.key}=${row.value}').toList(),
        ['reminder_time=07:30']);
    expect(await _marker(db, 'currentLocalGenerationId'), 'gen-1');
    expect(await _marker(db, 'pending_full_pull'), isNull);
  });

  test('successful replacement clears represented queue and journal state',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await _putLesson(db, 'local-before');
    await _setEpoch(db, 1);
    await _seedJournal(db,
        rowId: 'local-before', revision: 1, mutationEpoch: 1);
    await db.into(db.pendingSync).insert(
          PendingSyncCompanion.insert(
            uid: const Value('user-1'),
            generationId: const Value('gen-old'),
            tableType: 'lesson_progress',
            rowId: 'local-before',
            op: 'upsert',
            queuedAt: DateTime.utc(2026, 8, 30),
          ),
        );

    final result = await FullPullBootstrap(
      db: db,
      gateway: _cloudGateway(),
      uid: 'user-1',
    ).run(generationId: 'gen-1');

    expect(result.outcome, FullPullOutcome.applied);
    expect(await db.select(db.pendingSync).get(), isEmpty);
    expect(await db.customSelect('select * from sync_local_mutations').get(),
        isEmpty);
  });

  test(
      'typed custom-track authority is committed then projected after transaction',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final projected = <String>[];

    final result = await FullPullBootstrap(
      db: db,
      gateway: _cloudGateway(includeCustomTrack: true),
      uid: 'user-1',
      rebuildCustomTrackProjection: (examId) async {
        projected.add(examId);
      },
    ).run(generationId: 'gen-1');

    expect(result.outcome, FullPullOutcome.applied);
    final meta = await db.select(db.customTrackMetaLocal).get();
    expect(meta.single.examId, 'exam_custom_1');
    expect(meta.single.name, 'Cloud Track');
    final scope = await db.select(db.trackScopeLocal).get();
    expect(scope.single.examId, 'exam_custom_1');
    expect(scope.single.topicId, 'topic_1');
    expect(projected, ['exam_custom_1']);
    expect(await _projectionRequired(db, 'exam_custom_1'), isFalse);
  });

  test(
      'projection failure leaves authority committed and recoverable marker pending',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);

    final result = await FullPullBootstrap(
      db: db,
      gateway: _cloudGateway(includeCustomTrack: true),
      uid: 'user-1',
      rebuildCustomTrackProjection: (examId) async {
        throw StateError('projection unavailable');
      },
    ).run(generationId: 'gen-1');

    expect(result.outcome, FullPullOutcome.appliedProjectionPending);
    expect((await db.select(db.customTrackMetaLocal).get()).single.name,
        'Cloud Track');
    expect(await _projectionRequired(db, 'exam_custom_1'), isTrue);
  });

  test('invalid typed custom-track document aborts before local replacement',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await _putLesson(db, 'local-before');
    final gateway = _cloudGateway(includeCustomTrack: true);
    final path = 'users/user-1/sync_generations/gen-1/track_scope';
    gateway.collections[path] = [
      {
        'id': TrackScopeDocumentId.metadata('exam_custom_1'),
        'kind': 'custom_track',
        'examId': 'wrong-exam',
        'name': 'Bad',
        'updatedAt': DateTime.utc(2026, 8, 30, 1),
        'originDeviceId': 'device-cloud',
        'mutationId': 'm-bad',
        'deleted': false,
        'schemaVersion': 1,
      },
    ];

    final result = await FullPullBootstrap(
      db: db,
      gateway: gateway,
      uid: 'user-1',
    ).run(generationId: 'gen-1');

    expect(result.outcome, FullPullOutcome.invalidSnapshot);
    expect((await db.select(db.lessonProgressLocal).get()).single.lessonId,
        'local-before');
  });
  test(
      'eligibility loss during download stops before next read and local replacement',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await _putLesson(db, 'local-before');
    var canContinue = true;
    final gateway = CancellingReadGateway(
      _cloudGateway(),
      onFirstCollectionRead: () => canContinue = false,
    );

    final result = await FullPullBootstrap(
      db: db,
      gateway: gateway,
      uid: 'user-1',
    ).run(
      generationId: 'gen-1',
      shouldContinue: () => canContinue,
    );

    expect(result.outcome, FullPullOutcome.cancelled);
    expect(gateway.collectionReads, 1);
    expect((await db.select(db.lessonProgressLocal).get()).single.lessonId,
        'local-before');
    expect(await _marker(db, 'pending_full_pull'), 'gen-1');
  });
}

FakeFirestoreGateway _cloudGateway({bool includeCustomTrack = false}) {
  final gateway = FakeFirestoreGateway();
  gateway.documents['users/user-1/sync_generations/gen-1'] = {
    'status': 'active',
    'schemaVersion': 1,
    'createdAt': DateTime.utc(2026, 8, 29),
    'createdByDeviceId': 'device-cloud',
    'preferences': {'reminder_time': '07:30'},
  };
  gateway.collections['users/user-1/sync_generations/gen-1/lesson_progress'] = [
    {
      'id': 'cloud-lesson',
      'lessonId': 'cloud-lesson',
      'readAt': '2026-08-30T00:00:00.000Z',
      'updatedAt': DateTime.utc(2026, 8, 30, 1),
      'originDeviceId': 'device-cloud',
      'mutationId': 'm-cloud-lesson',
      'deleted': false,
      'schemaVersion': 1,
    },
  ];
  if (includeCustomTrack) {
    gateway.collections['users/user-1/sync_generations/gen-1/track_scope'] = [
      {
        'id': TrackScopeDocumentId.metadata('exam_custom_1'),
        'kind': 'custom_track',
        'examId': 'exam_custom_1',
        'name': 'Cloud Track',
        'updatedAt': DateTime.utc(2026, 8, 30, 1),
        'originDeviceId': 'device-cloud',
        'mutationId': 'm-meta',
        'deleted': false,
        'schemaVersion': 1,
      },
      {
        'id': TrackScopeDocumentId.scope('exam_custom_1', 'topic_1'),
        'kind': 'scope',
        'examId': 'exam_custom_1',
        'topicId': 'topic_1',
        'updatedAt': DateTime.utc(2026, 8, 30, 1),
        'originDeviceId': 'device-cloud',
        'mutationId': 'm-scope',
        'deleted': false,
        'schemaVersion': 1,
      },
    ];
  }
  return gateway;
}

class CancellingReadGateway extends FakeFirestoreGateway {
  CancellingReadGateway(
    FakeFirestoreGateway source, {
    required this.onFirstCollectionRead,
  }) {
    documents.addAll(source.documents);
    collections.addAll(source.collections);
  }

  final void Function() onFirstCollectionRead;
  int collectionReads = 0;

  @override
  Future<List<SyncDocument>> readCollection(String path) async {
    collectionReads += 1;
    final rows = await super.readCollection(path);
    if (collectionReads == 1) onFirstCollectionRead();
    return rows;
  }
}

class ThrowingReadGateway extends FakeFirestoreGateway {
  ThrowingReadGateway(FakeFirestoreGateway source,
      {required this.throwCollection}) {
    documents.addAll(source.documents);
    collections.addAll(source.collections);
  }
  final String throwCollection;

  @override
  Future<List<SyncDocument>> readCollection(String path) async {
    if (path.endsWith('/$throwCollection')) {
      throw const SyncGatewayException('unavailable');
    }
    return super.readCollection(path);
  }
}

class HookReadGateway extends FakeFirestoreGateway {
  HookReadGateway(FakeFirestoreGateway source,
      {required this.afterCollectionRead}) {
    documents.addAll(source.documents);
    collections.addAll(source.collections);
  }
  final Future<void> Function(String path) afterCollectionRead;

  @override
  Future<List<SyncDocument>> readCollection(String path) async {
    final rows = await super.readCollection(path);
    await afterCollectionRead(path);
    return rows;
  }
}

Future<void> _putLesson(AppDatabase db, String id) =>
    db.into(db.lessonProgressLocal).insertOnConflictUpdate(
          LessonProgressLocalCompanion.insert(
              lessonId: id, readAt: DateTime.utc(2026, 8, 30)),
        );

Future<void> _setEpoch(AppDatabase db, int epoch) => db.customStatement(
      'insert into sync_meta (key,value) values (?,?) '
      'on conflict(key) do update set value=excluded.value',
      ['localMutationEpoch', '$epoch'],
    );

Future<void> _seedJournal(
  AppDatabase db, {
  required String rowId,
  required int revision,
  required int mutationEpoch,
}) =>
    db.customStatement(
      'insert into sync_local_mutations '
      '(collection,row_id,op,revision,mutation_epoch,causal_base_state,recorded_at) '
      'values (?,?,?,?,?,?,?)',
      [
        'lesson_progress',
        rowId,
        'upsert',
        revision,
        mutationEpoch,
        'unbound',
        DateTime.utc(2026, 8, 30).millisecondsSinceEpoch,
      ],
    );

Future<String?> _marker(AppDatabase db, String key) async {
  final row = await db.customSelect(
    'select value from sync_meta where key = ?',
    variables: [Variable<String>(key)],
  ).getSingleOrNull();
  return row?.read<String>('value');
}

Future<bool> _projectionRequired(AppDatabase db, String examId) async =>
    await _marker(
      db,
      'customTrackProjectionRequired:${TrackScopeDocumentId.metadata(examId)}',
    ) ==
    '1';
