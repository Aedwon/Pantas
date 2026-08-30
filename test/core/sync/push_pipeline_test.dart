import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/engine/local_sync_mutation_recorder.dart';
import 'package:pantas/core/sync/engine/pending_queue.dart';
import 'package:pantas/core/sync/engine/pull_pipeline.dart';
import 'package:pantas/core/sync/engine/push_pipeline.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/core/sync/engine/sync_outbox_promoter.dart';
import 'package:pantas/core/sync/engine/sync_row_meta_repository.dart';
import 'package:pantas/core/sync/firestore/firestore_gateway.dart';
import 'package:pantas/core/sync/model/sync_causal_base.dart';
import 'package:pantas/core/sync/model/sync_document.dart';

import '../../helpers/in_memory_database.dart';

const uid = 'user-1';
const generationId = 'generation-1';
const deviceId = 'device-1';

void main() {
  test('knownAbsent create commits only while cloud remains absent', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = PendingQueue(db);
    final gateway = FakeFirestoreGateway(
      serverNow: () => DateTime.utc(2026, 8, 30, 1),
    );
    final pull = _pull(db, queue);
    final pipeline = _pipeline(db, queue, gateway, pull);

    await _putLesson(db, 'lesson-1', DateTime.utc(2026, 8, 29, 20));
    await queue.enqueueGenerationBound(
      uid: uid,
      generationId: generationId,
      tableType: 'lesson_progress',
      rowId: 'lesson-1',
      op: PendingSyncOp.upsert,
      baseState: 'knownAbsent',
      baseUpdatedAt: null,
      mutationId: 'mutation-1',
      queuedAt: DateTime.utc(2026, 8, 29, 20),
    );

    await pipeline.flush();

    final path = _path('lesson_progress', 'lesson-1');
    final cloud = await gateway.readDocument(path);
    expect(cloud, isNotNull);
    expect(cloud!.deleted, isFalse);
    expect(cloud.mutationId, 'mutation-1');
    expect(cloud.originDeviceId, deviceId);
    expect(cloud.updatedAt, DateTime.utc(2026, 8, 30, 1));
    expect(
        await queue.drainGeneration(
            uid: uid, generationId: generationId, limit: 10),
        isEmpty);
    final accepted = await SyncRowMetaRepository(db).readAcceptedBase(
      collection: 'lesson_progress',
      rowId: 'lesson-1',
    );
    expect(accepted!.state, SyncCausalBaseState.knownVersion);
    expect(accepted.updatedAt, DateTime.utc(2026, 8, 30, 1));
  });

  test(
      'knownVersion update loses to newer cloud state and reconciles it locally',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = PendingQueue(db);
    final gateway = FakeFirestoreGateway();
    final v1 = DateTime.utc(2026, 8, 29, 20);
    final v2 = DateTime.utc(2026, 8, 29, 21);
    gateway.documents[_path('lesson_progress', 'lesson-1')] = _lessonDoc(
      'lesson-1',
      readAt: DateTime.utc(2026, 8, 29, 21),
      updatedAt: v2,
      mutationId: 'remote-v2',
      originDeviceId: 'device-2',
    );
    await _putLesson(db, 'lesson-1', DateTime.utc(2026, 8, 29, 22));
    await queue.enqueueGenerationBound(
      uid: uid,
      generationId: generationId,
      tableType: 'lesson_progress',
      rowId: 'lesson-1',
      op: PendingSyncOp.upsert,
      baseState: 'knownVersion',
      baseUpdatedAt: v1,
      mutationId: 'local-l',
      queuedAt: DateTime.utc(2026, 8, 29, 22),
    );
    final pull = _pull(db, queue);

    await _pipeline(db, queue, gateway, pull).flush();

    final local = await _lesson(db, 'lesson-1');
    expect(local!.readAt.toUtc(), DateTime.utc(2026, 8, 29, 21));
    expect(
        (await gateway.readDocument(_path('lesson_progress', 'lesson-1')))!
            .mutationId,
        'remote-v2');
    expect(
        await queue.drainGeneration(
            uid: uid, generationId: generationId, limit: 10),
        isEmpty);
  });

  test('knownVersion delete loses to newer cloud state instead of deleting it',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = PendingQueue(db);
    final gateway = FakeFirestoreGateway();
    final v1 = DateTime.utc(2026, 8, 29, 20);
    final v2 = DateTime.utc(2026, 8, 29, 21);
    gateway.documents[_path('lesson_progress', 'lesson-1')] = _lessonDoc(
      'lesson-1',
      readAt: DateTime.utc(2026, 8, 29, 21),
      updatedAt: v2,
      mutationId: 'remote-v2',
      originDeviceId: 'device-2',
    );
    await _putLesson(db, 'lesson-1', DateTime.utc(2026, 8, 29, 20));
    await queue.enqueueGenerationBound(
      uid: uid,
      generationId: generationId,
      tableType: 'lesson_progress',
      rowId: 'lesson-1',
      op: PendingSyncOp.delete,
      baseState: 'knownVersion',
      baseUpdatedAt: v1,
      mutationId: 'local-delete',
      queuedAt: DateTime.utc(2026, 8, 29, 22),
    );
    final pull = _pull(db, queue);

    await _pipeline(db, queue, gateway, pull).flush();

    expect(await _lesson(db, 'lesson-1'), isNotNull);
    final cloud =
        await gateway.readDocument(_path('lesson_progress', 'lesson-1'));
    expect(cloud!.deleted, isFalse);
    expect(cloud.mutationId, 'remote-v2');
    expect(
        await queue.drainGeneration(
            uid: uid, generationId: generationId, limit: 10),
        isEmpty);
  });

  test(
      'successful delete writes a tombstone and never physically deletes cloud row',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = PendingQueue(db);
    final v1 = DateTime.utc(2026, 8, 29, 20);
    final v2 = DateTime.utc(2026, 8, 29, 21);
    final gateway = FakeFirestoreGateway(serverNow: () => v2);
    gateway.documents[_path('lesson_progress', 'lesson-1')] = _lessonDoc(
      'lesson-1',
      readAt: DateTime.utc(2026, 8, 29, 19),
      updatedAt: v1,
      mutationId: 'remote-v1',
      originDeviceId: 'device-2',
    );
    await _putLesson(db, 'lesson-1', DateTime.utc(2026, 8, 29, 19));
    await queue.enqueueGenerationBound(
      uid: uid,
      generationId: generationId,
      tableType: 'lesson_progress',
      rowId: 'lesson-1',
      op: PendingSyncOp.delete,
      baseState: 'knownVersion',
      baseUpdatedAt: v1,
      mutationId: 'delete-1',
      queuedAt: DateTime.utc(2026, 8, 29, 20, 30),
    );
    final pull = _pull(db, queue);

    await _pipeline(db, queue, gateway, pull).flush();

    final cloud =
        await gateway.readDocument(_path('lesson_progress', 'lesson-1'));
    expect(cloud, isNotNull);
    expect(cloud!.deleted, isTrue);
    expect(cloud.updatedAt, v2);
    expect(cloud.mutationId, 'delete-1');
    expect(await _lesson(db, 'lesson-1'), isNull);
  });

  test('newer local revision survives old successful in-flight acknowledgement',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = PendingQueue(db);
    final v1 = DateTime.utc(2026, 8, 29, 20);
    final v2 = DateTime.utc(2026, 8, 29, 21);
    final gateway = BlockingCommitGateway(serverNow: () => v2);
    gateway.documents[_path('lesson_progress', 'lesson-1')] = _lessonDoc(
      'lesson-1',
      readAt: DateTime.utc(2026, 8, 29, 19),
      updatedAt: v1,
      mutationId: 'remote-v1',
      originDeviceId: 'device-2',
    );
    await _putLesson(db, 'lesson-1', DateTime.utc(2026, 8, 29, 20, 5));
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
    final flush = _pipeline(db, queue, gateway, pull).flush();
    await gateway.entered.future;

    await _putLesson(db, 'lesson-1', DateTime.utc(2026, 8, 29, 20, 10));
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
    gateway.release.complete();
    await flush;

    final pending = await queue.findGenerationBound(
      uid: uid,
      generationId: generationId,
      tableType: 'lesson_progress',
      rowId: 'lesson-1',
    );
    expect(pending, isNotNull);
    expect(pending!.revision, 2);
    expect(pending.mutationId, 'mutation-2');
    expect(pending.baseState, 'knownVersion');
    expect(pending.baseUpdatedAt, v2);
    expect((await _lesson(db, 'lesson-1'))!.readAt.toUtc(),
        DateTime.utc(2026, 8, 29, 20, 10));
  });

  test('newer local revision is not marked failed by old in-flight failure',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = PendingQueue(db);
    final gateway = BlockingFailureGateway();
    final v1 = DateTime.utc(2026, 8, 29, 20);
    await _putLesson(db, 'lesson-1', DateTime.utc(2026, 8, 29, 20));
    await queue.enqueueGenerationBound(
      uid: uid,
      generationId: generationId,
      tableType: 'lesson_progress',
      rowId: 'lesson-1',
      op: PendingSyncOp.upsert,
      baseState: 'knownVersion',
      baseUpdatedAt: v1,
      mutationId: 'mutation-1',
      queuedAt: v1,
    );
    final pull = _pull(db, queue);
    final flush = _pipeline(db, queue, gateway, pull).flush();
    await gateway.entered.future;
    await queue.enqueueGenerationBound(
      uid: uid,
      generationId: generationId,
      tableType: 'lesson_progress',
      rowId: 'lesson-1',
      op: PendingSyncOp.upsert,
      baseState: 'knownVersion',
      baseUpdatedAt: v1,
      mutationId: 'mutation-2',
      queuedAt: v1.add(const Duration(minutes: 1)),
    );
    gateway.release.complete();
    await flush;

    final pending = await queue.findGenerationBound(
      uid: uid,
      generationId: generationId,
      tableType: 'lesson_progress',
      rowId: 'lesson-1',
    );
    expect(pending!.revision, 2);
    expect(pending.mutationId, 'mutation-2');
    expect(pending.attempts, 0);
    expect(pending.lastError, isNull);
  });

  test('flush is serialized so overlapping calls share one active drain',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = PendingQueue(db);
    final gateway = BlockingCommitGateway();
    await _putLesson(db, 'lesson-1', DateTime.utc(2026, 8, 29, 20));
    await queue.enqueueGenerationBound(
      uid: uid,
      generationId: generationId,
      tableType: 'lesson_progress',
      rowId: 'lesson-1',
      op: PendingSyncOp.upsert,
      baseState: 'knownAbsent',
      baseUpdatedAt: null,
      mutationId: 'mutation-1',
      queuedAt: DateTime.utc(2026, 8, 29, 20),
    );
    final pull = _pull(db, queue);
    final pipeline = _pipeline(db, queue, gateway, pull);

    final first = pipeline.flush();
    await gateway.entered.future;
    final second = pipeline.flush();
    await Future<void>.delayed(Duration.zero);
    expect(gateway.maxActive, 1);
    gateway.release.complete();
    await Future.wait([first, second]);

    expect(gateway.calls, 1);
    expect(gateway.maxActive, 1);
  });

  test('transient gateway failure retains durable work and diagnostics',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = PendingQueue(db);
    final gateway = ThrowingConditionalGateway();
    await _putLesson(db, 'lesson-1', DateTime.utc(2026, 8, 29, 20));
    await queue.enqueueGenerationBound(
      uid: uid,
      generationId: generationId,
      tableType: 'lesson_progress',
      rowId: 'lesson-1',
      op: PendingSyncOp.upsert,
      baseState: 'knownAbsent',
      baseUpdatedAt: null,
      mutationId: 'mutation-1',
      queuedAt: DateTime.utc(2026, 8, 29, 20),
    );
    final pull = _pull(db, queue);

    await _pipeline(db, queue, gateway, pull).flush();

    final pending = await queue.findGenerationBound(
      uid: uid,
      generationId: generationId,
      tableType: 'lesson_progress',
      rowId: 'lesson-1',
    );
    expect(pending!.attempts, 1);
    expect(pending.lastError, 'unavailable');
    expect(pending.lastAttemptAt, isNotNull);
  });

  test(
      'V1 local base survives V2 remote before promotion and stale local loses',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = PendingQueue(db);
    final contextStore = SyncActiveContextStore(db);
    final rowMeta = SyncRowMetaRepository(db);
    final v1 = DateTime.utc(2026, 8, 29, 20);
    final v2 = DateTime.utc(2026, 8, 29, 21);
    await contextStore.publishStable(uid: uid, generationId: generationId);
    await rowMeta.acceptKnownVersion(
      collection: 'lesson_progress',
      rowId: 'lesson-1',
      updatedAt: v1,
      originDeviceId: 'device-2',
    );
    await _putLesson(db, 'lesson-1', DateTime.utc(2026, 8, 29, 19));
    final recorder = LocalSyncMutationRecorder(
      db,
      activeContextStore: contextStore,
      rowMetaRepository: rowMeta,
      now: () => DateTime.utc(2026, 8, 29, 20, 5),
    );
    await recorder.runRecorded(
      collection: 'lesson_progress',
      rowId: 'lesson-1',
      op: SyncLocalMutationOp.upsert,
      mutate: () =>
          _putLesson(db, 'lesson-1', DateTime.utc(2026, 8, 29, 20, 5)),
    );

    final pull = _pull(db, queue);
    await pull.applyDocument(
      generationId: generationId,
      collection: 'lesson_progress',
      document: SyncDocument(
        id: 'lesson-1',
        data: _lessonDoc(
          'lesson-1',
          readAt: DateTime.utc(2026, 8, 29, 21),
          updatedAt: v2,
          mutationId: 'remote-v2',
          originDeviceId: 'device-2',
        ),
      ),
    );
    final acceptedBeforePromotion = await rowMeta.readAcceptedBase(
      collection: 'lesson_progress',
      rowId: 'lesson-1',
    );
    expect(acceptedBeforePromotion!.state, SyncCausalBaseState.knownVersion);
    expect(acceptedBeforePromotion.updatedAt, v2);

    final promoter = SyncOutboxPromoter(
      db,
      activeContextStore: contextStore,
      pendingQueue: queue,
      mutationIdFactory: () => 'local-l',
    );
    expect(await promoter.promoteAvailable(), 1);
    final pending = await queue.findGenerationBound(
      uid: uid,
      generationId: generationId,
      tableType: 'lesson_progress',
      rowId: 'lesson-1',
    );
    expect(pending!.baseState, 'knownVersion');
    expect(pending.baseUpdatedAt, v1);

    final gateway = FakeFirestoreGateway();
    gateway.documents[_path('lesson_progress', 'lesson-1')] = _lessonDoc(
      'lesson-1',
      readAt: DateTime.utc(2026, 8, 29, 21),
      updatedAt: v2,
      mutationId: 'remote-v2',
      originDeviceId: 'device-2',
    );
    await _pipeline(db, queue, gateway, pull).flush();

    expect(
        await queue.drainGeneration(
            uid: uid, generationId: generationId, limit: 10),
        isEmpty);
    expect((await _lesson(db, 'lesson-1'))!.readAt.toUtc(),
        DateTime.utc(2026, 8, 29, 21));
    final acceptedAfterStale = await rowMeta.readAcceptedBase(
      collection: 'lesson_progress',
      rowId: 'lesson-1',
    );
    expect(acceptedAfterStale!.state, SyncCausalBaseState.knownVersion);
    expect(acceptedAfterStale.updatedAt, v2);
    expect(
        (await gateway.readDocument(_path('lesson_progress', 'lesson-1')))!
            .mutationId,
        'remote-v2');
  });
}

PullPipeline _pull(AppDatabase db, PendingQueue queue) => PullPipeline(
      db: db,
      queue: queue,
      uid: uid,
      generationId: generationId,
      deviceId: deviceId,
    );

PushPipeline _pipeline(
  AppDatabase db,
  PendingQueue queue,
  FirestoreGateway gateway,
  PullPipeline pull,
) =>
    PushPipeline(
      queue: queue,
      gateway: gateway,
      uid: uid,
      generationId: generationId,
      deviceId: deviceId,
      isAnonymous: false,
      loadPayload: (collection, rowId) => _loadPayload(db, collection, rowId),
      handleResult: pull.handlePushResult,
      now: () => DateTime.utc(2026, 8, 30),
    );

Future<Map<String, Object?>?> _loadPayload(
  AppDatabase db,
  String collection,
  String rowId,
) async {
  if (collection != 'lesson_progress') return null;
  final row = await _lesson(db, rowId);
  if (row == null) return null;
  return {
    'lessonId': row.lessonId,
    'readAt': row.readAt.toUtc().toIso8601String(),
  };
}

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

Map<String, Object?> _lessonDoc(
  String id, {
  required DateTime readAt,
  required DateTime updatedAt,
  required String mutationId,
  required String originDeviceId,
  bool deleted = false,
}) =>
    {
      'lessonId': id,
      'readAt': readAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc(),
      'originDeviceId': originDeviceId,
      'mutationId': mutationId,
      'deleted': deleted,
      'schemaVersion': 1,
    };

String _path(String collection, String rowId) =>
    'users/$uid/sync_generations/$generationId/$collection/$rowId';

class ThrowingConditionalGateway extends FakeFirestoreGateway {
  @override
  Future<RowCommitResult> commitRowIfBaseMatches({
    required String path,
    required SyncCausalBase base,
    required Map<String, Object?> data,
  }) async {
    throw const SyncGatewayException('unavailable');
  }
}

class BlockingFailureGateway extends FakeFirestoreGateway {
  final entered = Completer<void>();
  final release = Completer<void>();

  @override
  Future<RowCommitResult> commitRowIfBaseMatches({
    required String path,
    required SyncCausalBase base,
    required Map<String, Object?> data,
  }) async {
    if (!entered.isCompleted) entered.complete();
    await release.future;
    throw const SyncGatewayException('unavailable');
  }
}

class BlockingCommitGateway extends FakeFirestoreGateway {
  BlockingCommitGateway({super.serverNow});

  final entered = Completer<void>();
  final release = Completer<void>();
  var calls = 0;
  var active = 0;
  var maxActive = 0;

  @override
  Future<RowCommitResult> commitRowIfBaseMatches({
    required String path,
    required SyncCausalBase base,
    required Map<String, Object?> data,
  }) async {
    calls += 1;
    active += 1;
    if (active > maxActive) maxActive = active;
    if (!entered.isCompleted) entered.complete();
    await release.future;
    try {
      return await super
          .commitRowIfBaseMatches(path: path, base: base, data: data);
    } finally {
      active -= 1;
    }
  }
}
