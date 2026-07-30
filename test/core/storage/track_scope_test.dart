import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;
  late ProviderContainer container;

  setUp(() {
    db = inMemoryDatabase();
    contentDb = openTestContentDatabase();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  /// Two exams that both carry "Mathematics", so the shared subject case is
  /// the default rather than a special one.
  Future<void> seedTwoExams({int upcatAlgebraQuestions = 1}) async {
    for (final exam in ['exam_upcat', 'exam_cse']) {
      await seedContentExam(
        contentDb,
        examId: exam,
        code: exam,
        name: exam,
        shortName: exam,
      );
      await seedContentSubject(
        contentDb,
        subjectId: '${exam}_math',
        examId: exam,
        name: 'Mathematics',
        ordering: 0,
      );
      await seedContentTopic(
        contentDb,
        topicId: '${exam}_algebra',
        subjectId: '${exam}_math',
        name: 'Algebra',
        ordering: 0,
      );
    }

    await seedContentSubject(
      contentDb,
      subjectId: 'upcat_sci',
      examId: 'exam_upcat',
      name: 'Science',
    );
    await seedContentTopic(
      contentDb,
      topicId: 'upcat_chem',
      subjectId: 'upcat_sci',
      name: 'Chemistry',
      ordering: 0,
    );

    for (var i = 0; i < upcatAlgebraQuestions; i += 1) {
      await seedContentQuestionWithChoices(
        contentDb,
        questionId: 'q_upcat_$i',
        topicId: 'exam_upcat_algebra',
        examId: 'exam_upcat',
        choices: [
          {'id': 'a', 'label': 'A', 'text': 'a', 'isCorrect': true},
        ],
        stem: 'stem',
        explanation: 'why',
      );
    }
  }

  test('a listed exam with no exclusions scopes to its own topics', () async {
    await seedTwoExams();

    final topics =
        await container.read(scopedTopicsProvider('exam_upcat').future);

    expect(
      topics.map((t) => t.id).toSet(),
      {'exam_upcat_algebra', 'upcat_chem'},
    );
  });

  test('an exclusion hides a topic', () async {
    await seedTwoExams();
    await container.read(customTrackRepositoryProvider).setExcluded(
      examId: 'exam_upcat',
      topicIds: {'upcat_chem'},
    );

    final topics =
        await container.read(scopedTopicsProvider('exam_upcat').future);

    expect(topics.map((t) => t.id), isNot(contains('upcat_chem')));
  });

  test('a custom track scopes to the whole corpus minus its exclusions',
      () async {
    await seedTwoExams();
    final repo = container.read(customTrackRepositoryProvider);
    final examId = await repo.create(
      name: 'Provincial scholarship',
      includedTopicIds: {'exam_upcat_algebra', 'upcat_chem'},
    );

    final topics = await container.read(scopedTopicsProvider(examId).future);

    expect(topics.map((t) => t.name).toSet(), {'Algebra', 'Chemistry'});
  });

  test('a shared subject appears once for a custom track', () async {
    await seedTwoExams();
    final repo = container.read(customTrackRepositoryProvider);
    final examId = await repo.create(
      name: 'Everything',
      includedTopicIds: {
        'exam_upcat_algebra',
        'exam_cse_algebra',
        'upcat_chem',
      },
    );

    final topics = await container.read(scopedTopicsProvider(examId).future);

    expect(topics.where((t) => t.name == 'Algebra'), hasLength(1));
  });

  test('the winning id is the one with more questions', () async {
    await seedTwoExams(upcatAlgebraQuestions: 3);
    final repo = container.read(customTrackRepositoryProvider);
    final examId = await repo.create(
      name: 'Everything',
      includedTopicIds: {
        'exam_upcat_algebra',
        'exam_cse_algebra',
        'upcat_chem',
      },
    );

    final topics = await container.read(scopedTopicsProvider(examId).future);

    // The CSE's Algebra holds none, so the UPCAT's wins and a track drawing
    // on Algebra draws on the one with questions in it.
    expect(
      topics.firstWhere((t) => t.name == 'Algebra').id,
      'exam_upcat_algebra',
    );
  });

  test('scoped subjects drop a subject whose topics are all hidden', () async {
    await seedTwoExams();
    await container.read(customTrackRepositoryProvider).setExcluded(
      examId: 'exam_upcat',
      topicIds: {'upcat_chem'},
    );

    final subjects =
        await container.read(scopedSubjectsProvider('exam_upcat').future);

    expect(subjects.map((s) => s.name), isNot(contains('Science')));
    expect(subjects.map((s) => s.name), contains('Mathematics'));
  });
}
