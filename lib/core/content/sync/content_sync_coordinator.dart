import 'dart:async';

import 'package:cse_cet_reviewer/core/content/content_database.dart';
import 'package:cse_cet_reviewer/core/content/sync/sync_status.dart';
import 'package:cse_cet_reviewer/core/content/sync/sync_throttle.dart';

enum ContentFetchResult { success, failure }

abstract interface class ContentDoctypeFetcher {
  String get doctype;
  Future<ContentFetchResult> fetchFull();
  Future<ContentFetchResult> fetchDelta(DateTime since);
}

class ContentSyncCoordinator {
  ContentSyncCoordinator({
    required ContentDatabase db,
    required List<ContentDoctypeFetcher> fetchers,
    required DateTime Function() now,
    ContentSyncThrottle? throttle,
  })  : _db = db,
        _fetchers = fetchers,
        _now = now,
        _throttle = throttle ?? ContentSyncThrottle(now: now);

  static const lastSyncedAtKey = 'lastSyncedAt';

  final ContentDatabase _db;
  final List<ContentDoctypeFetcher> _fetchers;
  final DateTime Function() _now;
  final ContentSyncThrottle _throttle;
  final _controller = StreamController<SyncStatus>.broadcast();
  Future<SyncStatus>? _inFlight;

  Stream<SyncStatus> get statuses => _controller.stream;

  Future<SyncStatus> syncIfStale() async {
    final lastSyncedAt = await _lastSyncedAt();
    if (!_throttle.isStale(lastSyncedAt)) {
      final status = SyncStatus.idle(lastSyncedAt: lastSyncedAt);
      _controller.add(status);
      return status;
    }
    return _runSync();
  }

  Future<SyncStatus> refreshNow() => _runSync();

  Future<SyncStatus> _runSync() {
    final existing = _inFlight;
    if (existing != null) return existing;
    final future = _runSyncInternal();
    _inFlight = future;
    future.whenComplete(() => _inFlight = null);
    return future;
  }

  Future<SyncStatus> _runSyncInternal() async {
    _controller.add(const SyncStatus.syncing());
    final since = await _lastSyncedAt();
    var successCount = 0;
    final failed = <String>[];
    for (final fetcher in _fetchers) {
      final result = since == null
          ? await fetcher.fetchFull()
          : await fetcher.fetchDelta(since);
      if (result == ContentFetchResult.success) {
        successCount++;
      } else {
        failed.add(fetcher.doctype);
      }
    }
    if (successCount > 0) {
      await _setLastSyncedAt(_now());
    }
    final status = switch ((successCount, failed.isEmpty)) {
      (0, _) => const SyncStatus.failure(reason: 'all doctypes failed'),
      (_, true) => SyncStatus.ok(at: _now(), updatedCount: successCount),
      _ => SyncStatus.partialFailure(failedDoctypes: failed),
    };
    _controller.add(status);
    return status;
  }

  Future<DateTime?> _lastSyncedAt() async {
    final row = await (_db.select(_db.contentMeta)
          ..where((meta) => meta.key.equals(lastSyncedAtKey)))
        .getSingleOrNull();
    if (row == null) return null;
    return DateTime.parse(row.value).toUtc();
  }

  Future<void> _setLastSyncedAt(DateTime value) {
    return _db.into(_db.contentMeta).insertOnConflictUpdate(
          ContentMetaCompanion.insert(
            key: lastSyncedAtKey,
            value: value.toUtc().toIso8601String(),
          ),
        );
  }

  Future<void> close() => _controller.close();
}
