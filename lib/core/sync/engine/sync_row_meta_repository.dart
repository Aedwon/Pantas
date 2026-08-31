import 'package:drift/drift.dart' show Variable;
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/model/sync_causal_base.dart';

class SyncRowMetaRepository {
  SyncRowMetaRepository(this._db);

  final AppDatabase _db;

  Future<SyncCausalBase?> readAcceptedBase({
    required String collection,
    required String rowId,
  }) async {
    final rows = await _db.customSelect(
      'select state, updated_at from sync_row_meta '
      'where collection = ? and row_id = ?',
      variables: [
        Variable<String>(collection),
        Variable<String>(rowId),
      ],
    ).get();
    if (rows.isEmpty) return null;

    final row = rows.single;
    final state = row.read<String>('state');
    if (state == SyncCausalBaseState.knownAbsent.storageValue) {
      return const SyncCausalBase.knownAbsent();
    }
    if (state == SyncCausalBaseState.knownVersion.storageValue) {
      final stored = row.readNullable<int>('updated_at');
      if (stored == null) return null;
      return SyncCausalBase.knownVersion(
        DateTime.fromMillisecondsSinceEpoch(stored, isUtc: true),
      );
    }
    return null;
  }

  Future<void> acceptKnownAbsent({
    required String collection,
    required String rowId,
    String? originDeviceId,
  }) =>
      _db.customStatement(
        'insert into sync_row_meta '
        '(collection,row_id,state,updated_at,origin_device_id) '
        'values (?,?,?,?,?) '
        'on conflict(collection,row_id) do update set '
        'state=excluded.state, updated_at=excluded.updated_at, '
        'origin_device_id=excluded.origin_device_id',
        <Object?>[
          collection,
          rowId,
          SyncCausalBaseState.knownAbsent.storageValue,
          null,
          originDeviceId,
        ],
      );

  Future<void> acceptKnownVersion({
    required String collection,
    required String rowId,
    required DateTime updatedAt,
    String? originDeviceId,
  }) =>
      _db.customStatement(
        'insert into sync_row_meta '
        '(collection,row_id,state,updated_at,origin_device_id) '
        'values (?,?,?,?,?) '
        'on conflict(collection,row_id) do update set '
        'state=excluded.state, updated_at=excluded.updated_at, '
        'origin_device_id=excluded.origin_device_id',
        <Object?>[
          collection,
          rowId,
          SyncCausalBaseState.knownVersion.storageValue,
          updatedAt.toUtc().millisecondsSinceEpoch,
          originDeviceId,
        ],
      );
}
