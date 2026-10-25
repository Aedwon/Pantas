import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/features/settings/presentation/carry_over_prompt.dart';
import '../../../helpers/pump_app.dart';

void main() {
  testWidgets(
      'issue 26: carry over opens once as a screen and stays '
      'closed after returning', (tester) async {
    bool? result;
    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            result = await showCarryOverPrompt(
              context: context,
              examShortName: 'CSE Professional',
              carryableCount: 3,
            );
          },
          child: const Text('Switch'),
        ),
      ),
    );
    await tester.tap(find.text('Switch'));
    await tester.pumpAndSettle();
    expect(find.text('Count Them'), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byType(PantasButton), findsWidgets);
    await tester.ensureVisible(find.text('Start My Numbers Fresh'));
    await tester.tap(find.text('Start My Numbers Fresh'));
    await tester.pumpAndSettle();
    expect(result, isFalse);
    expect(find.text("You're not starting from zero"), findsNothing);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text("You're not starting from zero"), findsNothing);
  });
}
