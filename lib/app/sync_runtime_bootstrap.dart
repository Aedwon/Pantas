import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/app/firebase_bootstrap.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/custom_track_repository.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/bootstrap/full_pull.dart';
import 'package:pantas/core/sync/bootstrap/full_push.dart';
import 'package:pantas/core/sync/eligibility/sync_claim_gateway.dart';
import 'package:pantas/core/sync/eligibility/sync_entitlement.dart';
import 'package:pantas/core/sync/engine/generation_repository.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/core/sync/firestore/firebase_firestore_gateway.dart';
import 'package:pantas/core/sync/firestore/firebase_sync_functions_gateway.dart';
import 'package:pantas/core/sync/firestore/firestore_gateway.dart';
import 'package:pantas/core/sync/firestore/functions_gateway.dart';
import 'package:pantas/core/sync/providers.dart';
import 'package:pantas/core/sync/runtime/production_sync_runtime_engine.dart';
import 'package:pantas/core/sync/runtime/sync_runtime_controller.dart';
import 'package:pantas/core/sync/sync_coordinator.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:uuid/uuid.dart';

typedef SyncRuntimeBuilder = Future<SyncRuntimeSurface> Function();
typedef ProjectionRecovery = Future<bool> Function();

class SyncRuntimeBinding {
  SyncRuntimeBinding({
    required ProviderContainer container,
    required SyncRuntimeSurface runtime,
  })  : _runtime = runtime,
        lifecycleObserver = SyncRuntimeLifecycleObserver(
          () => container.read(syncRuntimeProvider),
        ) {
    WidgetsFlutterBinding.ensureInitialized();
    _authSubscription = container.listen<AsyncValue<AuthState>>(
      authStateProvider,
      (_, next) {
        next.whenData((value) {
          _auth = value;
          _scheduleUpdate();
        });
      },
      fireImmediately: true,
    );
    _entitlementSubscription = container.listen<AsyncValue<Entitlement>>(
      entitlementProvider,
      (_, next) {
        next.whenData((value) {
          _entitlement = value;
          final syncEntitlement = _toSyncEntitlement(value);
          container.read(syncEntitlementProvider.notifier).state =
              syncEntitlement;
          _scheduleUpdate();
        });
      },
      fireImmediately: true,
    );
    WidgetsBinding.instance.addObserver(lifecycleObserver);
  }

  final SyncRuntimeSurface _runtime;
  late final ProviderSubscription<AsyncValue<AuthState>> _authSubscription;
  late final ProviderSubscription<AsyncValue<Entitlement>>
      _entitlementSubscription;
  final SyncRuntimeLifecycleObserver lifecycleObserver;

  AuthState? _auth;
  Entitlement? _entitlement;
  Future<void> _updateTail = Future<void>.value();
  bool _disposed = false;

  void _scheduleUpdate() {
    if (_disposed || _auth == null || _entitlement == null) return;
    final identity = _toSyncIdentity(_auth!);
    final entitlement = _toSyncEntitlement(_entitlement!);
    _updateTail = _updateTail.then(
      (_) => _runtime.update(identity: identity, entitlement: entitlement),
      onError: (Object _, StackTrace __) =>
          _runtime.update(identity: identity, entitlement: entitlement),
    );
  }

  Future<void> settle() => _updateTail;

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _authSubscription.close();
    _entitlementSubscription.close();
    WidgetsBinding.instance.removeObserver(lifecycleObserver);
    unawaited(_runtime.quiesce(flush: false));
  }
}

class SyncRuntimeLifecycleObserver extends WidgetsBindingObserver {
  SyncRuntimeLifecycleObserver(this._runtime);

  final SyncRuntimeSurface Function() _runtime;

  Future<void> flushForBackground() async {
    try {
      await _runtime().forceFlush();
    } on Object {
      // Background flush is best-effort; durable queue/journal state remains.
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        unawaited(flushForBackground());
      case AppLifecycleState.resumed:
        break;
    }
  }
}

Future<SyncRuntimeBinding> bootstrapSyncRuntime(
  ProviderContainer container,
  FirebaseBootstrapResult firebaseResult, {
  SyncRuntimeBuilder? runtimeBuilder,
  ProjectionRecovery? recoverProjection,
}) async {
  if (firebaseResult != FirebaseBootstrapResult.configured) {
    const disabled = DisabledSyncRuntimeSurface();
    container.read(syncRuntimeProvider.notifier).state = disabled;
    container.read(syncEntitlementProvider.notifier).state =
        SyncEntitlement.free;
    return SyncRuntimeBinding(container: container, runtime: disabled);
  }

  final recovery = recoverProjection ?? () => _recoverProjection(container);
  await recovery();
  final runtime =
      await (runtimeBuilder ?? () => buildConfiguredSyncRuntime(container))();
  container.read(syncRuntimeProvider.notifier).state = runtime;
  return SyncRuntimeBinding(container: container, runtime: runtime);
}

Future<SyncRuntimeSurface> buildConfiguredSyncRuntime(
  ProviderContainer container, {
  FirestoreGateway? firestoreGateway,
  SyncFunctionsGateway? functionsGateway,
  SyncClaimGateway? claimGateway,
  String? deviceId,
}) async {
  final db = container.read(appDatabaseProvider);
  final contentDb = container.read(contentDatabaseProvider);
  final gateway = firestoreGateway ?? FirebaseFirestoreGateway();
  final functions = functionsGateway ?? FirebaseSyncFunctionsGateway();
  final claims = claimGateway ?? FirebaseSyncClaimGateway();
  final stableDeviceId = deviceId ?? await ensureDatabaseSyncDeviceId(db);
  final activeContextStore = SyncActiveContextStore(db);
  final customTracks = CustomTrackRepository(db, contentDb);
  final engine = ProductionSyncRuntimeEngine(
    db: db,
    gateway: gateway,
    activeContextStore: activeContextStore,
    deviceId: stableDeviceId,
    recoverCustomTrackProjection: customTracks.retryPendingProjections,
  );
  final coordinator = SyncCoordinatorImpl(
    fullPush: ({
      required uid,
      required expectedActiveGenerationId,
      shouldContinue,
    }) {
      return FullPushBootstrap(
        db: db,
        gateway: gateway,
        functionsGateway: functions,
        uid: uid,
        deviceId: stableDeviceId,
      ).run(
        expectedActiveGenerationId: expectedActiveGenerationId,
        shouldContinue: shouldContinue,
      );
    },
    fullPull: ({required uid, required generationId, shouldContinue}) {
      return FullPullBootstrap(
        db: db,
        gateway: gateway,
        uid: uid,
        rebuildCustomTrackProjection: customTracks.retryProjection,
      ).run(
        generationId: generationId,
        shouldContinue: shouldContinue,
      );
    },
  );
  final controller = SyncRuntimeController(
    db: db,
    claimGateway: claims,
    activeContextStore: activeContextStore,
    generationRepositoryForUid: (uid) => GenerationRepository(
      gateway: gateway,
      functionsGateway: functions,
      uid: uid,
    ),
    coordinator: coordinator,
    engine: engine,
    runtimeEvents: engine.events,
  );
  return ConfiguredSyncRuntimeSurface(controller: controller, engine: engine);
}

Future<bool> _recoverProjection(ProviderContainer container) {
  return CustomTrackRepository(
    container.read(appDatabaseProvider),
    container.read(contentDatabaseProvider),
  ).retryPendingProjections();
}

Future<String> ensureDatabaseSyncDeviceId(AppDatabase db) {
  return ensureSyncDeviceId(
    read: () async {
      final row = await db
          .customSelect(
            "select value from sync_meta where key = 'deviceId'",
          )
          .getSingleOrNull();
      return row?.read<String>('value');
    },
    write: (value) => db.customStatement(
      'insert into sync_meta (key,value) values (?,?) '
      'on conflict(key) do update set value=excluded.value',
      <Object?>['deviceId', value],
    ),
    create: () => const Uuid().v4(),
  );
}

Future<String> ensureSyncDeviceId({
  required Future<String?> Function() read,
  required Future<void> Function(String value) write,
  required String Function() create,
}) async {
  final existing = await read();
  if (existing != null && existing.isNotEmpty) return existing;
  final value = create();
  if (value.isEmpty) {
    throw StateError('Sync device id factory returned an empty id');
  }
  await write(value);
  return value;
}

SyncEntitlement _toSyncEntitlement(Entitlement entitlement) {
  return entitlement.proIsActive ? SyncEntitlement.pro : SyncEntitlement.free;
}

SyncIdentity _toSyncIdentity(AuthState state) {
  return switch (state) {
    AnonymousAuthState(:final uid) => SyncIdentity(uid: uid, isAnonymous: true),
    SignedInAuthState(:final user) => SyncIdentity(uid: user.uid),
    SignedOutAuthState() ||
    UnknownAuthState() =>
      const SyncIdentity(uid: 'signed-out', isAnonymous: true),
  };
}
