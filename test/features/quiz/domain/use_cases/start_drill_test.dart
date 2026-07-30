import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:pantas/features/quiz/domain/models/quiz_preferences.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/quiz/domain/picker/pick_context.dart';
import 'package:pantas/features/quiz/domain/picker/question_picker.dart';
import 'package:pantas/features/quiz/domain/use_cases/start_drill.dart';
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('start drill stores drill origin and subtopicId', () async {
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

    final result = await StartDrill(
      content: content,
      sessions: QuizSessionRepository(db),
      picker: const _TakingPicker(),
    )(
      userId: 'user',
      examId: 'exam_cse_pro',
      topicId: topic.id,
      subtopicId: 'subtopic_vocab_context',
      requestedLength: 5,
      now: DateTime.utc(2026, 5, 18),
    );

    final session = (result as StartDrillStarted).session;
    expect(session.origin, SessionOrigin.drill);
    expect(session.topicId, topic.id);
    expect(session.subtopicId, 'subtopic_vocab_context');

    final row = await QuizSessionRepository(db)
        .activeFor(userId: 'user', examId: 'exam_cse_pro');
    expect(row?.origin, SessionOrigin.drill.storageValue);
    expect(row?.subtopicId, 'subtopic_vocab_context');
  });

  test('start drill supports 5 10 20 and all available lengths', () async {
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

    for (final length in [5, 10, 20, QuizPreferences.allDueSessionLength]) {
      final result = await StartDrill(
        content: content,
        sessions: QuizSessionRepository(db),
        picker: const _TakingPicker(),
      )(
        userId: 'user-$length',
        examId: 'exam_cse_pro',
        topicId: topic.id,
        requestedLength: length,
        now: DateTime.utc(2026, 5, 18),
      );

      expect(result, isA<StartDrillStarted>());
      final session = (result as StartDrillStarted).session;
      expect(session.questions, isNotEmpty);
      if (length != QuizPreferences.allDueSessionLength) {
        expect(session.questions.length, lessThanOrEqualTo(length));
      }
    }
  });

  test('start drill falls back to General topic bucket when subtopicId is null',
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
    final content = ContentRepository(contentDb);
    final topic = (await content.topicsBySubject('subj_cse_verbal')).first;

    final result = await StartDrill(
      content: content,
      sessions: QuizSessionRepository(db),
    )(
      userId: 'user',
      examId: 'exam_cse_pro',
      topicId: topic.id,
      requestedLength: 5,
      now: DateTime.utc(2026, 5, 18),
    );

    final session = (result as StartDrillStarted).session;
    expect(session.origin, SessionOrigin.drill);
    expect(session.subtopicId, isNull);
    expect(session.questions, isNotEmpty);
  });
}
