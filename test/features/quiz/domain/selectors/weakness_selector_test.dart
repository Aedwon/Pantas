import 'package:cse_cet_reviewer/core/storage/domain/choice.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/selectors/weakness_selector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ranks low rolling accuracy subtopics first', () {
    final selected = WeaknessSelector.select([
      WeaknessCandidate(
        question: _question('q1'),
        subtopicId: 'easy',
        rollingAccuracy: 0.8,
        attemptCount: 10,
      ),
      WeaknessCandidate(
        question: _question('q2'),
        subtopicId: 'weak',
        rollingAccuracy: 0.2,
        attemptCount: 10,
      ),
    ]);

    expect(selected.map((question) => question.id), equals(['q2']));
  });
}

Question _question(String id) => Question(
      id: id,
      version: 1,
      examIds: const ['exam'],
      topicId: 'topic',
      language: 'en',
      stem: id,
      choices: const [
        Choice(id: 'a', label: 'A', text: 'A', isCorrect: true),
        Choice(id: 'b', label: 'B', text: 'B', isCorrect: false),
      ],
      explanation: 'Because.',
    );
