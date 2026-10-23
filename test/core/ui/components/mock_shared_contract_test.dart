import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/button_pair.dart';
import 'package:pantas/core/ui/components/centered_dialog.dart';
import 'package:pantas/core/ui/components/new_design/question_grid_sheet.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

void main() {
  for (final dark in [false, true]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('inline accent dialog actions dark=$dark scale=$scale',
          (tester) async {
        var confirmed = 0;
        var canceled = 0;
        await tester.pumpWidget(
          MaterialApp(
            theme: dark ? buildDarkTheme() : buildLightTheme(),
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: Scaffold(
                body: CenteredDialog(
                  title: 'Submit the exam?',
                  message: 'Your answers can’t be changed.',
                  primaryLabel: 'Submit',
                  secondaryLabel: 'Keep Working',
                  inlineActions: true,
                  onConfirm: () => confirmed++,
                  onCancel: () => canceled++,
                ),
              ),
            ),
          ),
        );
        final context = tester.element(find.byType(CenteredDialog));
        final submit = tester
            .widget<TextButton>(find.widgetWithText(TextButton, 'Submit'));
        expect(
          submit.style!.backgroundColor!.resolve({}),
          context.colors.accentFill,
        );
        expect(
          submit.style!.foregroundColor!.resolve({}),
          context.colors.onAccent,
        );
        expect(
          tester.widget<ButtonPair>(find.byType(ButtonPair)).stacked,
          isFalse,
        );
        await tester.tap(find.text('Submit'));
        expect(confirmed, 1);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        expect(canceled, 1);
        expect(tester.takeException(), isNull);
      });
      testWidgets('mock grid footer acts after help dark=$dark scale=$scale',
          (tester) async {
        var submitted = false;
        await tester.pumpWidget(
          MaterialApp(
            theme: dark ? buildDarkTheme() : buildLightTheme(),
            home: MediaQuery(
              data: MediaQueryData(
                textScaler: TextScaler.linear(scale),
                disableAnimations: true,
              ),
              child: Scaffold(
                body: QuestionGridSheet(
                  page: const SizedBox(),
                  open: true,
                  onDismiss: () {},
                  parts: const [],
                  onSelected: (_) {},
                  mock: true,
                  footer: PantasButton(
                    label: 'Submit the Exam',
                    onPressed: () => submitted = true,
                  ),
                ),
              ),
            ),
          ),
        );
        expect(
          tester.getTopLeft(find.text('Submit the Exam')).dy,
          greaterThan(
            tester
                .getBottomLeft(
                  find.text('You can go back to any question in this part.'),
                )
                .dy,
          ),
        );
        await tester.tap(find.text('Submit the Exam'));
        expect(submitted, isTrue);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
