import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/features/quiz/domain/selectors/recency_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('avoids consecutive same-topic questions when possible', () {
    final reordered = RecencyFilter.noConsecutiveSameTopic([
      _question('q1', 'a'),
      _question('q2', 'a'),
      _question('q3', 'b'),
      _question('q4', 'b'),
    ]);

    for (var i = 1; i < reordered.length; i++) {
      expect(reordered[i].topicId, isNot(equals(reordered[i - 1].topicId)));
    }
  });

  test('keeps degenerate all-same-topic lists intact', () {
    final questions = [_question('q1', 'a'), _question('q2', 'a')];

    expect(RecencyFilter.noConsecutiveSameTopic(questions), equals(questions));
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
