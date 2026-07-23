import 'dart:convert';

import 'package:cse_cet_reviewer/core/content/content.dart';
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/storage/track_scope.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
      await db.into(db.exams).insert(
            ExamsCompanion.insert(
              id: exam,
              code: exam,
              name: exam,
              shortName: exam,
              language: 'en',
            ),
          );
      await db.into(db.subjects).insert(
            SubjectsCompanion.insert(
              id: '${exam}_math',
              examId: exam,
              name: 'Mathematics',
              ordering: 0,
            ),
          );
      await db.into(db.topics).insert(
            TopicsCompanion.insert(
              id: '${exam}_algebra',
              subjectId: '${exam}_math',
              name: 'Algebra',
              ordering: 0,
            ),
          );
    }

    await db.into(db.subjects).insert(
          SubjectsCompanion.insert(
            id: 'upcat_sci',
            examId: 'exam_upcat',
            name: 'Science',
            ordering: 1,
          ),
        );
    await db.into(db.topics).insert(
          TopicsCompanion.insert(
            id: 'upcat_chem',
            subjectId: 'upcat_sci',
            name: 'Chemistry',
            ordering: 0,
          ),
        );

    for (var i = 0; i < upcatAlgebraQuestions; i += 1) {
      await db.into(db.questions).insert(
            QuestionsCompanion.insert(
              id: 'q_upcat_$i',
              version: 1,
              examIdsJson: jsonEncode(['exam_upcat']),
              topicId: 'exam_upcat_algebra',
              language: 'en',
              stem: 'stem',
              choicesJson: jsonEncode([
                {'id': 'a', 'label': 'A', 'text': 'a', 'isCorrect': true},
              ]),
              explanation: 'why',
            ),
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
