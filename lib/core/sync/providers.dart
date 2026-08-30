import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/sync/eligibility/sync_entitlement.dart';
import 'package:pantas/core/sync/runtime/sync_runtime_controller.dart';
import 'package:pantas/core/sync/sync_status.dart';

enum SyncRuntimeKind { disabled, configured }

abstract interface class SyncRuntimeSurface {
  SyncRuntimeKind get runtimeKind;

  SyncStatus get currentStatus;

  Stream<SyncStatus> get statuses;

  Future<void> update({
    required SyncIdentity identity,
    required SyncEntitlement entitlement,
  });

  Future<void> chooseReconciliation(SyncReconciliationChoice choice);

  Future<void> forceFlush();

  Future<void> quiesce({required bool flush});
}

class DisabledSyncRuntimeSurface implements SyncRuntimeSurface {
  const DisabledSyncRuntimeSurface();

  @override
  SyncRuntimeKind get runtimeKind => SyncRuntimeKind.disabled;

  @override
  SyncStatus get currentStatus => const SyncOff();

  @override
  Stream<SyncStatus> get statuses => Stream.value(currentStatus);

  @override
  Future<void> update({
    required SyncIdentity identity,
    required SyncEntitlement entitlement,
  }) async {}

  @override
  Future<void> chooseReconciliation(SyncReconciliationChoice choice) async {}

  @override
  Future<void> forceFlush() async {}

  @override
  Future<void> quiesce({required bool flush}) async {}
}

class ConfiguredSyncRuntimeSurface implements SyncRuntimeSurface {
  ConfiguredSyncRuntimeSurface({
    required SyncRuntimeController controller,
    required SyncRuntimeEngine engine,
  })  : _controller = controller,
        _engine = engine;

  final SyncRuntimeController _controller;
  final SyncRuntimeEngine _engine;

  @override
  SyncRuntimeKind get runtimeKind => SyncRuntimeKind.configured;

  @override
  SyncStatus get currentStatus => _controller.status;

  @override
  Stream<SyncStatus> get statuses => _controller.statuses;

  @override
  Future<void> update({
    required SyncIdentity identity,
    required SyncEntitlement entitlement,
  }) {
    return _controller.update(identity: identity, entitlement: entitlement);
  }

  @override
  Future<void> chooseReconciliation(SyncReconciliationChoice choice) {
    return _controller.chooseReconciliation(choice);
  }

  @override
  Future<void> forceFlush() => _engine.forceFlush();

  @override
  Future<void> quiesce({required bool flush}) {
    return _controller.quiesce(flush: flush);
  }
}

/// Test helper retained for older focused tests. Production never installs it
/// by default.
class FakeSyncEngine implements SyncRuntimeSurface {
  int forceFlushCalls = 0;

  @override
  SyncRuntimeKind get runtimeKind => SyncRuntimeKind.configured;

  @override
  SyncStatus get currentStatus => const SyncIdle();

  @override
  Stream<SyncStatus> get statuses => Stream.value(currentStatus);

  @override
  Future<void> update({
    required SyncIdentity identity,
    required SyncEntitlement entitlement,
  }) async {}

  @override
  Future<void> chooseReconciliation(SyncReconciliationChoice choice) async {}

  @override
  Future<void> forceFlush() async {
    forceFlushCalls += 1;
  }

  @override
  Future<void> quiesce({required bool flush}) async {}
}

final syncRuntimeProvider = StateProvider<SyncRuntimeSurface>(
  (ref) => const DisabledSyncRuntimeSurface(),
);

final syncEntitlementProvider = StateProvider<SyncEntitlement>(
  (ref) => SyncEntitlement.free,
);

final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  return ref.watch(syncRuntimeProvider).statuses;
});

final manualSyncRetryProvider = FutureProvider<void>((ref) {
  return ref.watch(syncRuntimeProvider).forceFlush();
});
