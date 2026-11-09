import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/month_first_date_picker.dart';
import 'package:pantas/core/ui/components/typed_date_field.dart';

import '../../../helpers/ds_matrix.dart';

final _today = DateTime(2026, 11, 10);

class _Host extends StatefulWidget {
  const _Host({
    this.initial = const MonthFirstDate(year: 2026),
    this.onboarding = false,
    this.log,
  });

  final MonthFirstDate initial;
  final bool onboarding;
  final List<MonthFirstDate>? log;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late MonthFirstDate value = widget.initial;

  void _set(MonthFirstDate next) {
    widget.log?.add(next);
    setState(() => value = next);
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 360,
        child: widget.onboarding
            ? MonthFirstDatePicker.onboarding(
                value: value,
                today: _today,
                onChanged: _set,
              )
            : MonthFirstDatePicker(
                value: value,
                today: _today,
                onChanged: _set,
              ),
      );
}

_HostState _host(WidgetTester tester) =>
    tester.state<_HostState>(find.byType(_Host));

String _text(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField)).controller!.text;

/// The onboarding day strip scrolls after a delay of 450 ms; let it finish.
Future<void> _drain(WidgetTester tester) =>
    tester.pump(const Duration(seconds: 3));

void main() {
  setUpAll(loadDsFonts);

  for (final onboarding in [false, true]) {
    final name = onboarding ? 'onboarding' : 'sheet';

    testWidgets('$name: the typed field sits above the month grid',
        (tester) async {
      await pumpDs(tester, dsCells.first, _Host(onboarding: onboarding));
      expect(find.byType(TypedDateField), findsOneWidget);
      final field = tester.getRect(find.byType(TypedDateField));
      final months =
          tester.getRect(find.byKey(const ValueKey('date-month-11')));
      expect(field.bottom, lessThan(months.top));
      expect(
        tester.widget<TextField>(find.byType(TextField)).decoration!.hintText,
        'MM/DD/YYYY',
      );
    });

    testWidgets('$name: a typed valid date selects the month and the day',
        (tester) async {
      final log = <MonthFirstDate>[];
      await pumpDs(
        tester,
        dsCells.first,
        _Host(onboarding: onboarding, log: log),
      );
      await tester.enterText(find.byType(TextField), '12252026');
      await tester.pumpAndSettle();
      expect(log.last.year, 2026);
      expect(log.last.month, 12);
      expect(log.last.day, 25);
      expect(
        tester
            .widget<TextButton>(find.byKey(const ValueKey('date-month-12')))
            .style!
            .backgroundColor!
            .resolve({}),
        isNot(Colors.transparent),
      );
      expect(find.byKey(const ValueKey('date-day-25')), findsOneWidget);
      await _drain(tester);
    });

    testWidgets('$name: picking a day in the grid fills the typed field',
        (tester) async {
      await pumpDs(
        tester,
        dsCells.first,
        _Host(
          onboarding: onboarding,
          initial: const MonthFirstDate(year: 2026, month: 12),
        ),
      );
      await tester.ensureVisible(find.byKey(const ValueKey('date-day-18')));
      await tester.tap(find.byKey(const ValueKey('date-day-18')));
      await tester.pumpAndSettle();
      expect(_text(tester), '12/18/2026');
      await _drain(tester);
    });

    testWidgets('$name: picking a month only empties the field',
        (tester) async {
      await pumpDs(
        tester,
        dsCells.first,
        _Host(
          onboarding: onboarding,
          initial: const MonthFirstDate(year: 2026, month: 12, day: 18),
        ),
      );
      expect(_text(tester), '12/18/2026');
      await tester.tap(find.byKey(const ValueKey('date-month-11')));
      await tester.pumpAndSettle();
      expect(_text(tester), '');
      await _drain(tester);
    });

    testWidgets(
        '$name: an invalid typed date keeps the selection and errors '
        'on blur', (tester) async {
      final log = <MonthFirstDate>[];
      await pumpDs(
        tester,
        dsCells.first,
        _Host(
          onboarding: onboarding,
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
      expect(_host(tester).value.day, 18);
      await _drain(tester);
    });
  }

  testWidgets('day cells keep their full names', (tester) async {
    await pumpDs(
      tester,
      dsCells.first,
      const _Host(initial: MonthFirstDate(year: 2026, month: 11)),
    );
    final handle = tester.ensureSemantics();
    await tester.pump();
    expect(find.bySemanticsLabel('November 28, 2026'), findsOneWidget);
    handle.dispose();
  });

  dsMatrix(
    'month-first picker with the typed field fits',
    (context) => const _Host(initial: MonthFirstDate(year: 2026, month: 12)),
    check: (tester, cell) async {
      expect(find.byType(TypedDateField), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  dsMatrix(
    'onboarding month-first picker with the typed field fits',
    (context) => const _Host(
      onboarding: true,
      initial: MonthFirstDate(year: 2026, month: 12),
    ),
    check: (tester, cell) async {
      expect(find.byType(TypedDateField), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
