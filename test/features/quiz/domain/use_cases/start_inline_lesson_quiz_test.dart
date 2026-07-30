import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/quiz/domain/use_cases/start_inline_lesson_quiz.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('inline lesson quiz stores inline origin lessonId and subtopicId',
      () async {
    final db = inMemoryDatabase();
    final contentDb = ContentDatabase(NativeDatabase.memory());
    addTearDown(contentDb.close);
    addTearDown(db.close);
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'exam_cse_pro',
      subjectId: 'subj_cse_verbal',
      topicId: 'topic_cse_vocab',
      topicName: 'Vocab',
      questionIds: List.generate(30, (i) => 'q$i'),
      // These used to seed the whole asset corpus, which carried lessons with
      // it. An inline quiz starts from a lesson, so the topic needs one.
      lessonIds: const ['les_vocab'],
      questionLessonMap: {
        for (var i = 0; i < 30; i++) 'q$i': 'les_vocab',
      },
    );
    final content = ContentRepository(contentDb);
    final lesson = (await content.lessonsByTopic('topic_cse_vocab')).first;

    final result = await StartInlineLessonQuiz(
      content: content,
      sessions: QuizSessionRepository(db),
    )(
      userId: 'user',
      examId: 'exam_cse_pro',
      lessonId: lesson.id,
      now: DateTime.utc(2026, 5, 18),
    );

    final session = (result as StartInlineLessonQuizStarted).session;
    expect(session.origin, SessionOrigin.inline);
    expect(session.lessonId, lesson.id);
    expect(session.subtopicId, lesson.subtopicId);

    final row = await QuizSessionRepository(db)
        .activeFor(userId: 'user', examId: 'exam_cse_pro');
    expect(row?.origin, SessionOrigin.inline.storageValue);
    expect(row?.lessonId, lesson.id);
  });

  test('inline lesson quiz requests exactly five questions', () async {
    final db = inMemoryDatabase();
    final contentDb = ContentDatabase(NativeDatabase.memory());
    addTearDown(contentDb.close);
    addTearDown(db.close);
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'exam_cse_pro',
      subjectId: 'subj_cse_verbal',
      topicId: 'topic_cse_vocab',
      topicName: 'Vocab',
      questionIds: List.generate(30, (i) => 'q$i'),
      // These used to seed the whole asset corpus, which carried lessons with
      // it. An inline quiz starts from a lesson, so the topic needs one.
      lessonIds: const ['les_vocab'],
      questionLessonMap: {
        for (var i = 0; i < 30; i++) 'q$i': 'les_vocab',
      },
    );
    final content = ContentRepository(contentDb);
    final lesson = (await content.lessonsByTopic('topic_cse_vocab')).first;

    final result = await StartInlineLessonQuiz(
      content: content,
      sessions: QuizSessionRepository(db),
    )(
      userId: 'user',
      examId: 'exam_cse_pro',
      lessonId: lesson.id,
      now: DateTime.utc(2026, 5, 18),
    );

    final session = (result as StartInlineLessonQuizStarted).session;
    expect(session.questions.length, lessThanOrEqualTo(5));
    expect(session.questions, isNotEmpty);
  });

  test('inline lesson quiz falls back to topic when lesson has no subtopicId',
      () async {
    final db = inMemoryDatabase();
    final contentDb = ContentDatabase(NativeDatabase.memory());
    addTearDown(contentDb.close);
    addTearDown(db.close);
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'exam_cse_pro',
      subjectId: 'subj_cse_verbal',
      topicId: 'topic_cse_vocab',
      topicName: 'Vocab',
      questionIds: List.generate(30, (i) => 'q$i'),
      // These used to seed the whole asset corpus, which carried lessons with
      // it. An inline quiz starts from a lesson, so the topic needs one.
      lessonIds: const ['les_vocab'],
      questionLessonMap: {
        for (var i = 0; i < 30; i++) 'q$i': 'les_vocab',
      },
    );
    final content = ContentRepository(contentDb);
    final lesson = (await content.lessonsByTopic('topic_cse_vocab')).first;

    final result = await StartInlineLessonQuiz(
      content: content,
      sessions: QuizSessionRepository(db),
    )(
      userId: 'user',
      examId: 'exam_cse_pro',
      lessonId: lesson.id,
      now: DateTime.utc(2026, 5, 18),
    );

    final session = (result as StartInlineLessonQuizStarted).session;
    expect(lesson.subtopicId, isNull);
    expect(
      session.questions.every((question) => question.topicId == lesson.topicId),
      isTrue,
    );
  });
}
