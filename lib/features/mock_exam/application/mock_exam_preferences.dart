import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';

class MockExamPreferences {
  MockExamPreferences(this._db);

  static const strictMockModeKey = 'strict_mock_mode';

  final AppDatabase _db;

  Future<bool> strictMockMode() async {
    final row = await (_db.select(_db.accountPrefs)
          ..where((pref) => pref.key.equals(strictMockModeKey)))
        .getSingleOrNull();
    return row?.value == 'true';
  }

  Future<void> setStrictMockMode({required bool value}) async {
    await _db.into(_db.accountPrefs).insertOnConflictUpdate(
          AccountPrefsCompanion.insert(
            key: strictMockModeKey,
            value: value ? 'true' : 'false',
          ),
        );
  }
}
