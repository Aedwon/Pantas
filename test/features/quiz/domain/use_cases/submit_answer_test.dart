import 'package:cse_cet_reviewer/core/fsrs/fsrs_scheduler.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/review_state_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/choice.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/core/storage/domain/review_state.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/submit_answer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockReviewRepo extends Mock implements ReviewStateRepository {}

class _FakeReviewState extends Fake implements ReviewState {}

void main() {
  setUpAll(() => registerFallbackValue(_FakeReviewState()));

  late _MockReviewRepo repo;
  late SubmitAnswer useCase;

  setUp(() {
    repo = _MockReviewRepo();
    useCase = SubmitAnswer(reviewRepo: repo, scheduler: const FsrsScheduler());
    when(() => repo.byQuestionId(any())).thenAnswer((_) async => null);
    when(() => repo.upsert(any())).thenAnswer((_) async {});
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
