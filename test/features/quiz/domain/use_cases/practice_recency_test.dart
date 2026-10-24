import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/repos/attempts_repository.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/data/repos/review_state_repository.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/domain/review_state.dart';
import 'package:pantas/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:pantas/features/quiz/domain/picker/pick_context.dart';
import 'package:pantas/features/quiz/domain/picker/practice_selection.dart';
import 'package:pantas/features/quiz/domain/picker/question_picker.dart';
import 'package:pantas/features/quiz/domain/use_cases/start_practice.dart';

import '../../../../helpers/in_memory_database.dart';

// Fix ordering at the picker seam so the real repository read decides recency.
class _OrderedPicker implements QuestionPicker {
  @override
  List<Question> pick(PickContext c) => [
        ...c.allQuestions.where((q) => !c.excludedQuestionIds.contains(q.id)),
        ...c.allQuestions.where((q) => c.excludedQuestionIds.contains(q.id)),
      ].take(c.requestedLength).toList();
}

void main() {
  final now = DateTime.utc(2026, 10, 13, 12);

  test('selected lessons are mixed and the exact order is saved', () async {
    final db = inMemoryDatabase();
    final contentDb = ContentDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    addTearDown(contentDb.close);
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'e',
      topicId: 't',
      topicName: 'Topic',
      lessonIds: ['l1', 'l2'],
      questionIds: ['a1', 'a2', 'a3', 'b1', 'b2', 'b3'],
      questionLessonMap: {
        'a1': 'l1',
        'a2': 'l1',
        'a3': 'l1',
        'b1': 'l2',
        'b2': 'l2',
        'b3': 'l2',
      },
    );
    final sessions = QuizSessionRepository(db);
    final start = StartPractice(
      content: ContentRepository(contentDb),
      sessions: sessions,
      attempts: AttemptsRepository(db),
      reviews: ReviewStateRepository(db),
      picker: _OrderedPicker(),
    );
    final result = await start(
      userId: 'local',
      examId: 'e',
      units: const [
        PracticeUnit(topicId: 't', lessonId: 'l1'),
        PracticeUnit(topicId: 't', lessonId: 'l2'),
      ],
      perUnit: 3,
      now: now,
    );
    final session = (result as StartPracticeStarted).session;
    expect(
      session.questions.map((q) => q.lessonId),
      ['l1', 'l2', 'l1', 'l2', 'l1', 'l2'],
    );
    final saved = await sessions.activeFor(userId: 'local', examId: 'e');
    expect(saved!.questionIds, ['a1', 'b1', 'a2', 'b2', 'a3', 'b3']);
  });

  test('checked discarded partial is recent even without a saved attempt',
      () async {
    final db = inMemoryDatabase();
    final contentDb = ContentDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    addTearDown(contentDb.close);
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'e',
      topicId: 't',
      topicName: 'Topic',
      questionIds: ['checked', 'fresh'],
      lessonIds: ['l'],
      questionLessonMap: {'checked': 'l', 'fresh': 'l'},
    );
    await ReviewStateRepository(db).upsert(
      ReviewState.seed(
        questionId: 'checked',
        questionVersion: 1,
        now: now.subtract(const Duration(days: 1)),
      ).copyWith(reps: 1),
    );
    expect(await AttemptsRepository(db).countForExam('e'), 0);
    final start = StartPractice(
      content: ContentRepository(contentDb),
      sessions: QuizSessionRepository(db),
      attempts: AttemptsRepository(db),
      reviews: ReviewStateRepository(db),
      picker: _OrderedPicker(),
    );
    final result = await start(
      userId: 'local',
      examId: 'e',
      units: const [PracticeUnit(topicId: 't', lessonId: 'l')],
      perUnit: 1,
      now: now,
    );
    expect(
      (result as StartPracticeStarted).session.questions.single.id,
      'fresh',
    );
  });

  test('seven-day boundary is recent but an unreviewed seed is eligible',
      () async {
    final db = inMemoryDatabase();
    final contentDb = ContentDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    addTearDown(contentDb.close);
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'e',
      topicId: 't',
      topicName: 'Topic',
      questionIds: ['boundary', 'older', 'seed'],
      lessonIds: ['l'],
      questionLessonMap: {'boundary': 'l', 'older': 'l', 'seed': 'l'},
    );
    final reviews = ReviewStateRepository(db);
    await reviews.upsert(
      ReviewState.seed(
        questionId: 'boundary',
        questionVersion: 1,
        now: now.subtract(const Duration(days: 7)),
      ).copyWith(reps: 1),
    );
    await reviews.upsert(
      ReviewState.seed(
        questionId: 'older',
        questionVersion: 1,
        now: now.subtract(const Duration(days: 7, seconds: 1)),
      ).copyWith(reps: 1),
    );
    await reviews.upsert(
      ReviewState.seed(
        questionId: 'seed',
        questionVersion: 1,
        now: now,
      ),
    );
    final start = StartPractice(
      content: ContentRepository(contentDb),
      sessions: QuizSessionRepository(db),
      attempts: AttemptsRepository(db),
      reviews: ReviewStateRepository(db),
      picker: _OrderedPicker(),
    );
    final result = await start(
      userId: 'local',
      examId: 'e',
      units: const [PracticeUnit(topicId: 't', lessonId: 'l')],
      perUnit: 2,
      now: now,
    );
    expect(
      (result as StartPracticeStarted).session.questions.map((q) => q.id),
      ['older', 'seed'],
    );
  });

  test('a small pool tops up recent questions before shortening the run',
      () async {
    final db = inMemoryDatabase();
    final contentDb = ContentDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    addTearDown(contentDb.close);
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'e',
      topicId: 't',
      topicName: 'Topic',
      questionIds: ['past1', 'past2', 'fresh'],
      lessonIds: ['l'],
      questionLessonMap: {'past1': 'l', 'past2': 'l', 'fresh': 'l'},
    );
    final reviews = ReviewStateRepository(db);
    for (final id in ['past1', 'past2']) {
      await reviews.upsert(
        ReviewState.seed(
          questionId: id,
          questionVersion: 1,
          now: now.subtract(const Duration(days: 1)),
        ).copyWith(reps: 1),
      );
    }
    final start = StartPractice(
      content: ContentRepository(contentDb),
      sessions: QuizSessionRepository(db),
      attempts: AttemptsRepository(db),
      reviews: ReviewStateRepository(db),
      picker: _OrderedPicker(),
    );
    final result = await start(
      userId: 'local',
      examId: 'e',
      units: const [PracticeUnit(topicId: 't', lessonId: 'l')],
      perUnit: 4,
      now: now,
    );
    expect(
      (result as StartPracticeStarted).session.questions.map((q) => q.id),
      ['fresh', 'past1', 'past2'],
    );
  });

  test('passage grouping is identical in the displayed and durable order',
      () async {
    final db = inMemoryDatabase();
    final contentDb = ContentDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    addTearDown(contentDb.close);
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'e',
      topicId: 't',
      topicName: 'Topic',
      lessonIds: ['l1', 'l2'],
      questionIds: ['a1', 'a2', 'a3', 'b1'],
      questionLessonMap: {'a1': 'l1', 'a2': 'l1', 'a3': 'l1', 'b1': 'l2'},
    );
    await contentDb.into(contentDb.contentPassages).insert(
          ContentPassagesCompanion.insert(
            id: 'p',
            schemaVersion: 1,
            updatedAt: now,
            topicId: 't',
            title: 'Passage',
            body: 'Passage text.',
            language: 'en',
            wordCount: 2,
          ),
        );
    await (contentDb.update(contentDb.contentQuestions)
          ..where((q) => q.id.isIn(['a1', 'a3'])))
        .write(const ContentQuestionsCompanion(passageId: Value('p')));
    final sessions = QuizSessionRepository(db);
    final start = StartPractice(
      content: ContentRepository(contentDb),
      sessions: sessions,
      attempts: AttemptsRepository(db),
      reviews: ReviewStateRepository(db),
      picker: _OrderedPicker(),
    );
    final result = await start(
      userId: 'local',
      examId: 'e',
      units: const [
        PracticeUnit(topicId: 't', lessonId: 'l1'),
        PracticeUnit(topicId: 't', lessonId: 'l2'),
      ],
      perUnit: 3,
      now: now,
    );
    expect(
      (result as StartPracticeStarted).session.questions.map((q) => q.id),
      ['a1', 'a3', 'b1', 'a2'],
    );
    final saved = await sessions.activeFor(userId: 'local', examId: 'e');
    expect(saved!.questionIds, ['a1', 'a3', 'b1', 'a2']);
  });
}
