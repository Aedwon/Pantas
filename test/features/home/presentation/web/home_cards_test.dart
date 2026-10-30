import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/features/home/presentation/widgets/home_web_layout.dart';

void main() {
  for (final dark in [false, true]) {
    testWidgets('Home links have separate card surfaces, dark=$dark',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
          home: Scaffold(
            body: HomeWebLayout(
              header: const Text('Home'),
              today: const Text('Today'),
              onRecord: () {},
              onTendencies: () {},
            ),
          ),
        ),
      );
      final cards = <Element>[];
      for (final title in ['Your record', 'Your tendencies']) {
        final card =
            find.ancestor(of: find.text(title), matching: find.byType(WebCard));
        expect(card, findsOneWidget);
        cards.add(card.evaluate().single);
        final container = tester.widget<Container>(
          find
              .descendant(
                of: card,
                matching: find.byType(Container),
              )
              .first,
        );
        expect(
          (container.decoration! as BoxDecoration).color,
          dark ? const Color(0xFF1F1F1F) : Colors.white,
        );
      }
      expect(identical(cards[0], cards[1]), isFalse);
      expect(tester.takeException(), isNull);
    });
  }
}
