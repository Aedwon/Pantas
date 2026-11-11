import 'package:drift/drift.dart' show Variable;
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';

/// Which cloud generation this device's local data is a copy of, for which
/// account, and how much of it this device has seen.
///
/// A finished full push or pull stores the hold. It outlives a page reload and
/// time spent offline, so a start needs no new choice and a change made while
/// Sync is stopped can still be tied to the copy it was made against.
class SyncHeldGeneration {
  const SyncHeldGeneration(this._db);

  static const generationKey = 'currentLocalGenerationId';
  static const uidKey = 'currentLocalGenerationUid';
  static const _snapshotPrefix = 'syncSnapshotComplete:';

  final AppDatabase _db;

  /// The hold, or null when there is none or a full push or pull is unfinished,
  /// since local data may not be that copy yet.
  Future<SyncActiveContext?> read() async {
    final rows = await _db.customSelect(
      'select key, value from sync_meta where key in '
      '(?,?,?,?)',
      variables: [
        const Variable<String>(generationKey),
        const Variable<String>(uidKey),
        const Variable<String>('pending_full_push'),
        const Variable<String>('pending_full_pull'),
      ],
    ).get();
    final meta = {
      for (final row in rows)
        row.read<String>('key'): row.read<String>('value'),
    };
    final generationId = meta[generationKey];
    final uid = meta[uidKey];
    if (generationId == null ||
        uid == null ||
        meta.containsKey('pending_full_push') ||
        meta.containsKey('pending_full_pull')) {
      return null;
    }
    return SyncActiveContext(uid: uid, generationId: generationId);
  }

  /// Ends a hold another account owns. An account switch keeps local data, so
  /// from here on it may no longer be that account's copy.
  Future<void> forgetUnlessOwnedBy(String uid) => _db.customStatement(
        'delete from sync_meta where key in (?,?) and exists '
        '(select 1 from sync_meta where key = ? and value <> ?)',
        <Object?>[generationKey, uidKey, uidKey, uid],
      );

  /// Whether this device has applied a complete server copy of [collection]
  /// from [generationId], so a row with no accepted state is one the cloud
  /// did not have.
  Future<bool> isSnapshotComplete({
    required String generationId,
    required String collection,
  }) async {
    final row = await _db.customSelect(
      'select 1 as complete from sync_meta where key = ?',
      variables: [Variable<String>(_key(generationId, collection))],
    ).getSingleOrNull();
    return row != null;
  }

  Future<void> markSnapshotComplete({
    required String generationId,
    required String collection,
  }) =>
      _db.customStatement(
        'insert or ignore into sync_meta (key,value) values (?,?)',
        <Object?>[_key(generationId, collection), '1'],
      );

  /// A new generation starts with nothing seen.
  Future<void> clearSnapshotMarks() => _db.customStatement(
        'delete from sync_meta where key like ?',
        <Object?>['$_snapshotPrefix%'],
      );

  static String _key(String generationId, String collection) =>
      '$_snapshotPrefix$generationId:$collection';
}
