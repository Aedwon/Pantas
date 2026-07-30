import 'package:pantas/core/fsrs/fsrs_scheduler.dart';
import 'package:pantas/core/fsrs/rating.dart';
import 'package:pantas/core/storage/data/repos/review_log_repository.dart';
import 'package:pantas/core/storage/data/repos/review_state_repository.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/domain/review_log.dart';
import 'package:pantas/core/storage/domain/review_state.dart';
import 'package:pantas/core/sync/engine/pending_queue.dart';
import 'package:pantas/features/quiz/data/repos/new_card_intro_repository.dart';
import 'package:pantas/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:pantas/features/quiz/domain/rating_heuristic.dart';
import 'package:pantas/features/quiz/domain/use_cases/submit_answer.dart';
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
  late _RecordingReviewLog reviewLog;
  late SubmitAnswer useCase;

  setUp(() {
    repo = _MockReviewRepo();
    sessions = _MockSessions();
    pendingQueue = _MockPendingQueue();
    newCards = _MockNewCards();
    reviewLog = _RecordingReviewLog();
    useCase = SubmitAnswer(
      reviewRepo: repo,
      scheduler: const FsrsScheduler(),
      sessions: sessions,
      pendingQueue: pendingQueue,
      newCards: newCards,
      reviewLog: reviewLog,
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
    expect(outcome.derivedRating.name, equals('good'));
    expect(outcome.nextReviewIntervalDays, greaterThanOrEqualTo(1));
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

  group('the review log', () {
    test('one answer appends exactly one row', () async {
      when(() => repo.byQuestionId(any())).thenAnswer((_) async => null);

      await useCase(
        question: question,
        chosenChoiceId: 'c_b',
        responseMs: 4000,
        now: DateTime.utc(2026, 8, 9, 10),
      );

      expect(reviewLog.rows, hasLength(1));
    });

    test('the stored rating is the rating the scheduler was given', () async {
      when(() => repo.byQuestionId(any())).thenAnswer((_) async => null);

      // A wrong answer is unambiguously Again. If the row disagrees with what
      // scheduled the card, the training data describes a review that never
      // happened that way, which is worse than having no row at all.
      await useCase(
        question: question,
        chosenChoiceId: 'c_a',
        responseMs: 4000,
        now: DateTime.utc(2026, 8, 9, 10),
      );

      expect(reviewLog.rows.single.rating, Rating.again);
      expect(reviewLog.rows.single.isCorrect, isFalse);
    });

    test('the row carries the state before the review, not after', () async {
      when(() => repo.byQuestionId(any())).thenAnswer((_) async => null);

      final now = DateTime.utc(2026, 8, 9, 10);
      await useCase(
        question: question,
        chosenChoiceId: 'c_b',
        responseMs: 4000,
        now: now,
      );

      final captured = verify(() => repo.upsert(captureAny())).captured.single
          as ReviewState;
      final row = reviewLog.rows.single;

      // The optimizer replays a fit from the state as it was, so a row holding
      // the post-review values would train against its own outcome.
      expect(row.stability, isNot(captured.stability));
      expect(row.review, now);
    });

    test('the row records which heuristic produced the rating', () async {
      when(() => repo.byQuestionId(any())).thenAnswer((_) async => null);

      await useCase(
        question: question,
        chosenChoiceId: 'c_b',
        responseMs: 4000,
        now: DateTime.utc(2026, 8, 9, 10),
      );

      expect(reviewLog.rows.single.heuristicVersion, kRatingHeuristicVersion);
    });
  });
}

class _RecordingReviewLog implements ReviewLogRepository {
  final List<ReviewLog> rows = [];

  @override
  Future<void> insert(ReviewLog log) async => rows.add(log);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
