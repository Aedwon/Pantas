import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/ui/components/week_strip.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/home/presentation/home_providers.dart';
import 'package:pantas/features/home/presentation/widgets/home_masthead.dart';

import '../../../helpers/ds_matrix.dart';
import 'home_tab_test.dart' as home_tab;

// Lead ruling D196: the phone Home row keeps the chip on one line and shows as
// many days as fit (5, 4 or 3), centered on Today; under 3 the chip drops.
// Tuesday, November 10, 2026: the week is Sun 8 to Sat 14.
final _tue = DateTime(2026, 11, 10, 9);
final _sun = DateTime(2026, 11, 8, 9);

HomeWeekStripData _week() => HomeWeekStripData(
      // Sun..Sat of the week of Nov 8.
      // ignore: prefer_const_literals_to_create_immutables
      states: [
        WeekDayState.done,
        WeekDayState.done,
        WeekDayState.today,
        WeekDayState.plain,
        WeekDayState.plain,
        WeekDayState.plain,
        WeekDayState.dayOff,
      ],
      todayFraction: .5,
      around: const {
        -2: WeekDayState.done,
        -1: WeekDayState.partial,
        7: WeekDayState.plain,
        8: WeekDayState.plain,
      },
    );

Future<void> _pump(
  WidgetTester tester, {
  required double width,
  double scale = 1,
  bool dark = false,
  DateTime? now,
  HomeWeekStripData? week,
}) async {
  tester.view
    ..physicalSize = Size(width, 1400)
    ..devicePixelRatio = 1;
  debugWebPlatformOverride = false;
  addTearDown(() {
    tester.view.reset();
    debugWebPlatformOverride = null;
  });
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
        weekStripProvider('exam_1').overrideWith(
          (ref) async => week ?? _week(),
        ),
      ],
      child: MaterialApp(
        theme: dark ? home_tab.darkTheme() : home_tab.lightTheme(),
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(width, 1400),
            textScaler: TextScaler.linear(scale),
          ),
          child: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: HomeMasthead(examId: 'exam_1', now: now ?? _tue),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 800));
}

Finder get _days => find.byWidgetPredicate(
      (w) =>
          w.key is ValueKey<String> &&
          (w.key! as ValueKey<String>).value.startsWith('week-day-'),
    );

List<Rect> _dayRects(WidgetTester tester) => [
      for (final e in _days.evaluate())
        tester.getRect(find.byKey(e.widget.key!)),
    ]..sort((a, b) => a.left.compareTo(b.left));

void main() {
  setUpAll(loadDsFonts);

  for (final (width, days, first) in [
    (390.0, 5, 8),
    (375.0, 4, 9),
    (360.0, 4, 9),
    (320.0, 3, 9),
  ]) {
    testWidgets(
        '$width wide shows $days days on one line with the chip, '
        'Today centered', (tester) async {
      await _pump(tester, width: width);
      expect(tester.takeException(), isNull);
      final rects = _dayRects(tester);
      expect(rects.length, days);
      for (var i = 0; i < days; i++) {
        expect(find.text('${first + i}'), findsWidgets);
      }
      // Cells are 44 wide. Five days touch.
      for (final r in rects) {
        expect(r.width, 44);
      }
      if (days == 5) {
        for (var i = 1; i < 5; i++) {
          expect(rects[i].left, closeTo(rects[i - 1].right, .01));
        }
      } else {
        for (var i = 1; i < days; i++) {
          expect(rects[i].left - rects[i - 1].right, greaterThanOrEqualTo(4));
        }
      }
      // Today (the 10th) sits at the window's center: two before, two after
      // for five; one before, two after for four; one and one for three.
      final todayIndex = days == 5 ? 2 : 1;
      final today = find.descendant(
        of: find.byKey(ValueKey('week-day-$todayIndex')),
        matching: find.text('10'),
      );
      expect(today, findsOneWidget);
      // The chip is on the same line, after the days.
      final chip =
          tester.getRect(find.byKey(const ValueKey('masthead-exam-chip')));
      expect(chip.left, greaterThanOrEqualTo(rects.last.right));
      expect(chip.center.dy, closeTo(rects.first.center.dy, 30));
      expect(chip.top, lessThan(rects.first.bottom));
    });
  }

  testWidgets('the window crosses the week boundary and keeps the dots',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await _pump(
      tester,
      width: 390,
      now: _sun,
      week: HomeWeekStripData(
        states: [
          WeekDayState.today,
          ...List.filled(5, WeekDayState.plain),
          WeekDayState.dayOff,
        ],
        todayFraction: .5,
        around: const {
          -2: WeekDayState.done,
          -1: WeekDayState.partial,
        },
      ),
    );
    expect(tester.takeException(), isNull);
    // Today is Sunday the 8th: the 6th and 7th come from the week before.
    expect(find.bySemanticsLabel(RegExp('November 6, done')), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('November 7, partly done')),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel(RegExp('November 8, today')), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('server path: days before the week are plain, not dimmed',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await _pump(
      tester,
      width: 390,
      now: _sun,
      week: HomeWeekStripData(
        // ignore: prefer_const_literals_to_create_immutables
        states: [
          WeekDayState.today,
          ...List.filled(5, WeekDayState.plain),
          WeekDayState.dayOff,
        ],
        todayFraction: .5,
      ),
    );
    expect(tester.takeException(), isNull);
    // Friday the 6th and Saturday the 7th: no status and not dimmed.
    expect(find.bySemanticsLabel('Friday, November 6'), findsOneWidget);
    expect(find.bySemanticsLabel('Saturday, November 7'), findsOneWidget);
    final digit = tester.widget<Text>(
      find.descendant(
        of: find.byKey(const ValueKey('week-day-0')),
        matching: find.text('6'),
      ),
    );
    expect(digit.style!.fontWeight, isNot(FontWeight.w400));
    expect(
      digit.style!.color,
      tester.element(find.text('6')).colors.textPrimary,
    );
    semantics.dispose();
  });

  testWidgets('390 at 2.0 text: the chip goes under, no scrolling',
      (tester) async {
    await _pump(tester, width: 390, scale: 2);
    expect(tester.takeException(), isNull);
    final rects = _dayRects(tester);
    expect(rects.length, inInclusiveRange(1, 5));
    final chip =
        tester.getRect(find.byKey(const ValueKey('masthead-exam-chip')));
    expect(chip.top, greaterThanOrEqualTo(rects.first.bottom));
    expect(
      find.descendant(
        of: find.byType(WeekStrip),
        matching: find.byType(SingleChildScrollView),
      ),
      findsNothing,
    );
    for (var i = 1; i < rects.length; i++) {
      expect(rects[i].left - rects[i - 1].right, greaterThanOrEqualTo(4));
    }
  });

  for (final dark in [false, true]) {
    for (final scale in [1.0, 1.5, 2.0]) {
      for (final width in [320.0, 360.0, 390.0, 430.0]) {
        testWidgets('no overflow at $width x$scale dark=$dark', (tester) async {
          await _pump(tester, width: width, scale: scale, dark: dark);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
