import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';

void main() {
  test('a choice carries an optional rationale through json', () {
    const choice = Choice(
      id: 'c2',
      label: 'B',
      text: 'Change the subscript',
      isCorrect: false,
      rationale: "A subscript is part of the molecule's identity.",
    );

    final parsed = Choice.fromJson(choice.toJson());
    expect(parsed.rationale, choice.rationale);
  });

  test('choices authored before rationales still parse', () {
    final legacy = <String, dynamic>{
      'id': 'c1',
      'label': 'A',
      'text': 'Change the coefficient',
      'isCorrect': true,
    };

    expect(Choice.fromJson(legacy).rationale, isNull);
  });

  test('a question carries an optional short label through json', () {
    const question = Question(
      id: 'q1',
      version: 1,
      examIds: ['e1'],
      topicId: 't1',
      language: 'en',
      stem: r'Balance $H_2O$ by changing which part?',
      choices: [Choice(id: 'c1', label: 'A', text: 'A', isCorrect: true)],
      explanation: 'Because.',
      shortLabel: 'Balancing an equation',
    );

    expect(
      Question.fromJson(question.toJson()).shortLabel,
      'Balancing an equation',
    );
  });
}
