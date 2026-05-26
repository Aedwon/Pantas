import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/features/study_plan/domain/plan_prefs.dart';
import 'package:drift/drift.dart';

abstract class PlanPrefsRepository {
  Future<PlanPrefs> read();
}

class PastExamDateException implements Exception {
  const PastExamDateException(this.date);

  final DateTime date;
}

class DriftPlanPrefsRepository implements PlanPrefsRepository {
  DriftPlanPrefsRepository(this._db);

  static const _examDateKey = 'study_plan.exam_date';
  static const _examDateIsProvisionalKey =
      'study_plan.exam_date_is_provisional';
  static const _intensityKey = 'study_plan.intensity';
  static const _planUpdatedPendingKey = 'study_plan.updated_pending';

  final AppDatabase _db;

  @override
  Future<PlanPrefs> read() async {
    final rows = await _db.select(_db.accountPrefs).get();
    final values = {for (final row in rows) row.key: row.value};
    final date = _parseDate(values[_examDateKey]);
    return PlanPrefs(
      examDate: date,
      examDateIsProvisional: values[_examDateIsProvisionalKey] != 'false',
      intensity: StudyPlanIntensityX.fromStorage(values[_intensityKey]),
      planUpdatedPending: values[_planUpdatedPendingKey] == 'true',
    );
  }

  Future<void> setExamDate(
    DateTime date, {
    required DateTime today,
    bool provisional = true,
  }) async {
    final normalizedDate = _dateOnly(date);
    if (normalizedDate.isBefore(_dateOnly(today))) {
      throw PastExamDateException(normalizedDate);
    }
    await _writeAll({
      _examDateKey: _formatDate(normalizedDate),
      _examDateIsProvisionalKey: provisional ? 'true' : 'false',
      _planUpdatedPendingKey: 'true',
    });
  }

  Future<void> setIntensity(StudyPlanIntensity intensity) async {
    await _writeAll({
      _intensityKey: intensity.storageValue,
      _planUpdatedPendingKey: 'true',
    });
  }

  Future<void> acknowledgePlanUpdated() async {
    await _write(_planUpdatedPendingKey, 'false');
  }

  Future<void> _writeAll(Map<String, String> values) async {
    await _db.batch((batch) {
      for (final entry in values.entries) {
        batch.insert(
          _db.accountPrefs,
          AccountPrefsCompanion.insert(
            key: entry.key,
            value: entry.value,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> _write(String key, String value) async {
    await _db.into(_db.accountPrefs).insertOnConflictUpdate(
          AccountPrefsCompanion.insert(key: key, value: value),
        );
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  static DateTime? _parseDate(String? value) {
    if (value == null) return null;
    final parts = value.split('-');
    if (parts.length != 3) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;
    return DateTime(year, month, day);
  }
}
