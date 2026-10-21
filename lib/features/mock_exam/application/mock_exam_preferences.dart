import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/app_preferences_repository.dart';

class MockExamPreferences {
  MockExamPreferences(this._db);

  static const strictMockModeKey = 'strict_mock_mode';
  static const pauseWarningSeenKey = 'mock_pause_warning_seen';

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

  /// "Don't show this again" on the pause warning. It belongs to the phone,
  /// not the account, because the student learns it once per device.
  Future<bool> pauseWarningSeen() async =>
      await AppPreferencesRepository(_db).deviceValue(pauseWarningSeenKey) ==
      'true';

  Future<void> setPauseWarningSeen({required bool value}) =>
      AppPreferencesRepository(_db).setDeviceValue(
        pauseWarningSeenKey,
        value ? 'true' : 'false',
      );
}
