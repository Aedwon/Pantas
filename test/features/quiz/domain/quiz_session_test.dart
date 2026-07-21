import 'package:cse_cet_reviewer/core/storage/domain/choice.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/session_origin.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/quiz_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const q1 = Question(
    id: 'q1',
    version: 1,
    examIds: ['e'],
    topicId: 't',
    language: 'en',
    stem: 's1',
    choices: [
      Choice(id: 'c1a', label: 'A', text: 'x', isCorrect: true),
      Choice(id: 'c1b', label: 'B', text: 'y', isCorrect: false),
    ],
    explanation: 'e1',
  );
  const q2 = Question(
    id: 'q2',
    version: 1,
    examIds: ['e'],
    topicId: 't',
    language: 'en',
    stem: 's2',
    choices: [
      Choice(id: 'c2a', label: 'A', text: 'x', isCorrect: false),
      Choice(id: 'c2b', label: 'B', text: 'y', isCorrect: true),
    ],
    explanation: 'e2',
  );

  test('start() creates a session at index 0 with no outcomes', () {
    final s = QuizSession.start(
      sessionId: 'sess',
      examId: 'e',
      questions: [q1, q2],
      startedAt: DateTime.utc(2026),
    );
    expect(s.currentIndex, equals(0));
    expect(s.outcomes, isEmpty);
    expect(s.isComplete, isFalse);
    expect(s.currentQuestion, equals(q1));
  });

  test('record() stores the outcome and stays on the question', () {
    final s = QuizSession.start(
      sessionId: 'sess',
      examId: 'e',
      questions: [q1, q2],
      startedAt: DateTime.utc(2026),
    );
    final s2 = s.record(
      const AnswerOutcome(
        questionId: 'q1',
        questionVersion: 1,
        chosenChoiceId: 'c1a',
        correctChoiceId: 'c1a',
        responseMs: 1500,
      ),
    );
    // The reveal is the point of a practice quiz, so the session stays
    // where it is until the student has read it.
    expect(s2.currentIndex, equals(0));
    expect(s2.outcomes, hasLength(1));
    expect(s2.currentQuestion, equals(q1));
    expect(s2.currentOutcome, isNotNull);
    expect(s2.isComplete, isFalse);

    final s3 = s2.advance();
    expect(s3.currentIndex, equals(1));
    expect(s3.currentQuestion, equals(q2));
    expect(s3.currentOutcome, isNull);
  });

  test('advance() stops at the last question', () {
    final s = QuizSession.start(
      sessionId: 'sess',
      examId: 'e',
      questions: [q1, q2],
      startedAt: DateTime.utc(2026),
    );

    expect(s.advance().advance().advance().currentIndex, equals(1));
  });

  test('isComplete after every question answered', () {
    var s = QuizSession.start(
      sessionId: 'sess',
      examId: 'e',
      questions: [q1, q2],
      startedAt: DateTime.utc(2026),
    );
    s = s.record(
      const AnswerOutcome(
        questionId: 'q1',
        questionVersion: 1,
        chosenChoiceId: 'c1a',
        correctChoiceId: 'c1a',
        responseMs: 1500,
      ),
    );
    s = s.record(
      const AnswerOutcome(
        questionId: 'q2',
        questionVersion: 1,
        chosenChoiceId: 'c2a',
        correctChoiceId: 'c2b',
        responseMs: 4200,
      ),
    );
    expect(s.isComplete, isTrue);
    expect(s.score, equals((1, 2)));
  });

  test('start stores origin topic subtopic lesson and ordered questions', () {
    final s = QuizSession.start(
      sessionId: 'sess',
      examId: 'e',
      questions: [q1, q2],
      startedAt: DateTime.utc(2026),
      origin: SessionOrigin.inline,
      topicId: 't',
      subtopicId: 'subtopic_synonyms',
      lessonId: 'lesson_vocab',
    );

    expect(s.origin, SessionOrigin.inline);
    expect(s.topicId, equals('t'));
    expect(s.subtopicId, equals('subtopic_synonyms'));
    expect(s.lessonId, equals('lesson_vocab'));
    expect(s.questions.map((question) => question.id), equals(['q1', 'q2']));
  });

  test('today origins are recognized as streak eligible', () {
    expect(SessionOrigin.todayTopic.isStreakEligible, isTrue);
    expect(SessionOrigin.todayInterleaved.isStreakEligible, isTrue);
  });

  test('drill retake and inline origins are not streak eligible', () {
    expect(SessionOrigin.drill.isStreakEligible, isFalse);
    expect(SessionOrigin.retake.isStreakEligible, isFalse);
    expect(SessionOrigin.inline.isStreakEligible, isFalse);
  });

  test('an answered question keeps its outcome when revisited', () {
    var s = QuizSession.start(
      sessionId: 'sess',
      examId: 'e',
      questions: [q1, q2],
      startedAt: DateTime.utc(2026),
    );
    s = s
        .record(
          const AnswerOutcome(
            questionId: 'q1',
            questionVersion: 1,
            chosenChoiceId: 'c1b',
            correctChoiceId: 'c1a',
            responseMs: 900,
          ),
        )
        .advance();

    // Going back reads the answer that was written when it was tapped.
    final back = s.copyWith(currentIndex: 0);
    expect(back.currentOutcome?.chosenChoiceId, equals('c1b'));
    expect(back.currentOutcome?.isCorrect, isFalse);
  });
}
