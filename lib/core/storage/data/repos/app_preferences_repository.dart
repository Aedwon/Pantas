import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';

class AppPreferencesRepository {
  AppPreferencesRepository(this._db);

  static const _selectedExamIdKey = 'selected_exam_id';

  final AppDatabase _db;

  Future<String?> selectedExamId() async {
    final row = await (_db.select(_db.appPreferencesLocal)
          ..where((p) => p.key.equals(_selectedExamIdKey)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setSelectedExamId(String examId) async {
    await _db.into(_db.appPreferencesLocal).insertOnConflictUpdate(
          AppPreferencesLocalCompanion.insert(
            key: _selectedExamIdKey,
            value: examId,
          ),
        );
  }
}
