import 'package:pantas/core/storage/data/app_database.dart';

/// True while this device holds study changes the server has not accepted: a
/// queued change, a recorded local change not yet promoted, or a first full
/// upload that has not run. A pull in waiting is not unsent data. Sign-out
/// wipes the device, so it must not run while this is true.
Future<bool> hasUnsentSyncData(AppDatabase db) async {
  final queued = await (db.select(db.pendingSync)..limit(1)).get();
  if (queued.isNotEmpty) return true;
  final rows = await db
      .customSelect(
        'select 1 as unsent from sync_local_mutations limit 1',
      )
      .get();
  if (rows.isNotEmpty) return true;
  final markers = await db
      .customSelect(
        "select 1 as unsent from sync_meta where key = 'pending_full_push' "
        "and value = '1' limit 1",
      )
      .get();
  return markers.isNotEmpty;
}
