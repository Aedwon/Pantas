import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/features/quiz/data/repos/quiz_preferences_repository.dart';
import 'package:pantas/features/quiz/domain/models/quiz_ordering.dart';
import 'package:pantas/features/quiz/domain/models/quiz_preferences.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  test('default quiz preferences are length 10 interleaved tail newCardCap 10',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);

    final prefs = await QuizPreferencesRepository(db).read();

    expect(prefs.sessionLength, 10);
    expect(prefs.ordering, QuizOrdering.interleavedTail);
    expect(prefs.newCardCap, 10);
  });

  test('sessionLength accepts 5 10 20 and all-due sentinel', () {
    expect(
      () => QuizPreferences(
        sessionLength: 5,
        ordering: QuizOrdering.blocked,
        newCardCap: 10,
      ),
      returnsNormally,
    );
    expect(
      () => QuizPreferences(
        sessionLength: 10,
        ordering: QuizOrdering.blocked,
        newCardCap: 10,
      ),
      returnsNormally,
    );
    expect(
      () => QuizPreferences(
        sessionLength: 20,
        ordering: QuizOrdering.blocked,
        newCardCap: 10,
      ),
      returnsNormally,
    );
    expect(
      () => QuizPreferences(
        sessionLength: QuizPreferences.allDueSessionLength,
        ordering: QuizOrdering.blocked,
        newCardCap: 10,
      ),
      returnsNormally,
    );
    expect(
      () => QuizPreferences(
        sessionLength: 7,
        ordering: QuizOrdering.blocked,
        newCardCap: 10,
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
        newCardCap: 5,
      ),
    );

    final accountRows = await db.select(db.accountPrefs).get();
    final deviceRows = await db.select(db.devicePrefs).get();

    expect(
      {for (final row in accountRows) row.key: row.value},
      {
        QuizPreferencesRepository.sessionLengthKey: '20',
        QuizPreferencesRepository.interleavedTodayKey: 'interleaved_tail',
        QuizPreferencesRepository.newCardCapKey: '5',
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
            key: QuizPreferencesRepository.newCardCapKey,
            value: 'nope',
          ),
        );

    final prefs = await QuizPreferencesRepository(db).read();

    expect(prefs.sessionLength, 10);
    expect(prefs.ordering, QuizOrdering.interleavedTail);
    expect(prefs.newCardCap, 10);
  });
}
