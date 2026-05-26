import 'package:cse_cet_reviewer/features/study_plan/data/plan_prefs_repository.dart';
import 'package:cse_cet_reviewer/features/study_plan/domain/plan_prefs.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  test('returns defaults when plan prefs are missing', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = DriftPlanPrefsRepository(db);

    final prefs = await repo.read();

    expect(prefs.examDate, isNull);
    expect(prefs.examDateIsProvisional, isTrue);
    expect(prefs.intensity, StudyPlanIntensity.standard);
    expect(prefs.planUpdatedPending, isFalse);
  });

  test('saves exact exam date as non-provisional', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = DriftPlanPrefsRepository(db);

    await repo.setExamDate(
      DateTime(2026, 8, 10),
      today: DateTime(2026, 5, 21),
      provisional: false,
    );

    final prefs = await repo.read();
    expect(prefs.examDate, DateTime(2026, 8, 10));
    expect(prefs.examDateIsProvisional, isFalse);
    expect(prefs.planUpdatedPending, isTrue);
  });

  test('saves provisional exam date separately from exact date', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = DriftPlanPrefsRepository(db);

    await repo.setExamDate(
      DateTime(2026, 9, 1),
      today: DateTime(2026, 5, 21),
    );

    final prefs = await repo.read();
    expect(prefs.examDate, DateTime(2026, 9));
    expect(prefs.examDateIsProvisional, isTrue);
  });

  test('rejects an exam date before today', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = DriftPlanPrefsRepository(db);

    await expectLater(
      repo.setExamDate(DateTime(2026, 5, 20), today: DateTime(2026, 5, 21)),
      throwsA(isA<PastExamDateException>()),
    );
  });

  test('saves and reads light standard and intense intensity presets',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = DriftPlanPrefsRepository(db);

    for (final intensity in StudyPlanIntensity.values) {
      await repo.setIntensity(intensity);
      final prefs = await repo.read();
      expect(prefs.intensity, intensity);
      expect(prefs.planUpdatedPending, isTrue);
    }
  });

  test('marks plan updated chip as pending until acknowledged', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = DriftPlanPrefsRepository(db);

    await repo.setIntensity(StudyPlanIntensity.intense);
    expect((await repo.read()).planUpdatedPending, isTrue);

    await repo.acknowledgePlanUpdated();
    expect((await repo.read()).planUpdatedPending, isFalse);
  });
}
