import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/half_ring_gauge.dart';

import '../../../helpers/accessibility.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('quiz count real score and board arc in $brightness',
        (tester) async {
      final semantics = tester.ensureSemantics();

      const gauge = HalfRingGauge.quizCount(correct: 7, total: 10);
      await pumpAccessibilitySurface(
        tester,
        gauge,
        brightness: brightness,
        disableAnimations: true,
      );
      final paint = find.byKey(const ValueKey('half-ring-paint'));
      expect(tester.getSize(paint), const Size(264, 128));
      expect(
        paint,
        paints
          ..arc(
            rect: const Rect.fromLTWH(24, 10, 216, 216),
            startAngle: math.pi,
            sweepAngle: math.pi,
            strokeWidth: 16,
          )
          ..arc(
            sweepAngle: math.pi * .7,
            color: brightness == Brightness.light
                ? const Color(0xFF0B7A68)
                : const Color(0xFF2FB39C),
          ),
      );
      expect(find.bySemanticsLabel('7 of 10 correct'), findsOneWidget);
      expect(find.text('%'), findsNothing);
      final score = tester.widget<Text>(find.text('7'));
      expect(score.style!.fontSize, 60);
      expect(tester.widget<Text>(find.text('/10')).style!.fontSize, 24);
      semantics.dispose();
      await expectSurvivesTextScale(
        tester,
        gauge,
        viewportSize: const Size(320, 640),
        brightness: brightness,
        disableAnimations: true,
      );
    });
  }
  testWidgets(
      'quiz rolling strip and arc share 400 to 1600 millisecond timeline',
      (tester) async {
    await pumpAccessibilitySurface(
      tester,
      const HalfRingGauge.quizCount(correct: 7, total: 10),
    );
    final paint = find.byKey(const ValueKey('half-ring-paint'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(paint, paints..arc(strokeWidth: 16));
    expect(
      tester
          .widget<Transform>(find.byKey(const ValueKey('quiz-count-strip')))
          .transform
          .getTranslation()
          .y,
      0,
    );
    await tester.pump(const Duration(milliseconds: 600));
    // Independently evaluated CSS cubic(.2,.8,.25,1) at t=.5 gives .938556667.
    expect(
      tester
          .widget<Transform>(find.byKey(const ValueKey('quiz-count-strip')))
          .transform
          .getTranslation()
          .y,
      closeTo(-420.4734, .1),
    );

    await tester.pump(const Duration(milliseconds: 600));
    expect(
      tester
          .widget<Transform>(find.byKey(const ValueKey('quiz-count-strip')))
          .transform
          .getTranslation()
          .y,
      -448,
    );
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });
  testWidgets('changing motion preference preserves the displayed count',
      (tester) async {
    await pumpAccessibilitySurface(
      tester,
      const HalfRingGauge.quizCount(correct: 7, total: 10),
      disableAnimations: true,
    );
    await pumpAccessibilitySurface(
      tester,
      const HalfRingGauge.quizCount(correct: 7, total: 10),
    );
    expect(
      tester
          .widget<Transform>(find.byKey(const ValueKey('quiz-count-strip')))
          .transform
          .getTranslation()
          .y,
      -448,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'quiz updates count even when fraction stays the same and handles zero',
      (tester) async {
    await pumpAccessibilitySurface(
      tester,
      const HalfRingGauge.quizCount(correct: 7, total: 10),
      disableAnimations: true,
    );
    await pumpAccessibilitySurface(
      tester,
      const HalfRingGauge.quizCount(correct: 14, total: 20),
      disableAnimations: true,
    );
    expect(find.text('/20'), findsOneWidget);
    expect(
      tester
          .widget<Transform>(find.byKey(const ValueKey('quiz-count-strip')))
          .transform
          .getTranslation()
          .y,
      -896,
    );
    await pumpAccessibilitySurface(
      tester,
      const HalfRingGauge.quizCount(correct: 0, total: 0),
      disableAnimations: true,
    );
    expect(find.text('/0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
