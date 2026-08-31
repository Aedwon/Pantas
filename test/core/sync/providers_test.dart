import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/sync/eligibility/sync_entitlement.dart';
import 'package:pantas/core/sync/providers.dart';
import 'package:pantas/core/sync/runtime/sync_runtime_controller.dart';
import 'package:pantas/core/sync/sync_status.dart';

void main() {
  test('production default is disabled local-only, never FakeSyncEngine',
      () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final runtime = container.read(syncRuntimeProvider);
    final status = await container.read(syncStatusProvider.future);

    expect(runtime, isA<DisabledSyncRuntimeSurface>());
    expect(runtime.runtimeKind, SyncRuntimeKind.disabled);
    expect(status, isA<SyncOff>());
  });

  test('app bridge can publish feature-neutral entitlement state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(syncEntitlementProvider), SyncEntitlement.free);
    container.read(syncEntitlementProvider.notifier).state =
        SyncEntitlement.pro;
    expect(container.read(syncEntitlementProvider), SyncEntitlement.pro);
  });

  test('manual retry delegates to installed runtime surface', () async {
    final runtime = RecordingRuntimeSurface();
    final container = ProviderContainer(
      overrides: [syncRuntimeProvider.overrideWith((ref) => runtime)],
    );
    addTearDown(container.dispose);

    await container.read(manualSyncRetryProvider.future);

    expect(runtime.forceFlushCalls, 1);
  });
}

class RecordingRuntimeSurface implements SyncRuntimeSurface {
  int forceFlushCalls = 0;

  @override
  SyncRuntimeKind get runtimeKind => SyncRuntimeKind.configured;

  @override
  SyncStatus get currentStatus => const SyncUpToDate();

  @override
  Stream<SyncStatus> get statuses => Stream.value(currentStatus);

  @override
  Future<void> forceFlush() async {
    forceFlushCalls += 1;
  }

  @override
  Future<void> update({
    required SyncIdentity identity,
    required SyncEntitlement entitlement,
  }) async {}

  @override
  Future<void> chooseReconciliation(SyncReconciliationChoice choice) async {}

  @override
  Future<void> quiesce({required bool flush}) async {}
}
