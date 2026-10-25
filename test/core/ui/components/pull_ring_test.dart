import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/check_mark.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';

import '../../../helpers/accessibility.dart';

void main() {
  testWidgets('pull fractions and inherited motion/theme update immediately',
      (tester) async {
    for (final step in [
      (0.0, Brightness.light, false),
      (.5, Brightness.dark, true),
      (1.0, Brightness.light, false),
    ]) {
      await pumpAccessibilitySurface(
        tester,
        ProgressRing.pull(fraction: step.$1),
        brightness: step.$2,
        disableAnimations: step.$3,
      );
      final paint = find.byKey(const ValueKey('progress-ring-paint'));
      if (step.$1 > 0) {
        expect(
          paint,
          paints
            ..circle()
            ..arc(sweepAngle: 2 * math.pi * step.$1),
        );
      }
      // MaterialApp animates a theme change independently of the live ring.
      await tester.pumpAndSettle();
      expect(
        paint,
        paints
          ..circle(
            color: step.$2 == Brightness.light
                ? PantasColors.light.separator
                : PantasColors.dark.separator,
          ),
      );
    }
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.binding.transientCallbackCount, 0);
    expect(tester.takeException(), isNull);
  });

  for (final study in [false, true]) {
    testWidgets('existing ring study=$study retains its fill motion and cap',
        (tester) async {
      await pumpAccessibilitySurface(
        tester,
        study
            ? const ProgressRing.study(fraction: .5)
            : const ProgressRing(fraction: .5),
      );
      await tester.pump(Duration(milliseconds: study ? 350 : 300));
      final paint = find.byKey(const ValueKey('progress-ring-paint'));
      expect(tester.getSize(paint), const Size(24, 24));
      expect(
        paint,
        paints
          ..circle(radius: 10.5, strokeWidth: 2)
          ..arc(
            strokeWidth: (Paint()..strokeWidth = 2.4).strokeWidth,
            strokeCap: StrokeCap.round,
            sweepAngle: math.pi * PantasCurves.houseOut.transform(.5),
          ),
      );
      await tester.pumpAndSettle();
      expect(
        paint,
        paints
          ..circle()
          ..arc(sweepAngle: math.pi),
      );
    });
  }

  for (final brightness in Brightness.values) {
    for (final fraction in [0.0, .5, 1.0]) {
      testWidgets('pull ring paints live $fraction in $brightness',
          (tester) async {
        final semantics = tester.ensureSemantics();
        await pumpAccessibilitySurface(
          tester,
          ProgressRing.pull(fraction: fraction, child: const Text('Arrow')),
          brightness: brightness,
        );
        final colors = brightness == Brightness.light
            ? PantasColors.light
            : PantasColors.dark;
        final paint = find.byKey(const ValueKey('progress-ring-paint'));
        expect(tester.getSize(paint), const Size(44, 44));
        expect(
          paint,
          paints
            ..circle(
              x: 22,
              y: 22,
              radius: 19,
              strokeWidth: 2.5,
              color: colors.separator,
            ),
        );
        if (fraction > 0) {
          expect(
            paint,
            paints
              ..circle()
              ..arc(
                rect: const Rect.fromLTWH(3, 3, 38, 38),
                startAngle: -math.pi / 2,
                sweepAngle: 2 * math.pi * fraction,
                strokeWidth: 2.5,
                strokeCap: StrokeCap.butt,
                color: colors.accent,
              ),
          );
        }
        expect(find.text('Arrow'), findsOneWidget);
        expect(find.byType(CheckMark), findsNothing);
        expect(find.bySemanticsLabel(RegExp('percent|Done')), findsNothing);
        await tester.pumpWidget(const SizedBox.shrink());
        expect(tester.takeException(), isNull);
        semantics.dispose();
      });
    }
  }

  testWidgets('switching a moving generic ring to pull cancels old fill',
      (tester) async {
    await pumpAccessibilitySurface(tester, const ProgressRing(fraction: 1));
    await tester.pump(const Duration(milliseconds: 100));
    await pumpAccessibilitySurface(
      tester,
      const ProgressRing.pull(fraction: .5),
    );
    final paint = find.byKey(const ValueKey('progress-ring-paint'));
    expect(
      paint,
      paints
        ..circle()
        ..arc(sweepAngle: math.pi),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(
      paint,
      paints
        ..circle()
        ..arc(sweepAngle: math.pi),
    );
    await pumpAccessibilitySurface(
      tester,
      const ProgressRing.study(fraction: .5),
      disableAnimations: true,
    );
    expect(tester.getSize(paint), const Size(24, 24));
    expect(
      paint,
      paints
        ..circle()
        ..arc(sweepAngle: math.pi),
    );
    expect(tester.takeException(), isNull);
  });
}
