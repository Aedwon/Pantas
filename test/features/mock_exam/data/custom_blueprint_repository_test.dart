import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/features/mock_exam/data/blueprint_section.dart';
import 'package:pantas/features/mock_exam/data/custom_blueprint_repository.dart';
import 'package:pantas/features/mock_exam/domain/custom_blueprint.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late CustomBlueprintRepository repo;

  const topicsBySubject = {
    'math': ['algebra', 'geometry'],
    'sci': ['chem'],
  };

  setUp(() async {
    db = inMemoryDatabase();
    repo = CustomBlueprintRepository(db);
    await db.into(db.exams).insert(
          ExamsCompanion.insert(
            id: 'exam_custom_1',
            code: 'custom',
            name: 'Provincial scholarship',
            shortName: 'Provincial scholarship',
            language: 'en',
            isCustom: const Value(true),
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  test('a saved blueprint reads back and parses as sections', () async {
    await repo.save(
      const CustomBlueprint(
        examId: 'exam_custom_1',
        totalQuestions: 120,
        totalMinutes: 90,
      ),
      topicsBySubject: topicsBySubject,
      now: DateTime(2026, 8, 10),
    );

    final row = await repo.read('exam_custom_1');
    expect(row, isNotNull);
    expect(row!.totalQuestions, 120);
    expect(BlueprintSection.parseList(row.sectionsJson), hasLength(1));
  });

  test('the stored totals are the effective ones, not the top rows', () async {
    await repo.save(
      const CustomBlueprint(
        examId: 'exam_custom_1',
        totalQuestions: 120,
        totalMinutes: 120,
        sections: [
          CustomBlueprintSectionDraft(
            subjectId: 'math',
            name: 'Mathematics',
            questions: 60,
            minutes: 50,
          ),
        ],
      ),
      topicsBySubject: topicsBySubject,
      now: DateTime(2026, 8, 10),
    );

    final row = await repo.read('exam_custom_1');
    expect(row!.totalQuestions, 60);
    expect(row.totalMinutes, 50);
  });

  test('saving again replaces rather than adding', () async {
    for (final questions in [120, 80]) {
      await repo.save(
        CustomBlueprint(
          examId: 'exam_custom_1',
          totalQuestions: questions,
          totalMinutes: 90,
        ),
        topicsBySubject: topicsBySubject,
        now: DateTime(2026, 8, 10),
      );
    }

    final rows = await db.select(db.customBlueprintsLocal).get();
    expect(rows, hasLength(1));
    expect(rows.single.totalQuestions, 80);
  });

  test('a track with no blueprint reads as absent', () async {
    expect(await repo.read('exam_custom_1'), isNull);
    expect(await repo.exists('exam_custom_1'), isFalse);
  });

  test('whether the parts are timed separately survives the round trip',
      () async {
    await repo.save(
      const CustomBlueprint(
        examId: 'exam_custom_1',
        totalQuestions: 60,
        totalMinutes: 60,
        sectionsTimedSeparately: true,
      ),
      topicsBySubject: topicsBySubject,
      now: DateTime(2026, 8, 10),
    );

    expect((await repo.read('exam_custom_1'))!.sectionsTimedSeparately, isTrue);
  });
}
