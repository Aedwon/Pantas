import 'package:pantas/core/content/remote/content_checks.dart';
import 'package:pantas/core/storage/data/app_database.dart';

/// Keeps the record in the device preferences table, so it needs no schema
/// change and is never synced.
class AppDatabaseCheckStore implements ContentCheckStore {
  AppDatabaseCheckStore(this._db);

  static const key = 'content.checks.v1';
  final AppDatabase _db;

  @override
  Future<String?> read() async {
    final row = await (_db.select(_db.devicePrefs)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  @override
  Future<void> write(String value) {
    return _db.into(_db.devicePrefs).insertOnConflictUpdate(
          DevicePrefsCompanion.insert(key: key, value: value),
        );
  }
}
