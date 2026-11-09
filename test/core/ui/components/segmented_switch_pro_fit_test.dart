import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pro_tag.dart';
import 'package:pantas/core/ui/components/segmented_switch.dart';

import '../../../helpers/accessibility.dart';
import '../../../helpers/ds_matrix.dart';

/// Performance page, Free account: Subjects, Topics (Pro) and Lessons (Pro)
/// in the row left by the sort button. At normal text size the control must
/// fit without scrolling and show every Pro mark whole (SegmentedControl and
/// ProMark READMEs). Scrolling is only for large text.
void main() {
  setUpAll(loadDsFonts);

  // 390 wide: 16 + row + 8 + 36 sort button + 16. At 320 the row (244) is
  // too narrow for three labels and two marks, so README lets it scroll.
  for (final (screen, row) in [(390.0, 314.0)]) {
    testWidgets('at 100% on a $screen screen the Pro segments fit', (
      tester,
    ) async {
      await pumpAccessibilitySurface(
        tester,
        SizedBox(
          width: row,
          child: SegmentedSwitch(
            labels: const ['Subjects', 'Topics', 'Lessons'],
            proMarks: const [1, 2],
            selected: 0,
            onChanged: (_) {},
          ),
        ),
        viewportSize: Size(screen, 844),
        disableAnimations: true,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final control = tester.getRect(find.byType(SegmentedSwitch));
      expect(
        find.descendant(
          of: find.byType(SegmentedSwitch),
          matching: find.byType(SingleChildScrollView),
        ),
        findsNothing,
        reason: 'the control scrolls at normal text',
      );
      final marks = find.byType(ProMark);
      expect(marks, findsNWidgets(2));
      for (final mark in tester.widgetList<ProMark>(marks).indexed) {
        final r = tester.getRect(marks.at(mark.$1));
        expect(r.left, greaterThanOrEqualTo(control.left));
        expect(r.right, lessThanOrEqualTo(control.right));
        expect(r.width, greaterThan(24), reason: 'the mark is whole');
      }
    });
  }
}
