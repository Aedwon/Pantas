import 'package:cse_cet_reviewer/core/storage/domain/choice.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sample = Question(
    id: 'q_1',
    version: 1,
    examIds: ['exam_cse_pro'],
    topicId: 'topic_vocab',
    language: 'en',
    stem: 'Pick one.',
    choices: [
      Choice(id: 'c_a', label: 'A', text: 'x', isCorrect: false),
      Choice(id: 'c_b', label: 'B', text: 'y', isCorrect: true),
    ],
    explanation: 'because y',
  );

  test('round-trips JSON', () {
    expect(Question.fromJson(sample.toJson()), equals(sample));
  });

  test('correctChoice returns the choice flagged isCorrect', () {
    expect(sample.correctChoice.id, equals('c_b'));
  });

  test('correctChoice throws StateError when no choice is correct', () {
    final bad = sample.copyWith(
      choices: [
        const Choice(id: 'c_a', label: 'A', text: 'x', isCorrect: false),
      ],
    );
    expect(() => bad.correctChoice, throwsStateError);
  });
}
