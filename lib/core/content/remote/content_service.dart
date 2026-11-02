import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pantas/core/content/remote/content_cache.dart';
import 'package:pantas/core/content/remote/content_checks.dart';
import 'package:pantas/core/content/remote/content_item.dart';
import 'package:pantas/core/content/remote/content_remote.dart';

/// Stale-while-revalidate access to server content.
///
/// `read` returns the stored copy at once and asks the server for the latest
/// in the background; a changed copy is stored and announced on [changes].
/// With nothing stored it waits for the server. Pro-only fields exist in the
/// store only when the server sent them to a Pro account.
class ContentService {
  /// With [checks], an item the server was asked about today is not asked
  /// about again the same local day. [onLimitReached] hears whether the last
  /// request was refused for the daily limit.
  ContentService({
    required ContentRemote remote,
    required ContentCache cache,
    ContentChecks? checks,
    ValueSetter<bool>? onLimitReached,
  })  : _remote = remote,
        _cache = cache,
        _checks = checks,
        _onLimitReached = onLimitReached;

  final ContentRemote _remote;
  final ContentCache _cache;
  final ContentChecks? _checks;
  final ValueSetter<bool>? _onLimitReached;
  final _changes = StreamController<ContentItem>.broadcast();
  final _inFlight = <Future<void>>{};

  /// Emits each item whose stored copy changed.
  Stream<ContentItem> get changes => _changes.stream;

  /// True when no background request is running.
  bool get isIdle => _inFlight.isEmpty;

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

  /// The stored copy only; never asks the server.
  Future<ContentItem?> stored(ContentKind kind, String id) =>
      _cache.get(kind, id);

  /// Every stored item.
  Future<List<ContentItem>> storedItems() => _cache.all();

  /// Fetches the latest of [ids] in calls of at most 20. A failed call keeps
  /// the stored copies and does not throw.
  ///
  /// An id with a stored copy that was checked today is skipped, unless
  /// [force] is set (a manual retry). An id with no stored copy is always
  /// fetched.
  Future<void> refresh(
    ContentKind kind,
    List<String> ids, {
    bool force = false,
  }) async {
    final unique = ids.toSet().toList();
    final due = force ? unique : await _due(kind, unique);
    for (var start = 0; start < due.length; start += maxContentIdsPerCall) {
      final end = (start + maxContentIdsPerCall).clamp(0, due.length);
      await _refreshBatch(kind, due.sublist(start, end));
    }
  }

  Future<List<String>> _due(ContentKind kind, List<String> ids) async {
    final checks = _checks;
    if (checks == null) return ids;
    final stored = await _cache.versions(kind, ids);
    return [
      for (final id in ids)
        if (!stored.containsKey(id) || !await checks.isFresh(kind, id)) id,
    ];
  }

  /// Makes the next [refresh] of this item ask the server. Call when the
  /// stored copy could not be used.
  Future<void> forgetCheck(ContentKind kind, String id) async =>
      _checks?.forget(kind, id);

  /// Tells the service which account is signed in. True when a different
  /// account dropped the day's checks.
  Future<bool> useAccount(String? uid) async =>
      await _checks?.useAccount(uid) ?? false;

  /// Tells the service what the account has paid for. True when that changed
  /// and the day's checks were dropped, so the caller should fetch again.
  Future<bool> useAccess(String access) async =>
      await _checks?.useAccess(access) ?? false;

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
      var limited = false;
      final checked = <String>[];
      for (final id in ids) {
        final entry = fetched.entries[id];
        if (entry == null) continue;
        if (entry.status == RemoteStatus.limited) {
          limited = true;
          continue;
        }
        checked.add(id);
        if (entry.status != RemoteStatus.ok) continue;
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
      await _checks?.markChecked(kind, checked);
      _onLimitReached?.call(limited);
      // A Free answer means any Pro copy in the store is out of date.
      if (fetched.tier == 'free') await _downgrade();
    } on ContentLimitReached {
      _onLimitReached?.call(true);
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
