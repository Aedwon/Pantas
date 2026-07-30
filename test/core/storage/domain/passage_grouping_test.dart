import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/passage_set_filler.dart';
import 'package:pantas/core/storage/domain/question.dart';

Question q(String id, {String? passageId}) => Question(
      id: id,
      version: 1,
      topicId: 't',
      examIds: const ['e'],
      language: 'en',
      stem: id,
      choices: const [
        Choice(id: 'a', label: 'A', text: 'a', isCorrect: true),
        Choice(id: 'b', label: 'B', text: 'b', isCorrect: false),
      ],
      explanation: 'why',
      passageId: passageId,
    );

void main() {
  test('questions sharing a passage are answered in one run', () {
    final grouped = groupPassageSets([
      q('p1-a', passageId: 'p1'),
      q('free-1'),
      q('p2-a', passageId: 'p2'),
      q('p1-b', passageId: 'p1'),
      q('free-2'),
      q('p1-c', passageId: 'p1'),
      q('p2-b', passageId: 'p2'),
    ]);

    expect(
      grouped.map((question) => question.id),
      ['p1-a', 'p1-b', 'p1-c', 'free-1', 'p2-a', 'p2-b', 'free-2'],
    );
  });

  test('a set sits where its first question was, not at the front', () {
    final grouped = groupPassageSets([
      q('free-1'),
      q('p1-a', passageId: 'p1'),
      q('p1-b', passageId: 'p1'),
    ]);

    expect(grouped.first.id, 'free-1');
  });

  test('questions with no passage keep their order', () {
    final grouped = groupPassageSets([q('one'), q('two'), q('three')]);

    expect(grouped.map((question) => question.id), ['one', 'two', 'three']);
  });

  test('an empty passage id counts as free standing', () {
    final grouped = groupPassageSets([
      q('a', passageId: ''),
      q('b'),
      q('c', passageId: ''),
    ]);

    expect(grouped.map((question) => question.id), ['a', 'b', 'c']);
  });
}
