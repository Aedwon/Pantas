import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/segmented_switch.dart';

import '../../../helpers/accessibility.dart';
import '../../../helpers/ds_matrix.dart';

/// SegmentedControl README: labels never wrap, the track scrolls when the row
/// is too narrow, and the control stays usable: the chosen segment is in view.
void main() {
  setUpAll(loadDsFonts);

  for (final selected in [0, 1, 2]) {
    testWidgets('at 200% the selected segment $selected is fully in view',
        (tester) async {
      await pumpAccessibilitySurface(
        tester,
        SizedBox(
          width: 358,
          child: SegmentedSwitch(
            labels: const ['All 8', 'Wrong 5', 'Flagged 1'],
            selected: selected,
            onChanged: (_) {},
          ),
        ),
        textScale: 2,
        disableAnimations: true,
        viewportSize: const Size(390, 844),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final label = tester.getRect(
        find.text(const ['All 8', 'Wrong 5', 'Flagged 1'][selected]),
      );
      expect(label.left, greaterThanOrEqualTo(16));
      expect(label.right, lessThanOrEqualTo(16 + 358));
    });
  }

  testWidgets('moving the selection scrolls the new segment into view',
      (tester) async {
    var selected = 0;
    late StateSetter set;
    await pumpAccessibilitySurface(
      tester,
      StatefulBuilder(
        builder: (context, setState) {
          set = setState;
          return SizedBox(
            width: 358,
            child: SegmentedSwitch(
              labels: const ['Subjects', 'Topics', 'Lessons'],
              selected: selected,
              onChanged: (_) {},
            ),
          );
        },
      ),
      textScale: 2,
      viewportSize: const Size(390, 844),
    );
    await tester.pumpAndSettle();
    set(() => selected = 2);
    await tester.pumpAndSettle();
    final label = tester.getRect(find.text('Lessons'));
    expect(label.right, lessThanOrEqualTo(16 + 358));
    expect(label.left, greaterThanOrEqualTo(16));
  });
}
