typedef SyncClock = DateTime Function();

sealed class SyncStatus {
  const SyncStatus();
}

class SyncIdle extends SyncStatus {
  const SyncIdle({this.lastSyncedAt});

  final DateTime? lastSyncedAt;
}

class Syncing extends SyncStatus {
  const Syncing({required this.pendingCount});

  final int pendingCount;
}

class SyncOk extends SyncStatus {
  const SyncOk({
    required this.lastSyncedAt,
    required this.pendingCount,
  });

  final DateTime lastSyncedAt;
  final int pendingCount;
}

class SyncPartialFailure extends SyncStatus {
  const SyncPartialFailure({required this.failedCollections});

  final List<String> failedCollections;
}

class SyncFailedSince extends SyncStatus {
  const SyncFailedSince({required this.since});

  final DateTime since;
}

class SyncFailureTracker {
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
