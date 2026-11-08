import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/features/wrapped/domain/wrapped_payload.dart';
import 'package:pantas/features/wrapped/rendering/wrapped_share_card.dart';

void main() {
  testWidgets('the share card uses the design system share gradient',
      (tester) async {
    // Design system 4.0 (`.card--share`): `hero-start` to `share-end`. The
    // card is drawn in the light palette whatever the reader's theme is.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WrappedShareCard(
            payload: WrappedPayload(
              title: 'Your year in review',
              archetypeId: 'night_owl_sprinter',
              slides: [],
              shareId: 'share_1',
            ),
            includeArchetype: false,
          ),
        ),
      ),
    );

    final gradients = tester
        .widgetList<DecoratedBox>(
          find.descendant(
            of: find.byType(WrappedShareCard),
            matching: find.byType(DecoratedBox),
          ),
        )
        .map((box) => (box.decoration as BoxDecoration).gradient)
        .whereType<LinearGradient>();

    expect(gradients, hasLength(1));
    expect(gradients.single.colors, [
      PantasColors.light.heroStart,
      PantasColors.light.shareEnd,
    ]);
  });
}
