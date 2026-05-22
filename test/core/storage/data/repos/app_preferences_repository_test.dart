import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/app_preferences_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  test('selectedExamId returns null when unset', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = AppPreferencesRepository(db);

    expect(await repo.selectedExamId(), isNull);
  });

  test('setSelectedExamId persists the selected exam id', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = AppPreferencesRepository(db);

    await repo.setSelectedExamId('cse');

    expect(await repo.selectedExamId(), equals('cse'));
    final deviceRow = await (db.select(db.devicePrefs)
          ..where((p) => p.key.equals('selected_exam_id')))
        .getSingle();
    expect(deviceRow.value, equals('cse'));
  });

  test('setSelectedExamId overwrites previous value', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = AppPreferencesRepository(db);

    await repo.setSelectedExamId('cse');
    await repo.setSelectedExamId('upcat');

    expect(await repo.selectedExamId(), equals('upcat'));
  });

  test('hasPassedAgeGate returns false when unset', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = AppPreferencesRepository(db);

    expect(await repo.hasPassedAgeGate(), isFalse);
  });

  test('setPassedAgeGate persists true', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = AppPreferencesRepository(db);

    await repo.setPassedAgeGate(value: true);

    expect(await repo.hasPassedAgeGate(), isTrue);
    final deviceRow = await (db.select(db.devicePrefs)
          ..where((p) => p.key.equals('passed_age_gate')))
        .getSingle();
    expect(deviceRow.value, equals('true'));
  });

  test('setPassedAgeGate overwrites previous value', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = AppPreferencesRepository(db);

    await repo.setPassedAgeGate(value: true);
    await repo.setPassedAgeGate(value: false);

    expect(await repo.hasPassedAgeGate(), isFalse);
  });

  test('account preferences stay empty when only onboarding prefs exist',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = AppPreferencesRepository(db);

    await repo.setSelectedExamId('cse');
    await repo.setPassedAgeGate(value: true);

    expect(await db.select(db.accountPrefs).get(), isEmpty);
  });

  test('selected exam id falls back from legacy local preferences', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await db.into(db.appPreferencesLocal).insert(
          AppPreferencesLocalCompanion.insert(
            key: 'selected_exam_id',
            value: 'upcat',
          ),
        );

    expect(
      await AppPreferencesRepository(db).selectedExamId(),
      equals('upcat'),
    );
  });
}
