import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/app_preferences_repository.dart';

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

  test('the installed content seed version round-trips', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = AppPreferencesRepository(db);

    expect(await repo.installedContentSeedVersion(), isNull);

    await repo.setInstalledContentSeedVersion('2026-08-02');

    expect(await repo.installedContentSeedVersion(), '2026-08-02');
  });

  test('the last opened lesson round-trips per exam', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = AppPreferencesRepository(db);

    expect(await repo.lastOpenedLessonId('e1'), isNull);

    await repo.pushOpenedLesson(examId: 'e1', lessonId: 'l1');
    await repo.pushOpenedLesson(examId: 'e2', lessonId: 'l9');

    expect(await repo.lastOpenedLessonId('e1'), 'l1');
    expect(await repo.lastOpenedLessonId('e2'), 'l9');
  });

  test('opening a second lesson puts it at the head', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = AppPreferencesRepository(db);

    await repo.pushOpenedLesson(examId: 'e1', lessonId: 'l1');
    await repo.pushOpenedLesson(examId: 'e1', lessonId: 'l2');

    expect(await repo.lastOpenedLessonId('e1'), 'l2');
    expect(await repo.recentlyOpenedLessonIds('e1'), ['l2', 'l1']);
  });

  test('the recent list keeps three and drops the oldest', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = AppPreferencesRepository(db);

    for (final id in ['l1', 'l2', 'l3', 'l4']) {
      await repo.pushOpenedLesson(examId: 'e1', lessonId: id);
    }

    expect(await repo.recentlyOpenedLessonIds('e1'), ['l4', 'l3', 'l2']);
  });

  test('reopening a lesson moves it to the head without duplicating it',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = AppPreferencesRepository(db);

    await repo.pushOpenedLesson(examId: 'e1', lessonId: 'l1');
    await repo.pushOpenedLesson(examId: 'e1', lessonId: 'l2');
    await repo.pushOpenedLesson(examId: 'e1', lessonId: 'l1');

    expect(await repo.recentlyOpenedLessonIds('e1'), ['l1', 'l2']);
  });

  test('an exam nobody has opened has no recent lessons', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = AppPreferencesRepository(db);

    expect(await repo.recentlyOpenedLessonIds('e1'), isEmpty);
  });

  test('the open topic round-trips per exam', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = AppPreferencesRepository(db);

    expect(await repo.openTopicId('e1'), isNull);

    await repo.setOpenTopicId(examId: 'e1', topicId: 't1');

    expect(await repo.openTopicId('e1'), 't1');
    expect(await repo.openTopicId('e2'), isNull);
  });

  test('collapsing the open topic clears it', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = AppPreferencesRepository(db);

    await repo.setOpenTopicId(examId: 'e1', topicId: 't1');

    await repo.setOpenTopicId(examId: 'e1', topicId: null);

    expect(await repo.openTopicId('e1'), isNull);
  });

  test('appliedContentVersion round-trips int in devicePrefs', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = AppPreferencesRepository(db);

    expect(await repo.appliedContentVersion(), isNull);

    await repo.setAppliedContentVersion(2026080410);

    expect(await repo.appliedContentVersion(), equals(2026080410));

    final deviceRow = await (db.select(db.devicePrefs)
          ..where((p) => p.key.equals('applied_content_version')))
        .getSingle();
    expect(deviceRow.value, equals('2026080410'));

    expect(await db.select(db.accountPrefs).get(), isEmpty);
  });

  test('onboarding is not complete until it is marked complete', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = AppPreferencesRepository(db);

    expect(await repo.hasCompletedOnboarding(), isFalse);

    await repo.setCompletedOnboarding(value: true);

    expect(await repo.hasCompletedOnboarding(), isTrue);
  });
}
