import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/features/mock_exam/domain/mock_results.dart';
import 'package:pantas/features/mock_exam/domain/mock_session_state.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_finale.dart';

void main() {
  test('submission input keeps immutable original parts and outcomes', () {
    final questions = [
      const MockFinaleQuestion(id: 'q', outcome: MockFinaleOutcome.blank),
    ];
    final part = MockFinalePart(name: 'Science', questions: questions);
    final parts = [
      part,
      MockFinalePart(name: 'Retired part', questions: const []),
    ];
    final input = MockFinaleInput(
      reason: MockSubmitReason.timeUp,
      currentPartIndex: 0,
      currentQuestionIndex: 0,
      parts: parts,
    );
    questions.clear();
    parts.clear();
    expect(input.parts, hasLength(2));
    expect(input.parts.first.questions.single.id, 'q');
    expect(input.parts.first.questions.single.outcome, MockFinaleOutcome.blank);
    expect(input.parts.last.questions, isEmpty);
    expect(input.parts.clear, throwsUnsupportedError);
    expect(() => input.parts.first.questions.clear(), throwsUnsupportedError);
  });
  test(
      'submission builder excludes retired questions and keeps the real cursor',
      () {
    const q1 = Question(
      id: 'q1',
      version: 1,
      examIds: ['exam'],
      topicId: 'topic',
      language: 'en',
      stem: 'q1',
      choices: [
        Choice(id: 'q1a', label: 'A', text: 'A', isCorrect: true),
        Choice(id: 'q1b', label: 'B', text: 'B', isCorrect: false),
      ],
      explanation: 'why',
    );
    const q4 = Question(
      id: 'q4',
      version: 1,
      examIds: ['exam'],
      topicId: 'topic',
      language: 'en',
      stem: 'q4',
      choices: [
        Choice(id: 'q4a', label: 'A', text: 'A', isCorrect: true),
        Choice(id: 'q4b', label: 'B', text: 'B', isCorrect: false),
      ],
      explanation: 'why',
    );
    const q5 = Question(
      id: 'q5',
      version: 1,
      examIds: ['exam'],
      topicId: 'topic',
      language: 'en',
      stem: 'q5',
      choices: [
        Choice(id: 'q5a', label: 'A', text: 'A', isCorrect: true),
        Choice(id: 'q5b', label: 'B', text: 'B', isCorrect: false),
      ],
      explanation: 'why',
    );

    final input = buildMockFinaleInput(
      reason: MockSubmitReason.timeUp,
      questionIds: const ['q1', 'q2', 'q3', 'q4', 'q5'],
      partRanges: const [
        (name: 'Part 1', startIndex: 0, count: 2),
        (name: 'Part 2', startIndex: 2, count: 3),
      ],
      questionsById: const {'q1': q1, 'q4': q4, 'q5': q5},
      answers: const {
        'q1': MockAnswer(selectedIndex: 0, atSec: 5),
        'q4': MockAnswer(selectedIndex: 1, atSec: 10),
      },
      currentPartIndex: 1,
      currentQuestionIndex: 4,
    );

    expect(input, isNotNull);
    expect(input!.parts, hasLength(2));
    expect(input.parts[0].questions.map((q) => q.id), ['q1']);
    expect(input.parts[1].questions.map((q) => q.id), ['q4', 'q5']);
    expect(input.parts[0].questions.single.outcome, MockFinaleOutcome.correct);
    expect(input.parts[1].questions[0].outcome, MockFinaleOutcome.wrong);
    expect(input.parts[1].questions[1].outcome, MockFinaleOutcome.blank);
    expect(input.currentPartIndex, 1);
    expect(input.currentQuestionIndex, 1);
  });

  test('submission builder omits the finale when every question retired', () {
    final input = buildMockFinaleInput(
      reason: MockSubmitReason.manual,
      questionIds: const ['retired'],
      partRanges: const [(name: 'Paper', startIndex: 0, count: 1)],
      questionsById: const {},
      answers: const {},
      currentPartIndex: 0,
      currentQuestionIndex: 0,
    );

    expect(input, isNull);
  });
}
