import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/accuracy_bar.dart';
import 'package:pantas/core/ui/components/half_ring_gauge.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/components/today_questions.dart';
import 'package:pantas/core/ui/components/week_strip.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';

import '../../../helpers/accessibility.dart';
import 'w2_test_support.dart';

void main() {
  test('accuracy tint matches the independent board samples and clamps', () {
    final samples = {
      .54: const Color(0xFF97C9BF),
      .58: const Color(0xFF87C0B5),
      .61: const Color(0xFF7BB9AE),
      .70: const Color(0xFF57A597),
    };
    for (final entry in samples.entries) {
      final c = PantasColors.light.accuracyTint(entry.key);
      for (final pair in [
        (c.r, entry.value.r),
        (c.g, entry.value.g),
        (c.b, entry.value.b),
      ]) {
        expect((pair.$1 - pair.$2).abs() * 255, lessThanOrEqualTo(2));
      }
    }
    expect(
      PantasColors.light.accuracyTint(.3),
      PantasColors.light.accuracyTint(.4),
    );
    expect(PantasColors.light.accuracyTint(.6), const Color(0xFF7FBCB0));
    expect(
      PantasColors.light.accuracyTint(.8),
      PantasColors.light.accuracyTint(.95),
    );
  });
  for (final brightness in Brightness.values) {
    testWidgets('empty progress outline follows board $brightness',
        (tester) async {
      await pumpAccessibilitySurface(
        tester,
        const ProgressRing(fraction: 0),
        brightness: brightness,
        disableAnimations: true,
      );
      // ProgressRing README: the track is `divider`. Dark keeps the 3:1 gray,
      // because the pale one disappears into the card.
      final colors = tester
          .element(find.byKey(const ValueKey('progress-ring-paint')))
          .colors;
      expect(
        find.byKey(const ValueKey('progress-ring-paint')),
        paints
          ..circle(
            color: brightness == Brightness.light
                ? colors.divider
                : const Color(0xFF949494),
            strokeWidth: 1.5,
          ),
      );
    });
    testWidgets('phone Today rows keep the empty ring visible $brightness',
        (tester) async {
      await pumpAccessibilitySurface(
        tester,
        TodayQuestionRow(
          title: 'Reviews',
          subtitle: 'Questions due today',
          done: 0,
          total: 4,
          onTap: () {},
        ),
        brightness: brightness,
        disableAnimations: true,
      );
      expect(
        find.byKey(const ValueKey('progress-ring-paint')),
        paints
          ..circle(
            color: brightness == Brightness.light
                ? PantasColors.light.separator
                : PantasColors.dark.chevron,
            strokeWidth: 2,
          ),
      );
    });
    testWidgets('progress ring geometry, animation and completion $brightness',
        (tester) async {
      await pumpAccessibilitySurface(
        tester,
        const ProgressRing(fraction: .5),
        brightness: brightness,
      );
      expect(tester.getSize(find.byType(ProgressRing)), const Size(24, 24));
      await tester.pump(const Duration(milliseconds: 450));
      expect(
        find.byKey(const ValueKey('progress-ring-paint')),
        paints
          ..circle(radius: 10.5)
          ..something((method, args) {
            if (method != #drawArc) return false;
            // The arc waits 300 ms, then grows over 900 on `motion-house`.
            final eased = PantasCurves.house.transform((450 - 300) / 900);
            expect(args[2] as double, closeTo(math.pi * eased, .002));
            return true;
          }),
      );
      await pumpAccessibilitySurface(
        tester,
        const ProgressRing(fraction: 1),
        brightness: brightness,
        disableAnimations: true,
      );
      expect(find.byKey(const ValueKey('check-mark-circle')), findsOneWidget);
      await expectSurvivesTextScale(
        tester,
        const ProgressRing(fraction: 0),
        brightness: brightness,
        disableAnimations: true,
      );
    });
    testWidgets('accuracy heights and measured fill widths $brightness',
        (tester) async {
      for (final topic in [false, true]) {
        final bar = topic
            ? const AccuracyBar.topicRows(accuracy: .6)
            : const AccuracyBar(accuracy: .6);
        await pumpAccessibilitySurface(
          tester,
          SizedBox(width: 200, child: bar),
          brightness: brightness,
          disableAnimations: true,
        );
        expect(tester.getSize(find.byType(AccuracyBar)).height, topic ? 4 : 5);
        expect(
          tester.getSize(find.byKey(const ValueKey('accuracy-bar-fill'))).width,
          120,
        );
      }
    });
    testWidgets('week dates, marks, keyboard and day-off colors $brightness',
        (tester) async {
      DateTime? picked;
      final strip = WeekStrip(
        today: DateTime(2026, 10, 7),
        states: const [
          WeekDayState.done,
          WeekDayState.partial,
          WeekDayState.missed,
          WeekDayState.today,
          WeekDayState.dayOff,
          WeekDayState.plain,
          WeekDayState.plain,
        ],
        onSelected: (d) => picked = d,
      );
      await pumpAccessibilitySurface(
        tester,
        strip,
        brightness: brightness,
        viewportSize: const Size(390, 844),
      );
      expect(find.text('Sun'), findsOneWidget);
      expect(find.text('Sat'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Sun')).dx,
        lessThan(tester.getTopLeft(find.text('Sat')).dx),
      );
      // Day columns are 44 wide; the gap shrinks from 10 toward 4.
      final wed = tester.getRect(find.byKey(const ValueKey('week-day-3')));
      final thu = tester.getRect(find.byKey(const ValueKey('week-day-4')));
      expect(wed.width, 44);
      expect(thu.left - wed.right, inInclusiveRange(4, 10));
      // A past or future off-day is `text-secondary` in both themes (the old
      // pale gray folded into it in design system 4.0).
      final off = brightness == Brightness.light
          ? const Color(0xFF6E6E73)
          : PantasColors.dark.textSecondary;
      expect(tester.widget<Text>(find.text('Thu')).style!.color, off);
      expect(tester.widget<Text>(find.text('8')).style!.color, off);
      expect(
        tester.widget<Text>(find.text('9')).style!.color,
        isNot(off),
        reason: 'a study day keeps its normal color',
      );
      expectContrast(
        tester.widget<Text>(find.text('Wed')).style!.color!,
        brightness == Brightness.light
            ? const Color(0xFFF5F5F7)
            : const Color(0xFF151515),
      );
      // Roving focus (ruling R1): Tab reaches one stop, the selected day or
      // Today. Left and Right pick the next day; Home and End pick the first
      // and last day shown.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(picked, DateTime(2026, 10, 7));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      expect(picked, DateTime(2026, 10, 6));
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      expect(picked, DateTime(2026, 10, 4));
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      expect(picked, DateTime(2026, 10, 10));
      await expectSurvivesTextScale(
        tester,
        strip,
        brightness: brightness,
        viewportSize: const Size(390, 844),
        disableAnimations: true,
      );
    });
    testWidgets('mock gauge precision and overlay $brightness', (tester) async {
      await pumpAccessibilitySurface(
        tester,
        HalfRingGauge(
          fraction: .694,
          label: 'Your score',
          decimalPlaces: 1,
          overlayBuilder: (context, f) => Text('Two balls $f'),
        ),
        brightness: brightness,
        disableAnimations: true,
      );
      expect(find.text('69.4'), findsOneWidget);
      expect(find.text('Two balls 0.694'), findsOneWidget);
    });
  }
}
