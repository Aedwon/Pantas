import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/features/quiz/domain/selectors/subtopic_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('filters questions by subtopic id', () {
    final filtered = SubtopicFilter.select(
      candidates: [
        SubtopicQuestion(question: _question('q1'), subtopicId: 'synonyms'),
        SubtopicQuestion(question: _question('q2'), subtopicId: 'antonyms'),
      ],
      subtopicId: 'synonyms',
    );

    expect(filtered.map((question) => question.id), equals(['q1']));
  });

  test('returns General topic fallback for null subtopicId when requested', () {
    final filtered = SubtopicFilter.general([
      SubtopicQuestion(question: _question('q1'), subtopicId: null),
      SubtopicQuestion(question: _question('q2'), subtopicId: 'synonyms'),
    ]);

    expect(filtered.map((question) => question.id), equals(['q1']));
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
