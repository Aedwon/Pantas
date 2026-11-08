import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
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
                  child: HomeMasthead(examId: _examId, now: now, web: false),
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

/// The right edge of what the eye reads as the last day: its number, or the
/// today mark when the last day is today.
double _lastDayRight(WidgetTester tester, {required bool lastIsToday}) {
  final cell = find.byKey(const ValueKey('week-day-6'));
  if (lastIsToday) {
    final ring = find.descendant(
      of: cell,
      matching: find.byType(ProgressRing),
    );
    if (ring.evaluate().isNotEmpty) return tester.getRect(ring).right;
    final disc = find.descendant(
      of: cell,
      matching: find.byWidgetPredicate(
        (w) =>
            w is DecoratedBox &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).shape == BoxShape.circle,
      ),
    );
    return tester.getRect(disc.first).right;
  }
  final number = find.descendant(of: cell, matching: find.byType(Text));
  // The first Text in the cell is the weekday name; the number follows it.
  return tester.getRect(number.at(1)).right;
}

void _expectBalanced(WidgetTester tester, {required bool lastIsToday}) {
  // On a narrow strip the last cell can start partly out of view. Only what
  // the strip shows counts, so the number's edge is clipped to the strip.
  final stripRight = tester.getRect(find.byType(WeekStrip)).right;
  final numberRight = min(
    _lastDayRight(tester, lastIsToday: lastIsToday),
    stripRight,
  );
  final dots =
      tester.getRect(find.byKey(const ValueKey('masthead-bridge-dots')));
  final tile = tester.getRect(find.byKey(const ValueKey('masthead-exam-chip')));
  // The dots are a 15 px wide group inside a taller padded box.
  final dotsLeft = dots.left;
  final dotsRight = dots.right;
  final left = dotsLeft - numberRight;
  final right = tile.left - dotsRight;
  expect(left, greaterThan(0), reason: 'dots must not touch the number');
  expect(right, greaterThan(0), reason: 'dots must not touch the tile');
  expect(
    (left - right).abs(),
    lessThanOrEqualTo(1),
    reason: 'left gap $left, right gap $right',
  );
}

void main() {
  // Thursday 15 Oct 2026: the week ends on Saturday 17, a two digit number.
  final thursday = DateTime(2026, 10, 15, 20);
  // Tuesday 3 Nov 2026: the week ends on Saturday 7, a one digit number.
  final tuesday = DateTime(2026, 11, 3, 20);
  // Saturday 17 Oct 2026: the last day is today.
  final saturday = DateTime(2026, 10, 17, 20);

  for (final width in [320.0, 360.0, 390.0, 430.0, 520.0]) {
    for (final scale in [1.0, 1.3, 2.0]) {
      testWidgets(
          'dots sit centered after a two digit day at $width px, '
          'text $scale', (tester) async {
        await _pump(
          tester,
          width: width,
          now: thursday,
          week: _week(4),
          textScale: scale,
        );
        _expectBalanced(tester, lastIsToday: false);
      });

      testWidgets(
          'dots sit centered after a one digit day at $width px, '
          'text $scale', (tester) async {
        await _pump(
          tester,
          width: width,
          now: tuesday,
          week: _week(2),
          textScale: scale,
        );
        _expectBalanced(tester, lastIsToday: false);
      });
    }
  }

  testWidgets('dots sit centered after today on Saturday', (tester) async {
    await _pump(tester, width: 390, now: saturday, week: _week(6));
    _expectBalanced(tester, lastIsToday: true);
  });

  testWidgets('dots sit centered after today on Saturday with no progress',
      (tester) async {
    await _pump(
      tester,
      width: 390,
      now: saturday,
      week: _week(6, fraction: 0),
    );
    _expectBalanced(tester, lastIsToday: true);
  });
}
