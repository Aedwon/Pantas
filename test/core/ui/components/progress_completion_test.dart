import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/accuracy_bar.dart';
import 'package:pantas/core/ui/components/half_ring_gauge.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/components/week_strip.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';

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
      expect(
        find.byKey(const ValueKey('progress-ring-paint')),
        paints
          ..circle(
            color: brightness == Brightness.light
                ? const Color(0xFFC7C7CC)
                : const Color(0xFF48484A),
            strokeWidth: 1.5,
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
            expect(args[2] as double, closeTo(3.1184549092656737, .002));
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
    testWidgets(
        'week strip Sunday first, all marks, keyboard, day off colors $brightness',
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
      expect(
        tester.getCenter(find.byKey(const ValueKey('week-day-3'))).dx,
        closeTo(195, 1),
      );
      expect(
        tester.widget<Text>(find.text('Thu')).style!.color,
        const Color(0xFFC7C7CC),
      );
      expectContrast(
        tester.widget<Text>(find.text('Wed')).style!.color!,
        brightness == Brightness.light ? const Color(0xFFF5F5F7) : Colors.black,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(picked, DateTime(2026, 10, 4));
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
