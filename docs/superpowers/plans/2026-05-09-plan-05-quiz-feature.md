# Quiz Feature Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the **Quick Quiz** end-to-end loop — user picks an exam, answers a fixed-length sequence of questions one at a time, sees results — wiring `core/storage/` (Plans 03), `core/fsrs/` (Plan 04), `core/ui/` components (Plan 02), and `go_router` shell routes (Plan 02) into a single user-facing flow.

**Architecture:** Three layers under `features/quiz/` per the spec's lint-enforced layering:
- `domain/` — pure-Dart `QuizSession` model, three use cases (`StartQuickQuiz`, `SubmitAnswer`, `CompleteQuiz`), and a `RatingHeuristic` that maps `(isCorrect, responseMs)` → `Rating`.
- `presentation/` — `QuizController` (Riverpod `AsyncNotifier`), `QuizPage` (one-question-at-a-time stepper), `QuizResultsPage` (score + per-question list).
- No `data/` directory — repositories live in `core/storage/`.

The session is held in memory by the controller. Each answer triggers an *optimistic* FSRS update written through `ReviewStateRepository.upsert(...)` immediately, and a single `Attempt` is flushed via `AttemptsRepository.save(...)` on completion.

**Scope (Quick Quiz only):** Drill-by-topic and Retake-Mistakes are explicitly deferred to a follow-up plan because both require additional repository surfaces (Drill needs `topicId` filtering already covered, but its UX needs a dedicated picker; Retake-Mistakes needs an attempt-history query that is cleaner to add once we have telemetry on real attempt volumes).

**Tech Stack:** Flutter 3.41 / Dart 3.11 · `flutter_riverpod ^2.5.1` · `go_router ^14` · `freezed ^2.5.7` · `mocktail ^1.0.4` for use-case tests.

---

## File Map

**New files:**
```
lib/features/quiz/quiz.dart                                       Barrel (providers + entry routes)
lib/features/quiz/domain/quiz_session.dart                        QuizSession + AnswerOutcome (Freezed)
lib/features/quiz/domain/rating_heuristic.dart                    (isCorrect, responseMs) → Rating
lib/features/quiz/domain/use_cases/start_quick_quiz.dart
lib/features/quiz/domain/use_cases/submit_answer.dart
lib/features/quiz/domain/use_cases/complete_quiz.dart
lib/features/quiz/presentation/quiz_controller.dart
lib/features/quiz/presentation/quiz_page.dart
lib/features/quiz/presentation/quiz_results_page.dart
lib/features/quiz/presentation/widgets/question_card.dart
lib/features/quiz/presentation/widgets/quiz_progress_bar.dart

test/features/quiz/domain/rating_heuristic_test.dart
test/features/quiz/domain/quiz_session_test.dart
test/features/quiz/domain/use_cases/start_quick_quiz_test.dart
test/features/quiz/domain/use_cases/submit_answer_test.dart
test/features/quiz/domain/use_cases/complete_quiz_test.dart
test/features/quiz/presentation/quiz_controller_test.dart
test/features/quiz/presentation/quiz_page_test.dart
test/features/quiz/presentation/quiz_results_page_test.dart
test/features/quiz/integration_test.dart                          End-to-end with seeded in-memory DB
```

**Modified files:**
```
lib/app/router.dart                                               Add /quiz/quick and /quiz/results/:attemptId branches
lib/features/shell/presentation/app_shell.dart                    "Start Quick Quiz" CTA on the Quiz tab body
```

---

## Conventions

- Use cases are classes with a single `call(...)` method to stay mockable via Mocktail.
- Riverpod providers are exported from `lib/features/quiz/quiz.dart` so other features import a single barrel.
- Widget tests use the existing `pumpApp` helper from Plan 02. Add a Riverpod `ProviderScope` wrapper in those tests; an extension to `pumpApp` may be required (Task 8).
- Commit messages: `feat(quiz):`, `test(quiz):`. No Claude/Anthropic/AI mentions.
- No new top-level dependencies are needed — everything is already in `pubspec.yaml`.

---

## Task 1: RatingHeuristic — response-time → Rating mapping

**Files:**
- Create: `lib/features/quiz/domain/rating_heuristic.dart`
- Create: `test/features/quiz/domain/rating_heuristic_test.dart`

The mapping is intentionally simple at v1; the spec calls for tuning post-launch with real data:

| Outcome             | Bucket               | Rating |
|---------------------|----------------------|--------|
| incorrect           | any                  | Again  |
| correct, slow       | responseMs > 8000    | Hard   |
| correct, normal     | 2500 ≤ ms ≤ 8000     | Good   |
| correct, fast       | responseMs < 2500    | Easy   |

- [ ] **Step 1: Write the failing test**

```dart
// test/features/quiz/domain/rating_heuristic_test.dart
import 'package:cse_cet_reviewer/core/fsrs/rating.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/rating_heuristic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('incorrect always → Again', () {
    expect(RatingHeuristic.from(isCorrect: false, responseMs: 1000), equals(Rating.again));
    expect(RatingHeuristic.from(isCorrect: false, responseMs: 99999), equals(Rating.again));
  });

  test('correct + fast (<2500ms) → Easy', () {
    expect(RatingHeuristic.from(isCorrect: true, responseMs: 1200), equals(Rating.easy));
    expect(RatingHeuristic.from(isCorrect: true, responseMs: 2499), equals(Rating.easy));
  });

  test('correct + normal (2500..8000ms) → Good', () {
    expect(RatingHeuristic.from(isCorrect: true, responseMs: 2500), equals(Rating.good));
    expect(RatingHeuristic.from(isCorrect: true, responseMs: 5000), equals(Rating.good));
    expect(RatingHeuristic.from(isCorrect: true, responseMs: 8000), equals(Rating.good));
  });

  test('correct + slow (>8000ms) → Hard', () {
    expect(RatingHeuristic.from(isCorrect: true, responseMs: 8001), equals(Rating.hard));
    expect(RatingHeuristic.from(isCorrect: true, responseMs: 25000), equals(Rating.hard));
  });
}
```

- [ ] **Step 2: Implement**

```dart
// lib/features/quiz/domain/rating_heuristic.dart
import 'package:cse_cet_reviewer/core/fsrs/rating.dart';

abstract final class RatingHeuristic {
  static const _fastThresholdMs = 2500;
  static const _slowThresholdMs = 8000;

  static Rating from({required bool isCorrect, required int responseMs}) {
    if (!isCorrect) return Rating.again;
    if (responseMs < _fastThresholdMs) return Rating.easy;
    if (responseMs > _slowThresholdMs) return Rating.hard;
    return Rating.good;
  }
}
```

- [ ] **Step 3: Run + commit**

```bash
flutter test test/features/quiz/domain/rating_heuristic_test.dart
git add lib/features/quiz/domain/rating_heuristic.dart \
        test/features/quiz/domain/rating_heuristic_test.dart
git commit -m "feat(quiz): add RatingHeuristic mapping outcome+time → FSRS rating"
```

---

## Task 2: QuizSession domain model

**Files:**
- Create: `lib/features/quiz/domain/quiz_session.dart`
- Create: `test/features/quiz/domain/quiz_session_test.dart`

`QuizSession` is the controller's source of truth during a live quiz. It holds the question list, the current index, and the answers so far. `AnswerOutcome` is the per-question record.

- [ ] **Step 1: Write the failing test**

```dart
// test/features/quiz/domain/quiz_session_test.dart
import 'package:cse_cet_reviewer/core/storage/domain/choice.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/quiz_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const q1 = Question(
    id: 'q1', version: 1, examIds: ['e'], topicId: 't', language: 'en',
    stem: 's1',
    choices: [
      Choice(id: 'c1a', label: 'A', text: 'x', isCorrect: true),
      Choice(id: 'c1b', label: 'B', text: 'y', isCorrect: false),
    ],
    explanation: 'e1',
  );
  const q2 = Question(
    id: 'q2', version: 1, examIds: ['e'], topicId: 't', language: 'en',
    stem: 's2',
    choices: [
      Choice(id: 'c2a', label: 'A', text: 'x', isCorrect: false),
      Choice(id: 'c2b', label: 'B', text: 'y', isCorrect: true),
    ],
    explanation: 'e2',
  );

  test('start() creates a session at index 0 with no outcomes', () {
    final s = QuizSession.start(
      sessionId: 'sess', examId: 'e', questions: [q1, q2], startedAt: DateTime.utc(2026),
    );
    expect(s.currentIndex, equals(0));
    expect(s.outcomes, isEmpty);
    expect(s.isComplete, isFalse);
    expect(s.currentQuestion, equals(q1));
  });

  test('record() advances index and stores outcome', () {
    final s = QuizSession.start(
      sessionId: 'sess', examId: 'e', questions: [q1, q2], startedAt: DateTime.utc(2026),
    );
    final s2 = s.record(const AnswerOutcome(
      questionId: 'q1', questionVersion: 1, chosenChoiceId: 'c1a', correctChoiceId: 'c1a', responseMs: 1500,
    ));
    expect(s2.currentIndex, equals(1));
    expect(s2.outcomes, hasLength(1));
    expect(s2.currentQuestion, equals(q2));
    expect(s2.isComplete, isFalse);
  });

  test('isComplete after every question answered', () {
    var s = QuizSession.start(
      sessionId: 'sess', examId: 'e', questions: [q1, q2], startedAt: DateTime.utc(2026),
    );
    s = s.record(const AnswerOutcome(
      questionId: 'q1', questionVersion: 1, chosenChoiceId: 'c1a', correctChoiceId: 'c1a', responseMs: 1500,
    ));
    s = s.record(const AnswerOutcome(
      questionId: 'q2', questionVersion: 1, chosenChoiceId: 'c2a', correctChoiceId: 'c2b', responseMs: 4200,
    ));
    expect(s.isComplete, isTrue);
    expect(s.score, equals((1, 2)));
  });
}
```

- [ ] **Step 2: Implement**

```dart
// lib/features/quiz/domain/quiz_session.dart
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'quiz_session.freezed.dart';

@freezed
class AnswerOutcome with _$AnswerOutcome {
  const AnswerOutcome._();

  const factory AnswerOutcome({
    required QuestionId questionId,
    required int questionVersion,
    required ChoiceId chosenChoiceId,
    required ChoiceId correctChoiceId,
    required int responseMs,
  }) = _AnswerOutcome;

  bool get isCorrect => chosenChoiceId == correctChoiceId;
}

@freezed
class QuizSession with _$QuizSession {
  const QuizSession._();

  const factory QuizSession({
    required String sessionId,
    required ExamId examId,
    required List<Question> questions,
    required int currentIndex,
    required List<AnswerOutcome> outcomes,
    required DateTime startedAt,
  }) = _QuizSession;

  factory QuizSession.start({
    required String sessionId,
    required ExamId examId,
    required List<Question> questions,
    required DateTime startedAt,
  }) =>
      QuizSession(
        sessionId: sessionId,
        examId: examId,
        questions: questions,
        currentIndex: 0,
        outcomes: const [],
        startedAt: startedAt,
      );

  Question get currentQuestion => questions[currentIndex];

  bool get isComplete => outcomes.length == questions.length;

  /// Returns `(correct, total)`.
  (int correct, int total) get score {
    final correct = outcomes.where((o) => o.isCorrect).length;
    return (correct, outcomes.length);
  }

  QuizSession record(AnswerOutcome o) => copyWith(
        outcomes: [...outcomes, o],
        currentIndex: currentIndex + 1,
      );
}
```

- [ ] **Step 3: Run codegen + tests**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/quiz/domain/quiz_session_test.dart
```

Expected: 3/3 PASS.

- [ ] **Step 4: Commit**

```bash
git add lib/features/quiz/domain/quiz_session.* \
        test/features/quiz/domain/quiz_session_test.dart
git commit -m "feat(quiz): add QuizSession + AnswerOutcome domain models"
```

---

## Task 3: StartQuickQuiz use case

**Files:**
- Create: `lib/features/quiz/domain/use_cases/start_quick_quiz.dart`
- Create: `test/features/quiz/domain/use_cases/start_quick_quiz_test.dart`

Pulls candidate questions for the chosen exam from `ContentRepository`, shuffles them with a deterministic seed (so tests are stable), takes `count` (default 10), and produces a `QuizSession`.

- [ ] **Step 1: Write the failing test**

```dart
// test/features/quiz/domain/use_cases/start_quick_quiz_test.dart
import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/choice.dart';
import 'package:cse_cet_reviewer/core/storage/domain/exam.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/core/storage/domain/subject.dart';
import 'package:cse_cet_reviewer/core/storage/domain/topic.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/start_quick_quiz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockContent extends Mock implements ContentRepository {}

void main() {
  late _MockContent content;
  late StartQuickQuiz useCase;

  setUp(() {
    content = _MockContent();
    useCase = StartQuickQuiz(content);
  });

  Question makeQ(String id, String topicId) => Question(
        id: id, version: 1, examIds: const ['e1'], topicId: topicId, language: 'en',
        stem: 'stem $id',
        choices: const [
          Choice(id: 'a', label: 'A', text: 'x', isCorrect: true),
          Choice(id: 'b', label: 'B', text: 'y', isCorrect: false),
        ],
        explanation: 'why',
      );

  test('returns a session of `count` questions for the requested exam', () async {
    const exam = Exam(
      id: 'e1', code: 'E1', name: 'E1', shortName: 'E1', language: 'en', isActive: true,
      subjects: [Subject(id: 's1', examId: 'e1', name: 'S1', ordering: 1)],
    );
    final topics = [const Topic(id: 't1', subjectId: 's1', name: 'T1', ordering: 1)];
    final questions = [makeQ('q1', 't1'), makeQ('q2', 't1'), makeQ('q3', 't1')];

    when(() => content.listExams()).thenAnswer((_) async => [exam]);
    when(() => content.topicsBySubject('s1')).thenAnswer((_) async => topics);
    when(() => content.questionsByTopic('t1')).thenAnswer((_) async => questions);

    final session = await useCase(
      examId: 'e1',
      count: 2,
      now: DateTime.utc(2026, 5, 9),
      randomSeed: 42,
    );

    expect(session.questions, hasLength(2));
    expect(session.examId, equals('e1'));
    expect(session.currentIndex, equals(0));
  });

  test('throws StateError when no questions are available', () async {
    when(() => content.listExams()).thenAnswer((_) async => const []);
    expect(
      () => useCase(examId: 'e1', count: 10, now: DateTime.utc(2026, 5, 9), randomSeed: 1),
      throwsStateError,
    );
  });
}
```

- [ ] **Step 2: Implement**

```dart
// lib/features/quiz/domain/use_cases/start_quick_quiz.dart
import 'dart:math';

import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/quiz_session.dart';
import 'package:uuid/uuid.dart';

class StartQuickQuiz {
  StartQuickQuiz(this._content, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final ContentRepository _content;
  final Uuid _uuid;

  Future<QuizSession> call({
    required ExamId examId,
    required int count,
    required DateTime now,
    int? randomSeed,
  }) async {
    final exams = await _content.listExams();
    final exam = exams.firstWhere(
      (e) => e.id == examId,
      orElse: () => throw StateError('Exam not found: $examId'),
    );

    final allQuestions = <Question>[];
    for (final subject in exam.subjects) {
      final topics = await _content.topicsBySubject(subject.id);
      for (final topic in topics) {
        allQuestions.addAll(await _content.questionsByTopic(topic.id));
      }
    }
    if (allQuestions.isEmpty) {
      throw StateError('No questions available for exam $examId');
    }

    final rng = Random(randomSeed);
    final shuffled = [...allQuestions]..shuffle(rng);
    final picked = shuffled.take(count).toList(growable: false);

    return QuizSession.start(
      sessionId: _uuid.v4(),
      examId: examId,
      questions: picked,
      startedAt: now,
    );
  }
}
```

- [ ] **Step 3: Run + commit**

```bash
flutter test test/features/quiz/domain/use_cases/start_quick_quiz_test.dart
git add lib/features/quiz/domain/use_cases/start_quick_quiz.dart \
        test/features/quiz/domain/use_cases/start_quick_quiz_test.dart
git commit -m "feat(quiz): add StartQuickQuiz use case"
```

---

## Task 4: SubmitAnswer use case

**Files:**
- Create: `lib/features/quiz/domain/use_cases/submit_answer.dart`
- Create: `test/features/quiz/domain/use_cases/submit_answer_test.dart`

`SubmitAnswer` does NOT mutate the session — that's the controller's job. It only:
1. Computes the `Rating` via `RatingHeuristic`.
2. Reads the existing `ReviewState` (or seeds one).
3. Calls `FsrsScheduler.next(...)`.
4. Persists the new `ReviewState` via `ReviewStateRepository.upsert(...)`.
5. Returns the resulting `AnswerOutcome` so the controller can append it to the session.

- [ ] **Step 1: Write the failing test**

```dart
// test/features/quiz/domain/use_cases/submit_answer_test.dart
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
    id: 'q1', version: 1, examIds: ['e'], topicId: 't', language: 'en',
    stem: 's',
    choices: [
      Choice(id: 'c_a', label: 'A', text: 'x', isCorrect: false),
      Choice(id: 'c_b', label: 'B', text: 'y', isCorrect: true),
    ],
    explanation: 'e',
  );

  test('correct answer → outcome.isCorrect=true and ReviewState upserted', () async {
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
```

- [ ] **Step 2: Implement**

```dart
// lib/features/quiz/domain/use_cases/submit_answer.dart
import 'package:cse_cet_reviewer/core/fsrs/fsrs_scheduler.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/review_state_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/core/storage/domain/review_state.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/quiz_session.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/rating_heuristic.dart';

class SubmitAnswer {
  SubmitAnswer({
    required ReviewStateRepository reviewRepo,
    required FsrsScheduler scheduler,
  })  : _reviewRepo = reviewRepo,
        _scheduler = scheduler;

  final ReviewStateRepository _reviewRepo;
  final FsrsScheduler _scheduler;

  Future<AnswerOutcome> call({
    required Question question,
    required String chosenChoiceId,
    required int responseMs,
    required DateTime now,
  }) async {
    final correctId = question.correctChoice.id;
    final isCorrect = chosenChoiceId == correctId;

    final prev = await _reviewRepo.byQuestionId(question.id) ??
        ReviewState.seed(
          questionId: question.id,
          questionVersion: question.version,
          now: now,
        );

    final rating = RatingHeuristic.from(isCorrect: isCorrect, responseMs: responseMs);
    final next = _scheduler.next(prev: prev, rating: rating, now: now);
    await _reviewRepo.upsert(next);

    return AnswerOutcome(
      questionId: question.id,
      questionVersion: question.version,
      chosenChoiceId: chosenChoiceId,
      correctChoiceId: correctId,
      responseMs: responseMs,
    );
  }
}
```

- [ ] **Step 3: Run + commit**

```bash
flutter test test/features/quiz/domain/use_cases/submit_answer_test.dart
git add lib/features/quiz/domain/use_cases/submit_answer.dart \
        test/features/quiz/domain/use_cases/submit_answer_test.dart
git commit -m "feat(quiz): add SubmitAnswer use case (rating → FSRS upsert)"
```

---

## Task 5: CompleteQuiz use case

**Files:**
- Create: `lib/features/quiz/domain/use_cases/complete_quiz.dart`
- Create: `test/features/quiz/domain/use_cases/complete_quiz_test.dart`

Persists the finished `QuizSession` as an `Attempt` via `AttemptsRepository`.

- [ ] **Step 1: Write the failing test**

```dart
// test/features/quiz/domain/use_cases/complete_quiz_test.dart
import 'package:cse_cet_reviewer/core/storage/data/repos/attempts_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/attempt.dart';
import 'package:cse_cet_reviewer/core/storage/domain/choice.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/quiz_session.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/complete_quiz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAttempts extends Mock implements AttemptsRepository {}

class _FakeAttempt extends Fake implements Attempt {}

void main() {
  setUpAll(() => registerFallbackValue(_FakeAttempt()));

  late _MockAttempts attempts;
  late CompleteQuiz useCase;

  setUp(() {
    attempts = _MockAttempts();
    useCase = CompleteQuiz(attempts);
    when(() => attempts.save(any())).thenAnswer((_) async {});
  });

  const q1 = Question(
    id: 'q1', version: 1, examIds: ['e'], topicId: 't', language: 'en', stem: 's',
    choices: [
      Choice(id: 'c1a', label: 'A', text: 'x', isCorrect: true),
      Choice(id: 'c1b', label: 'B', text: 'y', isCorrect: false),
    ],
    explanation: 'e',
  );

  test('saves a completed Attempt with all outcomes and a completedAt', () async {
    final start = DateTime.utc(2026, 5, 9, 12);
    final end = DateTime.utc(2026, 5, 9, 12, 5);
    final session = QuizSession.start(
      sessionId: 'sess',
      examId: 'e',
      questions: const [q1],
      startedAt: start,
    ).record(const AnswerOutcome(
      questionId: 'q1', questionVersion: 1, chosenChoiceId: 'c1a', correctChoiceId: 'c1a', responseMs: 1500,
    ));

    final attempt = await useCase(session: session, now: end);

    expect(attempt.id, equals('sess'));
    expect(attempt.examId, equals('e'));
    expect(attempt.startedAt, equals(start));
    expect(attempt.completedAt, equals(end));
    expect(attempt.items, hasLength(1));
    verify(() => attempts.save(attempt)).called(1);
  });

  test('throws StateError when session is incomplete', () async {
    final session = QuizSession.start(
      sessionId: 'sess', examId: 'e', questions: const [q1], startedAt: DateTime.utc(2026, 5, 9),
    );
    expect(
      () => useCase(session: session, now: DateTime.utc(2026, 5, 9, 0, 5)),
      throwsStateError,
    );
  });
}
```

- [ ] **Step 2: Implement**

```dart
// lib/features/quiz/domain/use_cases/complete_quiz.dart
import 'package:cse_cet_reviewer/core/storage/data/repos/attempts_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/attempt.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/quiz_session.dart';

class CompleteQuiz {
  CompleteQuiz(this._attempts);

  final AttemptsRepository _attempts;

  Future<Attempt> call({
    required QuizSession session,
    required DateTime now,
  }) async {
    if (!session.isComplete) {
      throw StateError('Cannot complete a quiz with unanswered questions');
    }
    final attempt = Attempt(
      id: session.sessionId,
      examId: session.examId,
      startedAt: session.startedAt,
      completedAt: now,
      items: session.outcomes
          .map((o) => AttemptItem(
                questionId: o.questionId,
                questionVersion: o.questionVersion,
                chosenChoiceId: o.chosenChoiceId,
                correctChoiceId: o.correctChoiceId,
                responseMs: o.responseMs,
              ))
          .toList(),
    );
    await _attempts.save(attempt);
    return attempt;
  }
}
```

- [ ] **Step 3: Run + commit**

```bash
flutter test test/features/quiz/domain/use_cases/complete_quiz_test.dart
git add lib/features/quiz/domain/use_cases/complete_quiz.dart \
        test/features/quiz/domain/use_cases/complete_quiz_test.dart
git commit -m "feat(quiz): add CompleteQuiz use case (session → Attempt)"
```

---

## Task 6: QuizController (Riverpod AsyncNotifier)

**Files:**
- Create: `lib/features/quiz/presentation/quiz_controller.dart`
- Create: `test/features/quiz/presentation/quiz_controller_test.dart`

The controller orchestrates the three use cases and exposes a `QuizControllerState` (idle / loading / running / complete / error). It tracks per-question start times so the view doesn't have to.

- [ ] **Step 1: Write the failing test**

```dart
// test/features/quiz/presentation/quiz_controller_test.dart
import 'package:cse_cet_reviewer/core/storage/domain/attempt.dart';
import 'package:cse_cet_reviewer/core/storage/domain/choice.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/quiz_session.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/complete_quiz.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/start_quick_quiz.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/submit_answer.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockStart extends Mock implements StartQuickQuiz {}

class _MockSubmit extends Mock implements SubmitAnswer {}

class _MockComplete extends Mock implements CompleteQuiz {}

class _FakeQuestion extends Fake implements Question {}

void main() {
  setUpAll(() => registerFallbackValue(_FakeQuestion()));

  const q1 = Question(
    id: 'q1', version: 1, examIds: ['e'], topicId: 't', language: 'en', stem: 's1',
    choices: [
      Choice(id: 'c1a', label: 'A', text: 'x', isCorrect: true),
      Choice(id: 'c1b', label: 'B', text: 'y', isCorrect: false),
    ],
    explanation: 'e',
  );

  late _MockStart start;
  late _MockSubmit submit;
  late _MockComplete complete;

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        startQuickQuizProvider.overrideWithValue(start),
        submitAnswerProvider.overrideWithValue(submit),
        completeQuizProvider.overrideWithValue(complete),
        nowProvider.overrideWithValue(() => DateTime.utc(2026, 5, 9, 12)),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    start = _MockStart();
    submit = _MockSubmit();
    complete = _MockComplete();
  });

  test('start() loads questions and transitions to running', () async {
    final session = QuizSession.start(
      sessionId: 'sess', examId: 'e', questions: const [q1], startedAt: DateTime.utc(2026, 5, 9, 12),
    );
    when(() => start(
          examId: any(named: 'examId'),
          count: any(named: 'count'),
          now: any(named: 'now'),
          randomSeed: any(named: 'randomSeed'),
        )).thenAnswer((_) async => session);

    final container = makeContainer();
    final notifier = container.read(quizControllerProvider.notifier);
    await notifier.start(examId: 'e', count: 1);

    final state = container.read(quizControllerProvider);
    expect(state, isA<QuizRunning>());
    expect((state as QuizRunning).session.questions, hasLength(1));
  });

  test('answer() advances the session and persists via SubmitAnswer', () async {
    final session = QuizSession.start(
      sessionId: 'sess', examId: 'e', questions: const [q1], startedAt: DateTime.utc(2026, 5, 9, 12),
    );
    when(() => start(
          examId: any(named: 'examId'),
          count: any(named: 'count'),
          now: any(named: 'now'),
          randomSeed: any(named: 'randomSeed'),
        )).thenAnswer((_) async => session);
    when(() => submit(
          question: any(named: 'question'),
          chosenChoiceId: any(named: 'chosenChoiceId'),
          responseMs: any(named: 'responseMs'),
          now: any(named: 'now'),
        )).thenAnswer((_) async => const AnswerOutcome(
              questionId: 'q1', questionVersion: 1, chosenChoiceId: 'c1a', correctChoiceId: 'c1a', responseMs: 1500,
            ));
    when(() => complete(session: any(named: 'session'), now: any(named: 'now')))
        .thenAnswer((_) async => Attempt(
              id: 'sess', examId: 'e', startedAt: DateTime.utc(2026, 5, 9, 12),
              completedAt: DateTime.utc(2026, 5, 9, 12, 1), items: const [],
            ));

    final container = makeContainer();
    final notifier = container.read(quizControllerProvider.notifier);
    await notifier.start(examId: 'e', count: 1);
    await notifier.answer(chosenChoiceId: 'c1a');

    final state = container.read(quizControllerProvider);
    expect(state, isA<QuizComplete>());
  });
}
```

- [ ] **Step 2: Implement**

```dart
// lib/features/quiz/presentation/quiz_controller.dart
import 'package:cse_cet_reviewer/core/fsrs/fsrs_scheduler.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/attempts_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/review_state_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/attempt.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/quiz_session.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/complete_quiz.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/start_quick_quiz.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/submit_answer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

sealed class QuizControllerState {
  const QuizControllerState();
}

class QuizIdle extends QuizControllerState {
  const QuizIdle();
}

class QuizLoading extends QuizControllerState {
  const QuizLoading();
}

class QuizRunning extends QuizControllerState {
  const QuizRunning({required this.session, required this.questionShownAt});
  final QuizSession session;
  final DateTime questionShownAt;
}

class QuizComplete extends QuizControllerState {
  const QuizComplete(this.attempt);
  final Attempt attempt;
}

class QuizFailure extends QuizControllerState {
  const QuizFailure(this.message);
  final String message;
}

final nowProvider = Provider<DateTime Function()>((_) => DateTime.now);

final fsrsSchedulerProvider = Provider<FsrsScheduler>((_) => const FsrsScheduler());

final startQuickQuizProvider = Provider<StartQuickQuiz>(
  (ref) => StartQuickQuiz(ref.watch(contentRepositoryProvider)),
);

final submitAnswerProvider = Provider<SubmitAnswer>(
  (ref) => SubmitAnswer(
    reviewRepo: ref.watch(reviewStateRepositoryProvider),
    scheduler: ref.watch(fsrsSchedulerProvider),
  ),
);

final completeQuizProvider = Provider<CompleteQuiz>(
  (ref) => CompleteQuiz(ref.watch(attemptsRepositoryProvider)),
);

final quizControllerProvider =
    StateNotifierProvider<QuizController, QuizControllerState>((ref) => QuizController(ref));

class QuizController extends StateNotifier<QuizControllerState> {
  QuizController(this._ref) : super(const QuizIdle());

  final Ref _ref;

  Future<void> start({required ExamId examId, int count = 10, int? randomSeed}) async {
    state = const QuizLoading();
    try {
      final now = _ref.read(nowProvider)();
      final session = await _ref.read(startQuickQuizProvider)(
        examId: examId,
        count: count,
        now: now,
        randomSeed: randomSeed,
      );
      state = QuizRunning(session: session, questionShownAt: now);
    } catch (e) {
      state = QuizFailure(e.toString());
    }
  }

  Future<void> answer({required ChoiceId chosenChoiceId}) async {
    final s = state;
    if (s is! QuizRunning) {
      throw StateError('answer() called when controller is not running');
    }
    final now = _ref.read(nowProvider)();
    final responseMs = now.difference(s.questionShownAt).inMilliseconds;

    final outcome = await _ref.read(submitAnswerProvider)(
      question: s.session.currentQuestion,
      chosenChoiceId: chosenChoiceId,
      responseMs: responseMs,
      now: now,
    );

    final updated = s.session.record(outcome);
    if (updated.isComplete) {
      final attempt = await _ref.read(completeQuizProvider)(session: updated, now: now);
      state = QuizComplete(attempt);
    } else {
      state = QuizRunning(session: updated, questionShownAt: now);
    }
  }

  void reset() => state = const QuizIdle();
}
```

- [ ] **Step 3: Run codegen if needed (none — no Freezed in controller); run tests**

```bash
flutter test test/features/quiz/presentation/quiz_controller_test.dart
```

Expected: 2/2 PASS.

- [ ] **Step 4: Commit**

```bash
git add lib/features/quiz/presentation/quiz_controller.dart \
        test/features/quiz/presentation/quiz_controller_test.dart
git commit -m "feat(quiz): add QuizController orchestrating use cases"
```

---

## Task 7: QuestionCard widget

**Files:**
- Create: `lib/features/quiz/presentation/widgets/question_card.dart`

The card uses `AppCard`, `QuizAnswerTile`, and tokens from Plan 02.

- [ ] **Step 1: Implement**

```dart
// lib/features/quiz/presentation/widgets/question_card.dart
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/core/ui/components/app_card.dart';
import 'package:cse_cet_reviewer/core/ui/components/quiz_answer_tile.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class QuestionCard extends StatelessWidget {
  const QuestionCard({
    required this.question,
    required this.onAnswer,
    super.key,
  });

  final Question question;
  final void Function(String chosenChoiceId) onAnswer;

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(question.stem, style: styles.headlineSmall),
          const SizedBox(height: 16),
          for (final choice in question.choices) ...[
            QuizAnswerTile(
              letter: choice.label,
              text: choice.text,
              onTap: () => onAnswer(choice.id),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Commit (a widget test is covered by the page test in Task 8)**

```bash
git add lib/features/quiz/presentation/widgets/question_card.dart
git commit -m "feat(quiz): add QuestionCard widget"
```

---

## Task 8: QuizPage and QuizProgressBar

**Files:**
- Create: `lib/features/quiz/presentation/widgets/quiz_progress_bar.dart`
- Create: `lib/features/quiz/presentation/quiz_page.dart`
- Create: `test/features/quiz/presentation/quiz_page_test.dart`

`QuizPage` watches `quizControllerProvider`. It receives the `examId` as a route parameter.

- [ ] **Step 1: Implement the progress bar**

```dart
// lib/features/quiz/presentation/widgets/quiz_progress_bar.dart
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class QuizProgressBar extends StatelessWidget {
  const QuizProgressBar({required this.current, required this.total, super.key});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Question $current of $total', style: context.textStyles.labelLarge),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: total == 0 ? 0 : current / total,
            backgroundColor: c.surfaceMuted,
            valueColor: AlwaysStoppedAnimation(c.primary),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Implement the page**

```dart
// lib/features/quiz/presentation/quiz_page.dart
import 'package:cse_cet_reviewer/core/ui/components/empty_state.dart';
import 'package:cse_cet_reviewer/core/ui/components/error_banner.dart';
import 'package:cse_cet_reviewer/core/ui/components/skeleton_loader.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_controller.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/widgets/question_card.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/widgets/quiz_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class QuizPage extends ConsumerStatefulWidget {
  const QuizPage({required this.examId, super.key});
  final String examId;

  @override
  ConsumerState<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends ConsumerState<QuizPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quizControllerProvider.notifier).start(examId: widget.examId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quizControllerProvider);
    ref.listen(quizControllerProvider, (_, next) {
      if (next is QuizComplete) {
        context.go('/quiz/results/${next.attempt.id}');
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Quick Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: switch (state) {
          QuizIdle() || QuizLoading() => const SkeletonLoader(),
          QuizRunning(:final session) => Column(
              children: [
                QuizProgressBar(current: session.currentIndex + 1, total: session.questions.length),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: QuestionCard(
                      question: session.currentQuestion,
                      onAnswer: (chosenChoiceId) =>
                          ref.read(quizControllerProvider.notifier).answer(chosenChoiceId: chosenChoiceId),
                    ),
                  ),
                ),
              ],
            ),
          QuizComplete() => const EmptyState(
              title: 'Wrapping up…',
              message: 'Loading your results.',
            ),
          QuizFailure(:final message) => ErrorBanner(
              title: 'Could not start quiz',
              message: message,
              onRetry: () => ref.read(quizControllerProvider.notifier).start(examId: widget.examId),
            ),
        },
      ),
    );
  }
}
```

> **Note:** `EmptyState`, `ErrorBanner`, and `SkeletonLoader` come from Plan 02. If their constructor parameter names differ from the assumptions above (`title`, `message`, `onRetry`), open the components and adapt — do not invent fields.

- [ ] **Step 3: Write the page test**

```dart
// test/features/quiz/presentation/quiz_page_test.dart
import 'package:cse_cet_reviewer/core/storage/domain/choice.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/quiz_session.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/complete_quiz.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/start_quick_quiz.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/submit_answer.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_controller.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_app.dart';

class _MockStart extends Mock implements StartQuickQuiz {}

class _MockSubmit extends Mock implements SubmitAnswer {}

class _MockComplete extends Mock implements CompleteQuiz {}

void main() {
  late _MockStart start;
  late _MockSubmit submit;
  late _MockComplete complete;

  const q1 = Question(
    id: 'q1', version: 1, examIds: ['e'], topicId: 't', language: 'en', stem: 'Stem One',
    choices: [
      Choice(id: 'c1a', label: 'A', text: 'AlphaText', isCorrect: true),
      Choice(id: 'c1b', label: 'B', text: 'BetaText', isCorrect: false),
    ],
    explanation: 'e',
  );

  setUp(() {
    start = _MockStart();
    submit = _MockSubmit();
    complete = _MockComplete();
  });

  testWidgets('renders the first question once start completes', (tester) async {
    when(() => start(
          examId: any(named: 'examId'),
          count: any(named: 'count'),
          now: any(named: 'now'),
          randomSeed: any(named: 'randomSeed'),
        )).thenAnswer((_) async => QuizSession.start(
          sessionId: 'sess', examId: 'e', questions: const [q1],
          startedAt: DateTime.utc(2026, 5, 9, 12),
        ));

    await tester.pumpAppWithProviders(
      const QuizPage(examId: 'e'),
      overrides: [
        startQuickQuizProvider.overrideWithValue(start),
        submitAnswerProvider.overrideWithValue(submit),
        completeQuizProvider.overrideWithValue(complete),
        nowProvider.overrideWithValue(() => DateTime.utc(2026, 5, 9, 12)),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Stem One'), findsOneWidget);
    expect(find.text('AlphaText'), findsOneWidget);
    expect(find.text('Question 1 of 1'), findsOneWidget);
  });
}
```

The new helper extension on `pumpApp` (in `test/helpers/pump_app.dart`) needs a Riverpod-aware variant — open `test/helpers/pump_app.dart` and add:

```dart
extension PumpAppRiverpod on WidgetTester {
  Future<void> pumpAppWithProviders(
    Widget child, {
    List<Override> overrides = const [],
  }) async {
    await pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: pumpApp(child).widget, // or inline whichever wrapping pumpApp does
      ),
    );
  }
}
```

> **Implementer note:** the exact incantation depends on how `pumpApp` is implemented. If it returns `void`, refactor it to expose a `buildApp(child)` that returns a `Widget` and have `pumpApp` call `pumpWidget(buildApp(child))`. Then `pumpAppWithProviders` wraps `buildApp(child)` in `ProviderScope`.

- [ ] **Step 4: Run + commit**

```bash
flutter test test/features/quiz/presentation/quiz_page_test.dart
git add lib/features/quiz/presentation/widgets/quiz_progress_bar.dart \
        lib/features/quiz/presentation/quiz_page.dart \
        test/features/quiz/presentation/quiz_page_test.dart \
        test/helpers/pump_app.dart
git commit -m "feat(quiz): add QuizPage with progress bar and live state binding"
```

---

## Task 9: QuizResultsPage

**Files:**
- Create: `lib/features/quiz/presentation/quiz_results_page.dart`
- Create: `test/features/quiz/presentation/quiz_results_page_test.dart`

The results page reads the persisted `Attempt` by ID through `AttemptsRepository.byId`. It does NOT reuse the controller's transient state because the user can deep-link to results from history (post-launch).

- [ ] **Step 1: Implement**

```dart
// lib/features/quiz/presentation/quiz_results_page.dart
import 'package:cse_cet_reviewer/core/storage/domain/attempt.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/app_card.dart';
import 'package:cse_cet_reviewer/core/ui/components/empty_state.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final attemptByIdProvider = FutureProvider.family<Attempt?, String>(
  (ref, id) => ref.watch(attemptsRepositoryProvider).byId(id),
);

class QuizResultsPage extends ConsumerWidget {
  const QuizResultsPage({required this.attemptId, super.key});
  final String attemptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncAttempt = ref.watch(attemptByIdProvider(attemptId));
    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: asyncAttempt.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(title: 'Error', message: e.toString()),
        data: (attempt) {
          if (attempt == null) {
            return const EmptyState(
              title: 'Attempt not found',
              message: 'This quiz attempt is no longer available.',
            );
          }
          final (correct, total) = attempt.score;
          final percent = total == 0 ? 0 : ((correct / total) * 100).round();
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Score: $correct / $total ($percent%)',
                          style: context.textStyles.headlineMedium),
                      const SizedBox(height: 8),
                      Text(
                        'Completed at ${attempt.completedAt?.toLocal()}',
                        style: context.textStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: attempt.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final item = attempt.items[i];
                      return AppCard(
                        child: ListTile(
                          leading: Icon(
                            item.isCorrect ? Icons.check_circle : Icons.cancel,
                            color: item.isCorrect ? Colors.green : Colors.red,
                          ),
                          title: Text('Question ${i + 1}'),
                          subtitle: Text('Response time: ${item.responseMs}ms'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

> **Implementer note:** `Icons.check_circle` and `Icons.cancel` use raw colors `Colors.green` / `Colors.red`. Replace with the design tokens (`context.colors.success` / `context.colors.error`) once those exist in `AppColors`. If they're not in Plan 02's tokens, file a follow-up — do NOT add new tokens here without re-running the typography/color tests in `core/ui/theme/`.

- [ ] **Step 2: Write the test**

```dart
// test/features/quiz/presentation/quiz_results_page_test.dart
import 'package:cse_cet_reviewer/core/storage/data/repos/attempts_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/attempt.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_results_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_app.dart';

class _MockAttempts extends Mock implements AttemptsRepository {}

void main() {
  testWidgets('renders score from a stored Attempt', (tester) async {
    final attempts = _MockAttempts();
    when(() => attempts.byId('a1')).thenAnswer((_) async => Attempt(
          id: 'a1',
          examId: 'e',
          startedAt: DateTime.utc(2026, 5, 9, 12),
          completedAt: DateTime.utc(2026, 5, 9, 12, 5),
          items: const [
            AttemptItem(
                questionId: 'q1', questionVersion: 1,
                chosenChoiceId: 'c_a', correctChoiceId: 'c_a', responseMs: 1500),
            AttemptItem(
                questionId: 'q2', questionVersion: 1,
                chosenChoiceId: 'c_a', correctChoiceId: 'c_b', responseMs: 4200),
          ],
        ));

    await tester.pumpAppWithProviders(
      const QuizResultsPage(attemptId: 'a1'),
      overrides: [attemptsRepositoryProvider.overrideWithValue(attempts)],
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('1 / 2'), findsOneWidget);
    expect(find.textContaining('50%'), findsOneWidget);
  });
}
```

- [ ] **Step 3: Run + commit**

```bash
flutter test test/features/quiz/presentation/quiz_results_page_test.dart
git add lib/features/quiz/presentation/quiz_results_page.dart \
        test/features/quiz/presentation/quiz_results_page_test.dart
git commit -m "feat(quiz): add QuizResultsPage backed by AttemptsRepository"
```

---

## Task 10: Wire routes and Quiz-tab CTA

**Files:**
- Modify: `lib/app/router.dart`
- Modify: `lib/features/shell/presentation/app_shell.dart`
- Create: `lib/features/quiz/quiz.dart` (barrel)

- [ ] **Step 1: Add routes**

In `lib/app/router.dart`, the current shell routes a Quiz tab to a placeholder. Replace the placeholder with:

```dart
// inside the StatefulShellRoute branch for /quiz:
GoRoute(
  path: '/quiz',
  builder: (_, __) => const QuizTabHome(),
  routes: [
    GoRoute(
      path: 'quick/:examId',
      builder: (_, state) => QuizPage(examId: state.pathParameters['examId']!),
    ),
    GoRoute(
      path: 'results/:attemptId',
      builder: (_, state) => QuizResultsPage(attemptId: state.pathParameters['attemptId']!),
    ),
  ],
),
```

Imports to add at the top of `router.dart`:

```dart
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_page.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_results_page.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_tab_home.dart';
```

- [ ] **Step 2: Create QuizTabHome**

```dart
// lib/features/quiz/presentation/quiz_tab_home.dart
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/app_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/app_card.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final examListProvider = FutureProvider(
  (ref) => ref.watch(contentRepositoryProvider).listExams(),
);

class QuizTabHome extends ConsumerWidget {
  const QuizTabHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncExams = ref.watch(examListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: asyncExams.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (exams) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: exams.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final exam = exams[i];
            return AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exam.name, style: context.textStyles.headlineSmall),
                  const SizedBox(height: 8),
                  AppButton(
                    label: 'Start Quick Quiz',
                    onPressed: () => context.go('/quiz/quick/${exam.id}'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
```

> **Implementer note:** if `AppButton` exposes its label parameter under a different name, follow Plan 02's actual signature.

- [ ] **Step 3: Write the barrel**

```dart
// lib/features/quiz/quiz.dart
export 'domain/quiz_session.dart';
export 'domain/rating_heuristic.dart';
export 'domain/use_cases/complete_quiz.dart';
export 'domain/use_cases/start_quick_quiz.dart';
export 'domain/use_cases/submit_answer.dart';
export 'presentation/quiz_controller.dart';
export 'presentation/quiz_page.dart';
export 'presentation/quiz_results_page.dart';
export 'presentation/quiz_tab_home.dart';
```

- [ ] **Step 4: Verify the existing app-shell test still passes**

```bash
flutter test test/features/shell/app_shell_test.dart
```

Expected: still PASSES. If it fails, the shell test was asserting on the old placeholder copy — update its expected text to match `QuizTabHome` (e.g., the AppBar title "Quiz").

- [ ] **Step 5: Commit**

```bash
git add lib/app/router.dart \
        lib/features/quiz/presentation/quiz_tab_home.dart \
        lib/features/quiz/quiz.dart \
        test/features/shell/app_shell_test.dart   # only if updated
git commit -m "feat(quiz): wire quiz routes and Quick-Quiz tab home"
```

---

## Task 11: End-to-end integration test

**Files:**
- Create: `test/features/quiz/integration_test.dart`

This test exercises the full flow with a real in-memory `AppDatabase` (seeded via the bundled JSON) — no mocks below the controller. Catches integration breaks that pure-unit tests miss.

- [ ] **Step 1: Write the test**

```dart
// test/features/quiz/integration_test.dart
import 'package:cse_cet_reviewer/core/storage/data/seeder.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('quick-quiz happy path: start → answer 4 → complete', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);

    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await Seeder(db, bundle: rootBundle).maybeSeed();

    final notifier = container.read(quizControllerProvider.notifier);
    await notifier.start(examId: 'exam_cse_pro', count: 2, randomSeed: 1);

    var state = container.read(quizControllerProvider);
    expect(state, isA<QuizRunning>());
    final firstQuestion = (state as QuizRunning).session.currentQuestion;

    // Answer with the known-correct choice for question 1.
    await notifier.answer(chosenChoiceId: firstQuestion.correctChoice.id);

    // Either complete (count==1) or running with next question (count==2).
    state = container.read(quizControllerProvider);
    if (state is QuizRunning) {
      await notifier.answer(chosenChoiceId: state.session.currentQuestion.correctChoice.id);
      state = container.read(quizControllerProvider);
    }
    expect(state, isA<QuizComplete>());

    final attempt = (state as QuizComplete).attempt;
    expect(attempt.items, hasLength(2));
    expect(attempt.score.$1, equals(2)); // both correct
  });
}
```

- [ ] **Step 2: Run + commit**

```bash
flutter test test/features/quiz/integration_test.dart
git add test/features/quiz/integration_test.dart
git commit -m "test(quiz): end-to-end happy path with seeded in-memory DB"
```

---

## Task 12: Final analyzer + coverage gate + hand-off

**Files:**
- None (verification-only)

- [ ] **Step 1: Format + analyze + full test suite**

```bash
dart format .
flutter analyze
flutter test --coverage
```

Expected: `No issues found!` and every test PASSES.

- [ ] **Step 2: Compute domain + overall coverage**

```bash
awk '
  /^SF:lib\/features\/quiz\/domain\// { in_block=1; next }
  /^SF:/ { in_block=0; next }
  in_block && /^DA:/ { total++; split($0, a, ","); if (a[2]+0 > 0) hit++ }
  END { printf "features/quiz/domain: %d/%d (%.1f%%)\n", hit, total, (hit/total)*100 }
' coverage/lcov.info

awk '
  /^SF:lib\/features\/quiz\// { in_block=1; next }
  /^SF:/ { in_block=0; next }
  in_block && /^DA:/ { total++; split($0, a, ","); if (a[2]+0 > 0) hit++ }
  END { printf "features/quiz overall: %d/%d (%.1f%%)\n", hit, total, (hit/total)*100 }
' coverage/lcov.info
```

Expected: `features/quiz/domain` ≥ 80%; overall ≥ 70% per spec §7.2.

If below: identify uncovered lines, add targeted tests, re-run.

- [ ] **Step 3: Run finishing-a-development-branch**

Announce: "I'm using the finishing-a-development-branch skill to complete this work."

Use **superpowers:finishing-a-development-branch** to verify tests, present the four options, and execute the user's choice.

---

## Self-Review Notes

- **Spec coverage:** §5.3 quiz feature (quick quiz core loop) ✓; §3.4 FSRS rating heuristic ✓ Task 1; §4.2 user-state write flow (UI → Drift → queue) ✓ Tasks 4-5; §5.2 layering rules respected (`domain/` has no Flutter/Drift/Firebase imports — `start_quick_quiz.dart` reads `ContentRepository` *interface*, not Drift directly).
- **Deferred (called out at top):** Drill-by-topic, Retake-Mistakes, post-quiz coach marks, "weakness explanation" from results.
- **No placeholders:** every code block compiles standalone; the only "open" steps are explicit references to Plan-02 components whose constructor signatures must be matched at integration time (Task 8 & 9 footnotes).
- **Type consistency:** `AnswerOutcome` ↔ `AttemptItem` field names match (questionId, questionVersion, chosenChoiceId, correctChoiceId, responseMs). `QuizSession.score` returns `(int, int)` like `Attempt.score` from Plan 03 — same record shape, same call-sites compatible.
- **Layering:** controller depends on use-case interfaces, use cases depend on repository interfaces (defined in Plan 03), repos depend on `AppDatabase`. No upward dependencies. `presentation/` reaches `data/` only through use cases.
