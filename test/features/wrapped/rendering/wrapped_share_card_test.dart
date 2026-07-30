import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/wrapped/domain/wrapped_payload.dart';
import 'package:pantas/features/wrapped/rendering/wrapped_share_card.dart';

void main() {
  testWidgets('the share card is paper, never a gradient', (tester) async {
    // UI-013, open since 26 July. It was purple and navy over white, which is
    // pre-redesign styling and specifically a gradient, the first pattern the
    // identity lists as one it exists to remove. It is also the most public
    // thing the app makes: the one artefact a student posts, seen by people
    // who have never opened Pantas.
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

    final decorated = tester.widgetList<DecoratedBox>(
      find.descendant(
        of: find.byType(WrappedShareCard),
        matching: find.byType(DecoratedBox),
      ),
    );

    for (final box in decorated) {
      final decoration = box.decoration as BoxDecoration;
      expect(
        decoration.gradient,
        isNull,
        reason: 'the identity bans gradient decoration',
      );
    }
  });
}
