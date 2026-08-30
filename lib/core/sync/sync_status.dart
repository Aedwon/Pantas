typedef SyncClock = DateTime Function();

sealed class SyncStatus {
  const SyncStatus();
}

class SyncOff extends SyncStatus {
  const SyncOff();
}

class SyncActivating extends SyncStatus {
  const SyncActivating();
}

class SyncReconciliationRequired extends SyncStatus {
  const SyncReconciliationRequired({
    required this.activeGenerationId,
  });

  final String activeGenerationId;
}

class Syncing extends SyncStatus {
  const Syncing({this.pendingCount = 0});

  final int pendingCount;
}

class SyncUpToDate extends SyncStatus {
  const SyncUpToDate({this.lastSyncedAt});

  final DateTime? lastSyncedAt;
}

class SyncOffline extends SyncStatus {
  const SyncOffline({this.pendingCount = 0});

  final int pendingCount;
}

class SyncError extends SyncStatus {
  const SyncError({this.message});

  final String? message;
}

// Temporary source-compatibility aliases for the pre-Wave-2E provider/UI
// surface. Production runtime code uses only the frozen statuses above; the
// Task 12 composition/UI wave removes these old escalation semantics.
@Deprecated('Use SyncOff.')
class SyncIdle extends SyncStatus {
  @Deprecated('Compatibility only until Task 12 UI migration.')
  const SyncIdle({this.lastSyncedAt});

  final DateTime? lastSyncedAt;
}

@Deprecated('Use SyncUpToDate.')
class SyncOk extends SyncStatus {
  @Deprecated('Compatibility only until Task 12 UI migration.')
  const SyncOk({
    required this.lastSyncedAt,
    required this.pendingCount,
  });

  final DateTime lastSyncedAt;
  final int pendingCount;
}

@Deprecated('Use SyncError.')
class SyncPartialFailure extends SyncStatus {
  @Deprecated('Compatibility only until Task 12 UI migration.')
  const SyncPartialFailure({required this.failedCollections});

  final List<String> failedCollections;
}

@Deprecated('Use SyncError.')
class SyncFailedSince extends SyncStatus {
  @Deprecated('Compatibility only until Task 12 UI migration.')
  const SyncFailedSince({required this.since});

  final DateTime since;
}

@Deprecated('Wave 2E no longer uses threshold-based escalation.')
class SyncFailureTracker {
  @Deprecated('Compatibility only until Task 12 UI migration.')
  SyncFailureTracker({required SyncClock now}) : _now = now;

  final SyncClock _now;
  final _failedCollections = <String>{};
  int _consecutiveFailures = 0;
  DateTime? _failedSince;

  SyncStatus recordFailure({required String collection}) {
    _consecutiveFailures += 1;
    _failedCollections.add(collection);
    _failedSince ??= _now();
    final failedSince = _failedSince!;
    if (_now().difference(failedSince) >= const Duration(hours: 24)) {
      return SyncFailedSince(since: failedSince);
    }
    if (_consecutiveFailures >= 3) {
      return SyncPartialFailure(
        failedCollections: _failedCollections.toList(growable: false),
      );
    }
    return const SyncIdle();
  }

  SyncStatus recordSuccess({required int pendingCount}) {
    _consecutiveFailures = 0;
    _failedSince = null;
    _failedCollections.clear();
    return SyncOk(lastSyncedAt: _now(), pendingCount: pendingCount);
  }
}
