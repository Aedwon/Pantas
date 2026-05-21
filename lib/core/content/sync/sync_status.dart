sealed class SyncStatus {
  const SyncStatus();

  const factory SyncStatus.idle({DateTime? lastSyncedAt}) = SyncIdle;

  const factory SyncStatus.syncing() = Syncing;

  const factory SyncStatus.ok({
    required DateTime at,
    required int updatedCount,
  }) = SyncOk;

  const factory SyncStatus.partialFailure({
    required List<String> failedDoctypes,
  }) = SyncPartialFailure;

  const factory SyncStatus.failure({required String reason}) = SyncFailure;
}

class SyncIdle extends SyncStatus {
  const SyncIdle({this.lastSyncedAt});

  final DateTime? lastSyncedAt;
}

class Syncing extends SyncStatus {
  const Syncing();
}

class SyncOk extends SyncStatus {
  const SyncOk({required this.at, required this.updatedCount});

  final DateTime at;
  final int updatedCount;
}

class SyncPartialFailure extends SyncStatus {
  const SyncPartialFailure({required this.failedDoctypes});

  final List<String> failedDoctypes;
}

class SyncFailure extends SyncStatus {
  const SyncFailure({required this.reason});

  final String reason;
}
