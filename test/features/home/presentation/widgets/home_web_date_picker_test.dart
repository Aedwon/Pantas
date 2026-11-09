import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/month_first_date_picker.dart';
import 'package:pantas/core/ui/components/typed_date_field.dart';
import 'package:pantas/features/home/presentation/widgets/home_exam_date_sheet.dart';

import '../../../../helpers/ds_matrix.dart';

final _today = DateTime(2026, 11, 10);
const _wide = DsCell(1440, 1, dark: false);

class _Host extends StatefulWidget {
  const _Host({
    this.requireDay = false,
    this.log,
  });

  final bool requireDay;
  final List<MonthFirstDate>? log;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  MonthFirstDate value = const MonthFirstDate(year: 2026, month: 11, day: 15);

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 760,
        child: HomeWebDatePicker(
          value: value,
          today: _today,
          requireDay: widget.requireDay,
          onChanged: (next) {
            widget.log?.add(next);
            setState(() => value = next);
          },
        ),
      );
}

Finder _day(int day) => find.byKey(ValueKey('date-day-$day'));

Future<void> _focusDay(WidgetTester tester, int day) async {
  Focus.of(
    tester.element(find.descendant(of: _day(day), matching: find.text('$day'))),
  ).requestFocus();
  await tester.pump();
  expect(_focusedDay(), day);
}

int? _focusedDay() {
  final context = FocusManager.instance.primaryFocus?.context;
  if (context == null) return null;
  int? found;
  context.visitAncestorElements((e) {
    final key = e.widget.key;
    if (key is ValueKey<String> && key.value.startsWith('date-day-')) {
      found = int.parse(key.value.substring('date-day-'.length));
      return false;
    }
    return true;
  });
  return found;
}

Future<void> _press(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pump();
}

void main() {
  setUpAll(loadDsFonts);

  testWidgets('the typed field sits above the months and the calendar',
      (tester) async {
    await pumpDs(tester, _wide, const _Host());
    expect(find.byType(TypedDateField), findsOneWidget);
    final field = tester.getRect(find.byType(TypedDateField));
    final months =
        tester.getRect(find.byKey(const ValueKey('home-web-months')));
    expect(field.bottom, lessThanOrEqualTo(months.top));
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '11/15/2026',
    );
  });

  testWidgets('the typed field is above the calendar when a day is required',
      (tester) async {
    await pumpDs(tester, _wide, const _Host(requireDay: true));
    final field = tester.getRect(find.byType(TypedDateField));
    final cal = tester.getRect(find.byKey(const ValueKey('home-web-calendar')));
    expect(field.bottom, lessThanOrEqualTo(cal.top));
  });

  testWidgets('typing a full valid date selects that day', (tester) async {
    final log = <MonthFirstDate>[];
    await pumpDs(tester, _wide, _Host(log: log));
    await tester.enterText(find.byType(TextField), '12/24/2026');
    await tester.pumpAndSettle();
    expect(log.last.month, 12);
    expect(log.last.day, 24);
  });

  testWidgets('day cells have full names', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpDs(tester, _wide, const _Host());
    expect(find.bySemanticsLabel('November 28, 2026'), findsOneWidget);
    handle.dispose();
  });

  group('date grid keys', () {
    testWidgets('arrows move by a day and a week', (tester) async {
      await pumpDs(tester, _wide, const _Host());
      await _focusDay(tester, 15);
      await _press(tester, LogicalKeyboardKey.arrowRight);
      expect(_focusedDay(), 16);
      await _press(tester, LogicalKeyboardKey.arrowDown);
      expect(_focusedDay(), 23);
      await _press(tester, LogicalKeyboardKey.arrowLeft);
      expect(_focusedDay(), 22);
      await _press(tester, LogicalKeyboardKey.arrowUp);
      expect(_focusedDay(), 15);
    });

    testWidgets('Home and End jump to the first and last allowed day',
        (tester) async {
      await pumpDs(tester, _wide, const _Host());
      await _focusDay(tester, 15);
      await _press(tester, LogicalKeyboardKey.home);
      expect(_focusedDay(), 10);
      await _press(tester, LogicalKeyboardKey.end);
      expect(_focusedDay(), 30);
    });

    testWidgets('keys never land before the first allowed day', (tester) async {
      await pumpDs(tester, _wide, const _Host());
      await _focusDay(tester, 10);
      await _press(tester, LogicalKeyboardKey.arrowLeft);
      expect(_focusedDay(), 10);
    });

    testWidgets('Enter chooses the focused day', (tester) async {
      final log = <MonthFirstDate>[];
      await pumpDs(tester, _wide, _Host(log: log));
      await _focusDay(tester, 15);
      await _press(tester, LogicalKeyboardKey.arrowRight);
      expect(log, isEmpty);
      await _press(tester, LogicalKeyboardKey.enter);
      expect(log.last.day, 16);
    });

    testWidgets('only the chosen day is a Tab stop', (tester) async {
      await pumpDs(tester, _wide, const _Host());
      final scope = FocusManager.instance.rootScope;
      final stops = scope.traversalDescendants.where((n) {
        final ctx = n.context;
        if (ctx == null) return false;
        var inDay = false;
        ctx.visitAncestorElements((e) {
          final key = e.widget.key;
          if (key is ValueKey<String> && key.value.startsWith('date-day-')) {
            inDay = true;
            return false;
          }
          return true;
        });
        return inDay;
      }).length;
      expect(stops, 1);
    });
  });

  dsMatrix(
    'home wide date picker with the typed field fits',
    (context) => const _Host(),
    cells: [
      for (final c in dsShellCells)
        if (c.width >= 1100) c,
    ],
    check: (tester, cell) async {
      expect(find.byType(TypedDateField), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
