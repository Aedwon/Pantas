import 'package:cse_cet_reviewer/core/fsrs/rating.dart';
import 'package:cse_cet_reviewer/core/storage/domain/choice.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/debrief/session_debrief.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/session_origin.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/quiz_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Question makeQuestion(
    String id, {
    String? shortLabel,
    String topicId = 't_chem',
  }) {
    return Question(
      id: id,
      version: 1,
      examIds: const ['exam_cse_pro'],
      topicId: topicId,
      language: 'en',
      stem: 'Stem for $id',
      shortLabel: shortLabel,
      choices: const [
        Choice(id: 'c_a', label: 'A', text: 'Opt A', isCorrect: true),
        Choice(id: 'c_b', label: 'B', text: 'Opt B', isCorrect: false),
      ],
      explanation: 'Explanation',
    );
  }

  QuizSession makeSession({
    int totalQuestions = 10,
    int correctCount = 7,
    SessionOrigin origin = SessionOrigin.todayTopic,
    List<Question>? customQuestions,
    List<AnswerOutcome>? customOutcomes,
    DateTime? startedAt,
  }) {
    final start = startedAt ?? DateTime.utc(2026, 8, 2, 10);
    final questions = customQuestions ??
        List.generate(
          totalQuestions,
          (i) => makeQuestion(
            'q_$i',
            topicId: i < 4
                ? 't_chem'
                : i < 7
                    ? 't_phys'
                    : 't_bio',
          ),
        );
    final outcomes = customOutcomes ??
        List.generate(
          questions.length,
          (i) => AnswerOutcome(
            questionId: questions[i].id,
            questionVersion: 1,
            chosenChoiceId: i < correctCount ? 'c_a' : 'c_b',
            correctChoiceId: 'c_a',
            responseMs: 5000,
            derivedRating: i < correctCount ? Rating.good : Rating.again,
          ),
        );

    return QuizSession(
      sessionId: 'sess_1',
      examId: 'exam_cse_pro',
      questions: questions,
      currentIndex: questions.length,
      outcomes: outcomes,
      startedAt: start,
      origin: origin,
    );
  }

  final topicNames = {
    't_chem': 'Chemistry',
    't_phys': 'Physics',
    't_bio': 'Biology',
  };

  test('the headline spells the count', () {
    final session = makeSession();
    final debrief = BuildSessionDebrief.call(
      session: session,
      topicNames: topicNames,
      topicAverageMs: {},
      topicAnswerCount: {},
      priorCorrect: {},
      priorAttemptedQuestionIds: {},
      proIsActive: true,
      now: session.startedAt.add(const Duration(minutes: 9)),
    );

    expect(debrief.headline, 'Ten answered.');
  });

  test('the headline handles a length outside the spelled range', () {
    final session = makeSession(totalQuestions: 47);
    final debrief = BuildSessionDebrief.call(
      session: session,
      topicNames: topicNames,
      topicAverageMs: {},
      topicAnswerCount: {},
      priorCorrect: {},
      priorAttemptedQuestionIds: {},
      proIsActive: true,
      now: session.startedAt.add(const Duration(minutes: 9)),
    );

    expect(debrief.headline, '47 answered.');
  });

  test('the figures are counted and measured', () {
    final session = makeSession();
    final debrief = BuildSessionDebrief.call(
      session: session,
      topicNames: topicNames,
      topicAverageMs: {},
      topicAnswerCount: {},
      priorCorrect: {},
      priorAttemptedQuestionIds: {},
      proIsActive: true,
      now: session.startedAt.add(const Duration(minutes: 9)),
    );

    expect(debrief.correct, 7);
    expect(debrief.total, 10);
    expect(debrief.minutes, 9);
  });

  test('the source line names the topics in the session', () {
    final session = makeSession();
    final debrief = BuildSessionDebrief.call(
      session: session,
      topicNames: topicNames,
      topicAverageMs: {},
      topicAnswerCount: {},
      priorCorrect: {},
      priorAttemptedQuestionIds: {},
      proIsActive: true,
      now: session.startedAt.add(const Duration(minutes: 9)),
    );

    expect(
      debrief.sourceLine,
      "Today's session. Chemistry, Physics and Biology.",
    );
  });

  test('one topic reads without a list', () {
    final session = makeSession(
      customQuestions: [makeQuestion('q_1')],
      customOutcomes: [
        const AnswerOutcome(
          questionId: 'q_1',
          questionVersion: 1,
          chosenChoiceId: 'c_a',
          correctChoiceId: 'c_a',
          responseMs: 1000,
        ),
      ],
    );
    final debrief = BuildSessionDebrief.call(
      session: session,
      topicNames: topicNames,
      topicAverageMs: {},
      topicAnswerCount: {},
      priorCorrect: {},
      priorAttemptedQuestionIds: {},
      proIsActive: true,
      now: session.startedAt.add(const Duration(minutes: 1)),
    );

    expect(debrief.sourceLine, "Today's session. Chemistry.");
  });

  test('a drill names itself differently', () {
    final session = makeSession(origin: SessionOrigin.drill);
    final debrief = BuildSessionDebrief.call(
      session: session,
      topicNames: topicNames,
      topicAverageMs: {},
      topicAnswerCount: {},
      priorCorrect: {},
      priorAttemptedQuestionIds: {},
      proIsActive: true,
      now: session.startedAt.add(const Duration(minutes: 5)),
    );

    expect(debrief.sourceLine, startsWith('Practice.'));
  });

  test('every miss carries its pick and its answer', () {
    final session = makeSession(correctCount: 9);
    final debrief = BuildSessionDebrief.call(
      session: session,
      topicNames: topicNames,
      topicAverageMs: {},
      topicAnswerCount: {},
      priorCorrect: {},
      priorAttemptedQuestionIds: {},
      proIsActive: true,
      now: session.startedAt.add(const Duration(minutes: 5)),
    );

    expect(debrief.misses.single.pickedLabel, 'B');
    expect(debrief.misses.single.answerLabel, 'A');
  });

  test('a miss falls back to its stem when it has no short label', () {
    final session = makeSession(totalQuestions: 1, correctCount: 0);
    final debrief = BuildSessionDebrief.call(
      session: session,
      topicNames: topicNames,
      topicAverageMs: {},
      topicAnswerCount: {},
      priorCorrect: {},
      priorAttemptedQuestionIds: {},
      proIsActive: true,
      now: session.startedAt.add(const Duration(minutes: 1)),
    );

    expect(debrief.misses.single.labelIsStem, isTrue);
  });

  test('a short label is used when the content has one', () {
    final q = makeQuestion('q_1', shortLabel: 'Balancing an equation');
    final session = makeSession(
      customQuestions: [q],
      customOutcomes: [
        const AnswerOutcome(
          questionId: 'q_1',
          questionVersion: 1,
          chosenChoiceId: 'c_b',
          correctChoiceId: 'c_a',
          responseMs: 1000,
        ),
      ],
    );
    final debrief = BuildSessionDebrief.call(
      session: session,
      topicNames: topicNames,
      topicAverageMs: {},
      topicAnswerCount: {},
      priorCorrect: {},
      priorAttemptedQuestionIds: {},
      proIsActive: true,
      now: session.startedAt.add(const Duration(minutes: 1)),
    );

    expect(debrief.misses.single.label, 'Balancing an equation');
    expect(debrief.misses.single.labelIsStem, isFalse);
  });

  test('the return promise counts the misses and follows the scheduler', () {
    final session = makeSession();
    final debrief = BuildSessionDebrief.call(
      session: session,
      topicNames: topicNames,
      topicAverageMs: {},
      topicAnswerCount: {},
      priorCorrect: {},
      priorAttemptedQuestionIds: {},
      proIsActive: true,
      now: session.startedAt.add(const Duration(minutes: 9)),
    );

    expect(debrief.returnPromise, "You'll see all three again tomorrow.");
  });

  test('one miss reads in the singular', () {
    final session = makeSession(correctCount: 9);
    final debrief = BuildSessionDebrief.call(
      session: session,
      topicNames: topicNames,
      topicAverageMs: {},
      topicAnswerCount: {},
      priorCorrect: {},
      priorAttemptedQuestionIds: {},
      proIsActive: true,
      now: session.startedAt.add(const Duration(minutes: 5)),
    );

    expect(debrief.returnPromise, "You'll see it again tomorrow.");
  });

  test('a longer interval is said plainly', () {
    final q1 = makeQuestion('q_1');
    final q2 = makeQuestion('q_2');
    final session = makeSession(
      customQuestions: [q1, q2],
      customOutcomes: [
        const AnswerOutcome(
          questionId: 'q_1',
          questionVersion: 1,
          chosenChoiceId: 'c_b',
          correctChoiceId: 'c_a',
          responseMs: 1000,
        ),
        const AnswerOutcome(
          questionId: 'q_2',
          questionVersion: 1,
          chosenChoiceId: 'c_b',
          correctChoiceId: 'c_a',
          responseMs: 1000,
          nextReviewIntervalDays: 3,
        ),
      ],
    );
    final debrief = BuildSessionDebrief.call(
      session: session,
      topicNames: topicNames,
      topicAverageMs: {},
      topicAnswerCount: {},
      priorCorrect: {},
      priorAttemptedQuestionIds: {},
      proIsActive: true,
      now: session.startedAt.add(const Duration(minutes: 2)),
    );

    expect(debrief.returnPromise, "You'll see both again within 3 days.");
  });

  test('a clean session has no misses and no promise', () {
    final session = makeSession(correctCount: 10);
    final debrief = BuildSessionDebrief.call(
      session: session,
      topicNames: topicNames,
      topicAverageMs: {},
      topicAnswerCount: {},
      priorCorrect: {},
      priorAttemptedQuestionIds: {},
      proIsActive: true,
      now: session.startedAt.add(const Duration(minutes: 5)),
    );

    expect(debrief.isClean, isTrue);
    expect(debrief.returnPromise, isEmpty);
  });
}
