import 'package:pantas/core/ui/components/confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('ConfirmationDialog', () {
    Future<void> pumpDialog(
      WidgetTester tester, {
      VoidCallback? onCancel,
      VoidCallback? onConfirm,
    }) async {
      await tester.pumpApp(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showAppConfirmationDialog(
              context: context,
              title: 'Leave quiz?',
              body: 'Your progress will be lost.',
              cancelLabel: 'Keep going',
              confirmLabel: 'Leave',
              onCancel: onCancel ?? () {},
              onConfirm: onConfirm ?? () {},
            ),
            child: const Text('Open'),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
    }

    testWidgets('shows title, body, cancel and confirm labels', (tester) async {
      await pumpDialog(tester);
      expect(find.text('Leave quiz?'), findsOneWidget);
      expect(find.text('Your progress will be lost.'), findsOneWidget);
      expect(find.text('Keep going'), findsOneWidget);
      expect(find.text('Leave'), findsOneWidget);
    });

    testWidgets('cancel is to the left of confirm', (tester) async {
      await pumpDialog(tester);
      final cancelOffset = tester.getCenter(find.text('Keep going'));
      final confirmOffset = tester.getCenter(find.text('Leave'));
      expect(cancelOffset.dx, lessThan(confirmOffset.dx));
    });

    testWidgets('fires onCancel when cancel tapped', (tester) async {
      var cancelled = false;
      await pumpDialog(tester, onCancel: () => cancelled = true);
      await tester.tap(find.text('Keep going'));
      expect(cancelled, isTrue);
    });

    testWidgets('fires onConfirm when confirm tapped', (tester) async {
      var confirmed = false;
      await pumpDialog(tester, onConfirm: () => confirmed = true);
      await tester.tap(find.text('Leave'));
      expect(confirmed, isTrue);
    });
  });
}
