import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';
import 'package:pantas/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  test(
    'durable quiz completion publishes a session-panel refresh revision',
    () async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      const sessionId = 's_complete';
      const examId = 'exam_cse_pro';
      final startedAt = DateTime.utc(2026, 9, 11, 9);

      await QuizSessionRepository(db).create(
        sessionId: sessionId,
        userId: quizLocalUserId,
        examId: examId,
        origin: SessionOrigin.todayTopic,
        questionIds: const ['q1'],
        startedAt: startedAt,
      );

      const question = Question(
        id: 'q1',
        version: 1,
        examIds: [examId],
        topicId: 'topic_a',
        language: 'en',
        stem: 'Question',
        choices: [
          Choice(id: 'a', label: 'A', text: 'A', isCorrect: true),
          Choice(id: 'b', label: 'B', text: 'B', isCorrect: false),
        ],
        explanation: 'Because.',
      );
      const outcome = AnswerOutcome(
        questionId: 'q1',
        questionVersion: 1,
        chosenChoiceId: 'a',
        correctChoiceId: 'a',
        responseMs: 500,
      );
      final session = QuizSession(
        sessionId: sessionId,
        examId: examId,
        questions: const [question],
        currentIndex: 0,
        outcomes: const [outcome],
        startedAt: startedAt,
      );

      final before = container.read(quizSessionPanelRevisionProvider);

      await container.read(quizCompletionCoordinatorProvider).complete(
            session: session,
            now: DateTime.utc(2026, 9, 11, 9, 1),
            persisted: true,
          );

      final after = container.read(quizSessionPanelRevisionProvider);
      expect(after, before + 1);
      expect(
        await QuizSessionRepository(
          db,
        ).activeFor(userId: quizLocalUserId, examId: examId),
        isNull,
      );
    },
  );
}
