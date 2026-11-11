import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/domain/lesson_day_context.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_rail.dart';

import '../../../helpers/accessibility.dart';
import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('the rail fills to the fraction it is given', (tester) async {
    await tester.pumpApp(const ReaderRail(progress: 0.5));

    expect(tester.getSize(find.byType(ReaderRail)).height, 3);
    expect(
      tester.getSize(find.byKey(const ValueKey('reader-progress-fill'))).width,
      tester.getSize(find.byType(ReaderRail)).width * .5,
    );
    expect(find.byKey(const ValueKey('reader-day-tick-1')), findsNothing);
  });

  for (final fraction in [double.nan, -.2, 0.0, .5, 1.0, 1.2]) {
    testWidgets('rail bounds fraction=$fraction', (tester) async {
      await tester.pumpApp(
        SizedBox(
          width: 300,
          child: ReaderRail(progress: fraction),
        ),
      );
      expect(
        tester
            .getSize(find.byKey(const ValueKey('reader-progress-fill')))
            .width,
        300 * (fraction.isNaN ? 0 : fraction.clamp(0.0, 1.0)),
      );
    });
  }

  for (var index = 0; index < 3; index++) {
    testWidgets('day rail follows supplied order at index=$index',
        (tester) async {
      final day = LessonDayContext(
        date: DateTime(2026, 10, 14),
        lessonIds: const ['last-in-corpus', 'first-in-corpus', 'middle'],
        index: index,
      );
      await tester.pumpApp(
        SizedBox(
          width: 300,
          child: ReaderRail(progress: .5, dayContext: day),
        ),
      );
      expect(
        tester
            .getSize(find.byKey(const ValueKey('reader-progress-fill')))
            .width,
        closeTo((index + .5) * 100, .00001),
      );
      for (var boundary = 1; boundary < 3; boundary++) {
        final tick = tester.widget<Positioned>(
          find.byKey(ValueKey('reader-day-tick-$boundary')),
        );
        expect(tick.left, boundary * 100 - .5);
        expect(tick.top, -1);
        expect(tick.width, 1);
        expect(tick.height, 5);
      }
      expect(find.byKey(const ValueKey('reader-day-tick-3')), findsNothing);
    });
  }

  testWidgets('one-lesson day has no internal boundary', (tester) async {
    await tester.pumpApp(
      ReaderRail(
        progress: 1,
        dayContext: LessonDayContext(
          date: DateTime(2026, 10, 14),
          lessonIds: const ['only'],
          index: 0,
        ),
      ),
    );
    expect(find.byType(Positioned), findsNothing);
  });

  for (final brightness in Brightness.values) {
    testWidgets('day boundaries contrast across the rail in $brightness',
        (tester) async {
      await pumpAccessibilitySurface(
        tester,
        SizedBox(
          width: 300,
          child: ReaderRail(
            progress: 1,
            dayContext: LessonDayContext(
              date: DateTime(2026, 10, 14),
              lessonIds: const ['l1', 'l2', 'l3'],
              index: 1,
            ),
          ),
        ),
        brightness: brightness,
      );
      final colors = tester.element(find.byType(ReaderRail)).colors;
      final tick = tester
          .widget<ColoredBox>(
            find.descendant(
              of: find.byKey(const ValueKey('reader-day-tick-1')),
              matching: find.byType(ColoredBox),
            ),
          )
          .color;
      for (final background in [
        colors.surface,
        colors.fill,
        colors.accentFill,
      ]) {
        final a = tick.computeLuminance();
        final b = background.computeLuminance();
        final contrast =
            (a > b ? (a + .05) / (b + .05) : (b + .05) / (a + .05));
        expect(contrast, greaterThanOrEqualTo(3));
      }
      expect(tester.takeException(), isNull);
    });
  }
}
