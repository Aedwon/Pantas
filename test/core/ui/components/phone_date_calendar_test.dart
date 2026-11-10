import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/ui/components/month_first_date_picker.dart';
import 'package:pantas/core/ui/components/pantas_icon_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/presentation/widgets/home_exam_date_sheet.dart';

import '../../../helpers/ds_matrix.dart';

/// The phone exam-date calendar (Option A, chosen Nov 10, 2026): one month
/// calendar under the typed field, with Previous and Next month buttons.
final _today = DateTime(2026, 11, 10);

class _Host extends StatefulWidget {
  const _Host({
    this.initial = const MonthFirstDate(year: 2026),
    this.log,
    this.width = 358,
  });

  final MonthFirstDate initial;
  final List<MonthFirstDate>? log;
  final double width;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late MonthFirstDate value = widget.initial;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: widget.width,
        child: MonthFirstDatePicker.onboarding(
          value: value,
          today: _today,
          onChanged: (next) {
            widget.log?.add(next);
            setState(() => value = next);
          },
        ),
      );
}

Finder _day(int day) => find.byKey(ValueKey('date-day-$day'));

Finder _nav(String tooltip) => find.byWidgetPredicate(
      (w) => w is PantasIconButton && w.tooltip == tooltip,
    );

bool _enabled(WidgetTester tester, String tooltip) =>
    tester.widget<PantasIconButton>(_nav(tooltip)).onPressed != null;

/// Pumps the host in the phone cell and lets the first frame settle.
Future<void> _pump(
  WidgetTester tester,
  Widget host, {
  DsCell? cell,
  bool still = true,
}) async {
  await pumpDs(
    tester,
    cell ?? dsCells.first,
    still
        ? Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: host,
            ),
          )
        : host,
  );
}

bool _focused(WidgetTester tester, int day) =>
    tester.widget<TextButton>(_day(day)).focusNode!.hasFocus;

/// Tabs from the typed field until a date cell has focus.
Future<void> _tabToGrid(WidgetTester tester) async {
  await tester.tap(find.byType(TextField));
  await tester.pump();
  for (var i = 0; i < 8; i++) {
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    for (var d = 1; d <= 31; d++) {
      if (_day(d).evaluate().isNotEmpty && _focused(tester, d)) return;
    }
  }
  fail('Tab never reached a date cell');
}

void main() {
  setUpAll(loadDsFonts);

  testWidgets('shows a 7-column grid with weekday labels and no day strip',
      (tester) async {
    await _pump(
      tester,
      const _Host(initial: MonthFirstDate(year: 2026, month: 11, day: 28)),
    );
    for (final name in ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']) {
      expect(find.text(name), findsOneWidget);
    }
    expect(find.text('November 2026'), findsOneWidget);
    expect(find.byKey(const ValueKey('onboarding-day-strip')), findsNothing);
    expect(find.byKey(const ValueKey('date-month-11')), findsNothing);
    expect(find.text('Nov'), findsNothing);
    expect(find.byTooltip('Next year'), findsNothing);
    for (var d = 1; d <= 30; d++) {
      expect(_day(d), findsOneWidget);
    }
    expect(_day(31), findsNothing);
    // November 2026 starts on a Sunday: day 1 and day 8 share a column, day 7
    // is the last column and day 8 starts the second row.
    final one = tester.getRect(_day(1));
    final seven = tester.getRect(_day(7));
    final eight = tester.getRect(_day(8));
    expect(eight.left, one.left);
    expect(eight.top, greaterThan(one.top));
    expect(seven.top, one.top);
    expect(seven.left, greaterThan(one.left));
    expect(one.width, closeTo((358 - 6 * 4) / 7, .01));
    expect(one.height, greaterThanOrEqualTo(46));
  });

  testWidgets('a month that starts mid-week leaves spacers before day 1',
      (tester) async {
    await _pump(
      tester,
      const _Host(initial: MonthFirstDate(year: 2026, month: 12)),
    );
    // December 2026 starts on a Tuesday (column 3).
    final one = tester.getRect(_day(1));
    final sunday = tester.getRect(find.text('Sun'));
    final tuesday = tester.getRect(find.text('Tue'));
    expect(one.center.dx, closeTo(tuesday.center.dx, 1));
    expect(one.center.dx, greaterThan(sunday.center.dx));
  });

  testWidgets('picking a day sets the date and names it', (tester) async {
    final log = <MonthFirstDate>[];
    await _pump(
      tester,
      _Host(initial: const MonthFirstDate(year: 2026, month: 11), log: log),
    );
    await tester.tap(_day(28));
    await tester.pump();
    expect(log.single.year, 2026);
    expect(log.single.month, 11);
    expect(log.single.day, 28);
    expect(find.text('Saturday, November 28'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '11/28/2026',
    );
  });

  testWidgets('past days are dimmed and cannot be picked', (tester) async {
    final log = <MonthFirstDate>[];
    await _pump(
      tester,
      _Host(initial: const MonthFirstDate(year: 2026, month: 11), log: log),
    );
    for (var d = 1; d <= 9; d++) {
      expect(tester.widget<TextButton>(_day(d)).onPressed, isNull);
    }
    expect(tester.widget<TextButton>(_day(10)).onPressed, isNotNull);
    await tester.tap(_day(9), warnIfMissed: false);
    await tester.pump();
    expect(log, isEmpty);
  });

  testWidgets('cells have full names and the grid is named by the month',
      (tester) async {
    await _pump(
      tester,
      const _Host(initial: MonthFirstDate(year: 2026, month: 11, day: 28)),
    );
    final handle = tester.ensureSemantics();
    await tester.pump();
    expect(find.bySemanticsLabel('November 28, 2026'), findsOneWidget);
    expect(find.bySemanticsLabel('November 2026'), findsWidgets);
    final node =
        tester.getSemantics(find.bySemanticsLabel('November 28, 2026'));
    expect(node.flagsCollection.isSelected, Tristate.isTrue);
    handle.dispose();
  });

  testWidgets('Previous is off on the first month and Next never ends',
      (tester) async {
    final log = <MonthFirstDate>[];
    await _pump(
      tester,
      _Host(initial: const MonthFirstDate(year: 2026, month: 11), log: log),
    );
    expect(_enabled(tester, 'Previous month'), isFalse);
    expect(_enabled(tester, 'Next month'), isTrue);
    await tester.tap(_nav('Next month'));
    await tester.pump();
    expect(log.last.month, 12);
    expect(_enabled(tester, 'Previous month'), isTrue);
    // The phone has no upper limit: Next stays on far past next year.
    for (var i = 0; i < 40; i++) {
      await tester.tap(_nav('Next month'));
      await tester.pump();
    }
    expect(find.text('April 2030'), findsOneWidget);
    expect(_enabled(tester, 'Next month'), isTrue);
    expect(_enabled(tester, 'Previous month'), isTrue);
    await tester.tap(_nav('Previous month'));
    await tester.pump();
    expect(find.text('March 2030'), findsOneWidget);
  });

  testWidgets('with no month set the calendar shows this month and no line',
      (tester) async {
    final log = <MonthFirstDate>[];
    await _pump(tester, _Host(log: log));
    expect(find.text('November 2026'), findsOneWidget);
    expect(find.textContaining('No day yet?'), findsNothing);
    await tester.tap(_nav('Next month'));
    await tester.pump();
    expect(log.single.month, 12);
    expect(log.single.day, isNull);
  });

  testWidgets('month only shows the plan line and saves a month',
      (tester) async {
    final log = <MonthFirstDate>[];
    await _pump(tester, _Host(log: log));
    await tester.tap(_nav('Next month'));
    await tester.pump();
    expect(
      find.text("No day yet? We'll plan from 1 December and ask later."),
      findsOneWidget,
    );
    expect(
      ExamDate.inMonth(year: log.last.year, month: log.last.month!).day,
      isNull,
    );
    await tester.tap(_nav('Previous month'));
    await tester.pump();
    expect(
      find.text("No day yet? We'll plan from today and ask later."),
      findsOneWidget,
    );
    expect(log.last.month, 11);
    expect(log.last.day, isNull);
  });

  testWidgets('moving to another month drops the picked day', (tester) async {
    await _pump(
      tester,
      const _Host(initial: MonthFirstDate(year: 2026, month: 11, day: 28)),
    );
    await tester.tap(_nav('Next month'));
    await tester.pump();
    expect(find.text('Saturday, November 28'), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '',
    );
  });

  testWidgets('a typed valid date moves the month and selects the cell',
      (tester) async {
    final log = <MonthFirstDate>[];
    await _pump(tester, _Host(log: log));
    await tester.enterText(find.byType(TextField), '03152027');
    await tester.pump();
    expect(log.last.year, 2027);
    expect(log.last.month, 3);
    expect(log.last.day, 15);
    expect(find.text('March 2027'), findsOneWidget);
    expect(find.text('Monday, March 15'), findsOneWidget);
    expect(_day(15), findsOneWidget);
  });

  testWidgets('a typed date beyond next year is accepted', (tester) async {
    final log = <MonthFirstDate>[];
    await _pump(tester, _Host(log: log));
    await tester.enterText(find.byType(TextField), '06152031');
    await tester.pump();
    expect(log.last.year, 2031);
    expect(log.last.month, 6);
    expect(log.last.day, 15);
    expect(find.text('June 2031'), findsOneWidget);
  });

  testWidgets('an invalid typed date keeps the last valid selection',
      (tester) async {
    final log = <MonthFirstDate>[];
    await _pump(
      tester,
      _Host(
        initial: const MonthFirstDate(year: 2026, month: 12, day: 18),
        log: log,
      ),
    );
    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), '11012026');
    await tester.pump();
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    expect(find.text('Pick Nov 10, 2026 or a later date.'), findsOneWidget);
    expect(log, isEmpty);
    expect(find.text('Friday, December 18'), findsOneWidget);
  });

  group('keyboard', () {
    testWidgets('only the picked day is in the Tab order', (tester) async {
      await _pump(
        tester,
        const _Host(initial: MonthFirstDate(year: 2026, month: 11, day: 20)),
      );
      await _tabToGrid(tester);
      expect(_focused(tester, 20), isTrue);
    });

    testWidgets('with none picked the first allowed day is the Tab stop',
        (tester) async {
      await _pump(
        tester,
        const _Host(initial: MonthFirstDate(year: 2026, month: 11)),
      );
      await _tabToGrid(tester);
      expect(_focused(tester, 10), isTrue);
    });

    testWidgets('arrows, Home and End move focus inside the allowed days',
        (tester) async {
      await _pump(
        tester,
        const _Host(initial: MonthFirstDate(year: 2026, month: 11, day: 20)),
      );
      await _tabToGrid(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(_focused(tester, 21), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(_focused(tester, 19), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(_focused(tester, 26), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(_focused(tester, 19), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(_focused(tester, 30), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      expect(_focused(tester, 10), isTrue);
      // Past days are not reachable.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(_focused(tester, 10), isTrue);
    });

    testWidgets('Enter picks the focused day', (tester) async {
      final log = <MonthFirstDate>[];
      await _pump(
        tester,
        _Host(
          initial: const MonthFirstDate(year: 2026, month: 11, day: 20),
          log: log,
        ),
      );
      await _tabToGrid(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(log.last.day, 21);
    });
  });

  group('pop', () {
    Finder pop(int day) => find.ancestor(
          of: _day(day),
          matching: find.byType(Opacity),
        );

    testWidgets('the picked day pops over 350 ms', (tester) async {
      await _pump(
        tester,
        const _Host(initial: MonthFirstDate(year: 2026, month: 11)),
        still: false,
      );
      await tester.tap(_day(20));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      expect(tester.widget<Opacity>(pop(20).first).opacity, lessThan(1));
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.widget<Opacity>(pop(20).first).opacity, 1);
    });

    testWidgets('reduced motion has no pop', (tester) async {
      await _pump(
        tester,
        const _Host(initial: MonthFirstDate(year: 2026, month: 11)),
      );
      await tester.tap(_day(20));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      expect(tester.widget<Opacity>(pop(20).first).opacity, 1);
    });
  });

  testWidgets('selected, today and past days take the board looks',
      (tester) async {
    await _pump(
      tester,
      const _Host(initial: MonthFirstDate(year: 2026, month: 11, day: 28)),
    );
    final colors = tester.element(_day(28)).colors;
    TextStyle style(int d) => tester
        .widget<Text>(find.descendant(of: _day(d), matching: find.byType(Text)))
        .style!;
    expect(style(28).color, colors.onAccent);
    expect(style(28).fontWeight, FontWeight.w700);
    expect(style(10).color, colors.accent);
    expect(style(10).fontWeight, FontWeight.w700);
    expect(style(5).color, colors.textSecondary);
    expect(style(5).fontWeight, FontWeight.w400);
    expect(style(15).color, colors.textPrimary);
    expect(style(15).fontWeight, FontWeight.w500);
    final fill = tester
        .widget<TextButton>(_day(28))
        .style!
        .backgroundColor!
        .resolve(<WidgetState>{});
    expect(fill, colors.accentFill);
  });

  testWidgets('weekday labels fall back to single letters when they do not fit',
      (tester) async {
    await _pump(
      tester,
      const _Host(
        initial: MonthFirstDate(year: 2026, month: 11),
        width: 288,
      ),
      cell: const DsCell(320, 2, dark: false),
    );
    expect(find.text('Wed'), findsNothing);
    expect(find.text('Sun'), findsNothing);
    expect(find.text('S'), findsNWidgets(2));
    expect(find.text('W'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the Home phone sheet shows the same calendar', (tester) async {
    final saved = <ExamDate>[];
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(390, 844),
            disableAnimations: true,
          ),
          child: Scaffold(
            body: SingleChildScrollView(
              child: HomeExamDateSheet(
                today: _today,
                onSave: saved.add,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Wed'), findsOneWidget);
    expect(find.text('November 2026'), findsOneWidget);
    expect(find.byKey(const ValueKey('onboarding-day-strip')), findsNothing);
    await tester.tap(_day(28));
    await tester.pumpAndSettle();
    expect(find.text('Saturday, November 28'), findsOneWidget);
    await tester.tap(find.text('Save'));
    expect(saved.single, ExamDate.onDay(DateTime(2026, 11, 28)));
  });

  for (final width in [390.0, 320.0]) {
    for (final dark in [false, true]) {
      for (final scale in [1.0, 2.0]) {
        final cell = DsCell(width, scale, dark: dark);
        testWidgets('the phone calendar fits ($cell)', (tester) async {
          await pumpDs(
            tester,
            cell,
            _Host(
              initial: const MonthFirstDate(year: 2027, month: 1, day: 15),
              width: width - 32,
            ),
          );
          expect(tester.takeException(), isNull);
          // January 2027 needs six week rows.
          expect(_day(31), findsOneWidget);
          final box = tester.getRect(find.byType(MonthFirstDatePicker));
          expect(box.width, closeTo(width - 32, .01));
          final last = tester.getRect(_day(31));
          expect(last.right, lessThanOrEqualTo(box.right + .01));
          expect(find.text('Friday, January 15'), findsOneWidget);
          // Three letters unless they cannot fit: only 320 wide at 2.0 falls
          // back to one letter each.
          expect(
            find.text('Wed'),
            width == 320 && scale == 2 ? findsNothing : findsOneWidget,
          );
        });
      }
    }
  }
}
