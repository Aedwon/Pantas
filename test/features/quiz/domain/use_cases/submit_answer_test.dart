import 'package:cse_cet_reviewer/core/fsrs/fsrs_scheduler.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/review_state_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/choice.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/core/storage/domain/review_state.dart';
import 'package:cse_cet_reviewer/core/sync/engine/pending_queue.dart';
import 'package:cse_cet_reviewer/features/quiz/data/repos/new_card_intro_repository.dart';
import 'package:cse_cet_reviewer/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/submit_answer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockReviewRepo extends Mock implements ReviewStateRepository {}

class _MockSessions extends Mock implements QuizSessionRepository {}

class _MockPendingQueue extends Mock implements PendingQueue {}

class _MockNewCards extends Mock implements NewCardIntroRepository {}

class _FakeReviewState extends Fake implements ReviewState {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeReviewState());
    registerFallbackValue(PendingSyncOp.upsert);
  });

  late _MockReviewRepo repo;
  late _MockSessions sessions;
  late _MockPendingQueue pendingQueue;
  late _MockNewCards newCards;
  late SubmitAnswer useCase;

  setUp(() {
    repo = _MockReviewRepo();
    sessions = _MockSessions();
    pendingQueue = _MockPendingQueue();
    newCards = _MockNewCards();
    useCase = SubmitAnswer(
      reviewRepo: repo,
      scheduler: const FsrsScheduler(),
      sessions: sessions,
      pendingQueue: pendingQueue,
      newCards: newCards,
    );
    when(() => repo.byQuestionId(any())).thenAnswer((_) async => null);
    when(() => repo.upsert(any())).thenAnswer((_) async {});
    when(
      () => sessions.recordAnswer(
        sessionId: any(named: 'sessionId'),
        isCorrect: any(named: 'isCorrect'),
        answeredAt: any(named: 'answeredAt'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => pendingQueue.enqueue(
        tableType: any(named: 'tableType'),
        rowId: any(named: 'rowId'),
        op: any(named: 'op'),
        queuedAt: any(named: 'queuedAt'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => newCards.incrementForDay(
        userId: any(named: 'userId'),
        examId: any(named: 'examId'),
        day: any(named: 'day'),
        by: any(named: 'by'),
      ),
    ).thenAnswer((_) async {});
  });

  const question = Question(
    id: 'q1',
    version: 1,
    examIds: ['e'],
    topicId: 't',
    language: 'en',
    stem: 's',
    choices: [
      Choice(id: 'c_a', label: 'A', text: 'x', isCorrect: false),
      Choice(id: 'c_b', label: 'B', text: 'y', isCorrect: true),
    ],
    explanation: 'e',
  );

  test('correct answer → outcome.isCorrect=true and ReviewState upserted',
      () async {
    final outcome = await useCase(
      question: question,
      chosenChoiceId: 'c_b',
      responseMs: 1800,
      now: DateTime.utc(2026, 5, 9),
    );
    expect(outcome.isCorrect, isTrue);
    expect(outcome.correctChoiceId, equals('c_b'));
    verify(() => repo.upsert(any())).called(1);
  });

  test(
      'records session progress enqueues fsrs sync and counts first seen cards',
      () async {
    await useCase(
      question: question,
      chosenChoiceId: 'c_b',
      responseMs: 1800,
      now: DateTime.utc(2026, 5, 9),
      sessionId: 'session',
      userId: 'user',
      examId: 'exam',
    );

    verify(
      () => sessions.recordAnswer(
        sessionId: 'session',
        isCorrect: true,
        answeredAt: DateTime.utc(2026, 5, 9),
      ),
    ).called(1);
    verify(
      () => pendingQueue.enqueue(
        tableType: 'fsrs_cards',
        rowId: 'q1',
        op: PendingSyncOp.upsert,
        queuedAt: DateTime.utc(2026, 5, 9),
      ),
    ).called(1);
    verify(
      () => newCards.incrementForDay(
        userId: 'user',
        examId: 'exam',
        day: DateTime.utc(2026, 5, 9),
      ),
    ).called(1);
  });

  test('does not increment new-card counter for existing review state',
      () async {
    when(() => repo.byQuestionId(any())).thenAnswer(
      (_) async => ReviewState.seed(
        questionId: 'q1',
        questionVersion: 1,
        now: DateTime.utc(2026, 5),
      ),
    );

    await useCase(
      question: question,
      chosenChoiceId: 'c_b',
      responseMs: 1800,
      now: DateTime.utc(2026, 5, 9),
      sessionId: 'session',
      userId: 'user',
      examId: 'exam',
    );

    verifyNever(
      () => newCards.incrementForDay(
        userId: any(named: 'userId'),
        examId: any(named: 'examId'),
        day: any(named: 'day'),
        by: any(named: 'by'),
      ),
    );
  });

  test('seeds a new ReviewState if none exists', () async {
    await useCase(
      question: question,
      chosenChoiceId: 'c_a',
      responseMs: 9000,
      now: DateTime.utc(2026, 5, 9),
    );
    verify(() => repo.byQuestionId('q1')).called(1);
    verify(() => repo.upsert(any(that: isA<ReviewState>()))).called(1);
  });
}
