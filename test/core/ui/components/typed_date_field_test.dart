import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/typed_date_field.dart';

import '../../../helpers/ds_matrix.dart';

final _first = DateTime(2026, 11, 10);

/// Holds the value the way a picker does: a valid typed date replaces it.
class _Host extends StatefulWidget {
  const _Host({this.initial, this.log});

  final DateTime? initial;
  final List<DateTime>? log;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late DateTime? value = widget.initial;
  final FocusNode other = FocusNode();

  @override
  void dispose() {
    other.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 340,
        child: Column(
          children: [
            TypedDateField(
              value: value,
              firstAllowed: _first,
              onChanged: (date) {
                widget.log?.add(date);
                setState(() => value = date);
              },
            ),
            // Something else to move focus to.
            Focus(focusNode: other, child: const SizedBox(height: 20)),
            TextButton(
              onPressed: () => setState(() => value = null),
              child: const Text('Clear value'),
            ),
            TextButton(
              onPressed: () => setState(() => value = DateTime(2027, 3, 5)),
              child: const Text('Pick March 5'),
            ),
          ],
        ),
      );
}

_HostState _host(WidgetTester tester) =>
    tester.state<_HostState>(find.byType(_Host));

TextField _input(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField));

String _text(WidgetTester tester) => _input(tester).controller!.text;

Future<void> _blur(WidgetTester tester) async {
  _host(tester).other.requestFocus();
  await tester.pump();
}

Future<void> _type(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.pump();
}

void main() {
  setUpAll(loadDsFonts);

  testWidgets('shows the MM/DD/YYYY placeholder, a numeric keyboard and help',
      (tester) async {
    await pumpDs(tester, dsCells.first, const _Host());
    final input = _input(tester);
    expect(input.decoration!.hintText, 'MM/DD/YYYY');
    expect(input.keyboardType, TextInputType.number);
    expect(_text(tester), '');
    // A help line says what is allowed.
    expect(find.textContaining('Nov 10, 2026'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('field-well'))).height,
      greaterThanOrEqualTo(48),
    );
  });

  testWidgets('typing a full valid date reports it and shows no error',
      (tester) async {
    final log = <DateTime>[];
    await pumpDs(tester, dsCells.first, _Host(log: log));
    await _type(tester, '11282026');
    expect(_text(tester), '11/28/2026');
    expect(log, [DateTime(2026, 11, 28)]);
    await _blur(tester);
    expect(find.textContaining('a later date'), findsNothing);
    expect(find.textContaining('real date'), findsNothing);
  });

  testWidgets('a partial date reports nothing and shows no error while typing',
      (tester) async {
    final log = <DateTime>[];
    await pumpDs(tester, dsCells.first, _Host(log: log));
    await _type(tester, '1128');
    expect(_text(tester), '11/28');
    expect(log, isEmpty);
    expect(find.textContaining('Type the full date'), findsNothing);
  });

  testWidgets('an invalid date shows its error on blur, not before',
      (tester) async {
    final log = <DateTime>[];
    await pumpDs(tester, dsCells.first, _Host(log: log));
    await tester.tap(find.byType(TextField));
    await tester.pump();
    await _type(tester, '13402026');
    expect(find.textContaining('real date'), findsNothing);
    await _blur(tester);
    expect(find.textContaining('real date'), findsOneWidget);
    expect(log, isEmpty);
  });

  testWidgets('a date before the first allowed day shows the early error',
      (tester) async {
    final log = <DateTime>[];
    await pumpDs(tester, dsCells.first, _Host(log: log));
    await tester.tap(find.byType(TextField));
    await _type(tester, '11092026');
    await _blur(tester);
    expect(find.text('Pick Nov 10, 2026 or a later date.'), findsOneWidget);
    expect(log, isEmpty);
  });

  testWidgets('a partial date shows the full-date error on blur',
      (tester) async {
    await pumpDs(tester, dsCells.first, const _Host());
    await tester.tap(find.byType(TextField));
    await _type(tester, '1128');
    await _blur(tester);
    expect(find.textContaining('Type the full date'), findsOneWidget);
  });

  testWidgets('empty on blur shows no error', (tester) async {
    await pumpDs(tester, dsCells.first, const _Host());
    await tester.tap(find.byType(TextField));
    await tester.pump();
    await _blur(tester);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.textContaining('Type the full date'), findsNothing);
  });

  testWidgets('typing a valid date clears the error at once', (tester) async {
    final log = <DateTime>[];
    await pumpDs(tester, dsCells.first, _Host(log: log));
    await tester.tap(find.byType(TextField));
    await _type(tester, '13402026');
    await _blur(tester);
    expect(find.textContaining('real date'), findsOneWidget);
    await tester.tap(find.byType(TextField));
    await _type(tester, '12012026');
    expect(find.textContaining('real date'), findsNothing);
    expect(log, [DateTime(2026, 12)]);
  });

  testWidgets('an invalid entry keeps the last valid selection',
      (tester) async {
    final log = <DateTime>[];
    await pumpDs(
      tester,
      dsCells.first,
      _Host(initial: DateTime(2026, 12, 25), log: log),
    );
    expect(_text(tester), '12/25/2026');
    await tester.tap(find.byType(TextField));
    await _type(tester, '02302027');
    await _blur(tester);
    expect(log, isEmpty);
    expect(_host(tester).value, DateTime(2026, 12, 25));
  });

  testWidgets('paste works: slashes, digits only and one-digit parts',
      (tester) async {
    final log = <DateTime>[];
    await pumpDs(tester, dsCells.first, _Host(log: log));
    await _type(tester, '11/28/2026');
    expect(_text(tester), '11/28/2026');
    await _type(tester, '1/5/2027');
    expect(_text(tester), '01/05/2027');
    await _type(tester, '12312026');
    expect(_text(tester), '12/31/2026');
    expect(log, [
      DateTime(2026, 11, 28),
      DateTime(2027, 1, 5),
      DateTime(2026, 12, 31),
    ]);
  });

  testWidgets('a pick in the picker fills the field and clears an error',
      (tester) async {
    await pumpDs(tester, dsCells.first, const _Host());
    await tester.tap(find.byType(TextField));
    await _type(tester, '13402026');
    await _blur(tester);
    expect(find.textContaining('real date'), findsOneWidget);
    await tester.tap(find.text('Pick March 5'));
    await tester.pump();
    expect(_text(tester), '03/05/2027');
    expect(find.textContaining('real date'), findsNothing);
  });

  testWidgets('clearing the value in the picker empties the field',
      (tester) async {
    await pumpDs(
      tester,
      dsCells.first,
      _Host(initial: DateTime(2026, 12, 25)),
    );
    expect(_text(tester), '12/25/2026');
    await tester.tap(find.text('Clear value'));
    await tester.pump();
    expect(_text(tester), '');
  });

  testWidgets('the field exposes the invalid state to a screen reader',
      (tester) async {
    final handle = tester.ensureSemantics();
    await pumpDs(tester, dsCells.first, const _Host());
    await tester.tap(find.byType(TextField));
    await _type(tester, '13402026');
    await _blur(tester);
    await tester.pump();
    expect(find.bySemanticsLabel(RegExp('real date')), findsWidgets);
    handle.dispose();
  });

  dsMatrix(
    'typed date field fits with an error showing',
    (context) => const _Host(),
    check: (tester, cell) async {
      await tester.tap(find.byType(TextField));
      await tester.enterText(find.byType(TextField), '13402026');
      await tester.pump();
      _host(tester).other.requestFocus();
      await tester.pumpAndSettle();
      expect(find.textContaining('real date'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  test('keeps the mask formatter and the validator the same one', () {
    expect(TypedDateField.formatters, isNotEmpty);
    final formatter = TypedDateField.formatters.first;
    final out = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(text: '1128'),
    );
    expect(out.text, '11/28');
  });
}
