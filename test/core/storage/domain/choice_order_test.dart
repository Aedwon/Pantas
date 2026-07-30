import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/choice_order.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  List<Choice> makeChoices({int count = 4, int correctIndex = 0}) {
    const labels = ['A', 'B', 'C', 'D', 'E', 'F'];
    return List.generate(
      count,
      (i) => Choice(
        id: 'q1-choice-${labels[i].toLowerCase()}',
        label: labels[i],
        text: 'Option ${labels[i]}',
        isCorrect: i == correctIndex,
      ),
    );
  }

  test('the same question always gets the same order', () {
    final first = orderChoicesFor('q-abc', makeChoices());
    final second = orderChoicesFor('q-abc', makeChoices());

    expect(
      first.map((c) => c.id).toList(),
      equals(second.map((c) => c.id).toList()),
    );
  });

  test('no choice is lost, duplicated or altered', () {
    final original = makeChoices();
    final ordered = orderChoicesFor('q-abc', original);

    expect(ordered.length, equals(original.length));
    expect(
      ordered.map((c) => c.id).toSet(),
      equals(original.map((c) => c.id).toSet()),
    );
    for (final choice in ordered) {
      final source = original.firstWhere((c) => c.id == choice.id);
      expect(choice.text, equals(source.text));
      expect(choice.isCorrect, equals(source.isCorrect));
      expect(choice.rationale, equals(source.rationale));
    }
  });

  test('exactly one choice stays correct', () {
    final ordered = orderChoicesFor('q-abc', makeChoices());

    expect(ordered.where((c) => c.isCorrect).length, equals(1));
  });

  test('labels are re-lettered to match the new positions', () {
    final ordered = orderChoicesFor('q-abc', makeChoices());

    expect(
      ordered.map((c) => c.label).toList(),
      equals(['A', 'B', 'C', 'D']),
    );
  });

  test('a two-choice question re-letters to A and B', () {
    final ordered = orderChoicesFor('q-abc', makeChoices(count: 2));

    expect(ordered.map((c) => c.label).toList(), equals(['A', 'B']));
  });

  test('an empty choice list is returned unchanged', () {
    expect(orderChoicesFor('q-abc', const []), isEmpty);
  });

  test(
    'a corpus of always-first answers spreads across every position',
    () {
      final counts = <int, int>{};
      for (var i = 0; i < 2000; i++) {
        final ordered = orderChoicesFor('q-$i', makeChoices());
        final position = ordered.indexWhere((c) => c.isCorrect);
        counts[position] = (counts[position] ?? 0) + 1;
      }

      expect(counts.keys.toSet(), equals({0, 1, 2, 3}));
      // Every position lands within a wide band of the 500 an even spread
      // would give. This is a bias check, not a randomness proof.
      for (final position in [0, 1, 2, 3]) {
        expect(counts[position], greaterThan(350));
        expect(counts[position], lessThan(650));
      }
    },
  );

  test('different questions do not all get the same permutation', () {
    final permutations = <String>{};
    for (var i = 0; i < 50; i++) {
      final ordered = orderChoicesFor('q-$i', makeChoices());
      permutations.add(ordered.map((c) => c.text).join());
    }

    expect(permutations.length, greaterThan(1));
  });
}
