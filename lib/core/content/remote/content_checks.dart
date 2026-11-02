import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:pantas/core/content/remote/content_item.dart';

/// Where the record of today's checks is kept between runs.
abstract interface class ContentCheckStore {
  Future<String?> read();
  Future<void> write(String value);
}

/// Which items the server was asked about today, on this device.
///
/// An item checked today is not asked about again the same local day, which
/// keeps the daily content limit for students who open the app often. The
/// record belongs to one account and one access level (what that account has
/// paid for). When either changes the record is dropped, because the server
/// sends a different copy: versions end in `.p` or `.f`.
class ContentChecks {
  ContentChecks({required ContentCheckStore store, DateTime Function()? now})
      : _store = store,
        _now = now ?? DateTime.now;

  final ContentCheckStore _store;
  final DateTime Function() _now;
  Future<void>? _loading;
  Future<void> _writing = Future.value();
  String _day = '';
  String? _uid;
  String? _access;
  final _ids = <String>{};

  String get _today {
    final n = _now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-'
        '${n.day.toString().padLeft(2, '0')}';
  }

  String _key(ContentKind kind, String id) => '${kind.wire}/$id';

  Future<void> _ready() {
    return _loading ??= () async {
      try {
        final raw = await _store.read();
        if (raw == null) return;
        final json = jsonDecode(raw) as Map<String, Object?>;
        _day = json['day'] as String? ?? '';
        _uid = json['uid'] as String?;
        _access = json['access'] as String?;
        _ids.addAll((json['ids'] as List? ?? const []).cast<String>());
      } on Object catch (error) {
        // An unreadable record only means more checks, never a wrong skip.
        debugPrint('Content checks unreadable: $error');
        _ids.clear();
      }
    }();
  }

  void _rollover() {
    final today = _today;
    if (_day != today) {
      _day = today;
      _ids.clear();
    }
  }

  Future<void> _save() {
    final json = jsonEncode({
      'day': _day,
      'uid': _uid,
      'access': _access,
      'ids': _ids.toList(),
    });
    return _writing = _writing.then((_) async {
      try {
        await _store.write(json);
      } on Object catch (error) {
        debugPrint('Content checks not saved: $error');
      }
    });
  }

  Future<bool> isFresh(ContentKind kind, String id) async {
    await _ready();
    _rollover();
    return _ids.contains(_key(kind, id));
  }

  Future<void> markChecked(ContentKind kind, Iterable<String> ids) async {
    await _ready();
    _rollover();
    _ids.addAll(ids.map((id) => _key(kind, id)));
    await _save();
  }

  Future<void> forget(ContentKind kind, String id) async {
    await _ready();
    if (_ids.remove(_key(kind, id))) await _save();
  }

  /// Switches the record to [uid]. A different account (or sign-out, with
  /// null) drops it. True when the record was dropped.
  Future<bool> useAccount(String? uid) async {
    await _ready();
    _rollover();
    if (uid == _uid) return false;
    final changed = _uid != null || uid == null;
    _uid = uid;
    if (changed) _ids.clear();
    await _save();
    return changed;
  }

  /// Switches the record to the access level [access]. A change drops the
  /// record. True when it did.
  Future<bool> useAccess(String access) async {
    await _ready();
    _rollover();
    if (access == _access) return false;
    final changed = _access != null;
    _access = access;
    if (changed) _ids.clear();
    await _save();
    return changed;
  }
}
