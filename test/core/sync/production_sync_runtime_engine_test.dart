import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/engine/collection_registry.dart';
import 'package:pantas/core/sync/engine/local_sync_mutation_recorder.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/core/sync/engine/sync_row_meta_repository.dart';
import 'package:pantas/core/sync/firestore/firestore_gateway.dart';
import 'package:pantas/core/sync/model/sync_causal_base.dart';
import 'package:pantas/core/sync/model/sync_document.dart';
import 'package:pantas/core/sync/runtime/production_sync_runtime_engine.dart';
import 'package:pantas/core/sync/runtime/sync_runtime_controller.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = inMemoryDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  test('production engine subscribes to exactly ten active generation paths',
      () async {
    final gateway = _TrackingFirestoreGateway();
    final context = SyncActiveContextStore(db);
    await context.publishStable(uid: 'user-1', generationId: 'gen-1');
    final engine = ProductionSyncRuntimeEngine(
      db: db,
      gateway: gateway,
      activeContextStore: context,
      deviceId: 'device-1',
      localMutationDebounce: const Duration(milliseconds: 1),
    );

    await engine.start(uid: 'user-1', generationId: 'gen-1');
    addTearDown(engine.stop);

    expect(activeSyncCollections, hasLength(10));
    expect(
      gateway.watchedCollections,
      activeSyncCollections
          .map(
            (entry) =>
                'users/user-1/sync_generations/gen-1/${entry.firestorePath}',
          )
          .toList(),
    );
    expect(engine.activeUid, 'user-1');
    expect(engine.activeGenerationId, 'gen-1');
  });

  test('a change waiting in the journal survives the first download', () async {
    // The student recreated a bookmark the cloud had deleted, and the page
    // reloaded inside the upload debounce. The snapshot still lacks the row.
    final gateway = _EmptySnapshotGateway();
    final context = SyncActiveContextStore(db);
    await context.publishStable(uid: 'user-1', generationId: 'gen-1');
    await SyncRowMetaRepository(db).acceptKnownAbsent(
      collection: 'lesson_bookmarks',
      rowId: 'lesson-1',
    );
    await LocalSyncMutationRecorder.forDatabase(db).runRecorded<void>(
      collection: 'lesson_bookmarks',
      rowId: 'lesson-1',
      op: SyncLocalMutationOp.upsert,
      mutate: () => db.into(db.lessonBookmarksLocal).insert(
            LessonBookmarksLocalCompanion.insert(
              lessonId: 'lesson-1',
              markedAt: DateTime.utc(2026, 11, 5),
            ),
          ),
    );
    final engine = ProductionSyncRuntimeEngine(
      db: db,
      gateway: gateway,
      activeContextStore: context,
      deviceId: 'device-1',
      localMutationDebounce: const Duration(hours: 1),
    );

    await engine.start(uid: 'user-1', generationId: 'gen-1');
    addTearDown(engine.stop);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(await db.select(db.lessonBookmarksLocal).get(), hasLength(1));
    expect(
      gateway.documents.keys,
      contains(
        'users/user-1/sync_generations/gen-1/lesson_bookmarks/lesson-1',
      ),
    );
  });

  test('failed offline flush retries both bookmarks without listener errors',
      () async {
    final gateway = _OfflineGateway();
    final context = SyncActiveContextStore(db);
    await context.publishStable(uid: 'user-1', generationId: 'gen-1');
    await _recordBookmark(db, 'lesson-1');
    await _recordBookmark(db, 'lesson-2');
    final engine = ProductionSyncRuntimeEngine(
      db: db,
      gateway: gateway,
      activeContextStore: context,
      deviceId: 'device-1',
      localMutationDebounce: const Duration(hours: 1),
    );
    addTearDown(engine.stop);
    await engine.start(uid: 'user-1', generationId: 'gen-1');
    await _waitFor(() async => gateway.attempts == 2);
    expect(await db.select(db.pendingSync).get(), hasLength(2));

    gateway.offline = false;
    await Future<void>.delayed(const Duration(milliseconds: 1200));

    expect(gateway.documents, hasLength(2));
    expect(await db.select(db.pendingSync).get(), isEmpty);
  });

  test('retry backs off after another failure and stops after success',
      () async {
    final gateway = _OfflineGateway();
    final context = SyncActiveContextStore(db);
    await context.publishStable(uid: 'user-1', generationId: 'gen-1');
    await _recordBookmark(db, 'lesson-1');
    var recoveries = 0;
    final engine = ProductionSyncRuntimeEngine(
      db: db,
      gateway: gateway,
      activeContextStore: context,
      deviceId: 'device-1',
      localMutationDebounce: const Duration(hours: 1),
      // Half the real 1 s, so every wait below is half what it would be.
      retryBaseDelay: const Duration(milliseconds: 500),
      recoverCustomTrackProjection: () async {
        recoveries++;
        return true;
      },
    );
    addTearDown(engine.stop);
    await engine.start(uid: 'user-1', generationId: 'gen-1');
    await _waitFor(() async => gateway.attempts == 1);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    expect(gateway.attempts, 2);
    gateway.offline = false;
    await Future<void>.delayed(const Duration(milliseconds: 550));
    expect(gateway.documents, isEmpty);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    expect(gateway.documents, hasLength(1));
    final settledRecoveries = recoveries;
    await Future<void>.delayed(const Duration(milliseconds: 2100));
    expect(recoveries, settledRecoveries);
  });

  test('stop cancels a pending retry', () async {
    final gateway = _OfflineGateway();
    final context = SyncActiveContextStore(db);
    await context.publishStable(uid: 'user-1', generationId: 'gen-1');
    await _recordBookmark(db, 'lesson-1');
    final engine = ProductionSyncRuntimeEngine(
      db: db,
      gateway: gateway,
      activeContextStore: context,
      deviceId: 'device-1',
      localMutationDebounce: const Duration(hours: 1),
    );
    addTearDown(engine.stop);
    await engine.start(uid: 'user-1', generationId: 'gen-1');
    await _waitFor(() async => gateway.attempts == 1);
    await engine.stop();
    gateway.offline = false;
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    expect(gateway.attempts, 1);
    expect(gateway.documents, isEmpty);
    expect(await db.select(db.pendingSync).get(), hasLength(1));
  });

  test('online event flushes immediately without another snapshot', () async {
    final online = StreamController<void>.broadcast();
    addTearDown(online.close);
    final gateway = _OfflineGateway();
    final context = SyncActiveContextStore(db);
    await context.publishStable(uid: 'user-1', generationId: 'gen-1');
    await _recordBookmark(db, 'lesson-1');
    final engine = ProductionSyncRuntimeEngine(
      db: db,
      gateway: gateway,
      activeContextStore: context,
      deviceId: 'device-1',
      localMutationDebounce: const Duration(hours: 1),
      onlineEvents: () => online.stream,
    );
    addTearDown(engine.stop);
    await engine.start(uid: 'user-1', generationId: 'gen-1');
    await _waitFor(() async => gateway.attempts == 1);
    gateway.offline = false;
    online.add(null);
    await _waitFor(
      () async =>
          gateway.documents.isNotEmpty &&
          (await db.select(db.pendingSync).get()).isEmpty,
    );
    expect(await db.select(db.pendingSync).get(), isEmpty);

    await engine.stop();
    await _recordBookmark(db, 'lesson-2');
    online.add(null);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(gateway.documents, hasLength(1));
  });

  test('online and explicit flush wait for remaining first snapshots',
      () async {
    final online = StreamController<void>.broadcast();
    final gateway = _DelayedSnapshotGateway();
    addTearDown(online.close);
    addTearDown(gateway.close);
    final context = SyncActiveContextStore(db);
    await context.publishStable(uid: 'user-1', generationId: 'gen-1');
    await _recordBookmark(db, 'lesson-1');
    final engine = ProductionSyncRuntimeEngine(
      db: db,
      gateway: gateway,
      activeContextStore: context,
      deviceId: 'device-1',
      localMutationDebounce: const Duration(milliseconds: 1),
      onlineEvents: () => online.stream,
    );
    addTearDown(engine.stop);
    await engine.start(uid: 'user-1', generationId: 'gen-1');
    online.add(null);
    await engine.forceFlush();
    final snapshots = gateway.snapshots.values.toList();
    snapshots.first.addError(const SyncGatewayException('unavailable'));
    for (final snapshot in snapshots.skip(1).take(snapshots.length - 2)) {
      snapshot.add(const []);
    }
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(gateway.documents, isEmpty);
    snapshots.last.add(const []);
    await _waitFor(
      () async =>
          gateway.documents.isNotEmpty &&
          (await db.select(db.pendingSync).get()).isEmpty,
    );
    expect(await db.select(db.lessonBookmarksLocal).get(), hasLength(1));
  });

  test('ordinary flush publishes activity then settled event', () async {
    final gateway = _EmptySnapshotGateway();
    final context = SyncActiveContextStore(db);
    await context.publishStable(uid: 'user-1', generationId: 'gen-1');
    final engine = ProductionSyncRuntimeEngine(
      db: db,
      gateway: gateway,
      activeContextStore: context,
      deviceId: 'device-1',
    );

    await engine.start(uid: 'user-1', generationId: 'gen-1');
    addTearDown(engine.stop);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final events = engine.events.take(2).toList();

    await engine.forceFlush();

    expect(
      await events,
      [isA<SyncRuntimeActivity>(), isA<SyncRuntimeSettled>()],
    );
  });

  test('projection recovery failure publishes runtime failure', () async {
    final gateway = _EmptySnapshotGateway();
    final context = SyncActiveContextStore(db);
    await context.publishStable(uid: 'user-1', generationId: 'gen-1');
    final engine = ProductionSyncRuntimeEngine(
      db: db,
      gateway: gateway,
      activeContextStore: context,
      deviceId: 'device-1',
      recoverCustomTrackProjection: () async {
        throw StateError('projection failed');
      },
    );

    await engine.start(uid: 'user-1', generationId: 'gen-1');
    addTearDown(engine.stop);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final failure = engine.events
        .firstWhere((event) => event is SyncRuntimeFailure)
        .then((event) => event as SyncRuntimeFailure);

    await expectLater(engine.forceFlush(), throwsA(isA<StateError>()));

    expect((await failure).message, contains('projection failed'));
  });

  group('paused account', () {
    const statePath = 'users/user-1/sync_state/current';

    // Starting the engine already pushes what waits in the outbox, once the
    // first downloads settle. The events list is attached before that.
    Future<(ProductionSyncRuntimeEngine, List<SyncRuntimeEvent>)> startEngine(
      _SuspendingGateway gateway,
    ) async {
      final context = SyncActiveContextStore(db);
      await context.publishStable(uid: 'user-1', generationId: 'gen-1');
      await _recordBookmark(db, 'lesson-1');
      await _recordBookmark(db, 'lesson-2');
      final engine = ProductionSyncRuntimeEngine(
        db: db,
        gateway: gateway,
        activeContextStore: context,
        deviceId: 'device-1',
        localMutationDebounce: const Duration(hours: 1),
        retryBaseDelay: const Duration(milliseconds: 20),
      );
      final events = <SyncRuntimeEvent>[];
      final subscription = engine.events.listen(events.add);
      addTearDown(subscription.cancel);
      addTearDown(engine.stop);
      await engine.start(uid: 'user-1', generationId: 'gen-1');
      return (engine, events);
    }

    test('a refused push with a future pause enters the paused status',
        () async {
      final until = DateTime.now().toUtc().add(const Duration(hours: 1));
      final gateway = _SuspendingGateway()
        ..documents[statePath] = {'suspendedUntil': until};

      final (_, events) = await startEngine(gateway);
      await _waitFor(
        () async => events.any((event) => event is SyncRuntimePaused),
      );

      final paused = events.whereType<SyncRuntimePaused>().toList();
      expect(paused.last.until, until);
      expect(events.last, isA<SyncRuntimePaused>());
      expect(events.whereType<SyncRuntimeFailure>(), isEmpty);
    });

    test('nothing is pushed while paused, and no retry loop runs', () async {
      final until = DateTime.now().toUtc().add(const Duration(hours: 1));
      final gateway = _SuspendingGateway()
        ..documents[statePath] = {'suspendedUntil': until};
      final (engine, events) = await startEngine(gateway);
      await _waitFor(
        () async => events.any((event) => event is SyncRuntimePaused),
      );
      final readsAtPause = gateway.stateReads;

      await engine.forceFlush();
      await engine.forceFlush();
      await Future<void>.delayed(const Duration(milliseconds: 300));

      expect(gateway.attempts, 1);
      expect(gateway.stateReads, readsAtPause);
      expect(await db.select(db.pendingSync).get(), isNotEmpty);
      expect(events.last, isA<SyncRuntimePaused>());
    });

    test('a push goes through again once the pause time has passed', () async {
      final until = DateTime.now().toUtc().add(
            const Duration(milliseconds: 600),
          );
      final gateway = _SuspendingGateway()
        ..documents[statePath] = {'suspendedUntil': until}
        ..refuseUntil = until;
      final (_, events) = await startEngine(gateway);
      await _waitFor(
        () async => events.any((event) => event is SyncRuntimePaused),
      );
      expect(gateway.attempts, 1);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(gateway.attempts, 1);

      await _waitFor(
        () async => (await db.select(db.pendingSync).get()).isEmpty,
      );

      expect(gateway.attempts, greaterThan(1));
      expect(events.last, isA<SyncRuntimeSettled>());
    });

    test('a refusal with no pause behaves as before', () async {
      final gateway = _SuspendingGateway();

      final (_, events) = await startEngine(gateway);
      await _waitFor(() async => gateway.attempts >= 4);

      expect(events.whereType<SyncRuntimePaused>(), isEmpty);
      final pending = await db.select(db.pendingSync).get();
      expect(pending, hasLength(2));
      expect(
        pending.every((row) => row.lastError == 'permission-denied'),
        isTrue,
      );
    });

    test('a pause time already in the past behaves as before', () async {
      final gateway = _SuspendingGateway(throwFirebase: true)
        ..documents[statePath] = {
          'suspendedUntil': DateTime.now().toUtc().subtract(
                const Duration(minutes: 1),
              ),
        };

      final (_, events) = await startEngine(gateway);
      await _waitFor(
        () async => events.any((event) => event is SyncRuntimeFailure),
      );

      expect(events.whereType<SyncRuntimePaused>(), isEmpty);
    });

    test('a refused push from the Firebase client also pauses', () async {
      final until = DateTime.now().toUtc().add(const Duration(hours: 1));
      final gateway = _SuspendingGateway(throwFirebase: true)
        ..documents[statePath] = {'suspendedUntil': until};

      final (_, events) = await startEngine(gateway);
      await _waitFor(
        () async => events.any((event) => event is SyncRuntimePaused),
      );

      expect(gateway.attempts, 1);
      expect(events.whereType<SyncRuntimeFailure>(), isEmpty);
    });
  });
}

class _SuspendingGateway extends _EmptySnapshotGateway {
  _SuspendingGateway({this.throwFirebase = false});

  final bool throwFirebase;
  DateTime? refuseUntil = DateTime.now().add(const Duration(hours: 1));
  int attempts = 0;
  int stateReads = 0;

  @override
  Future<SyncDocument?> readDocument(String path) {
    if (path.endsWith('/sync_state/current')) stateReads++;
    return super.readDocument(path);
  }

  @override
  Future<RowCommitResult> commitRowIfBaseMatches({
    required String path,
    required SyncCausalBase base,
    required Map<String, Object?> data,
  }) async {
    attempts++;
    final until = refuseUntil;
    if (until != null && DateTime.now().isBefore(until)) {
      if (throwFirebase) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
        );
      }
      throw const SyncGatewayException('permission-denied');
    }
    return super.commitRowIfBaseMatches(path: path, base: base, data: data);
  }
}

class _EmptySnapshotGateway extends FakeFirestoreGateway {
  @override
  Stream<List<SyncDocument>> watchCollection(String path) =>
      Stream.value(const <SyncDocument>[]);
}

class _TrackingFirestoreGateway extends FakeFirestoreGateway {
  final watchedCollections = <String>[];

  @override
  Stream<List<SyncDocument>> watchCollection(String path) {
    watchedCollections.add(path);
    return const Stream<List<SyncDocument>>.empty();
  }
}

Future<void> _recordBookmark(AppDatabase db, String id) async {
  await SyncRowMetaRepository(db).acceptKnownAbsent(
    collection: 'lesson_bookmarks',
    rowId: id,
  );
  await LocalSyncMutationRecorder.forDatabase(db).runRecorded<void>(
    collection: 'lesson_bookmarks',
    rowId: id,
    op: SyncLocalMutationOp.upsert,
    mutate: () => db.into(db.lessonBookmarksLocal).insert(
          LessonBookmarksLocalCompanion.insert(
            lessonId: id,
            markedAt: DateTime.utc(2026, 11, 5),
          ),
        ),
  );
}

Future<void> _waitFor(Future<bool> Function() predicate) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    if (await predicate()) return;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('Sync did not reach the expected state');
}

class _OfflineGateway extends _EmptySnapshotGateway {
  bool offline = true;
  int attempts = 0;

  @override
  Future<RowCommitResult> commitRowIfBaseMatches({
    required String path,
    required SyncCausalBase base,
    required Map<String, Object?> data,
  }) async {
    attempts++;
    if (offline) throw const SyncGatewayException('unavailable');
    return super.commitRowIfBaseMatches(path: path, base: base, data: data);
  }
}

class _DelayedSnapshotGateway extends FakeFirestoreGateway {
  final snapshots = <String, StreamController<List<SyncDocument>>>{};

  @override
  Stream<List<SyncDocument>> watchCollection(String path) {
    final controller = StreamController<List<SyncDocument>>();
    snapshots[path] = controller;
    return controller.stream;
  }

  Future<void> close() async {
    for (final controller in snapshots.values) {
      await controller.close();
    }
  }
}
