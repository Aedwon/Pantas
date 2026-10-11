import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/new_design/question_grid_sheet.dart';
import '../../../helpers/accessibility.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('future mock parts retain board dimming $brightness',
        (tester) async {
      await pumpAccessibilitySurface(
        tester,
        QuestionGridSheet(
          page: const Text('Page'),
          open: true,
          onDismiss: () {},
          onSelected: (_) {},
          mock: true,
          parts: const [
            QuestionGridPart(
              title: 'Future',
              enabled: false,
              questions: [
                GridQuestion(number: 8, state: GridQuestionState.unreached),
              ],
            ),
          ],
        ),
        brightness: brightness,
        disableAnimations: true,
        viewportSize: const Size(390, 844),
      );
      for (final finder in [
        find.text('Future'),
        find.byKey(const ValueKey('grid-question-0-8')),
      ]) {
        final opacity = tester.widget<Opacity>(
          find.ancestor(of: finder, matching: find.byType(Opacity)).first,
        );
        expect(opacity.opacity, .32);
      }
    });
  }
}
