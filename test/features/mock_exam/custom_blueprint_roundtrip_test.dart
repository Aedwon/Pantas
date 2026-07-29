import 'package:cse_cet_reviewer/core/content/content.dart';
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/mock_exam/data/custom_blueprint_repository.dart';
import 'package:cse_cet_reviewer/features/mock_exam/data/mock_sampler.dart';
import 'package:cse_cet_reviewer/features/mock_exam/domain/custom_blueprint.dart';
import 'package:cse_cet_reviewer/features/mock_exam/presentation/pages/mock_setup_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase appDb;
  late ContentDatabase contentDb;
  late ProviderContainer container;

  setUp(() async {
    appDb = inMemoryDatabase();
    contentDb = openTestContentDatabase();

    // Seed content
    await seedContentExam(
      contentDb,
      examId: 'custom_1',
      code: 'CUST',
      name: 'Custom Exam',
      shortName: 'CUST',
      isCustom: true,
    );
    await seedContentSubject(
      contentDb,
      examId: 'custom_1',
      subjectId: 'math',
      name: 'Math',
    );
    await seedContentSubject(
      contentDb,
      examId: 'custom_1',
      subjectId: 'science',
      name: 'Science',
    );

    // Add topics
    await seedContentTopic(
      contentDb,
      topicId: 'math_t1',
      subjectId: 'math',
      name: 'Math T1',
    );
    await seedContentTopic(
      contentDb,
      topicId: 'sci_t1',
      subjectId: 'science',
      name: 'Sci T1',
    );

    // Add questions for Math (5 questions)
    for (var i = 0; i < 5; i++) {
      await seedContentQuestion(
        contentDb,
        questionId: 'math_q$i',
        topicId: 'math_t1',
        examId: 'custom_1',
        stem: 'Math Q $i',
      );
    }

    // Add questions for Science (5 questions)
    for (var i = 0; i < 5; i++) {
      await seedContentQuestion(
        contentDb,
        questionId: 'sci_q$i',
        topicId: 'sci_t1',
        examId: 'custom_1',
        stem: 'Sci Q $i',
      );
    }

    // Set up provider container
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(appDb),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await appDb.close();
    await contentDb.close();
  });

  test('Compose, save, start, and the paper drawn matches the composition',
      () async {
    final customRepo = CustomBlueprintRepository(appDb);

    // Compose: 3 Math, 2 Science
    const draft = CustomBlueprint(
      examId: 'custom_1',
      totalQuestions: 5,
      totalMinutes: 10,
      sections: [
        CustomBlueprintSectionDraft(
          name: 'Math Part',
          questions: 3,
          minutes: 5,
          subjectId: 'math',
        ),
        CustomBlueprintSectionDraft(
          name: 'Science Part',
          questions: 2,
          minutes: 5,
          subjectId: 'science',
        ),
      ],
    );

    // Save
    await customRepo.save(
      draft,
      topicsBySubject: {
        'math': ['math_t1'],
        'science': ['sci_t1'],
      },
      now: DateTime(2026, 8, 11),
    );

    // The active exam focus reads the exam list and the stored selection, so
    // the custom exam has to be selected for the custom branch to be taken.
    final prefs = AppPreferencesRepository(appDb);
    await prefs.setSelectedExamId('custom_1');

    // Make sure we have the exams loaded
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(appDb),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );

    // Read the parsed blueprint
    final parsed = await container
        .read(mockSetupParsedBlueprintProvider('custom_1').future);
    expect(parsed, isNotNull);

    final sampler = MockSampler();
    final sample = sampler.sample(
      sections: parsed!.sections,
      poolsByTopic: {
        'math_t1': ['math_q0', 'math_q1', 'math_q2', 'math_q3', 'math_q4'],
        'sci_t1': ['sci_q0', 'sci_q1', 'sci_q2', 'sci_q3', 'sci_q4'],
      },
      recentlySampledQuestionIds: {},
      seed: 123,
    );

    expect(sample.sections.length, 2);

    final mathSection =
        sample.sections.firstWhere((s) => s.name == 'Math Part');
    expect(mathSection.questionIds.length, 3);
    expect(
      mathSection.questionIds.every((id) => id.startsWith('math_q')),
      isTrue,
    );

    final sciSection =
        sample.sections.firstWhere((s) => s.name == 'Science Part');
    expect(sciSection.questionIds.length, 2);
    expect(
      sciSection.questionIds.every((id) => id.startsWith('sci_q')),
      isTrue,
    );

    container.dispose();
  });
}
