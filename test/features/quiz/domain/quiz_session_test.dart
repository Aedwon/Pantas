import 'package:cse_cet_reviewer/core/storage/domain/choice.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
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

  test('record() advances index and stores outcome', () {
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
    expect(s2.currentIndex, equals(1));
    expect(s2.outcomes, hasLength(1));
    expect(s2.currentQuestion, equals(q2));
    expect(s2.isComplete, isFalse);
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
}
