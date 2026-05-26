import 'package:cse_cet_reviewer/features/mock_exam/mock_exam.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
