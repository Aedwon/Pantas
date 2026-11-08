import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/button_pair.dart';
import 'package:pantas/core/ui/components/centered_dialog.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';

import '../../../helpers/accessibility.dart';

void main() {
  for (final brightness in Brightness.values) {
    for (final destructive in [false, true]) {
      testWidgets('phone dialog spacing $brightness destructive=$destructive',
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
        // `dialog--phone`: inset 24 on each side.
        final rect = tester
            .getRect(find.byKey(const ValueKey('centered-dialog-surface')));
        expect(rect.left, 24);
        expect(rect.right, 366);
        final pair = find.byType(ButtonPair);
        // 12 above the pair (`.dialog--phone .dialog__actions`).
        expect(
          tester.getTopLeft(pair).dy -
              tester.getBottomLeft(find.text('Answers are saved.')).dy,
          12,
        );
        // Two pills side by side, 10 apart.
        final buttons = find.descendant(
          of: pair,
          matching: find.byType(PantasButton),
        );
        // The pill is 46 high; Material pads its tap target to 48.
        expect(
          tester.getSize(buttons.first).height,
          inInclusiveRange(PantasSize.btnBar, 48),
        );
        expect(
          tester.getRect(buttons.at(1)).left -
              tester.getRect(buttons.first).right,
          10,
        );
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
