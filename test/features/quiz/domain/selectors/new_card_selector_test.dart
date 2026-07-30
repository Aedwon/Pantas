import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/features/quiz/domain/selectors/new_card_selector.dart';

void main() {
  test('excludes questions with review state and respects cap remaining', () {
    final selected = NewCardSelector.select(
      questions: [
        _question('q1', 'topic_a'),
        _question('q2', 'topic_a'),
        _question('q3', 'topic_a'),
      ],
      seenQuestionIds: const {'q1'},
      capRemaining: 1,
      limit: 3,
    );

    expect(selected.map((question) => question.id), equals(['q2']));
  });
}

Question _question(String id, String topicId) => Question(
      id: id,
      version: 1,
      examIds: const ['exam'],
      topicId: topicId,
      language: 'en',
      stem: id,
      choices: const [
        Choice(id: 'a', label: 'A', text: 'A', isCorrect: true),
        Choice(id: 'b', label: 'B', text: 'B', isCorrect: false),
      ],
      explanation: 'Because.',
    );
