import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/ui/components/month_first_date_picker.dart';
import 'package:pantas/core/ui/components/pantas_button_parts.dart';
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
    this.unresolved,
    this.width = 358,
  });

  final MonthFirstDate initial;
  final List<MonthFirstDate>? log;

  /// Receives each change of the picker's "typed but not a date" state.
  final List<bool>? unresolved;
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
          onUnresolvedChanged: widget.unresolved?.add,
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

/// The day the grid fills with the accent, or null.
int? _selected(WidgetTester tester) {
  final fill = tester.element(find.byType(MonthFirstDatePicker)).colors;
  for (var d = 1; d <= 31; d++) {
    if (_day(d).evaluate().isEmpty) continue;
    final color = tester
        .widget<TextButton>(_day(d))
        .style!
        .backgroundColor!
        .resolve(<WidgetState>{});
    if (color == fill.accentFill) return d;
  }
  return null;
}

String _fieldText(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField)).controller!.text;

bool _hasFocus(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus;

Finder get _calendarButton => find.byWidgetPredicate(
      (w) => w is PantasIconButton && w.tooltip == 'Choose a date',
    );

bool _focused(WidgetTester tester, int day) =>
    tester.widget<TextButton>(_day(day)).focusNode!.hasFocus;

/// Tabs from the top until a date cell has focus. A tap on the field would
/// close the calendar, so the keys do the work.
Future<void> _tabToGrid(WidgetTester tester) async {
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
    expect(find.text('Saturday, November 28'), findsNothing);
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
    // The error stays; the calendar is closed by the tap, so open it again.
    await tester.tap(find.byTooltip('Choose a date'));
    await tester.pumpAndSettle();
    expect(find.text('Pick a date from November 10, 2026.'), findsOneWidget);
    expect(log, isEmpty);
    expect(_selected(tester), 18);
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
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '11/28/2026',
    );
    await tester.tap(find.text('Save'));
    expect(saved.single, ExamDate.onDay(DateTime(2026, 11, 28)));
  });

  testWidgets('the Home phone sheet holds Save while the field is unresolved',
      (tester) async {
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
                initial: ExamDate.onDay(DateTime(2026, 11, 28)),
                onSave: saved.add,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '11012026');
    await tester.pumpAndSettle();
    expect(find.text('Pick a date from November 10, 2026.'), findsOneWidget);
    await tester.tap(find.text('Save'), warnIfMissed: false);
    expect(saved, isEmpty);
    await tester.enterText(find.byType(TextField), '12122026');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    expect(saved.single, ExamDate.onDay(DateTime(2026, 12, 12)));
  });

  group('exam date final design', () {
    testWidgets('opens with the calendar showing and the field filled',
        (tester) async {
      await _pump(
        tester,
        const _Host(initial: MonthFirstDate(year: 2026, month: 11, day: 28)),
      );
      expect(_day(28), findsOneWidget);
      expect(find.text('November 2026'), findsOneWidget);
      expect(_fieldText(tester), '11/28/2026');
      expect(_selected(tester), 28);
      expect(_hasFocus(tester), isFalse);
      expect(tester.widget<PantasIconButton>(_calendarButton).accent, isTrue);
    });

    testWidgets('the field has the visible label Exam date', (tester) async {
      await _pump(tester, const _Host());
      expect(find.text('Exam date'), findsOneWidget);
    });

    testWidgets('there is no help line by default', (tester) async {
      await _pump(tester, const _Host());
      expect(find.textContaining('Type or paste'), findsNothing);
      expect(find.textContaining('first day you can pick'), findsNothing);
    });

    testWidgets('tapping the field hides the calendar and focuses it',
        (tester) async {
      await _pump(
        tester,
        const _Host(initial: MonthFirstDate(year: 2026, month: 11, day: 28)),
      );
      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(_day(28), findsNothing);
      expect(find.text('November 2026'), findsNothing);
      expect(_hasFocus(tester), isTrue);
      expect(tester.widget<PantasIconButton>(_calendarButton).accent, isFalse);
    });

    testWidgets('tapping the calendar button unfocuses and shows the calendar',
        (tester) async {
      await _pump(
        tester,
        const _Host(initial: MonthFirstDate(year: 2026, month: 11, day: 28)),
      );
      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(_day(28), findsNothing);
      await tester.tap(_calendarButton);
      await tester.pump();
      expect(_hasFocus(tester), isFalse);
      expect(_day(28), findsOneWidget);
      expect(find.text('November 2026'), findsOneWidget);
      expect(tester.widget<PantasIconButton>(_calendarButton).accent, isTrue);
      expect(_selected(tester), 28);
    });

    testWidgets('the calendar button is expanded while the calendar shows',
        (tester) async {
      await _pump(tester, const _Host());
      final handle = tester.ensureSemantics();
      await tester.pump();
      var node = tester.getSemantics(find.byTooltip('Choose a date'));
      expect(node.flagsCollection.isExpanded, Tristate.isTrue);
      await tester.tap(find.byType(TextField));
      await tester.pump();
      node = tester.getSemantics(find.byTooltip('Choose a date'));
      expect(node.flagsCollection.isExpanded, Tristate.isFalse);
      handle.dispose();
    });

    testWidgets('the calendar button has a 44 px touch area and a name',
        (tester) async {
      await _pump(tester, const _Host());
      final size = tester.getSize(_calendarButton);
      expect(size.width, greaterThanOrEqualTo(44));
      expect(size.height, greaterThanOrEqualTo(44));
      expect(find.byTooltip('Choose a date'), findsOneWidget);
    });

    testWidgets('typing 11282026 shows 11/28/2026 and picks the 28th',
        (tester) async {
      final log = <MonthFirstDate>[];
      await _pump(tester, _Host(log: log));
      await tester.tap(find.byType(TextField));
      await tester.enterText(find.byType(TextField), '11282026');
      await tester.pump();
      expect(_fieldText(tester), '11/28/2026');
      expect(log.last.month, 11);
      expect(log.last.day, 28);
      // The calendar is closed while typing; the button brings it back.
      await tester.tap(_calendarButton);
      await tester.pump();
      expect(find.text('November 2026'), findsOneWidget);
      expect(_selected(tester), 28);
    });

    testWidgets('a tapped day fills the field and the calendar stays open',
        (tester) async {
      await _pump(
        tester,
        const _Host(initial: MonthFirstDate(year: 2026, month: 11)),
      );
      await tester.tap(_day(20));
      await tester.pump();
      expect(_fieldText(tester), '11/20/2026');
      expect(_day(20), findsOneWidget);
      expect(_selected(tester), 20);
    });

    testWidgets('a past date says where to start and holds Continue',
        (tester) async {
      final unresolved = <bool>[];
      await _pump(tester, _Host(unresolved: unresolved));
      await tester.tap(find.byType(TextField));
      await tester.enterText(find.byType(TextField), '11012026');
      await tester.pump();
      expect(find.text('Pick a date from November 10, 2026.'), findsOneWidget);
      expect(unresolved.last, isTrue);
      // A valid date clears the message and lets Continue on.
      await tester.enterText(find.byType(TextField), '11282026');
      await tester.pump();
      expect(find.textContaining('Pick a date from'), findsNothing);
      expect(unresolved.last, isFalse);
    });

    testWidgets('a date that does not exist asks for a real one',
        (tester) async {
      final unresolved = <bool>[];
      await _pump(tester, _Host(unresolved: unresolved));
      await tester.tap(find.byType(TextField));
      await tester.enterText(find.byType(TextField), '02302027');
      await tester.pump();
      expect(
        find.text('Enter a real date, like 11/10/2026.'),
        findsOneWidget,
      );
      expect(unresolved.last, isTrue);
    });

    testWidgets('incomplete input shows nothing, even after the field blurs',
        (tester) async {
      final unresolved = <bool>[];
      await _pump(tester, _Host(unresolved: unresolved));
      await tester.tap(find.byType(TextField));
      await tester.enterText(find.byType(TextField), '1128');
      await tester.pump();
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      expect(find.textContaining('Pick a date from'), findsNothing);
      expect(find.textContaining('Enter a real date'), findsNothing);
      expect(find.textContaining('Type the full date'), findsNothing);
      expect(unresolved.last, isTrue);
    });

    testWidgets('Not sure of the day keeps the month and clears the day',
        (tester) async {
      final log = <MonthFirstDate>[];
      final unresolved = <bool>[];
      await _pump(
        tester,
        _Host(
          initial: const MonthFirstDate(year: 2026, month: 11, day: 28),
          log: log,
          unresolved: unresolved,
        ),
      );
      expect(find.textContaining('No day yet?'), findsNothing);
      await tester.tap(find.text('Not sure of the day'));
      await tester.pump();
      expect(log.last.year, 2026);
      expect(log.last.month, 11);
      expect(log.last.day, isNull);
      expect(_fieldText(tester), '');
      expect(_selected(tester), isNull);
      expect(
        find.text("No day yet? We'll plan from today and ask later."),
        findsOneWidget,
      );
    });

    testWidgets('Not sure of the day also empties half-typed text',
        (tester) async {
      final unresolved = <bool>[];
      await _pump(tester, _Host(unresolved: unresolved));
      await tester.enterText(find.byType(TextField), '1128');
      await tester.pump();
      expect(unresolved.last, isTrue);
      await tester.tap(find.text('Not sure of the day'));
      await tester.pump();
      expect(_fieldText(tester), '');
      expect(unresolved.last, isFalse);
    });

    testWidgets('Not sure of the day is a 44 px link under the grid',
        (tester) async {
      await _pump(tester, const _Host());
      final link = find.text('Not sure of the day');
      expect(link, findsOneWidget);
      expect(
        tester.getTopLeft(link).dy,
        greaterThan(tester.getBottomLeft(_day(30)).dy),
      );
      final hit = find.ancestor(of: link, matching: find.byType(TouchTarget));
      expect(tester.getSize(hit).height, greaterThanOrEqualTo(44));
    });

    testWidgets('there is no day line under the grid', (tester) async {
      await _pump(
        tester,
        const _Host(initial: MonthFirstDate(year: 2026, month: 11, day: 28)),
      );
      expect(find.textContaining('Saturday'), findsNothing);
      expect(find.textContaining('days from today'), findsNothing);
    });
  });

  for (final width in [390.0, 320.0]) {
    for (final dark in [false, true]) {
      for (final scale in [1.0, 2.0]) {
        for (final open in [true, false]) {
          final cell = DsCell(width, scale, dark: dark);
          testWidgets(
              'the exam date picker fits ($cell, '
              'calendar ${open ? 'open' : 'closed'})', (tester) async {
            await pumpDs(
              tester,
              cell,
              _Host(
                initial: const MonthFirstDate(year: 2027, month: 1, day: 15),
                width: width - 32,
              ),
            );
            if (!open) {
              await tester.tap(find.byType(TextField));
              await tester.pump();
            }
            expect(tester.takeException(), isNull);
            expect(find.text('Exam date'), findsOneWidget);
            expect(_day(31), open ? findsOneWidget : findsNothing);
            final box = tester.getRect(find.byType(MonthFirstDatePicker));
            expect(box.right, lessThanOrEqualTo(width - 16 + .01));
            final button = tester.getRect(_calendarButton);
            // The whole 44 px box sits inside the field's outline.
            final well = tester.getRect(
              find.byKey(const ValueKey('field-well')),
            );
            expect(button.right, lessThanOrEqualTo(well.right + .01));
            expect(button.left, greaterThanOrEqualTo(well.left));
            expect(button.top, greaterThanOrEqualTo(well.top - .01));
            expect(button.bottom, lessThanOrEqualTo(well.bottom + .01));
            expect(button.width, greaterThanOrEqualTo(44));
          });
        }
      }
    }
  }

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
          expect(
            tester.widget<TextField>(find.byType(TextField)).controller!.text,
            '01/15/2027',
          );
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
