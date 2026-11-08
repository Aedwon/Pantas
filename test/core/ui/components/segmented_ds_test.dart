import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/segmented_switch.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/web/web_components.dart';

import '../../../helpers/ds_matrix.dart';

void main() {
  dsMatrix(
    'segmented control: fill track, radius 8, selected 600, 44 targets',
    (context) => SizedBox(
      width: 358,
      child: SegmentedSwitch(
        labels: const ['Day', 'Week', '6 Months'],
        selected: 1,
        onChanged: (_) {},
      ),
    ),
    check: (tester, cell) async {
      final palette = cell.dark ? PantasColors.dark : PantasColors.light;
      final wide = cell.width >= 1024;
      // The phone draws the label itself; the desktop button carries it.
      TextStyle styleOf(String label) {
        if (!wide) return tester.widget<Text>(find.text(label)).style!;
        final style = tester
            .widget<TextButton>(
              find.ancestor(
                of: find.text(label),
                matching: find.byType(TextButton),
              ),
            )
            .style!;
        return style.textStyle!.resolve({})!.copyWith(
          color: style.foregroundColor!.resolve({}),
        );
      }

      final selected = styleOf('Week');
      final other = styleOf('Day');
      expect(selected.fontWeight, FontWeight.w600);
      expect(other.fontWeight, FontWeight.w500);
      expect(selected.fontSize, 14);
      expect(selected.color, palette.textPrimary);
      expect(other.color, palette.textOnFill);
      // A label never wraps: it is one line high.
      expect(
        tester.getSize(find.text('6 Months')).height,
        lessThan(30 * cell.scale),
      );
      final track = wide
          ? find.byKey(const ValueKey('segmented-control-track'))
          : find.byKey(const ValueKey('segmented-switch-track'));
      final deco =
          tester.widget<DecoratedBox>(track).decoration as BoxDecoration;
      expect(deco.color, palette.fill);
      expect(deco.borderRadius, BorderRadius.circular(8));
      // The segments are real 44 px targets; the well stays 36 to 38.
      final control = find.byWidgetPredicate(
        (w) => w is SegmentedSwitch,
      );
      expect(tester.getSize(control).height, greaterThanOrEqualTo(44));
    },
  );

  testWidgets('the thumb is surface-segment-on with the segment shadow',
      (tester) async {
    await pumpDs(
      tester,
      dsCells.first,
      WebSegmentedControl(
        labels: const ['Subjects', 'Topics'],
        selected: 0,
        onChanged: (_) {},
      ),
    );
    final thumb = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byKey(const ValueKey('segmented-control-thumb')),
        matching: find.byType(DecoratedBox),
      ),
    );
    final deco = thumb.decoration as BoxDecoration;
    expect(deco.color, PantasColors.light.surfaceSegmentOn);
    expect(deco.boxShadow, isNotEmpty);
    expect(deco.borderRadius, BorderRadius.circular(8));
  });
}
