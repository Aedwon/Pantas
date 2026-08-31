import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/firebase_bootstrap.dart';
import 'package:pantas/app/sync_runtime_bootstrap.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/sync/eligibility/sync_entitlement.dart';
import 'package:pantas/core/sync/providers.dart';
import 'package:pantas/core/sync/runtime/sync_runtime_controller.dart';
import 'package:pantas/core/sync/sync_status.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';

void main() {
  test(
      'unavailable Firebase remains disabled and never constructs '
      'cloud runtime', () async {
    var builds = 0;
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final binding = await bootstrapSyncRuntime(
      container,
      FirebaseBootstrapResult.unavailable,
      runtimeBuilder: () async {
        builds += 1;
        return RecordingSurface();
      },
    );
    addTearDown(binding.dispose);

    expect(builds, 0);
    expect(
      container.read(syncRuntimeProvider).runtimeKind,
      SyncRuntimeKind.disabled,
    );
  });

  test('configured bootstrap repairs projection before publishing real runtime',
      () async {
    final operations = <String>[];
    final runtime = RecordingSurface(operations: operations);
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final binding = await bootstrapSyncRuntime(
      container,
      FirebaseBootstrapResult.configured,
      recoverProjection: () async {
        operations.add('recover');
        return true;
      },
      runtimeBuilder: () async {
        operations.add('build');
        return runtime;
      },
    );
    addTearDown(binding.dispose);

    expect(operations.take(2), ['recover', 'build']);
    expect(container.read(syncRuntimeProvider), same(runtime));
  });

  test(
      'Auth and RevenueCat changes bridge into feature-neutral runtime updates',
      () async {
    final auth = StreamController<AuthState>();
    final entitlement = StreamController<Entitlement>();
    final runtime = RecordingSurface();
    final container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWith((ref) => auth.stream),
        entitlementProvider.overrideWith((ref) => entitlement.stream),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(auth.close);
    addTearDown(entitlement.close);

    final binding = await bootstrapSyncRuntime(
      container,
      FirebaseBootstrapResult.configured,
      recoverProjection: () async => true,
      runtimeBuilder: () async => runtime,
    );
    addTearDown(binding.dispose);

    auth.add(const AuthState.anonymous(uid: 'anon-1'));
    entitlement.add(const Entitlement(plan: EntitlementPlan.monthly));
    await pumpEventQueue();
    expect(runtime.updates.last.identity.isAnonymous, isTrue);
    expect(runtime.updates.last.entitlement, SyncEntitlement.pro);

    auth.add(
      const AuthState.signedIn(
        user: AuthUser(
          uid: 'user-1',
          email: 'u@example.test',
          displayName: 'User',
        ),
      ),
    );
    await pumpEventQueue();
    expect(runtime.updates.last.identity.uid, 'user-1');
    expect(runtime.updates.last.identity.isAnonymous, isFalse);
    expect(container.read(syncEntitlementProvider), SyncEntitlement.pro);
  });

  test('background lifecycle requests immediate best-effort flush', () async {
    final runtime = RecordingSurface(failFlush: true);
    final observer = SyncRuntimeLifecycleObserver(() => runtime);

    await observer.flushForBackground();

    expect(runtime.forceFlushCalls, 1);
    // Best-effort means the simulated network failure is swallowed.
  });

  test('device id initializer persists and reuses one stable id', () async {
    final store = MemoryDeviceIdStore();
    final first = await ensureSyncDeviceId(
      read: store.read,
      write: store.write,
      create: () => 'device-fixed',
    );
    final second = await ensureSyncDeviceId(
      read: store.read,
      write: store.write,
      create: () => 'device-other',
    );

    expect(first, 'device-fixed');
    expect(second, 'device-fixed');
    expect(store.writes, 1);
  });
}

class RuntimeUpdate {
  const RuntimeUpdate(this.identity, this.entitlement);
  final SyncIdentity identity;
  final SyncEntitlement entitlement;
}

class RecordingSurface implements SyncRuntimeSurface {
  RecordingSurface({this.operations, this.failFlush = false});

  final List<String>? operations;
  final bool failFlush;
  final updates = <RuntimeUpdate>[];
  int forceFlushCalls = 0;

  @override
  SyncRuntimeKind get runtimeKind => SyncRuntimeKind.configured;

  @override
  SyncStatus get currentStatus => const SyncOff();

  @override
  Stream<SyncStatus> get statuses => Stream.value(currentStatus);

  @override
  Future<void> update({
    required SyncIdentity identity,
    required SyncEntitlement entitlement,
  }) async {
    updates.add(RuntimeUpdate(identity, entitlement));
    operations?.add('update:${identity.uid}:${entitlement.name}');
  }

  @override
  Future<void> forceFlush() async {
    forceFlushCalls += 1;
    if (failFlush) throw StateError('offline');
  }

  @override
  Future<void> chooseReconciliation(SyncReconciliationChoice choice) async {}

  @override
  Future<void> quiesce({required bool flush}) async {}
}

class MemoryDeviceIdStore {
  String? value;
  int writes = 0;

  Future<String?> read() async => value;
  Future<void> write(String next) async {
    writes += 1;
    value = next;
  }
}
