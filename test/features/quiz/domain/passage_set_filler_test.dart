import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/features/quiz/domain/passage_set_filler.dart';

void main() {
  Question makeQ(String id, {String? passageId}) {
    return Question(
      id: id,
      version: 1,
      examIds: const ['e1'],
      topicId: 't1',
      language: 'en',
      stem: 'Stem for $id',
      choices: const [
        Choice(id: 'c1', label: 'A', text: 'Option A', isCorrect: true),
      ],
      explanation: 'Explanation',
      passageId: passageId,
    );
  }

  test('a set that fits is taken whole and its questions are consecutive', () {
    final free = [makeQ('f1'), makeQ('f2'), makeQ('f3'), makeQ('f4')];
    final passageSet = [
      makeQ('p1_1', passageId: 'p1'),
      makeQ('p1_2', passageId: 'p1'),
      makeQ('p1_3', passageId: 'p1'),
      makeQ('p1_4', passageId: 'p1'),
    ];

    final result = PassageSetFiller.fill(
      size: 6,
      freeStanding: free,
      setsByPassageId: {'p1': passageSet},
    );

    expect(result.length, equals(6));
    // Passage questions appear consecutively
    final p1Indices = result
        .asMap()
        .entries
        .where((e) => e.value.passageId == 'p1')
        .map((e) => e.key)
        .toList();
    expect(p1Indices.length, equals(4));
    expect(p1Indices, equals([0, 1, 2, 3]));
  });

  test('a set that does not fit in remaining room is not taken and not split',
      () {
    final free = [makeQ('f1'), makeQ('f2'), makeQ('f3')];
    final set1 = [
      makeQ('p1_1', passageId: 'p1'),
      makeQ('p1_2', passageId: 'p1'),
      makeQ('p1_3', passageId: 'p1'),
      makeQ('p1_4', passageId: 'p1'),
    ];
    final set2 = [
      makeQ('p2_1', passageId: 'p2'),
      makeQ('p2_2', passageId: 'p2'),
      makeQ('p2_3', passageId: 'p2'),
      makeQ('p2_4', passageId: 'p2'),
    ];

    final result = PassageSetFiller.fill(
      size: 6,
      freeStanding: free,
      setsByPassageId: {'p1': set1, 'p2': set2},
    );

    // Only set1 (size 4) fits in 6 slots. set2 (size 4) needs 4 remaining,
    // but only 2 remain.
    expect(result.length, equals(6));
    expect(result.where((q) => q.passageId == 'p1').length, equals(4));
    expect(result.where((q) => q.passageId == 'p2'), isEmpty);
  });

  test(
      'a session of 5 with only a 6-question set available '
      'contains zero passage questions', () {
    final free = List.generate(10, (i) => makeQ('f$i'));
    final set6 = List.generate(
      6,
      (i) => makeQ('p1_$i', passageId: 'p1'),
    );

    final result = PassageSetFiller.fill(
      size: 5,
      freeStanding: free,
      setsByPassageId: {'p1': set6},
    );

    expect(result.length, equals(5));
    expect(result.where((q) => q.passageId == 'p1'), isEmpty);
  });

  test('the result is never longer than size', () {
    final free = List.generate(20, (i) => makeQ('f$i'));
    final set4 = List.generate(4, (i) => makeQ('p1_$i', passageId: 'p1'));

    final result = PassageSetFiller.fill(
      size: 10,
      freeStanding: free,
      setsByPassageId: {'p1': set4},
    );

    expect(result.length, equals(10));
  });

  test('with no sets at all, output equals free-standing selection unchanged',
      () {
    final free = [makeQ('f1'), makeQ('f2'), makeQ('f3')];

    final result = PassageSetFiller.fill(
      size: 5,
      freeStanding: free,
      setsByPassageId: {},
    );

    expect(result, equals(free));
  });
}
