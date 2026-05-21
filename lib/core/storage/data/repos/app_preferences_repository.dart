import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';

class AppPreferencesRepository {
  AppPreferencesRepository(this._db);

  static const _selectedExamIdKey = 'selected_exam_id';
  static const _passedAgeGateKey = 'passed_age_gate';

  final AppDatabase _db;

  Future<String?> selectedExamId() async {
    final row = await (_db.select(_db.devicePrefs)
          ..where((p) => p.key.equals(_selectedExamIdKey)))
        .getSingleOrNull();
    if (row != null) return row.value;

    final legacyRow = await (_db.select(_db.appPreferencesLocal)
          ..where((p) => p.key.equals(_selectedExamIdKey)))
        .getSingleOrNull();
    return legacyRow?.value;
  }

  Future<void> setSelectedExamId(String examId) async {
    await _db.into(_db.devicePrefs).insertOnConflictUpdate(
          DevicePrefsCompanion.insert(
            key: _selectedExamIdKey,
            value: examId,
          ),
        );
  }

  Future<bool> hasPassedAgeGate() async {
    final row = await (_db.select(_db.devicePrefs)
          ..where((p) => p.key.equals(_passedAgeGateKey)))
        .getSingleOrNull();
    if (row != null) return row.value == 'true';

    final legacyRow = await (_db.select(_db.appPreferencesLocal)
          ..where((p) => p.key.equals(_passedAgeGateKey)))
        .getSingleOrNull();
    return legacyRow?.value == 'true';
  }

  Future<void> setPassedAgeGate({required bool value}) async {
    await _db.into(_db.devicePrefs).insertOnConflictUpdate(
          DevicePrefsCompanion.insert(
            key: _passedAgeGateKey,
            value: value ? 'true' : 'false',
          ),
        );
  }
}
