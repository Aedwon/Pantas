import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/core/notifications/notification_service.dart';
import 'package:pantas/core/storage/data/repos/attempts_repository.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/domain/streak/streak_evaluator.dart';
import 'package:pantas/features/quiz/domain/use_cases/complete_quiz.dart';

class _MockAttempts extends Mock implements AttemptsRepository {}

class _MockStreakEvaluator extends Mock implements StreakEvaluator {}

class _MockNotificationService extends Mock implements NotificationService {}

class _FakeAttempt extends Fake implements Attempt {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeAttempt());
    registerFallbackValue(SessionOrigin.todayTopic);
  });

  late _MockAttempts attempts;
  late _MockStreakEvaluator streaks;
  late _MockNotificationService notifications;
  late CompleteQuiz useCase;

  setUp(() {
    attempts = _MockAttempts();
    streaks = _MockStreakEvaluator();
    notifications = _MockNotificationService();
    useCase = CompleteQuiz(
      attempts,
      streakEvaluator: streaks,
      notifications: notifications,
    );
    when(() => attempts.save(any())).thenAnswer((_) async {});
    when(
      () => streaks.evaluate(
        origin: any(named: 'origin'),
        completedAt: any(named: 'completedAt'),
      ),
    ).thenAnswer(
      (_) async => const StreakEvaluation(
        credited: true,
        freezeUsed: false,
        current: 1,
      ),
    );
    when(() => notifications.onSessionCompleted()).thenAnswer((_) async {});
  });

  const q1 = Question(
    id: 'q1',
    version: 1,
    examIds: ['e'],
    topicId: 't',
    language: 'en',
    stem: 's',
    choices: [
      Choice(id: 'c1a', label: 'A', text: 'x', isCorrect: true),
      Choice(id: 'c1b', label: 'B', text: 'y', isCorrect: false),
    ],
    explanation: 'e',
  );

  test('saves a completed Attempt with all outcomes and a completedAt',
      () async {
    final start = DateTime.utc(2026, 5, 9, 12);
    final end = DateTime.utc(2026, 5, 9, 12, 5);
    final session = QuizSession.start(
      sessionId: 'sess',
      examId: 'e',
      questions: const [q1],
      startedAt: start,
    ).record(
      const AnswerOutcome(
        questionId: 'q1',
        questionVersion: 1,
        chosenChoiceId: 'c1a',
        correctChoiceId: 'c1a',
        responseMs: 1500,
      ),
    );

    final attempt = await useCase(session: session, now: end);

    expect(attempt.id, equals('sess'));
    expect(attempt.examId, equals('e'));
    expect(attempt.origin, equals(SessionOrigin.todayTopic.storageValue));
    expect(attempt.startedAt, equals(start));
    expect(attempt.completedAt, equals(end));
    expect(attempt.items, hasLength(1));
    verify(() => attempts.save(attempt)).called(1);
    verify(
      () => streaks.evaluate(
        origin: SessionOrigin.todayTopic,
        completedAt: end,
      ),
    ).called(1);
    verify(() => notifications.onSessionCompleted()).called(1);
  });

  test('saves the session origin on the completed attempt', () async {
    final start = DateTime.utc(2026, 5, 9, 12);
    final end = DateTime.utc(2026, 5, 9, 12, 5);
    final session = QuizSession.start(
      sessionId: 'sess',
      examId: 'e',
      questions: const [q1],
      startedAt: start,
      origin: SessionOrigin.drill,
    ).record(
      const AnswerOutcome(
        questionId: 'q1',
        questionVersion: 1,
        chosenChoiceId: 'c1a',
        correctChoiceId: 'c1a',
        responseMs: 1500,
      ),
    );

    final attempt = await useCase(session: session, now: end);

    expect(attempt.origin, equals(SessionOrigin.drill.storageValue));
    verify(() => attempts.save(attempt)).called(1);
    verify(
      () => streaks.evaluate(
        origin: SessionOrigin.drill,
        completedAt: end,
      ),
    ).called(1);
  });

  test('throws StateError when session is incomplete', () async {
    final session = QuizSession.start(
      sessionId: 'sess',
      examId: 'e',
      questions: const [q1],
      startedAt: DateTime.utc(2026, 5, 9),
    );
    expect(
      () => useCase(
        session: session,
        now: DateTime.utc(2026, 5, 9, 0, 5),
      ),
      throwsStateError,
    );
  });
}
