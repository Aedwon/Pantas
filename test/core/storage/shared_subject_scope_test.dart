import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/data/repos/review_state_repository.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/mock_exam/application/mock_start_providers.dart';
import 'package:pantas/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:pantas/features/quiz/domain/use_cases/start_drill.dart';
import 'package:pantas/features/quiz/domain/use_cases/start_inline_lesson_quiz.dart';
import 'package:pantas/features/quiz/domain/use_cases/start_quick_quiz.dart';
import 'package:pantas/features/quiz/presentation/debrief_providers.dart';
import 'package:pantas/features/quiz/presentation/practice_picker_providers.dart';

import '../../helpers/in_memory_database.dart';

/// Exams share subjects on purpose. UPCAT owns Mathematics and Language
/// Proficiency; CSE is tagged on part of their questions. A shared topic holds
/// four questions here: two tagged for both exams, two for UPCAT only.
void main() {
  const upcat = 'e_upcat';
  const cse = 'e_cse';
  const shared = ['t_m1', 't_m2', 't_m3', 't_l1', 't_l2', 't_l3'];

  late AppDatabase db;
  late ContentDatabase contentDb;
  late ContentRepository content;
  late ProviderContainer container;

  Future<void> tag(String questionId, String examId) =>
      contentDb.into(contentDb.contentQuestionExams).insertOnConflictUpdate(
            ContentQuestionExamsCompanion.insert(
              questionId: questionId,
              examId: examId,
            ),
          );

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = openTestContentDatabase();
    addTearDown(db.close);
    content = ContentRepository(contentDb);
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    addTearDown(container.dispose);

    await seedContentExam(contentDb, examId: upcat, code: 'UPCAT');
    await seedContentExam(contentDb, examId: cse, code: 'CSE', ordering: 2);
    await seedContentSubject(
      contentDb,
      subjectId: 's_math',
      examId: upcat,
      name: 'Mathematics',
    );
    await seedContentSubject(
      contentDb,
      subjectId: 's_lang',
      examId: upcat,
      name: 'Language Proficiency',
      ordering: 2,
    );
    await seedContentSubject(
      contentDb,
      subjectId: 's_clerical',
      examId: cse,
      name: 'Clerical',
    );
    final subjectOf = {
      't_m1': 's_math',
      't_m2': 's_math',
      't_m3': 's_math',
      't_up_only': 's_math',
      't_l1': 's_lang',
      't_l2': 's_lang',
      't_l3': 's_lang',
      't_own': 's_clerical',
    };
    var ordering = 1;
    for (final entry in subjectOf.entries) {
      await seedContentTopic(
        contentDb,
        topicId: entry.key,
        subjectId: entry.value,
        name: 'Name ${entry.key}',
        ordering: ordering++,
      );
    }
    await seedContentLesson(
      contentDb,
      lessonId: 'les_m1',
      topicId: 't_m1',
      title: 'Number sense',
    );
    // Every shared topic: two questions for both exams, two for UPCAT only.
    for (final topic in shared) {
      for (final n in [1, 2, 3, 4]) {
        final id = '${topic}_q$n';
        await seedContentQuestion(
          contentDb,
          questionId: id,
          topicId: topic,
          examId: upcat,
          lessonId: topic == 't_m1' ? 'les_m1' : null,
        );
        if (n <= 2) await tag(id, cse);
      }
    }
    await seedContentQuestion(
      contentDb,
      questionId: 't_up_only_q1',
      topicId: 't_up_only',
      examId: upcat,
    );
    await seedContentQuestion(
      contentDb,
      questionId: 't_own_q1',
      topicId: 't_own',
      examId: cse,
    );
  });

  Future<void> select(String examId) => container
      .read(appPreferencesRepositoryProvider)
      .setSelectedExamId(examId);

  group('scope', () {
    test('CSE includes the 6 shared topics after its own', () async {
      final topics = await content.topicsByExam(cse);

      expect(topics.map((t) => t.id), ['t_own', ...shared]);
    });

    test('UPCAT scope is unchanged', () async {
      final topics = await content.topicsByExam(upcat);

      expect(
        topics.map((t) => t.id).toSet(),
        {...shared, 't_up_only'},
      );
    });

    test('CSE subjects include the shared subjects', () async {
      await select(cse);

      final subjects = await container.read(scopedSubjectsProvider(cse).future);

      expect(
        subjects.map((s) => s.name),
        ['Clerical', 'Mathematics', 'Language Proficiency'],
      );
    });

    test('UPCAT subjects are unchanged', () async {
      final subjects =
          await container.read(scopedSubjectsProvider(upcat).future);

      expect(
        subjects.map((s) => s.name),
        ['Mathematics', 'Language Proficiency'],
      );
    });

    test('the study map lists the shared lesson for CSE', () async {
      await select(cse);

      final map = await container.read(studyMapProvider.future);

      final lessonIds = [
        for (final s in map!.subjects)
          for (final t in s.topics)
            for (final l in t.lessons) l.id,
      ];
      expect(lessonIds, ['les_m1']);
    });

    test('the reader finds a CSE Mathematics lesson', () async {
      await select(cse);
      await SyncActiveContextStore(db).clearStable();

      final context =
          await container.read(readerContextProvider('les_m1').future);

      expect(context, isNotNull);
      expect(context!.topicId, 't_m1');
    });

    test('the debrief shows the shared topic names', () async {
      await select(cse);
      final at = DateTime.utc(2026, 10, 31);
      final attempt = Attempt(
        id: 'a1',
        examId: cse,
        startedAt: at,
        completedAt: at.add(const Duration(minutes: 2)),
        items: const [
          AttemptItem(
            questionId: 't_m1_q1',
            questionVersion: 1,
            chosenChoiceId: 't_m1_q1_b',
            correctChoiceId: 't_m1_q1_a',
            responseMs: 1000,
          ),
          AttemptItem(
            questionId: 't_l1_q1',
            questionVersion: 1,
            chosenChoiceId: 't_l1_q1_a',
            correctChoiceId: 't_l1_q1_a',
            responseMs: 1000,
          ),
        ],
      );

      final debrief = await container.read(
        sessionDebriefProvider(
          (
            attemptId: 'a1',
            proIsActive: false,
            sessionOverride: null,
            attemptOverride: attempt,
          ),
        ).future,
      );

      expect(debrief.sourceLine, contains('Name t_m1'));
      expect(debrief.sourceLine, contains('Name t_l1'));
      expect(debrief.misses.single.topicName, 'Name t_m1');
    });
  });

  group('pools keep only questions tagged for the exam', () {
    Future<void> seedPracticeLessons() async {
      for (final topic in [...shared.skip(1), 't_up_only', 't_own']) {
        final lessonId = 'les_$topic';
        await seedContentLesson(
          contentDb,
          lessonId: lessonId,
          topicId: topic,
        );
        await contentDb.customStatement(
          'UPDATE content_questions SET lesson_id = ? WHERE id = ?',
          [lessonId, '${topic}_q1'],
        );
      }
    }

    Future<void> expectOnlyCse(Iterable<String> ids) async {
      expect(ids, isNotEmpty);
      final tagged = (await (contentDb.select(contentDb.contentQuestionExams)
                ..where((m) => m.examId.equals(cse)))
              .get())
          .map((m) => m.questionId)
          .toSet();
      expect(ids.where((id) => !tagged.contains(id)), isEmpty);
    }

    test('selection rows, counts and topic questions', () async {
      final rows = await content.selectionRowsByTopics(shared, examId: cse);
      await expectOnlyCse([for (final r in rows.values) ...r.map((q) => q.id)]);
      expect(rows.values.every((r) => r.length == 2), isTrue);

      final counts =
          await content.activeQuestionCountsByTopics(shared, examId: cse);
      expect(counts.values.every((c) => c == 2), isTrue);

      final single = await content.selectionRowsByTopic('t_m1', examId: cse);
      expect(single.length, 2);

      final questions = await content.questionsByTopic('t_m1', examId: cse);
      expect(questions.length, 2);
    });

    test('UPCAT pools are unchanged', () async {
      final rows = await content.selectionRowsByTopics(shared, examId: upcat);
      expect(rows.values.every((r) => r.length == 4), isTrue);
      expect(
        (await content.questionsByTopic('t_m1', examId: upcat)).length,
        4,
      );
      expect(
        (await content.activeQuestionCountsByTopics(shared, examId: upcat))
            .values
            .every((c) => c == 4),
        isTrue,
      );
    });

    test('a custom track keeps every question', () async {
      await seedContentExam(
        contentDb,
        examId: 'e_custom',
        code: 'CUSTOM',
        ordering: 3,
        isCustom: true,
      );

      final rows = await content.selectionRowsByTopics(
        ['t_m1'],
        examId: 'e_custom',
      );

      expect(rows['t_m1']!.length, 4);
    });

    test('placement test', () async {
      final selector =
          AssessmentQuestionSelector(content, ReviewStateRepository(db));

      final picked = await selector.select(cse);

      await expectOnlyCse([for (final p in picked) p.question.id]);
      expect(picked.any((p) => shared.contains(p.topicId)), isTrue);
    });

    test('quick quiz', () async {
      final session = await StartQuickQuiz(content)(
        examId: cse,
        count: 40,
        now: DateTime.utc(2026, 10, 31),
        randomSeed: 1,
      );

      await expectOnlyCse(session.questions.map((q) => q.id));
      expect(session.questions.length, 13);
    });

    test('drill', () async {
      final result = await StartDrill(
        content: content,
        sessions: QuizSessionRepository(db),
      )(
        userId: 'u',
        examId: cse,
        topicId: 't_m1',
        requestedLength: 10,
        now: DateTime.utc(2026, 10, 31),
      );

      final session = (result as StartDrillStarted).session;
      await expectOnlyCse(session.questions.map((q) => q.id));
    });

    test('lesson quiz', () async {
      final result = await StartInlineLessonQuiz(
        content: content,
        sessions: QuizSessionRepository(db),
      )(
        userId: 'u',
        examId: cse,
        lessonId: 'les_m1',
        now: DateTime.utc(2026, 10, 31),
      );

      final session = (result as StartInlineLessonQuizStarted).session;
      await expectOnlyCse(session.questions.map((q) => q.id));
      expect(session.questions.length, 2);
    });

    test('mock pools', () async {
      final pools = await container.read(mockQuestionPoolsProvider(cse).future);

      await expectOnlyCse([for (final p in pools.poolsByTopic.values) ...p]);
      expect(pools.poolsByTopic.keys, containsAll(shared));
    });

    test('practice counts shown in Study and Plan', () async {
      await seedPracticeLessons();
      await select(cse);

      final index = await container.read(practiceIndexProvider(cse).future);

      final counts = [
        for (final s in index.subjects)
          for (final t in s.topics) t.questionCount,
      ];
      expect(counts.reduce((a, b) => a + b), 13);
    });

    test('UPCAT practice counts are unchanged', () async {
      await seedPracticeLessons();
      final index = await container.read(practiceIndexProvider(upcat).future);

      final counts = [
        for (final s in index.subjects)
          for (final t in s.topics) t.questionCount,
      ];
      expect(counts.reduce((a, b) => a + b), 25);
    });
  });
}
