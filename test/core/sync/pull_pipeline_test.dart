import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/engine/pending_queue.dart';
import 'package:pantas/core/sync/engine/pull_pipeline.dart';
import 'package:pantas/core/sync/engine/sync_row_meta_repository.dart';
import 'package:pantas/core/sync/model/sync_causal_base.dart';
import 'package:pantas/core/sync/model/sync_document.dart';

import '../../helpers/in_memory_database.dart';

const uid = 'user-1';
const generationId = 'generation-1';
const deviceId = 'device-1';

void main() {
  test('matching mutation echo adopts server timestamp and clears exact outbox',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = PendingQueue(db);
    final v1 = DateTime.utc(2026, 8, 29, 20);
    final v2 = DateTime.utc(2026, 8, 29, 21);
    await _putLesson(db, 'lesson-1', DateTime.utc(2026, 8, 29, 20, 5));
    await SyncRowMetaRepository(db).acceptKnownVersion(
      collection: 'lesson_progress',
      rowId: 'lesson-1',
      updatedAt: v1,
      originDeviceId: 'device-2',
    );
    await queue.enqueueGenerationBound(
      uid: uid,
      generationId: generationId,
      tableType: 'lesson_progress',
      rowId: 'lesson-1',
      op: PendingSyncOp.upsert,
      baseState: 'knownVersion',
      baseUpdatedAt: v1,
      mutationId: 'mutation-1',
      queuedAt: DateTime.utc(2026, 8, 29, 20, 5),
    );
    final pull = _pull(db, queue);

    final result = await pull.applyDocument(
      generationId: generationId,
      collection: 'lesson_progress',
      document: _document(
        'lesson-1',
        readAt: DateTime.utc(2026, 8, 29, 20, 5),
        updatedAt: v2,
        mutationId: 'mutation-1',
        originDeviceId: deviceId,
      ),
    );

    expect(result, PullApplyResult.applied);
    expect(
      await queue.drainGeneration(
        uid: uid,
        generationId: generationId,
        limit: 10,
      ),
      isEmpty,
    );
    final accepted = await SyncRowMetaRepository(db).readAcceptedBase(
      collection: 'lesson_progress',
      rowId: 'lesson-1',
    );
    expect(accepted!.state, SyncCausalBaseState.knownVersion);
    expect(accepted.updatedAt, v2);
  });

  test(
      'older same-device echo advances a newer pending revision without '
      'clobbering it', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = PendingQueue(db);
    final v1 = DateTime.utc(2026, 8, 29, 20);
    final v2 = DateTime.utc(2026, 8, 29, 21);
    await _putLesson(db, 'lesson-1', DateTime.utc(2026, 8, 29, 20, 10));
    await SyncRowMetaRepository(db).acceptKnownVersion(
      collection: 'lesson_progress',
      rowId: 'lesson-1',
      updatedAt: v1,
    );
    await queue.enqueueGenerationBound(
      uid: uid,
      generationId: generationId,
      tableType: 'lesson_progress',
      rowId: 'lesson-1',
      op: PendingSyncOp.upsert,
      baseState: 'knownVersion',
      baseUpdatedAt: v1,
      mutationId: 'mutation-1',
      queuedAt: DateTime.utc(2026, 8, 29, 20, 5),
    );
    await queue.enqueueGenerationBound(
      uid: uid,
      generationId: generationId,
      tableType: 'lesson_progress',
      rowId: 'lesson-1',
      op: PendingSyncOp.upsert,
      baseState: 'knownVersion',
      baseUpdatedAt: v1,
      mutationId: 'mutation-2',
      queuedAt: DateTime.utc(2026, 8, 29, 20, 10),
    );
    final pull = _pull(db, queue);

    final result = await pull.applyDocument(
      generationId: generationId,
      collection: 'lesson_progress',
      document: _document(
        'lesson-1',
        readAt: DateTime.utc(2026, 8, 29, 20, 5),
        updatedAt: v2,
        mutationId: 'mutation-1',
        originDeviceId: deviceId,
      ),
    );

    expect(result, PullApplyResult.echoAdvanced);
    final pending = await queue.findGenerationBound(
      uid: uid,
      generationId: generationId,
      tableType: 'lesson_progress',
      rowId: 'lesson-1',
    );
    expect(pending!.revision, 2);
    expect(pending.mutationId, 'mutation-2');
    expect(pending.baseUpdatedAt, v2);
    expect(
      (await _lesson(db, 'lesson-1'))!.readAt.toUtc(),
      DateTime.utc(2026, 8, 29, 20, 10),
    );
  });

  test(
      'newer remote live row applies and never records a local journal '
      'mutation', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = PendingQueue(db);
    final v1 = DateTime.utc(2026, 8, 29, 20);
    final v2 = DateTime.utc(2026, 8, 29, 21);
    await _putLesson(db, 'lesson-1', DateTime.utc(2026, 8, 29, 19));
    await SyncRowMetaRepository(db).acceptKnownVersion(
      collection: 'lesson_progress',
      rowId: 'lesson-1',
      updatedAt: v1,
    );
    final pull = _pull(db, queue);

    final result = await pull.applyDocument(
      generationId: generationId,
      collection: 'lesson_progress',
      document: _document(
        'lesson-1',
        readAt: DateTime.utc(2026, 8, 29, 21),
        updatedAt: v2,
        mutationId: 'remote-v2',
        originDeviceId: 'device-2',
      ),
    );

    expect(result, PullApplyResult.applied);
    expect(
      (await _lesson(db, 'lesson-1'))!.readAt.toUtc(),
      DateTime.utc(2026, 8, 29, 21),
    );
    final journalCount = await db
        .customSelect('select count(*) as count from sync_local_mutations')
        .getSingle();
    expect(journalCount.read<int>('count'), 0);
  });

  test('older or equal non-echo remote row is ignored', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = PendingQueue(db);
    final v2 = DateTime.utc(2026, 8, 29, 21);
    await _putLesson(db, 'lesson-1', DateTime.utc(2026, 8, 29, 21));
    await SyncRowMetaRepository(db).acceptKnownVersion(
      collection: 'lesson_progress',
      rowId: 'lesson-1',
      updatedAt: v2,
    );
    final pull = _pull(db, queue);

    expect(
      await pull.applyDocument(
        generationId: generationId,
        collection: 'lesson_progress',
        document: _document(
          'lesson-1',
          readAt: DateTime.utc(2026, 8, 29, 19),
          updatedAt: DateTime.utc(2026, 8, 29, 20),
          mutationId: 'old',
          originDeviceId: 'device-2',
        ),
      ),
      PullApplyResult.ignored,
    );
    expect(
      (await _lesson(db, 'lesson-1'))!.readAt.toUtc(),
      DateTime.utc(2026, 8, 29, 21),
    );
  });

  test(
      'remote tombstone deletes local domain row and retains tombstone '
      'version meta', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = PendingQueue(db);
    final v1 = DateTime.utc(2026, 8, 29, 20);
    final v2 = DateTime.utc(2026, 8, 29, 21);
    await _putLesson(db, 'lesson-1', DateTime.utc(2026, 8, 29, 20));
    await SyncRowMetaRepository(db).acceptKnownVersion(
      collection: 'lesson_progress',
      rowId: 'lesson-1',
      updatedAt: v1,
    );
    final pull = _pull(db, queue);

    final result = await pull.applyDocument(
      generationId: generationId,
      collection: 'lesson_progress',
      document: SyncDocument(
        id: 'lesson-1',
        data: {
          'lessonId': 'lesson-1',
          'deleted': true,
          'updatedAt': v2,
          'originDeviceId': 'device-2',
          'mutationId': 'delete-v2',
          'schemaVersion': 1,
        },
      ),
    );

    expect(result, PullApplyResult.applied);
    expect(await _lesson(db, 'lesson-1'), isNull);
    final accepted = await SyncRowMetaRepository(db).readAcceptedBase(
      collection: 'lesson_progress',
      rowId: 'lesson-1',
    );
    expect(accepted!.state, SyncCausalBaseState.knownVersion);
    expect(accepted.updatedAt, v2);
  });

  test('complete snapshot reconciles missing known cloud row to known absence',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = PendingQueue(db);
    final v1 = DateTime.utc(2026, 8, 29, 20);
    await _putLesson(db, 'lesson-1', DateTime.utc(2026, 8, 29, 19));
    await SyncRowMetaRepository(db).acceptKnownVersion(
      collection: 'lesson_progress',
      rowId: 'lesson-1',
      updatedAt: v1,
    );
    final pull = _pull(db, queue);

    await pull.applyCompleteSnapshot(
      generationId: generationId,
      collection: 'lesson_progress',
      documents: const [],
    );

    expect(await _lesson(db, 'lesson-1'), isNull);
    expect(
      await SyncRowMetaRepository(db).readAcceptedBase(
        collection: 'lesson_progress',
        rowId: 'lesson-1',
      ),
      const SyncCausalBase.knownAbsent(),
    );
  });

  test('complete snapshot preserves legitimate pending knownAbsent create',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = PendingQueue(db);
    await _putLesson(db, 'lesson-new', DateTime.utc(2026, 8, 29, 20));
    await SyncRowMetaRepository(db).acceptKnownAbsent(
      collection: 'lesson_progress',
      rowId: 'lesson-new',
    );
    await queue.enqueueGenerationBound(
      uid: uid,
      generationId: generationId,
      tableType: 'lesson_progress',
      rowId: 'lesson-new',
      op: PendingSyncOp.upsert,
      baseState: 'knownAbsent',
      baseUpdatedAt: null,
      mutationId: 'create-1',
      queuedAt: DateTime.utc(2026, 8, 29, 20),
    );
    final pull = _pull(db, queue);

    await pull.applyCompleteSnapshot(
      generationId: generationId,
      collection: 'lesson_progress',
      documents: const [],
    );

    expect(await _lesson(db, 'lesson-new'), isNotNull);
    expect(
      await queue.findGenerationBound(
        uid: uid,
        generationId: generationId,
        tableType: 'lesson_progress',
        rowId: 'lesson-new',
      ),
      isNotNull,
    );
  });

  test('old-generation listener event is quarantined without local mutation',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = PendingQueue(db);
    await _putLesson(db, 'lesson-1', DateTime.utc(2026, 8, 29, 20));
    final pull = _pull(db, queue);

    final result = await pull.applyDocument(
      generationId: 'generation-old',
      collection: 'lesson_progress',
      document: _document(
        'lesson-1',
        readAt: DateTime.utc(2026, 8, 29, 22),
        updatedAt: DateTime.utc(2026, 8, 29, 22),
        mutationId: 'old-generation',
        originDeviceId: 'device-2',
      ),
    );

    expect(result, PullApplyResult.quarantined);
    expect(
      (await _lesson(db, 'lesson-1'))!.readAt.toUtc(),
      DateTime.utc(2026, 8, 29, 20),
    );
  });
}

PullPipeline _pull(AppDatabase db, PendingQueue queue) => PullPipeline(
      db: db,
      queue: queue,
      uid: uid,
      generationId: generationId,
      deviceId: deviceId,
    );

SyncDocument _document(
  String id, {
  required DateTime readAt,
  required DateTime updatedAt,
  required String mutationId,
  required String originDeviceId,
}) =>
    SyncDocument(
      id: id,
      data: {
        'lessonId': id,
        'readAt': readAt.toUtc().toIso8601String(),
        'updatedAt': updatedAt.toUtc(),
        'originDeviceId': originDeviceId,
        'mutationId': mutationId,
        'deleted': false,
        'schemaVersion': 1,
      },
    );

Future<void> _putLesson(AppDatabase db, String id, DateTime readAt) =>
    db.into(db.lessonProgressLocal).insertOnConflictUpdate(
          LessonProgressLocalCompanion(
            lessonId: Value(id),
            readAt: Value(readAt),
            syncState: const Value('pending'),
          ),
        );

Future<LessonProgressLocalRow?> _lesson(AppDatabase db, String id) =>
    (db.select(db.lessonProgressLocal)..where((row) => row.lessonId.equals(id)))
        .getSingleOrNull();
