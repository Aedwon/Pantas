import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/ui/components/week_strip.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/presentation/home_providers.dart';
import 'package:pantas/features/home/presentation/widgets/home_masthead.dart';

const _examId = 'upcat';

HomeWeekStripData _week(int todayIndex, {double fraction = .48}) =>
    HomeWeekStripData(
      states: [
        for (var i = 0; i < 7; i++)
          if (i == todayIndex)
            WeekDayState.today
          else if (i < todayIndex)
            WeekDayState.done
          else
            WeekDayState.plain,
      ],
      todayFraction: fraction,
    );

Future<void> _pump(
  WidgetTester tester, {
  required double width,
  required DateTime now,
  required HomeWeekStripData week,
  double textScale = 1,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        homeMastheadProvider.overrideWith(
          (ref) async => HomeMastheadData(
            name: 'Aedwon',
            examShortName: 'CSE Pro',
            examDate: ExamDate.onDay(DateTime(2027, 3, 14)),
          ),
        ),
        weekStripProvider(_examId).overrideWith((ref) async => week),
      ],
      child: MaterialApp(
        theme: buildLightTheme(),
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(width, 844),
            textScaler: TextScaler.linear(textScale),
          ),
          child: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: width,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: HomeMasthead(
                      examId: _examId,
                      now: now,
                      web: false,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  final thursday = DateTime(2026, 10, 15, 20);

  for (final scale in [1.0, 2.0]) {
    // D196: on the phone the full chip stays on one line while at least
    // three days fit beside it; at large text it goes under the days.
    for (final width in [320.0, 390.0, 520.0]) {
      testWidgets('phone chip placement at $width, x$scale', (tester) async {
        await _pump(
          tester,
          width: width,
          now: thursday,
          week: _week(4),
          textScale: scale,
        );
        expect(tester.takeException(), isNull);
        final strip = tester.getRect(find.byType(WeekStrip));
        final chip = tester.getRect(
          find.byKey(const ValueKey('masthead-exam-chip')),
        );
        if (width == 320) {
          // Fits three days or drops the chip, by the font's width: the
          // exact cases are in week_window_test with the app font.
        } else if (scale == 1) {
          expect(chip.left, greaterThanOrEqualTo(strip.right - 0.01));
          expect(chip.top, lessThan(strip.bottom));
        } else {
          expect(chip.top, greaterThanOrEqualTo(strip.bottom));
          // 4 px in from the strip's left edge, with no rule and no bridge.
          expect(chip.left - strip.left, 4);
        }
        expect(
          find.byKey(const ValueKey('masthead-bridge-dots')),
          findsNothing,
        );
      });
    }

    for (final width in [600.0, 768.0]) {
      testWidgets(
          'from 600 up the chip stays beside the days at $width, '
          'x$scale', (tester) async {
        await _pump(
          tester,
          width: width,
          now: thursday,
          week: _week(4),
          textScale: scale,
        );
        expect(tester.takeException(), isNull);
        final strip = tester.getRect(find.byType(WeekStrip));
        final chip = tester.getRect(
          find.byKey(const ValueKey('masthead-exam-chip')),
        );
        expect(chip.left, greaterThanOrEqualTo(strip.right));
        expect(chip.top, lessThan(strip.bottom));
      });
    }
  }

  testWidgets('every day is a 44 wide target', (tester) async {
    await _pump(tester, width: 390, now: thursday, week: _week(4));
    // D196: three to five days, depending on the room beside the chip.
    var shown = 0;
    for (var i = 0; i < 5; i++) {
      final key = find.byKey(ValueKey('week-day-$i'));
      if (key.evaluate().isEmpty) continue;
      shown++;
      expect(tester.getRect(key).width, closeTo(44, .01));
    }
    expect(shown, inInclusiveRange(3, 5));
  });
}
