import 'dart:convert';

import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/features/quiz/domain/picker/practice_summary.dart';

typedef SavedPracticePicks = ({
  Set<LessonId> lessonIds,
  PracticeUnitMode mode,
  int value,
  Map<String, int> adjustments,
});

class PracticePreferencesRepository {
  PracticePreferencesRepository(this._db);
  final AppDatabase _db;

  Future<SavedPracticePicks> read(ExamId examId) async {
    final picksKey = 'practice_last_picks.$examId';
    final lengthKey = 'practice_last_length.$examId';
    final rows = await (_db.select(_db.devicePrefs)
          ..where((p) => p.key.isIn([picksKey, lengthKey])))
        .get();
    final values = {for (final row in rows) row.key: row.value};
    final picks = values[picksKey];
    final length = values[lengthKey];
    final data = length == null
        ? <String, Object?>{}
        : jsonDecode(length) as Map<String, Object?>;
    final rawMode = data['mode'] as String?;
    final rawCounts = data['adjustments'] as Map<String, Object?>? ?? const {};
    return (
      lessonIds: picks == null
          ? <LessonId>{}
          : Set<LessonId>.unmodifiable(
              (jsonDecode(picks) as List<Object?>).map((id) => id! as LessonId),
            ),
      mode: rawMode == null
          ? PracticeUnitMode.questions
          : PracticeUnitMode.values.byName(rawMode),
      value: data['value'] as int? ?? 10,
      adjustments: Map<String, int>.unmodifiable(
        rawCounts.map<String, int>(
          (key, value) => MapEntry(key, value! as int),
        ),
      ),
    );
  }

  Future<void> save(
    ExamId examId, {
    required Set<LessonId> lessonIds,
    required PracticeUnitMode mode,
    required int value,
    required Map<String, int> adjustments,
  }) =>
      _db.transaction(() async {
        final picks = lessonIds.toList()..sort();
        for (final entry in {
          'practice_last_picks.$examId': jsonEncode(picks),
          'practice_last_length.$examId': jsonEncode({
            'mode': mode.name,
            'value': value,
            'adjustments': adjustments,
          }),
        }.entries) {
          await _db.into(_db.devicePrefs).insertOnConflictUpdate(
                DevicePrefsCompanion.insert(key: entry.key, value: entry.value),
              );
        }
      });
}
