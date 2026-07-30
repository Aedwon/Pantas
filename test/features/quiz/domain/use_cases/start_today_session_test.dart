import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:pantas/features/quiz/domain/models/quiz_ordering.dart';
import 'package:pantas/features/quiz/domain/models/quiz_preferences.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/quiz/domain/picker/pick_context.dart';
import 'package:pantas/features/quiz/domain/picker/question_picker.dart';
import 'package:pantas/features/quiz/domain/use_cases/build_today_plan.dart';
import 'package:pantas/features/quiz/domain/use_cases/start_today_session.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/in_memory_database.dart';

class _TakingPicker implements QuestionPicker {
  const _TakingPicker();

  @override
  List<Question> pick(PickContext context) {
    return context.allQuestions.take(context.requestedLength).toList();
  }
}

class _EmptyPicker implements QuestionPicker {
  const _EmptyPicker();

  @override
  List<Question> pick(PickContext context) => const [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
      'per-topic start builds context for selected topic and stores '
      'today_topic origin', () async {
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
    );
    final content = ContentRepository(contentDb);
    final topic = (await content.topicsBySubject('subj_cse_verbal')).first;

    final result = await StartTodaySession(
      content: content,
      sessions: QuizSessionRepository(db),
      topicPicker: const _TakingPicker(),
      interleavedPicker: const _EmptyPicker(),
    )(
      userId: 'user',
      examId: 'exam_cse_pro',
      topicId: topic.id,
      preferences: QuizPreferences(
        sessionLength: 10,
        ordering: QuizOrdering.blocked,
        newCardCap: 10,
      ),
      now: DateTime.utc(2026, 5, 18),
    );

    final session = (result as StartTodaySessionStarted).session;
    expect(session.origin, SessionOrigin.todayTopic);
    expect(session.topicId, topic.id);
    expect(session.questions, isNotEmpty);
    expect(session.questions.length, lessThanOrEqualTo(10));
    expect(
      session.questions.every((question) => question.topicId == topic.id),
      isTrue,
    );

    final row = await QuizSessionRepository(db)
        .activeFor(userId: 'user', examId: 'exam_cse_pro');
    expect(row?.origin, SessionOrigin.todayTopic.storageValue);
    expect(row?.topicId, topic.id);
  });

  test('interleaved start stores today_interleaved origin', () async {
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
    );

    final result = await StartTodaySession(
      content: ContentRepository(contentDb),
      sessions: QuizSessionRepository(db),
      topicPicker: const _EmptyPicker(),
      interleavedPicker: const _TakingPicker(),
    )(
      userId: 'user',
      examId: 'exam_cse_pro',
      preferences: QuizPreferences(
        sessionLength: 5,
        ordering: QuizOrdering.interleavedTail,
        newCardCap: 10,
      ),
      now: DateTime.utc(2026, 5, 18),
    );

    final session = (result as StartTodaySessionStarted).session;
    expect(session.origin, SessionOrigin.todayInterleaved);
    expect(session.topicId, isNull);

    final row = await QuizSessionRepository(db)
        .activeFor(userId: 'user', examId: 'exam_cse_pro');
    expect(row?.origin, SessionOrigin.todayInterleaved.storageValue);
  });

  test('empty picker output returns a user-facing no questions failure',
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
    );

    final result = await StartTodaySession(
      content: ContentRepository(contentDb),
      sessions: QuizSessionRepository(db),
      topicPicker: const _EmptyPicker(),
      interleavedPicker: const _EmptyPicker(),
    )(
      userId: 'user',
      examId: 'exam_cse_pro',
      preferences: QuizPreferences.defaults,
      now: DateTime.utc(2026, 5, 18),
    );

    expect(result, isA<StartTodaySessionNoQuestions>());
    expect(
      (result as StartTodaySessionNoQuestions).message,
      'No questions are available for today.',
    );
    expect(
      await QuizSessionRepository(db).activeFor(
        userId: 'user',
        examId: 'exam_cse_pro',
      ),
      isNull,
    );
  });

  test('a supplied plan is the session that gets created', () async {
    final db = inMemoryDatabase();
    final contentDb = ContentDatabase(NativeDatabase.memory());
    addTearDown(contentDb.close);
    addTearDown(db.close);
    final content = ContentRepository(contentDb);
    final sessions = QuizSessionRepository(db);

    final plan = TodaySessionPlan(
      questions: [_question('q_only')],
      dueCount: 1,
      weaknessCount: 0,
      freshCount: 0,
      topicId: 'topic_algebra',
      topicName: 'Algebra',
    );

    final result = await StartTodaySession(
      content: content,
      sessions: sessions,
    )(
      userId: 'local',
      examId: 'exam_cse_pro',
      preferences: QuizPreferences.defaults,
      now: DateTime.utc(2026, 8, 2),
      plan: plan,
    );

    final session = (result as StartTodaySessionStarted).session;
    expect(session.questions.map((q) => q.id), equals(['q_only']));
  });

  test('an empty plan reports no questions', () async {
    final db = inMemoryDatabase();
    final contentDb = ContentDatabase(NativeDatabase.memory());
    addTearDown(contentDb.close);
    addTearDown(db.close);
    final content = ContentRepository(contentDb);
    final sessions = QuizSessionRepository(db);

    final result = await StartTodaySession(
      content: content,
      sessions: sessions,
    )(
      userId: 'local',
      examId: 'exam_cse_pro',
      preferences: QuizPreferences.defaults,
      now: DateTime.utc(2026, 8, 2),
      plan: TodaySessionPlan.empty,
    );

    expect(result, isA<StartTodaySessionNoQuestions>());
  });

  test('the named topic is recorded under the interleaved tail', () async {
    final db = inMemoryDatabase();
    final contentDb = ContentDatabase(NativeDatabase.memory());
    addTearDown(contentDb.close);
    addTearDown(db.close);
    final content = ContentRepository(contentDb);
    final sessions = QuizSessionRepository(db);

    final plan = TodaySessionPlan(
      questions: [_question('q_only')],
      dueCount: 1,
      weaknessCount: 0,
      freshCount: 0,
      topicId: 'topic_algebra',
      topicName: 'Algebra',
    );

    final result = await StartTodaySession(
      content: content,
      sessions: sessions,
    )(
      userId: 'local',
      examId: 'exam_cse_pro',
      preferences: QuizPreferences(
        sessionLength: 10,
        ordering: QuizOrdering.interleavedTail,
        newCardCap: 10,
      ),
      now: DateTime.utc(2026, 8, 2),
      plan: plan,
    );

    final session = (result as StartTodaySessionStarted).session;
    expect(session.topicId, 'topic_algebra');
  });
}

Question _question(String id) => Question(
      id: id,
      version: 1,
      examIds: const ['exam_cse_pro'],
      topicId: 'topic_algebra',
      language: 'en',
      stem: 'stem $id',
      choices: const [
        Choice(id: 'c_a', label: 'A', text: 'a', isCorrect: true),
        Choice(id: 'c_b', label: 'B', text: 'b', isCorrect: false),
      ],
      explanation: 'because',
    );
