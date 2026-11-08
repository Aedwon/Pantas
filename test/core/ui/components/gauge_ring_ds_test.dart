import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/half_ring_gauge.dart';
import 'package:pantas/core/ui/components/placeholder_figure.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';

import '../../../helpers/ds_matrix.dart';

void main() {
  dsMatrix(
    'gauge: 224 by 118 dial, 14 px stroke, liquid gradient, number under',
    (context) => HalfRingGauge(
      fraction: .68,
      label: 'Overall accuracy',
      web: MediaQuery.sizeOf(context).width >= 1024,
    ),
    check: (tester, cell) async {
      final palette = cell.dark ? PantasColors.dark : PantasColors.light;
      await tester.pump(const Duration(milliseconds: 1800));
      final paint = find.byKey(const ValueKey('half-ring-paint'));
      expect(tester.getSize(paint), const Size(224, 118));
      expect(
        paint,
        paints
          ..arc(
            rect: const Rect.fromLTWH(7, 6, 210, 210),
            strokeWidth: 14,
            color: palette.fill,
          )
          ..arc(
            strokeWidth: 14,
            color: palette.accent,
            sweepAngle: math.pi * .68,
          ),
      );
      final wide = cell.width >= 1024;
      final number = tester.widget<Text>(find.text('68'));
      expect(number.style!.fontSize, wide ? 48 : 44);
      expect(number.style!.fontWeight, FontWeight.w700);
      final unit = tester.widget<Text>(find.text('%'));
      expect(unit.style!.fontSize, 22);
      expect(unit.style!.fontWeight, FontWeight.w600);
      expect(unit.style!.color, palette.textSecondary);
      final label = tester.widget<Text>(find.text('Overall accuracy'));
      expect(label.style!.fontSize, 15);
      expect(label.style!.color, palette.textSecondary);
    },
  );

  dsMatrix(
    'progress ring: 24, 34 and 44 px, divider track, accent arc',
    (context) => const Row(
      children: [
        ProgressRing(fraction: .5, showCheck: false),
        SizedBox(width: 8),
        ProgressRing(fraction: .5, size: 34, showCheck: false),
        SizedBox(width: 8),
        ProgressRing.pull(fraction: .5),
      ],
    ),
    check: (tester, cell) async {
      final palette = cell.dark ? PantasColors.dark : PantasColors.light;
      await tester.pump(const Duration(milliseconds: 1500));
      final rings = find.byKey(const ValueKey('progress-ring-paint'));
      expect(tester.getSize(rings.at(0)), const Size(24, 24));
      expect(tester.getSize(rings.at(1)), const Size(34, 34));
      expect(tester.getSize(rings.at(2)), const Size(44, 44));
      // 24 px: r 10.5, track 2 in `divider`, arc 2.4 in `accent`, round cap.
      expect(
        rings.at(0),
        paints
          ..circle(radius: 10.5, strokeWidth: 2, color: palette.divider)
          ..arc(
            strokeWidth: (Paint()..strokeWidth = 2.4).strokeWidth,
            strokeCap: StrokeCap.round,
            color: palette.accent,
          ),
      );
      // 44 px: r 19, arc 2.5 with a butt cap.
      expect(
        rings.at(2),
        paints
          ..circle(radius: 19, strokeWidth: 2.5)
          ..arc(strokeWidth: 2.5, strokeCap: StrokeCap.butt),
      );
    },
  );

  testWidgets('an empty ring draws no arc, so no dot shows at the top',
      (tester) async {
    await pumpDs(
      tester,
      dsCells.first,
      const ProgressRing(fraction: 0),
    );
    await tester.pumpAndSettle();
    final ring = find.byKey(const ValueKey('progress-ring-paint'));
    expect(ring, paints..circle());
    expect(ring, isNot(paints..arc()));
  });

  dsMatrix(
    'placeholder figure: web-body text in text-primary',
    (context) => const PlaceholderFigure(27, reason: 'Needs a source.'),
    check: (tester, cell) async {
      final palette = cell.dark ? PantasColors.dark : PantasColors.light;
      final text = tester.widget<Text>(find.text('27'));
      expect(text.style!.fontSize, 16);
      expect(text.style!.color, palette.textPrimary);
      expect(find.text('Needs a source.'), findsNothing);
    },
  );
}
