import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/question.dart';

void main() {
  test('Exam, Question, Choice and Attempt serialize identically', () {
    const choice = Choice(
      id: 'c1',
      label: 'A',
      text: 'Option A',
      isCorrect: true,
      rationale: 'Because.',
    );

    final choiceJson = choice.toJson();
    expect(choiceJson, {
      'id': 'c1',
      'label': 'A',
      'text': 'Option A',
      'isCorrect': true,
      'rationale': 'Because.',
    });
    expect(Choice.fromJson(choiceJson), choice);

    const question = Question(
      id: 'q1',
      version: 1,
      examIds: ['e1'],
      topicId: 't1',
      language: 'en',
      stem: 'What is 2+2?',
      choices: [choice],
      explanation: '4',
      shortLabel: 'Math',
    );

    final questionJson = question.toJson();
    expect(questionJson['id'], 'q1');
    expect(questionJson['version'], 1);
    expect(Question.fromJson(questionJson), question);

    const attemptItem = AttemptItem(
      questionId: 'q1',
      questionVersion: 1,
      chosenChoiceId: 'c1',
      correctChoiceId: 'c1',
      responseMs: 1500,
    );

    final attempt = Attempt(
      id: 'a1',
      examId: 'e1',
      startedAt: DateTime.utc(2026, 1, 1),
      items: [attemptItem],
      origin: 'today_topic',
    );

    final attemptJson = attempt.toJson();
    expect(attemptJson['id'], 'a1');
    expect(attemptJson['examId'], 'e1');
    expect(Attempt.fromJson(attemptJson), attempt);

    const exam = Exam(
      id: 'e1',
      code: 'EX',
      name: 'Exam',
      shortName: 'Ex',
      language: 'en',
      isActive: true,
      subjects: [],
      isCustom: false,
    );

    final examJson = exam.toJson();
    expect(examJson['id'], 'e1');
    expect(Exam.fromJson(examJson), exam);
  });
}
