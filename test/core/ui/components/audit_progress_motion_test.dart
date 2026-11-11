import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/half_ring_gauge.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';

import '../../../helpers/accessibility.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
        'HP_Day fill overlaps the delayed check and caches painter $brightness',
        (tester) async {
      await pumpAccessibilitySurface(
        tester,
        const ProgressRing(fraction: 1),
        brightness: brightness,
      );
      final ring = find.byKey(const ValueKey('progress-ring-paint'));
      expect(ring, findsOneWidget);
      final painter = tester.widget<CustomPaint>(ring).painter;
      // The arc waits `dur-wait` (300), grows over `dur-long-3` (900) on
      // `motion-house`; the check starts 120 before the fill ends and pops
      // on the spring, 1520 ms in all.
      const total = 1520.0;
      double fill(double ms) =>
          PantasCurves.house.transform(((ms - 300) / 900).clamp(0.0, 1.0));
      double scaleAt(double ms) =>
          .4 +
          .6 *
              PantasCurves.spring
                  .transform(((ms - 1080) / (total - 1080)).clamp(0.0, 1.0));
      Finder checkScale() => find.byKey(const ValueKey('check-mark-scale'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        identical(tester.widget<CustomPaint>(ring).painter, painter),
        isTrue,
      );
      expect(
        tester
            .widget<Opacity>(
              find.descendant(
                of: checkScale(),
                matching: find.byType(Opacity),
              ),
            )
            .opacity,
        0,
      );
      await tester.pump(const Duration(milliseconds: 450));
      expect(
        ring,
        paints
          ..circle()
          ..something((method, args) {
            if (method != #drawArc) return false;
            expect(args[2] as double, closeTo(math.pi * 2 * fill(750), .003));
            return true;
          }),
      );
      await tester.pump(const Duration(milliseconds: 450));
      expect(
        tester.widget<Transform>(checkScale()).transform.storage[0],
        closeTo(scaleAt(1200), .002),
      );
      expect(
        identical(tester.widget<CustomPaint>(ring).painter, painter),
        isTrue,
      );
      await tester.pump(const Duration(milliseconds: 320));
      expect(tester.widget<Transform>(checkScale()).transform.storage[0], 1);
      await pumpAccessibilitySurface(
        tester,
        const ProgressRing(fraction: 1),
        brightness: brightness,
        disableAnimations: true,
      );
      expect(
        tester
            .widget<Transform>(find.byKey(const ValueKey('check-mark-scale')))
            .transform
            .storage[0],
        1,
      );
    });
    testWidgets(
        'gauge repaints without replacing static paint or label $brightness',
        (tester) async {
      await pumpAccessibilitySurface(
        tester,
        const HalfRingGauge(fraction: .61, label: 'Recent accuracy'),
        brightness: brightness,
      );
      final paint = find.byKey(const ValueKey('half-ring-paint'));
      final painter = tester.widget<CustomPaint>(paint).painter;
      final label = tester.widget<Text>(find.text('Recent accuracy'));
      await tester.pump(const Duration(milliseconds: 850));
      expect(
        identical(tester.widget<CustomPaint>(paint).painter, painter),
        isTrue,
      );
      expect(
        identical(tester.widget<Text>(find.text('Recent accuracy')), label),
        isTrue,
      );
      // The arc waits `dur-wait` (300) and fills over the rest of 1400 ms on
      // `motion-gauge`: the dial is 224 by 118 with a 14 px stroke.
      final eased = PantasCurves.gauge.transform((850 - 300) / 1100);
      expect(find.text('${(.61 * eased * 100).round()}'), findsOneWidget);
      expect(
        paint,
        paints
          ..arc(rect: const Rect.fromLTWH(7, 6, 210, 210), strokeWidth: 14)
          ..something((method, args) {
            if (method != #drawArc) return false;
            expect(
              args[2] as double,
              closeTo(math.pi * .61 * eased, .003),
            );
            return true;
          }),
      );
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });
  }
}
