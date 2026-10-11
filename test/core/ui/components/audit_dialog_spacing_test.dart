import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/button_pair.dart';
import 'package:pantas/core/ui/components/centered_dialog.dart';
import '../../../helpers/accessibility.dart';

void main() {
  for (final brightness in Brightness.values) {
    for (final destructive in [false, true]) {
      testWidgets('dialog board spacing $brightness destructive=$destructive',
          (tester) async {
        final dialog = CenteredDialog(
          title: 'Leave?',
          message: 'Answers are saved.',
          primaryLabel: 'Confirm',
          secondaryLabel: 'Cancel',
          onConfirm: () {},
          onCancel: () {},
          destructive: destructive,
        );
        await pumpAccessibilitySurface(
          tester,
          dialog,
          brightness: brightness,
          viewportSize: const Size(390, 844),
        );
        final rect = tester
            .getRect(find.byKey(const ValueKey('centered-dialog-surface')));
        expect(rect.left, 28);
        expect(rect.right, 362);
        final pair = find.byType(ButtonPair);
        expect(
          tester.getTopLeft(pair).dy -
              tester.getBottomLeft(find.text('Answers are saved.')).dy,
          destructive ? 20 : 18,
        );
        final buttons =
            find.descendant(of: pair, matching: find.byType(TextButton));
        if (destructive) {
          expect(
            tester.getRect(buttons.at(1)).left -
                tester.getRect(buttons.first).right,
            8,
          );
        } else {
          expect(
            tester.getRect(buttons.at(1)).top -
                tester.getRect(buttons.first).bottom,
            8,
          );
        }
        await expectSurvivesTextScale(
          tester,
          dialog,
          brightness: brightness,
          viewportSize: const Size(390, 844),
          disableAnimations: true,
        );
      });
    }
  }
}
