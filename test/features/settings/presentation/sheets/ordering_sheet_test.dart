import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/settings/domain/session_ordering.dart';
import 'package:pantas/features/settings/presentation/sheets/ordering_sheet.dart';

import '../../../../helpers/pump_app.dart';

Future<SessionOrdering?> _open(WidgetTester tester) async {
  SessionOrdering? result;
  await tester.pumpApp(
    Builder(
      builder: (context) => TextButton(
        onPressed: () async {
          result = await showOrderingSheet(
            context: context,
            current: SessionOrdering.interleavedTail,
          );
        },
        child: const Text('open'),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return result;
}

void main() {
  testWidgets('all three orderings appear with their plain labels',
      (tester) async {
    await _open(tester);

    expect(find.text('One topic only'), findsOneWidget);
    expect(find.text('Interleaved tail'), findsOneWidget);
    expect(find.text('All mixed up'), findsOneWidget);
  });

  testWidgets('the lede is the one from the spec', (tester) async {
    await _open(tester);

    expect(
      find.text(
        'Each session has one main topic. This sets how much comes from '
        'other topics.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('only the default carries the recommended badge', (tester) async {
    await _open(tester);

    expect(find.text('Recommended'), findsOneWidget);
  });

  testWidgets('tapping a row picks it and closes, with no Save button',
      (tester) async {
    SessionOrdering? result;
    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            result = await showOrderingSheet(
              context: context,
              current: SessionOrdering.interleavedTail,
            );
          },
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Save'), findsNothing);
    expect(find.text('Cancel'), findsNothing);

    await tester.tap(find.text('All mixed up'));
    await tester.pumpAndSettle();

    expect(result, SessionOrdering.fullyMixed);
    expect(find.text('All mixed up'), findsNothing);
  });

  testWidgets('no reason on the sheet contains an em dash', (tester) async {
    await _open(tester);

    for (final text in tester.widgetList<Text>(find.byType(Text))) {
      expect(text.data?.contains('—') ?? false, isFalse);
    }
  });
}
