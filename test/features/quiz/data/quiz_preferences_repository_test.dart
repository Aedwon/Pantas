import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/features/quiz/data/repos/quiz_preferences_repository.dart';
import 'package:pantas/features/quiz/domain/models/quiz_ordering.dart';
import 'package:pantas/features/quiz/domain/models/quiz_preferences.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  test('default quiz preferences are length 10 and interleaved tail', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);

    final prefs = await QuizPreferencesRepository(db).read();

    expect(prefs.sessionLength, 10);
    expect(prefs.ordering, QuizOrdering.interleavedTail);
  });

  test('sessionLength accepts 5 10 20 and all-due sentinel', () {
    expect(
      () => QuizPreferences(
        sessionLength: 5,
        ordering: QuizOrdering.blocked,
      ),
      returnsNormally,
    );
    expect(
      () => QuizPreferences(
        sessionLength: 10,
        ordering: QuizOrdering.blocked,
      ),
      returnsNormally,
    );
    expect(
      () => QuizPreferences(
        sessionLength: 20,
        ordering: QuizOrdering.blocked,
      ),
      returnsNormally,
    );
    expect(
      () => QuizPreferences(
        sessionLength: QuizPreferences.allDueSessionLength,
        ordering: QuizOrdering.blocked,
      ),
      returnsNormally,
    );
    expect(
      () => QuizPreferences(
        sessionLength: 7,
        ordering: QuizOrdering.blocked,
      ),
      throwsArgumentError,
    );
  });

  test('save writes quiz preferences to account prefs only', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);

    await QuizPreferencesRepository(db).save(
      QuizPreferences(
        sessionLength: 20,
        ordering: QuizOrdering.interleavedTail,
      ),
    );

    final accountRows = await db.select(db.accountPrefs).get();
    final deviceRows = await db.select(db.devicePrefs).get();

    expect(
      {for (final row in accountRows) row.key: row.value},
      {
        QuizPreferencesRepository.sessionLengthKey: '20',
        SettingsPrefKeys.sessionOrdering: 'interleavedTail',
      },
    );
    expect(deviceRows, isEmpty);
  });

  test('read ignores invalid stored values and falls back per field', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);

    await db.into(db.accountPrefs).insertOnConflictUpdate(
          AccountPrefsCompanion.insert(
            key: QuizPreferencesRepository.sessionLengthKey,
            value: '7',
          ),
        );
    await db.into(db.accountPrefs).insertOnConflictUpdate(
          AccountPrefsCompanion.insert(
            key: QuizPreferencesRepository.interleavedTodayKey,
            value: 'true',
          ),
        );
    await db.into(db.accountPrefs).insertOnConflictUpdate(
          AccountPrefsCompanion.insert(
            key: 'quiz_new_card_cap',
            value: 'nope',
          ),
        );

    final prefs = await QuizPreferencesRepository(db).read();

    expect(prefs.sessionLength, 10);
    expect(prefs.ordering, QuizOrdering.interleavedTail);
  });

  test('saving leaves the legacy cap key unchanged and never creates it',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = QuizPreferencesRepository(db);
    await repo.save(QuizPreferences.defaults);
    expect(
      (await db.select(db.accountPrefs).get()).map((row) => row.key),
      isNot(contains('quiz_new_card_cap')),
    );
    await db.into(db.accountPrefs).insertOnConflictUpdate(
          AccountPrefsCompanion.insert(key: 'quiz_new_card_cap', value: '0'),
        );
    await repo.save(QuizPreferences.defaults);
    final rows = await db.select(db.accountPrefs).get();
    expect(
      rows.singleWhere((row) => row.key == 'quiz_new_card_cap').value,
      '0',
    );
    expect((await repo.read()).sessionLength, 10);
  });

  test('explicit Settings ordering wins disagreement with legacy quiz key',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await db.into(db.accountPrefs).insertOnConflictUpdate(
          AccountPrefsCompanion.insert(
            key: SettingsPrefKeys.sessionOrdering,
            value: 'fullyMixed',
          ),
        );
    await db.into(db.accountPrefs).insertOnConflictUpdate(
          AccountPrefsCompanion.insert(
            key: QuizPreferencesRepository.interleavedTodayKey,
            value: 'false',
          ),
        );

    final prefs = await QuizPreferencesRepository(db).read();
    expect(prefs.ordering, QuizOrdering.fullyMixed);
  });

  test('legacy boolean ordering remains fallback only when Settings is absent',
      () async {
    for (final entry in [
      ('true', QuizOrdering.interleavedTail),
      ('false', QuizOrdering.blocked),
    ]) {
      final db = inMemoryDatabase();
      await db.into(db.accountPrefs).insertOnConflictUpdate(
            AccountPrefsCompanion.insert(
              key: QuizPreferencesRepository.interleavedTodayKey,
              value: entry.$1,
            ),
          );
      expect((await QuizPreferencesRepository(db).read()).ordering, entry.$2);
      await db.close();
    }
  });
}
