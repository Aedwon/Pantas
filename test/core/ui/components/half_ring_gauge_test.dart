import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/half_ring_gauge.dart';

import '../../../helpers/accessibility.dart';

void main() {
  for (final brightness in Brightness.values) {
    for (final fraction in [0.0, .61, 1.0]) {
      testWidgets('gauge $fraction final frame in $brightness', (tester) async {
        final widget =
            HalfRingGauge(fraction: fraction, label: 'Overall accuracy');
        await pumpAccessibilitySurface(
          tester,
          widget,
          brightness: brightness,
          disableAnimations: true,
        );
        final paint = find.byKey(const ValueKey('half-ring-paint'));
        expect(tester.getSize(paint), const Size(220, 112));
        expect(
          paint,
          paints
            ..arc(
              rect: const Rect.fromLTWH(18, 10, 184, 184),
              startAngle: math.pi,
              sweepAngle: math.pi,
              strokeWidth: 16,
              style: PaintingStyle.stroke,
            ),
        );
        if (fraction > 0) {
          expect(
            paint,
            paints
              ..arc(strokeWidth: 16)
              ..arc(
                rect: const Rect.fromLTWH(18, 10, 184, 184),
                startAngle: math.pi,
                sweepAngle: math.pi * fraction,
                strokeWidth: 16,
                color: brightness == Brightness.light
                    ? const Color(0xFF0B7A68)
                    : const Color(0xFF2FB39C),
              ),
          );
        }
        final number =
            tester.widget<Text>(find.text('${(fraction * 100).round()}'));
        expect(number.style!.fontSize, 44);
        expect(number.style!.height, 1.12);
        expect(number.style!.fontWeight, FontWeight.w700);
        expect(number.style!.letterSpacing, -1.32);
        final percent = tester.widget<Text>(find.text('%'));
        expect(percent.style!.fontSize, 20);
        expect(percent.style!.fontWeight, FontWeight.w600);
        final background = brightness == Brightness.light
            ? const Color(0xFFFFFFFF)
            : const Color(0xFF1C1C1E);
        for (final style in [number.style!, percent.style!]) {
          final luminances = [
            style.color!.computeLuminance(),
            background.computeLuminance(),
          ]..sort();
          expect(
            (luminances.last + .05) / (luminances.first + .05),
            greaterThanOrEqualTo(4.5),
          );
        }
        await expectSurvivesTextScale(
          tester,
          widget,
          viewportSize: const Size(390, 844),
          brightness: brightness,
          disableAnimations: true,
        );
      });
    }
    testWidgets('gauge delay and intermediate count in $brightness',
        (tester) async {
      await pumpAccessibilitySurface(
        tester,
        const HalfRingGauge(fraction: .61, label: 'Overall accuracy'),
        brightness: brightness,
      );
      expect(find.text('0'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('0'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 550));
      expect(find.text('57'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 550));
      expect(find.text('61'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('mock overlay receives final progress with motion off',
      (tester) async {
    double? progress;
    await pumpAccessibilitySurface(
      tester,
      HalfRingGauge(
        fraction: .61,
        label: 'Mock score',
        overlayBuilder: (context, value) {
          progress = value;
          return const Text('Mock overlay');
        },
      ),
      disableAnimations: true,
    );
    expect(progress, .61);
    expect(find.text('Mock overlay'), findsOneWidget);
  });
}
