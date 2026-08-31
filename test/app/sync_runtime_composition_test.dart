import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/sync_runtime_bootstrap.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/eligibility/sync_claim_gateway.dart';
import 'package:pantas/core/sync/eligibility/sync_entitlement.dart';
import 'package:pantas/core/sync/firestore/firestore_gateway.dart';
import 'package:pantas/core/sync/firestore/functions_gateway.dart';
import 'package:pantas/core/sync/model/sync_document.dart';
import 'package:pantas/core/sync/providers.dart';
import 'package:pantas/core/sync/sync_status.dart';

import '../helpers/in_memory_database.dart';

void main() {
  test('configured builder composes a real runtime from injectable cloud seams',
      () async {
    final appDb = inMemoryDatabase();
    final contentDb = inMemoryContentDatabase();
    addTearDown(appDb.close);
    addTearDown(contentDb.close);
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(appDb),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    addTearDown(container.dispose);

    final runtime = await buildConfiguredSyncRuntime(
      container,
      firestoreGateway: FakeFirestoreGateway(),
      functionsGateway: FakeSyncFunctionsGateway(),
      claimGateway: const _AllowClaimGateway(),
    );

    expect(runtime.runtimeKind, SyncRuntimeKind.configured);
    expect(runtime, isA<ConfiguredSyncRuntimeSurface>());
    expect(runtime, isNot(isA<FakeSyncEngine>()));
    final deviceRow = await appDb
        .customSelect(
          "select value from sync_meta where key = 'deviceId'",
        )
        .getSingleOrNull();
    expect(deviceRow?.read<String>('value'), isNotEmpty);
  });

  test('configured runtime refreshes status after incremental journal changes',
      () async {
    final appDb = inMemoryDatabase();
    final contentDb = inMemoryContentDatabase();
    addTearDown(appDb.close);
    addTearDown(contentDb.close);
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(appDb),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    addTearDown(container.dispose);

    final runtime = await buildConfiguredSyncRuntime(
      container,
      firestoreGateway: FakeFirestoreGateway(),
      functionsGateway: FakeSyncFunctionsGateway(),
      claimGateway: const _AllowClaimGateway(),
      deviceId: 'device-1',
    );
    addTearDown(() => runtime.quiesce(flush: false));

    await runtime.update(
      identity: const SyncIdentity(uid: 'user-1'),
      entitlement: SyncEntitlement.pro,
    );
    await runtime.statuses
        .firstWhere((status) => status is SyncUpToDate)
        .timeout(const Duration(seconds: 1));

    await appDb.into(appDb.syncLocalMutations).insert(
          SyncLocalMutationsCompanion.insert(
            collection: 'lesson_progress',
            rowId: 'status-refresh',
            op: 'upsert',
            mutationEpoch: 1,
            causalBaseState: 'unbound',
            recordedAt: DateTime.utc(2026, 8, 30),
          ),
        );

    await runtime.statuses
        .firstWhere((status) => status is Syncing)
        .timeout(const Duration(milliseconds: 300));

    await (appDb.delete(appDb.syncLocalMutations)
          ..where((row) => row.rowId.equals('status-refresh')))
        .go();

    await runtime.statuses
        .firstWhere((status) => status is SyncUpToDate)
        .timeout(const Duration(milliseconds: 300));
  });

  test('incremental remote snapshots publish syncing then settled status',
      () async {
    final appDb = inMemoryDatabase();
    final contentDb = inMemoryContentDatabase();
    final gateway = _ControlledFirestoreGateway();
    addTearDown(appDb.close);
    addTearDown(contentDb.close);
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(appDb),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    addTearDown(container.dispose);

    final runtime = await buildConfiguredSyncRuntime(
      container,
      firestoreGateway: gateway,
      functionsGateway: FakeSyncFunctionsGateway(),
      claimGateway: const _AllowClaimGateway(),
      deviceId: 'device-1',
    );
    addTearDown(() async {
      await runtime.quiesce(flush: false);
      await gateway.close();
    });
    await runtime.update(
      identity: const SyncIdentity(uid: 'user-1'),
      entitlement: SyncEntitlement.pro,
    );
    expect(runtime.currentStatus, isA<SyncUpToDate>());

    final sawSyncing = Completer<void>();
    final sawSettled = Completer<void>();
    var activeSeen = false;
    final subscription = runtime.statuses.listen((status) {
      if (status is Syncing) {
        activeSeen = true;
        if (!sawSyncing.isCompleted) sawSyncing.complete();
      } else if (activeSeen && status is SyncUpToDate) {
        if (!sawSettled.isCompleted) sawSettled.complete();
      }
    });
    addTearDown(subscription.cancel);

    gateway.emit('lesson_progress', const <SyncDocument>[]);

    await sawSyncing.future.timeout(const Duration(seconds: 1));
    await sawSettled.future.timeout(const Duration(seconds: 1));
  });

  test('listener error publishes offline and next snapshot reconnects',
      () async {
    final appDb = inMemoryDatabase();
    final contentDb = inMemoryContentDatabase();
    final gateway = _ControlledFirestoreGateway();
    addTearDown(appDb.close);
    addTearDown(contentDb.close);
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(appDb),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    addTearDown(container.dispose);

    final runtime = await buildConfiguredSyncRuntime(
      container,
      firestoreGateway: gateway,
      functionsGateway: FakeSyncFunctionsGateway(),
      claimGateway: const _AllowClaimGateway(),
      deviceId: 'device-1',
    );
    addTearDown(() async {
      await runtime.quiesce(flush: false);
      await gateway.close();
    });
    await runtime.update(
      identity: const SyncIdentity(uid: 'user-1'),
      entitlement: SyncEntitlement.pro,
    );
    expect(runtime.currentStatus, isA<SyncUpToDate>());

    final sawOffline = Completer<void>();
    final sawRecovered = Completer<void>();
    var offlineSeen = false;
    final subscription = runtime.statuses.listen((status) {
      if (status is SyncOffline) {
        offlineSeen = true;
        if (!sawOffline.isCompleted) sawOffline.complete();
      } else if (offlineSeen && status is SyncUpToDate) {
        if (!sawRecovered.isCompleted) sawRecovered.complete();
      }
    });
    addTearDown(subscription.cancel);

    gateway.emitError('lesson_progress', StateError('network unavailable'));
    await sawOffline.future.timeout(const Duration(seconds: 1));

    gateway.emit('lesson_progress', const <SyncDocument>[]);
    await sawRecovered.future.timeout(const Duration(seconds: 1));
  });

  test('remote processing failure publishes error status', () async {
    final appDb = inMemoryDatabase();
    final contentDb = inMemoryContentDatabase();
    final gateway = _ControlledFirestoreGateway();
    addTearDown(appDb.close);
    addTearDown(contentDb.close);
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(appDb),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    addTearDown(container.dispose);

    final runtime = await buildConfiguredSyncRuntime(
      container,
      firestoreGateway: gateway,
      functionsGateway: FakeSyncFunctionsGateway(),
      claimGateway: const _AllowClaimGateway(),
      deviceId: 'device-1',
    );
    addTearDown(() async {
      await runtime.quiesce(flush: false);
      await gateway.close();
    });
    await runtime.update(
      identity: const SyncIdentity(uid: 'user-1'),
      entitlement: SyncEntitlement.pro,
    );
    expect(runtime.currentStatus, isA<SyncUpToDate>());

    final errorFuture = runtime.statuses
        .firstWhere((status) => status is SyncError)
        .timeout(const Duration(seconds: 1));
    gateway.emit(
      'lesson_progress',
      [SyncDocument(id: 'invalid', data: const <String, Object?>{})],
    );

    final status = await errorFuture as SyncError;
    expect(status.message, contains('authoritative updatedAt'));
  });
}

class _AllowClaimGateway implements SyncClaimGateway {
  const _AllowClaimGateway();

  @override
  Future<bool> refreshProClaim({required String uid}) async => true;
}

class _ControlledFirestoreGateway extends FakeFirestoreGateway {
  final _controllers = <String, StreamController<List<SyncDocument>>>{};

  @override
  Stream<List<SyncDocument>> watchCollection(String path) {
    final controller = StreamController<List<SyncDocument>>.broadcast();
    _controllers[path] = controller;
    return controller.stream;
  }

  void emit(String collection, List<SyncDocument> documents) {
    _controllerFor(collection).add(documents);
  }

  void emitError(String collection, Object error) {
    _controllerFor(collection).addError(error);
  }

  Future<void> close() async {
    for (final controller in _controllers.values) {
      await controller.close();
    }
  }

  StreamController<List<SyncDocument>> _controllerFor(String collection) {
    return _controllers.entries
        .singleWhere((entry) => entry.key.endsWith('/$collection'))
        .value;
  }
}
