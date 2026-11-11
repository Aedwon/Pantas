import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/month_first_date_picker.dart';
import 'package:pantas/core/ui/components/typed_date_field.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_web_calendar.dart';

import '../../../helpers/ds_matrix.dart';

/// Today is Nov 10, 2026: the first allowed day of November.
final _today = DateTime(2026, 11, 10);

const _wide = DsCell(1440, 1, dark: false);

class _Host extends StatefulWidget {
  const _Host({
    this.initial = const MonthFirstDate(year: 2026, month: 11, day: 15),
    this.log,
  });

  final MonthFirstDate initial;
  final List<MonthFirstDate>? log;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late MonthFirstDate value = widget.initial;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 780,
        child: OnboardingWebCalendar(
          value: value,
          today: _today,
          onChanged: (next) {
            widget.log?.add(next);
            setState(() => value = next);
          },
        ),
      );
}

_HostState _host(WidgetTester tester) =>
    tester.state<_HostState>(find.byType(_Host));

Finder _day(int day) => find.widgetWithText(TextButton, '$day');

FocusNode _node(WidgetTester tester, Finder button) => Focus.of(
      tester.element(
        find
            .descendant(
              of: button,
              matching: find.byType(Column),
            )
            .first,
      ),
    );

/// The day number of the day button that holds focus, or null.
int? _focusedDay(WidgetTester tester) {
  final focus = FocusManager.instance.primaryFocus;
  final context = focus?.context;
  if (context == null) return null;
  final button = context.findAncestorWidgetOfExactType<TextButton>() ??
      (context.widget is TextButton ? context.widget as TextButton : null);
  if (button == null) return null;
  final texts = <String>[];
  void collect(Element e) {
    if (e.widget is Text) texts.add((e.widget as Text).data ?? '');
    e.visitChildren(collect);
  }

  context.visitChildElements(collect);
  return int.tryParse(texts.isEmpty ? '' : texts.last);
}

Future<void> _focusDay(WidgetTester tester, int day) async {
  _node(tester, _day(day)).requestFocus();
  await tester.pump();
  expect(_focusedDay(tester), day);
}

Future<void> _press(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pump();
}

void main() {
  setUpAll(loadDsFonts);

  testWidgets('the typed field sits above the panels', (tester) async {
    await pumpDs(tester, _wide, const _Host());
    expect(find.byType(TypedDateField), findsOneWidget);
    final field = tester.getRect(find.byType(TypedDateField));
    final month = tester.getRect(find.text('Nov').first);
    expect(field.bottom, lessThan(month.top));
    expect(
      tester.widget<TextField>(find.byType(TextField)).decoration!.hintText,
      'MM/DD/YYYY',
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '11/15/2026',
    );
  });

  testWidgets('typing a full valid date selects that day', (tester) async {
    final log = <MonthFirstDate>[];
    await pumpDs(tester, _wide, _Host(log: log));
    await tester.enterText(find.byType(TextField), '12/24/2026');
    await tester.pumpAndSettle();
    expect(log.last.month, 12);
    expect(log.last.day, 24);
    expect(find.text('December 2026'), findsOneWidget);
  });

  testWidgets(
      'a typed date past the calendar shows an error and keeps '
      'the selection', (tester) async {
    final log = <MonthFirstDate>[];
    await pumpDs(tester, _wide, _Host(log: log));
    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), '01/05/2028');
    await tester.pump();
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    expect(find.text('Pick a date by Dec 31, 2027.'), findsOneWidget);
    expect(log, isEmpty);
    expect(_host(tester).value.day, 15);
  });

  testWidgets('day cells have full names and the grid is named by its month',
      (tester) async {
    final handle = tester.ensureSemantics();
    await pumpDs(tester, _wide, const _Host());
    expect(find.bySemanticsLabel('November 28, 2026'), findsOneWidget);
    expect(find.bySemanticsLabel('November 2026'), findsWidgets);
    handle.dispose();
  });

  group('date grid keys', () {
    testWidgets('Left and Right move one day', (tester) async {
      await pumpDs(tester, _wide, const _Host());
      await _focusDay(tester, 15);
      await _press(tester, LogicalKeyboardKey.arrowRight);
      expect(_focusedDay(tester), 16);
      await _press(tester, LogicalKeyboardKey.arrowLeft);
      await _press(tester, LogicalKeyboardKey.arrowLeft);
      expect(_focusedDay(tester), 14);
    });

    testWidgets('Up and Down move one week', (tester) async {
      await pumpDs(tester, _wide, const _Host());
      await _focusDay(tester, 15);
      await _press(tester, LogicalKeyboardKey.arrowDown);
      expect(_focusedDay(tester), 22);
      await _press(tester, LogicalKeyboardKey.arrowUp);
      expect(_focusedDay(tester), 15);
      // Eight is before the first allowed day, so Up stays on 15.
      await _press(tester, LogicalKeyboardKey.arrowUp);
      expect(_focusedDay(tester), 15);
    });

    testWidgets('Home and End jump to the first and last allowed day',
        (tester) async {
      await pumpDs(tester, _wide, const _Host());
      await _focusDay(tester, 15);
      await _press(tester, LogicalKeyboardKey.home);
      expect(_focusedDay(tester), 10);
      await _press(tester, LogicalKeyboardKey.end);
      expect(_focusedDay(tester), 30);
    });

    testWidgets('keys never land on a day before the first allowed day',
        (tester) async {
      await pumpDs(tester, _wide, const _Host());
      await _focusDay(tester, 10);
      await _press(tester, LogicalKeyboardKey.arrowLeft);
      expect(_focusedDay(tester), 10);
      await _press(tester, LogicalKeyboardKey.arrowUp);
      expect(_focusedDay(tester), 10);
    });

    testWidgets('keys stop at the ends of the month', (tester) async {
      await pumpDs(tester, _wide, const _Host());
      await _focusDay(tester, 30);
      await _press(tester, LogicalKeyboardKey.arrowRight);
      expect(_focusedDay(tester), 30);
      await _press(tester, LogicalKeyboardKey.arrowDown);
      expect(_focusedDay(tester), 30);
    });

    testWidgets('moving focus does not choose; Enter and Space do',
        (tester) async {
      final log = <MonthFirstDate>[];
      await pumpDs(tester, _wide, _Host(log: log));
      await _focusDay(tester, 15);
      await _press(tester, LogicalKeyboardKey.arrowRight);
      expect(log, isEmpty);
      await _press(tester, LogicalKeyboardKey.enter);
      expect(log.last.day, 16);
      await _press(tester, LogicalKeyboardKey.arrowRight);
      await _press(tester, LogicalKeyboardKey.space);
      expect(log.last.day, 17);
    });

    testWidgets('only the selected day is in the Tab order', (tester) async {
      await pumpDs(tester, _wide, const _Host());
      final stops = [
        for (var d = 1; d <= 30; d++)
          if (!_node(tester, _day(d)).skipTraversal &&
              _node(tester, _day(d)).canRequestFocus)
            d,
      ];
      expect(stops, [15]);
    });

    testWidgets('with no day chosen the first allowed day is the Tab stop',
        (tester) async {
      await pumpDs(
        tester,
        _wide,
        const _Host(initial: MonthFirstDate(year: 2026, month: 11)),
      );
      final stops = [
        for (var d = 1; d <= 30; d++)
          if (!_node(tester, _day(d)).skipTraversal &&
              _node(tester, _day(d)).canRequestFocus)
            d,
      ];
      expect(stops, [10]);
    });

    testWidgets('days before the first allowed day cannot take focus',
        (tester) async {
      await pumpDs(tester, _wide, const _Host());
      expect(_node(tester, _day(9)).canRequestFocus, isFalse);
    });
  });

  testWidgets('Tab reaches each month in the month grid', (tester) async {
    await pumpDs(tester, _wide, const _Host());
    Focus.of(tester.element(find.text('Nov').first)).requestFocus();
    await tester.pump();
    await _press(tester, LogicalKeyboardKey.tab);
    final focused = FocusManager.instance.primaryFocus!.context!;
    final label = <String>[];
    void collect(Element e) {
      if (e.widget is Text) label.add((e.widget as Text).data ?? '');
      e.visitChildren(collect);
    }

    focused.visitChildElements(collect);
    expect(label, contains('Dec'));
  });

  group('selected cell pop (350 ms)', () {
    double scale(WidgetTester tester, int day) => tester
        .widget<Transform>(
          find
              .descendant(
                of: find.byKey(ValueKey('date-cell-pop-$day')),
                matching: find.byType(Transform),
              )
              .first,
        )
        .transform
        .getMaxScaleOnAxis();

    testWidgets('a newly chosen cell pops over 350 ms and settles at 1',
        (tester) async {
      await pumpDs(tester, _wide, const _Host());
      await tester.tap(_day(20));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(scale(tester, 20), isNot(1));
      await tester.pump(const Duration(milliseconds: 260));
      expect(scale(tester, 20), 1);
    });

    testWidgets('the pop overshoots before it settles', (tester) async {
      await pumpDs(tester, _wide, const _Host());
      await tester.tap(_day(20));
      await tester.pump();
      var peak = 0.0;
      for (var i = 0; i < 35; i++) {
        await tester.pump(const Duration(milliseconds: 10));
        final s = scale(tester, 20);
        if (s > peak) peak = s;
      }
      expect(peak, greaterThan(1));
    });

    testWidgets('reduced motion: no pop', (tester) async {
      await pumpDs(
        tester,
        _wide,
        Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: const _Host(),
          ),
        ),
      );
      await tester.tap(_day(20));
      await tester.pump();
      expect(scale(tester, 20), 1);
    });
  });

  dsMatrix(
    'wide calendar with the typed field fits',
    (context) => const _Host(),
    cells: [
      for (final c in dsShellCells)
        if (c.width >= 1100) c,
    ],
    check: (tester, cell) async {
      expect(find.byType(TypedDateField), findsOneWidget);
      expect(tester.takeException(), isNull);
      // Cells follow the tokens: 46 for a date, 42 for a month, scaled.
      final cellHeight = tester.getSize(_day(20)).height;
      expect(cellHeight, 46 * cell.scale);
    },
  );
}
