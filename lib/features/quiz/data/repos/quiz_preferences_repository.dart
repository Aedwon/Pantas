import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/quiz_ordering.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/quiz_preferences.dart';

class QuizPreferencesRepository {
  QuizPreferencesRepository(this._db);

  static const sessionLengthKey = 'quiz_session_length';

  /// Named for the boolean it used to be. The key is synced and already on
  /// devices, so it widened in place rather than being replaced.
  static const interleavedTodayKey = 'quiz_today_interleaved';
  static const newCardCapKey = 'quiz_new_card_cap';

  final AppDatabase _db;

  Future<QuizPreferences> read() async {
    final rows = await _db.select(_db.accountPrefs).get();
    final values = {for (final row in rows) row.key: row.value};

    return QuizPreferences(
      sessionLength: _readSessionLength(values[sessionLengthKey]),
      ordering: QuizOrdering.fromStorage(values[interleavedTodayKey]),
      newCardCap: _readNonNegativeInt(
        values[newCardCapKey],
        fallback: QuizPreferences.defaults.newCardCap,
      ),
    );
  }

  Future<void> save(QuizPreferences preferences) async {
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.accountPrefs, [
        AccountPrefsCompanion.insert(
          key: sessionLengthKey,
          value: preferences.sessionLength.toString(),
        ),
        AccountPrefsCompanion.insert(
          key: interleavedTodayKey,
          value: preferences.ordering.storageValue,
        ),
        AccountPrefsCompanion.insert(
          key: newCardCapKey,
          value: preferences.newCardCap.toString(),
        ),
      ]);
    });
  }

  static int _readSessionLength(String? value) {
    final parsed = int.tryParse(value ?? '');
    return switch (parsed) {
      5 || 10 || 20 || QuizPreferences.allDueSessionLength => parsed!,
      _ => QuizPreferences.defaults.sessionLength,
    };
  }

  static int _readNonNegativeInt(String? value, {required int fallback}) {
    final parsed = int.tryParse(value ?? '');
    if (parsed == null || parsed < 0) return fallback;
    return parsed;
  }
}
