import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pantas/core/content/remote/content_cache.dart';
import 'package:pantas/core/content/remote/content_item.dart';
import 'package:pantas/core/content/remote/content_remote.dart';

/// Stale-while-revalidate access to server content.
///
/// `read` returns the stored copy at once and asks the server for the latest
/// in the background; a changed copy is stored and announced on [changes].
/// With nothing stored it waits for the server. Pro-only fields exist in the
/// store only when the server sent them to a Pro account.
class ContentService {
  ContentService({required ContentRemote remote, required ContentCache cache})
      : _remote = remote,
        _cache = cache;

  final ContentRemote _remote;
  final ContentCache _cache;
  final _changes = StreamController<ContentItem>.broadcast();
  final _inFlight = <Future<void>>{};

  /// Emits each item whose stored copy changed.
  Stream<ContentItem> get changes => _changes.stream;

  /// Completes when no background request is running.
  Future<void> get idle async {
    while (_inFlight.isNotEmpty) {
      await Future.wait(_inFlight.toList());
    }
  }

  Future<ContentItem?> read(ContentKind kind, String id) async {
    final stored = await _cache.get(kind, id);
    if (stored != null) {
      _track(refresh(kind, [id]));
      return stored;
    }
    await refresh(kind, [id]);
    return _cache.get(kind, id);
  }

  /// Fetches the latest of [ids] in calls of at most 20. A failed call keeps
  /// the stored copies and does not throw.
  Future<void> refresh(ContentKind kind, List<String> ids) async {
    final unique = ids.toSet().toList();
    for (var start = 0; start < unique.length; start += maxContentIdsPerCall) {
      final end = (start + maxContentIdsPerCall).clamp(0, unique.length);
      await _refreshBatch(kind, unique.sublist(start, end));
    }
  }

  /// After [openedId] opens, fetches up to [count] of the next ids in [ordered]
  /// that are not stored yet.
  Future<void> preloadAfter(
    ContentKind kind,
    String openedId,
    List<String> ordered, {
    int count = 3,
  }) async {
    final index = ordered.indexOf(openedId);
    final next = ordered.skip(index + 1).take(count).toList();
    if (next.isEmpty) return;
    final stored = await _cache.versions(kind, next);
    final missing = [
      for (final id in next)
        if (!stored.containsKey(id)) id,
    ];
    if (missing.isEmpty) return;
    await refresh(kind, missing);
  }

  /// Removes Pro-only fields. Call when the account signs out.
  Future<void> onSignedOut() => _downgrade();

  Future<void> _refreshBatch(ContentKind kind, List<String> ids) async {
    try {
      final known = await _cache.versions(kind, ids);
      final fetched = await _remote.fetch(kind, ids, known);
      for (final id in ids) {
        final entry = fetched.entries[id];
        if (entry == null || entry.status != RemoteStatus.ok) continue;
        final item = ContentItem(
          kind: kind,
          id: id,
          version: entry.version!,
          tier: fetched.tier,
          data: entry.data!,
        );
        await _cache.put(item);
        _changes.add(item);
      }
      // A Free answer means any Pro copy in the store is out of date.
      if (fetched.tier == 'free') await _downgrade();
    } on Object catch (error) {
      debugPrint('Content refresh failed: $error');
    }
  }

  Future<void> _downgrade() async {
    for (final item in await _cache.downgradeToFree()) {
      _changes.add(item);
    }
  }

  void _track(Future<void> work) {
    _inFlight.add(work);
    unawaited(work.whenComplete(() => _inFlight.remove(work)));
  }

  Future<void> dispose() => _changes.close();
}
