import 'dart:async';

import 'package:pantas/core/sync/sync_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class SyncEngineSurface {
  Stream<SyncStatus> get statuses;

  Future<void> forceFlush();
}

class FakeSyncEngine implements SyncEngineSurface {
  int forceFlushCalls = 0;

  @override
  Stream<SyncStatus> get statuses => Stream.value(const SyncIdle());

  @override
  Future<void> forceFlush() async {
    forceFlushCalls += 1;
  }
}

final syncEngineProvider = Provider<SyncEngineSurface>(
  (ref) => FakeSyncEngine(),
);

final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  return ref.watch(syncEngineProvider).statuses;
});

final manualSyncRetryProvider = FutureProvider<void>((ref) {
  return ref.watch(syncEngineProvider).forceFlush();
});
