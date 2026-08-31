import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/settings/presentation/sheets/name_sheet.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('the field is a hairline rule, not a filled Material box',
      (tester) async {
    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () => showNameSheet(context: context, current: 'Aedwon'),
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.decoration!.filled ?? false, isFalse);
    expect(field.decoration!.border, isA<UnderlineInputBorder>());
  });

  testWidgets('clearing the field and saving clears the name', (tester) async {
    String? result;
    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            result = await showNameSheet(context: context, current: 'Aedwon');
          },
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(result, '');
  });

  testWidgets('the field has a programmatic Name label', (tester) async {
    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () => showNameSheet(context: context, current: null),
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel(RegExp('^Name')), findsOneWidget);
  });
}
