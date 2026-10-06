import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/mock_exam/domain/mock_results.dart';

void main() {
  test('old mock answers default to no reasons or note', () {
    const answer = MockAnswer(selectedIndex: 1, atSec: 12);
    expect(answer.missReason, isNull);
    expect(answer.blankReason, isNull);
    expect(answer.reasonNote, isNull);
  });

  test('old section results default to unknown wrong and blank counts', () {
    const result = SectionResult(
      sectionId: 's1',
      name: 'Math',
      correct: 3,
      total: 5,
      retiredCount: 0,
      timeSeconds: 90,
    );
    expect(result.wrong, isNull);
    expect(result.blank, isNull);
  });

  test('answer equality distinguishes recorded reasons and notes', () {
    const base = MockAnswer(selectedIndex: 1, atSec: 12);
    expect(
      const MockAnswer(
        selectedIndex: 1,
        atSec: 12,
        missReason: MissReason.other,
        reasonNote: 'Wrong formula',
      ),
      isNot(base),
    );
    expect(
      const MockAnswer(
        selectedIndex: 1,
        atSec: 12,
        blankReason: BlankReason.skippedToReturn,
      ),
      isNot(base),
    );
  });
}
