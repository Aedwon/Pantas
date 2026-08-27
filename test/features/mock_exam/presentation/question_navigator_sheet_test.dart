import 'dart:ui' show Tristate;

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/mock_exam/mock_exam.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('question navigator jumps to tapped question', (tester) async {
    var index = -1;
    await tester.pumpApp(
      QuestionNavigatorSheet(
        sections: const [
          SampledMockSection(
            sectionId: 's1',
            name: 'Part 1',
            questionIds: ['q1', 'q2'],
          ),
        ],
        currentIndex: 0,
        answers: const {},
        flags: const {},
        onJumpTo: (value) => index = value,
      ),
    );

    await tester.tap(find.text('2'));
    expect(index, 1);
  });

  testWidgets('next blank and next flagged choose expected targets',
      (tester) async {
    final jumps = <int>[];
    await tester.pumpApp(
      QuestionNavigatorSheet(
        sections: const [
          SampledMockSection(
            sectionId: 's1',
            name: 'Part 1',
            questionIds: ['q1', 'q2', 'q3'],
          ),
        ],
        currentIndex: 0,
        answers: const {'q1': MockAnswer(selectedIndex: 0, atSec: 1)},
        flags: const {'q3'},
        onJumpTo: jumps.add,
      ),
    );

    await tester.tap(find.text('Next blank'));
    await tester.tap(find.text('Next flagged'));

    expect(jumps, [1, 2]);
  });

  testWidgets('cells name question state and meet the 48dp target',
      (tester) async {
    await tester.pumpApp(
      QuestionNavigatorSheet(
        sections: const [
          SampledMockSection(
            sectionId: 's1',
            name: 'Part 1',
            questionIds: ['q1', 'q2'],
          ),
        ],
        currentIndex: 0,
        answers: const {'q1': MockAnswer(selectedIndex: 0, atSec: 1)},
        flags: const {'q2'},
        onJumpTo: (_) {},
      ),
    );

    final currentFinder = find.bySemanticsLabel(
      'Question 1, answered, not flagged',
    );
    final flaggedFinder = find.bySemanticsLabel(
      'Question 2, not answered, flagged',
    );
    expect(
      tester.getSemantics(currentFinder).flagsCollection.isSelected,
      Tristate.isTrue,
    );
    expect(
      tester.getSemantics(flaggedFinder).flagsCollection.isSelected,
      Tristate.isFalse,
    );
    for (final finder in [currentFinder, flaggedFinder]) {
      final size = tester.getSize(finder);
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    }
  });

  testWidgets('named navigator actions expose enabled and disabled state',
      (tester) async {
    await tester.pumpApp(
      QuestionNavigatorSheet(
        sections: const [
          SampledMockSection(
            sectionId: 's1',
            name: 'Part 1',
            questionIds: ['q1'],
          ),
        ],
        currentIndex: 0,
        answers: const {'q1': MockAnswer(selectedIndex: 0, atSec: 1)},
        flags: const {},
        onJumpTo: (_) {},
      ),
    );

    for (final label in ['Next blank question', 'Next flagged question']) {
      final finder = find.bySemanticsLabel(label);
      final node = tester.getSemantics(finder);
      expect(node.flagsCollection.isButton, isTrue);
      expect(node.flagsCollection.isEnabled, Tristate.isFalse);
      final size = tester.getSize(finder);
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    }
  });
}
