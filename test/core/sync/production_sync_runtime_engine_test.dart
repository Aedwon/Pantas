import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/engine/collection_registry.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/core/sync/firestore/firestore_gateway.dart';
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

  test('ordinary flush publishes activity then settled event', () async {
    final gateway = _TrackingFirestoreGateway();
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
    final events = engine.events.take(2).toList();

    await engine.forceFlush();

    expect(
      await events,
      [isA<SyncRuntimeActivity>(), isA<SyncRuntimeSettled>()],
    );
  });

  test('projection recovery failure publishes runtime failure', () async {
    final gateway = _TrackingFirestoreGateway();
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
    final failure = engine.events
        .firstWhere((event) => event is SyncRuntimeFailure)
        .then((event) => event as SyncRuntimeFailure);

    await expectLater(engine.forceFlush(), throwsA(isA<StateError>()));

    expect((await failure).message, contains('projection failed'));
  });
}

class _TrackingFirestoreGateway extends FakeFirestoreGateway {
  final watchedCollections = <String>[];

  @override
  Stream<List<SyncDocument>> watchCollection(String path) {
    watchedCollections.add(path);
    return const Stream<List<SyncDocument>>.empty();
  }
}
