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
      // Home (Main) board: white 16 px cards.
      final rows = <Element>[];
      for (final title in ['Your record', 'Your tendencies']) {
        final card = find.ancestor(
          of: find.text(title),
          matching: find.byType(WebCard),
        );
        expect(card, findsOneWidget);
        rows.add(card.evaluate().single);
        final row =
            find.descendant(of: card, matching: find.byType(TextButton));
        expect(row, findsOneWidget);
        final surface = tester
            .widgetList<Container>(
              find.descendant(of: card, matching: find.byType(Container)),
            )
            .map((c) => c.decoration)
            .whereType<BoxDecoration>()
            .map((d) => d.color)
            .whereType<Color>()
            .first;
        expect(surface, dark ? const Color(0xFF1F1F1F) : Colors.white);
        final button = tester.widget<TextButton>(row);
        expect(
          button.style!.backgroundColor!.resolve({WidgetState.hovered}),
          dark ? const Color(0xFF2A2A2A) : const Color(0xFFF7F7F9),
        );
      }
      expect(identical(rows[0], rows[1]), isFalse);
      // Board HM_Advanced: a 24 px line icon drawn for the row, 20 px in from
      // the card's left edge (U80).
      for (final title in ['Your record', 'Your tendencies']) {
        final card = find.ancestor(
          of: find.text(title),
          matching: find.byType(WebCard),
        );
        final icon = find.descendant(
          of: card,
          matching: find.byWidgetPredicate(
            (w) => w is CustomPaint && w.size == const Size.square(24),
          ),
        );
        expect(icon, findsOneWidget);
        expect(
          tester.getTopLeft(icon).dx - tester.getTopLeft(card).dx,
          closeTo(20, 1),
        );
        expect(
          find.descendant(of: card, matching: find.byIcon(Icons.show_chart)),
          findsNothing,
        );
      }
      expect(tester.takeException(), isNull);
    });
  }
}
