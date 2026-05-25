import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/seeder.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/quiz_preferences.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/session_origin.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/pick_context.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/question_picker.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/start_today_session.dart';
import 'package:flutter/services.dart';
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
      'per-topic start builds context for selected topic and stores today_topic origin',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await Seeder(db, bundle: rootBundle).maybeSeed();
    final content = ContentRepository(db);
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
      preferences: QuizPreferences.defaults,
      now: DateTime.utc(2026, 5, 18),
    );

    final session = (result as StartTodaySessionStarted).session;
    expect(session.origin, SessionOrigin.todayTopic);
    expect(session.topicId, topic.id);
    expect(session.questions, isNotEmpty);
    expect(session.questions.length, lessThanOrEqualTo(10));
    expect(session.questions.every((question) => question.topicId == topic.id),
        isTrue);

    final row = await QuizSessionRepository(db)
        .activeFor(userId: 'user', examId: 'exam_cse_pro');
    expect(row?.origin, SessionOrigin.todayTopic.storageValue);
    expect(row?.topicId, topic.id);
  });

  test('interleaved start stores today_interleaved origin', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await Seeder(db, bundle: rootBundle).maybeSeed();

    final result = await StartTodaySession(
      content: ContentRepository(db),
      sessions: QuizSessionRepository(db),
      topicPicker: const _EmptyPicker(),
      interleavedPicker: const _TakingPicker(),
    )(
      userId: 'user',
      examId: 'exam_cse_pro',
      preferences: QuizPreferences(
        sessionLength: 5,
        interleavedToday: true,
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
    addTearDown(db.close);
    await Seeder(db, bundle: rootBundle).maybeSeed();

    final result = await StartTodaySession(
      content: ContentRepository(db),
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
    expect((result as StartTodaySessionNoQuestions).message,
        'No questions are available for today.');
    expect(
      await QuizSessionRepository(db).activeFor(
        userId: 'user',
        examId: 'exam_cse_pro',
      ),
      isNull,
    );
  });
}
