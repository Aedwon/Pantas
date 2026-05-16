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
  });

  test('setSelectedExamId overwrites previous value', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = AppPreferencesRepository(db);

    await repo.setSelectedExamId('cse');
    await repo.setSelectedExamId('upcat');

    expect(await repo.selectedExamId(), equals('upcat'));
  });
}
