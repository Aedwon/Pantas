import 'package:cse_cet_reviewer/features/quiz/domain/picker/practice_summary.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/widgets/length_wheel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  test('question steps run 3 to 50 by one', () {
    final values = wheelValues(PracticeUnitMode.questions);

    expect(values.first, 3);
    expect(values.last, 50);
    expect(values, hasLength(48));
  });

  test('minute steps run by one to 30, then by five to 60', () {
    final values = wheelValues(PracticeUnitMode.minutes);

    expect(values.first, 2);
    expect(values, contains(30));
    expect(values, contains(35));
    expect(values, isNot(contains(31)));
    expect(values.last, 60);
  });

  test('snapping picks the nearest available value', () {
    expect(snapToNearest(33, wheelValues(PracticeUnitMode.minutes)), 35);
    expect(snapToNearest(31, wheelValues(PracticeUnitMode.minutes)), 30);
  });

  test('snapping clamps below the range', () {
    expect(snapToNearest(1, wheelValues(PracticeUnitMode.questions)), 3);
  });

  test('snapping clamps above the range', () {
    expect(snapToNearest(90, wheelValues(PracticeUnitMode.questions)), 50);
  });

  testWidgets('the wheel reports the value scrolled into the band',
      (tester) async {
    int? selected;
    await tester.pumpApp(
      SizedBox(
        width: 260,
        height: 58,
        child: LengthWheel(
          mode: PracticeUnitMode.questions,
          value: 10,
          onChanged: (v) => selected = v,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Drag on LengthWheel horizontally
    await tester.drag(find.byType(LengthWheel), const Offset(-156, 0));
    await tester.pumpAndSettle();

    expect(selected, 13);
  });
}
