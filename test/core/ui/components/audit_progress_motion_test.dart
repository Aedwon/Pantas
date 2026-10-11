import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/components/half_ring_gauge.dart';
import '../../../helpers/accessibility.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
        'HP_Day fill overlaps the delayed check and caches painter $brightness',
        (tester) async {
      await pumpAccessibilitySurface(tester, const ProgressRing(fraction: 1),
          brightness: brightness);
      final ring = find.byKey(const ValueKey('progress-ring-paint'));
      expect(ring, findsOneWidget);
      final painter = tester.widget<CustomPaint>(ring).painter;
      await tester.pump(const Duration(milliseconds: 300));
      expect(
          identical(tester.widget<CustomPaint>(ring).painter, painter), isTrue);
      expect(
          ring,
          paints
            ..circle()
            ..something((method, args) {
              if (method != #drawArc) return false;
              expect(args[2] as double, closeTo(math.pi * 2 * .9419172, .003));
              return true;
            }));
      expect(
          tester
              .widget<Opacity>(find.descendant(
                  of: find.byKey(const ValueKey('check-mark-scale')),
                  matching: find.byType(Opacity)))
              .opacity,
          0);
      await tester.pump(const Duration(milliseconds: 200));
      expect(
          tester
              .widget<Transform>(find.byKey(const ValueKey('check-mark-scale')))
              .transform
              .storage[0],
          closeTo(.4, .002));
      await tester.pump(const Duration(milliseconds: 210));
      expect(
          tester
              .widget<Transform>(find.byKey(const ValueKey('check-mark-scale')))
              .transform
              .storage[0],
          closeTo(1.05244, .002));
      expect(
          identical(tester.widget<CustomPaint>(ring).painter, painter), isTrue);
      await tester.pump(const Duration(milliseconds: 210));
      expect(
          tester
              .widget<Transform>(find.byKey(const ValueKey('check-mark-scale')))
              .transform
              .storage[0],
          1);
      await pumpAccessibilitySurface(tester, const ProgressRing(fraction: 1),
          brightness: brightness, disableAnimations: true);
      expect(
          tester
              .widget<Transform>(find.byKey(const ValueKey('check-mark-scale')))
              .transform
              .storage[0],
          1);
    });
    testWidgets(
        'gauge repaints without replacing static paint or label $brightness',
        (tester) async {
      await pumpAccessibilitySurface(
          tester, const HalfRingGauge(fraction: .61, label: 'Recent accuracy'),
          brightness: brightness);
      final paint = find.byKey(const ValueKey('half-ring-paint'));
      final painter = tester.widget<CustomPaint>(paint).painter;
      final label = tester.widget<Text>(find.text('Recent accuracy'));
      await tester.pump(const Duration(milliseconds: 850));
      expect(identical(tester.widget<CustomPaint>(paint).painter, painter),
          isTrue);
      expect(
          identical(tester.widget<Text>(find.text('Recent accuracy')), label),
          isTrue);
      expect(find.text('57'), findsOneWidget);
      expect(
          paint,
          paints
            ..arc(rect: const Rect.fromLTWH(18, 10, 184, 184), strokeWidth: 16)
            ..something((method, args) {
              if (method != #drawArc) return false;
              expect(
                  args[2] as double, closeTo(math.pi * .61 * .9419172, .003));
              return true;
            }));
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });
  }
}
