import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/math_text.dart';
import 'package:pantas/core/ui/components/new_design/answer_reveal.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';

import '../../../helpers/accessibility.dart';
import '../../../helpers/ds_matrix.dart';

/// Explanation README, `.xpl-phone`: a 30px bare-letter key, the label
/// "Correct answer", and a 15/1.5 body in the primary text color.
void main() {
  setUpAll(loadDsFonts);

  for (final dark in [false, true]) {
    for (final width in [390.0, 320.0]) {
      testWidgets('phone explanation follows the README dark=$dark at $width',
          (tester) async {
        final colors = dark ? PantasColors.dark : PantasColors.light;
        await pumpAccessibilitySurface(
          tester,
          const AnswerReveal(
            correctLetter: 'B',
            explanation: 'Because the sum of the angles is 180 degrees.',
            pickedLetter: 'C',
            wrongPick: 'That adds the wrong angles.',
          ),
          brightness: dark ? Brightness.dark : Brightness.light,
          viewportSize: Size(width, 700),
        );
        expect(find.text('Correct answer'), findsOneWidget);
        expect(find.text('Your pick'), findsOneWidget);
        final key = find.byKey(const ValueKey('answer-reveal-key')).first;
        expect(tester.getSize(key), const Size(30, 30));
        // The boards draw a bare letter, no circle (QV_MissPro, MK_ReviewQ).
        expect(
          find.descendant(of: key, matching: find.byType(DecoratedBox)),
          findsNothing,
        );
        for (final l in ['B', 'C']) {
          final letter = tester.widget<Text>(find.text(l));
          expect(letter.style!.color, colors.textSecondary, reason: l);
          expect(letter.style!.fontWeight, FontWeight.w700, reason: l);
          expect(letter.style!.fontSize, 15, reason: l);
        }
        final body = tester.widget<MathText>(
          find.widgetWithText(
            MathText,
            'Because the sum of the angles is 180 degrees.',
          ),
        );
        expect(body.style!.fontSize, 15);
        expect(body.style!.height, 1.5);
        expect(body.style!.color, colors.textPrimary);
      });
    }
  }
}
